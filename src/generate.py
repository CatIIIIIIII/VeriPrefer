import argparse
import torch
import json
import os
from typing import List, Dict
from dataclasses import dataclass
from vllm import LLM, SamplingParams
from transformers import AutoTokenizer, AutoModelForCausalLM
from peft import PeftModel  # Import PeftModel from peft, not transformers


@dataclass
class ModelConfig:
    tensor_parallel_size: int = 4
    gpu_memory_utilization: float = 0.95
    # max_num_batched_tokens: int = 4096
    max_num_seqs: int = 32
    # max_seq_len: int = 4096
    dtype: str = 'bfloat16'
    trust_remote_code: bool = True
    enforce_eager: bool = True


def set_seed(seed: int):
    """Set random seed for reproducibility"""
    if seed is not None:
        torch.manual_seed(seed)
        torch.cuda.manual_seed_all(seed)


@dataclass
class GenerationConfig:
    num_generations: int = 20
    max_length: int = 4096
    temperature: float = 0.2
    top_p: float = 0.95
    top_k: int = 50
    batch_size: int = 32
    is_postprocess: bool = False


def load_tasks(file_path: str) -> List[Dict]:
    """Load tasks from JSON file"""
    with open(file_path, 'r') as f:
        return json.load(f)


def save_results(results: List[Dict], file_path: str):
    """Save results to JSON file"""
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    with open(file_path, 'w') as f:
        json.dump(results, f, indent=4)


def merge_lora_with_base_model(base_model_path: str, adapter_path: str) -> str:
    """Merge LoRA adapter with base model and return the path to the merged model"""
    print(f"Merging LoRA adapter from {adapter_path} with base model {base_model_path}")

    # Create a directory for the merged model
    merged_model_path = os.path.join(os.path.dirname(adapter_path), "merged_model")
    os.makedirs(merged_model_path, exist_ok=True)

    # Load the base model
    base_model = AutoModelForCausalLM.from_pretrained(
        base_model_path,
        torch_dtype=torch.bfloat16,
        device_map="auto",
        trust_remote_code=True
    )

    # Load the PEFT model
    model = PeftModel.from_pretrained(base_model, adapter_path)

    # Merge the LoRA weights with the base model
    merged_model = model.merge_and_unload()

    # Save the merged model
    merged_model.save_pretrained(merged_model_path)

    # Also save the tokenizer
    tokenizer = AutoTokenizer.from_pretrained(base_model_path)
    tokenizer.save_pretrained(merged_model_path)

    print(f"Merged model saved to {merged_model_path}")
    return merged_model_path


class Generator:
    def __init__(self, model_path: str, model_config: ModelConfig, task: str):
        self.model_path = model_path
        self.model_config = model_config
        self.task_name = task
        self.llm = None
        self.tokenizer = AutoTokenizer.from_pretrained(model_path)
        # self.tokenizer.model_max_length = self.model_config.max_seq_len
        self.initialize_model()

    def initialize_model(self):
        """Initialize the vLLM model with proper GPU parallelization"""

        # Get available GPU count and set up tensor parallel size
        gpu_count = torch.cuda.device_count()
        if gpu_count < 1:
            raise RuntimeError("No GPUs available")

        # Set CUDA_VISIBLE_DEVICES if not already set
        if "CUDA_VISIBLE_DEVICES" not in os.environ:
            gpu_ids = ",".join(str(i) for i in range(gpu_count))
            os.environ["CUDA_VISIBLE_DEVICES"] = gpu_ids

        # Initialize CUDA context on all GPUs
        torch.cuda.init()
        for i in range(gpu_count):
            with torch.cuda.device(i):
                torch.cuda.set_device(i)
                torch.tensor([1.0], device=f"cuda:{i}")

        # Update tensor parallel size based on available GPUs
        self.model_config.tensor_parallel_size = min(self.model_config.tensor_parallel_size, gpu_count)
        print(f"Initializing model with tensor parallel size: {self.model_config.tensor_parallel_size}")
        # print(f"Using max_seq_len: {self.model_config.max_seq_len}")

        self.llm = LLM(
            model=self.model_path,
            tensor_parallel_size=self.model_config.tensor_parallel_size,
            gpu_memory_utilization=self.model_config.gpu_memory_utilization,
            # max_num_batched_tokens=self.model_config.max_num_batched_tokens,
            max_num_seqs=self.model_config.max_num_seqs,
            dtype=self.model_config.dtype,
            trust_remote_code=self.model_config.trust_remote_code,
            enforce_eager=self.model_config.enforce_eager,
            device="cuda",
            max_model_len=4096
        )

    def format_chat(self, prompt: str) -> str:
        """Format the prompt using the model's chat template"""
        if not hasattr(self.tokenizer, 'chat_template'):
            # If no chat template, return prompt as is
            return prompt

        # For single-turn dialogue, create a simple messages list
        messages = [{"role": "user", "content": prompt}]

        # Apply the chat template using the tokenizer's apply_chat_template method
        formatted_prompt = self.tokenizer.apply_chat_template(
            messages,
            tokenize=False,
            add_generation_prompt=True
        )
        return formatted_prompt

    def generate(self, tasks: List[Dict], gen_config: GenerationConfig, save_path: str) -> List[Dict]:
        """Generate responses for all tasks"""
        sampling_params = SamplingParams(
            n=gen_config.num_generations,
            temperature=gen_config.temperature,
            top_p=gen_config.top_p,
            max_tokens=gen_config.max_length,
        )

        results = []
        total_tasks = len(tasks)
        # with tqdm(total=total_tasks, desc="Processing tasks", ncols=100) as pbar:
        for i in range(0, total_tasks, gen_config.batch_size):
            batch = tasks[i:i + gen_config.batch_size]
            # Apply chat template to each prompt using the tokenizer
            prompts = [self.format_chat(task['spec']) for task in batch]

            print(f"\nProcessing batch {i//gen_config.batch_size + 1}/{(total_tasks-1)//gen_config.batch_size + 1}")
            outputs = self.llm.generate(prompts, sampling_params, use_tqdm=True)

            for task_idx, output in enumerate(outputs):
                task = batch[task_idx]

                # output
                prompt = task['spec']
                gens = [gen.text for gen in output.outputs]
                if gen_config.is_postprocess:
                    gens = [self.postprocess_generation(prompt, gen) for gen in gens]
                if "output" in task:
                    task.pop("output")
                if "input" in task:
                    task.pop("input")
                task['generated_responses'] = gens
                results.append(task)

            # Save intermediate results after processing each batch
            save_results(results, save_path)

        return results

    def postprocess_generation(self, prompt: str, gen: int) -> str:
        """Postprocess the generated response"""
        def _extract_module_name(content):
            """Extract the module name from Verilog code using regex"""
            import re  # Import re inside the function to avoid global import
            pattern = r'module\s+(\w+)(?:\s*#?\s*\(|\s+)'
            match = re.search(pattern, content)
            if match:
                return match.group(1)
            else:
                return None  # Return None if no module name is found
        if "CodeV" in self.model_path:
            ret = gen
        elif "codellama" in self.model_path.lower() and "outputs" not in self.model_path:
            if "```scss" in gen:
                gen = gen.split("```scss")[1]
            if "```vhdl" in gen:
                gen = gen.split("```vhdl")[1]
            if "```" in gen:
                gen = gen.split('```')[0]
            ret = gen
        elif "Haven" in self.model_path:
            module_header = prompt.split("\n\nGive me the complete code.\n\n")[1]
            module_name = _extract_module_name(module_header)
            if module_name not in gen:
                gen = f"{module_header}\n{gen}"
            ret = gen
        elif "RTLCoder" in self.model_path:
            if len(gen.split('endmodulemodule', 1)) == 2:
                s = gen.split('endmodulemodule', 1)[0] + "\n" + "endmodule"
            else:
                s = gen.rsplit('endmodule', 1)[0] + "\n" + "endmodule"
            if s.find('top_module') != -1:
                s = s.split('top_module', 1)[0]
                s = s.rsplit('endmodule', 1)[0] + "\n" + "endmodule"
            index = s.rfind('tb_module')
            if index == -1:
                index = s.find('testbench')
            if index != -1:
                s_tmp = s[:index]
                s = s_tmp.rsplit("endmodule", 1)[0] + "\n" + "endmodule"
            if "```verilog" in s:
                s = s.split("```verilog")[1]
            if "```" in s:
                s = s.split("```")[1]
            header = prompt.split("\n\nGive me the complete code.\n\n")[1]

            if _extract_module_name(s) is None:
                s = f"{header}\n{s}"
            ret = s
        elif "V2-Lite" in self.model_path:
            gen = gen.split("```verilog")[1]
            gen = gen.split('```')[0]
            ret = gen
        elif "OriGen" in self.model_path:
            ret = gen
        elif "Qwen2.5" in self.model_path and "outputs" not in self.model_path:
            if "```verilog" in gen:
                gen = gen.split("```verilog")[1]
            if "```" in gen:
                gen = gen.split('```')[0]
            header = prompt.split("\n\nGive me the complete code.\n\n")[1]
            if _extract_module_name(gen) is None:
                gen = f"{header}\n{gen}"
            ret = gen
        elif "Mistral" in self.model_path and "outputs" not in self.model_path:
            ret = gen
        else:
            header = prompt.split("\n\nGive me the complete code.\n\n")[1]
            try:
                gen = gen.split("```verilog\n")[1]
                gen = gen.split('```')[0]

                # Split into lines and filter out timescale lines
                lines = gen.split('\n')
                filtered_lines = [line for line in lines if '`timescale' not in line]
                gen = '\n'.join(filtered_lines)
                # ret = gen
                ret = f"{header}\n{gen}"
            except IndexError:
                ret = ''
        if "verilogmachine" in self.task_name or "veriloghuman" in self.task_name:
            module_name = _extract_module_name(ret)
            if module_name is not None:
                ret = ret.replace(f"module {module_name}", "module top_module")
        # if "verilogeval" in self.task_name:
        #     module_name = _extract_module_name(ret)
        #     if module_name is not None:
        #         ret = ret.replace(f"module {module_name}", "module TopModule")
        if "```verilog" in ret:
            ret = ret.split("```verilog")[1]
        if "```" in ret:
            ret = ret.split('```')[0]
        return ret


def parse_args():
    parser = argparse.ArgumentParser(description='Generate multiple responses using vLLM')
    parser.add_argument('--model', type=str, required=True, help='Path to the model')
    parser.add_argument('--adapter_path', type=str, default=None, help='Path to the LoRA adapter')
    parser.add_argument('--task', type=str, required=True, help='Path to the task JSON file')
    parser.add_argument('--save', type=str, required=True, help='Path to save the results')
    parser.add_argument('--max_length', type=int, default=4096, help='Maximum length of generated text')
    # parser.add_argument('--max_seq_len', type=int, default=4096, help='Maximum sequence length for the model')
    parser.add_argument('--temperature', type=float, default=0.8, help='Sampling temperature')
    parser.add_argument('--top_p', type=float, default=0.95, help='Top-p sampling parameter')
    parser.add_argument('--num_generations', type=int, default=20, help='Number of generations per prompt')
    parser.add_argument('--batch_size', type=int, default=8, help='Batch size for generation')
    parser.add_argument('--gpu_memory_utilization', type=float, default=0.95, help='GPU memory utilization (0-1)')
    parser.add_argument('--is_postprocess', action='store_true', help='Whether to postprocess the generations')
    parser.add_argument('--seed', type=int, default=None, help='Random seed for reproducibility')
    return parser.parse_args()


def main():
    args = parse_args()

    set_seed(args.seed)
    # Ensure CUDA is available
    if not torch.cuda.is_available():
        raise RuntimeError("CUDA is not available")

    print(f"Available GPUs: {torch.cuda.device_count()}")

    # Check if adapter path is provided and merge with base model if needed
    model_path = args.model
    if args.adapter_path:
        print(f"LoRA adapter path provided: {args.adapter_path}")
        model_path = merge_lora_with_base_model(args.model, args.adapter_path)
        print(f"Using merged model from: {model_path}")

    # Initialize configurations
    model_config = ModelConfig(
        gpu_memory_utilization=args.gpu_memory_utilization,
        tensor_parallel_size=min(8, torch.cuda.device_count()),  # Automatically adjust based on available GPUs
        # max_seq_len=args.max_seq_len  # Set max_seq_len from command line arguments
    )

    gen_config = GenerationConfig(
        num_generations=args.num_generations,
        max_length=args.max_length,
        temperature=args.temperature,
        top_p=args.top_p,
        batch_size=args.batch_size,
        is_postprocess=args.is_postprocess
    )

    # Load tasks
    tasks = load_tasks(args.task)
    print(f"Loaded {len(tasks)} tasks")
    print(f"Will generate {args.num_generations} responses per task")

    # Initialize generator
    generator = Generator(model_path, model_config, args.task)

    # Generate responses
    results = generator.generate(tasks, gen_config, args.save)

    # Save results
    save_results(results, args.save)
    print(f"\nGeneration completed. Results saved to {args.save}")


if __name__ == "__main__":
    main()
