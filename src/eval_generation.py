import os
import time
import tqdm
from scipy.special import comb
from threading import Thread
from typing import Dict
import json
from multiprocessing import Pool
import multiprocessing


class VerilogEvaluator:
    def __init__(self, base_path: str, batch_size: int = 4):
        self.base_path = os.path.abspath(base_path)
        self.result_dic = {}
        self.batch_size = min(batch_size, multiprocessing.cpu_count())

        if not os.path.exists(self.base_path):
            raise FileNotFoundError(f"Base path does not exist: {self.base_path}")

        print(f"Using base path: {self.base_path}")
        print(f"Using batch size: {self.batch_size}")

    @staticmethod
    def exec_shell(cmd_str: str, timeout: int = 8) -> int:
        """Execute shell command with timeout"""
        def run_shell_func(sh):
            os.system(sh)

        start_time = time.time()
        t = Thread(target=run_shell_func, args=(cmd_str,), daemon=False)
        t.start()

        while True:
            now = time.time()
            if now - start_time >= timeout:
                return 0 if t.is_alive() else 1
            if not t.is_alive():
                return 1
            time.sleep(1)

    def evaluate_design(self, design_data: Dict) -> Dict:
        """Evaluate a single design"""
        design_name = design_data['name']
        design_dir = f"{self.base_path}/{design_name}"
        result = {design_name: {'syntax_success': 0, 'func_success': 0}}

        if not os.path.exists(design_dir):
            print(f"Warning: Directory for {design_name} not found at {design_dir}")
            return result

        original_dir = os.getcwd()

        try:
            # Create progress bar for responses
            responses = design_data['generated_responses']
            pbar = tqdm.tqdm(
                total=len(responses),
                desc=f"Evaluating {design_name}",
                leave=False
            )

            # Evaluate each generated response sequentially
            for response in responses:
                try:
                    # Write the generated code to the design file
                    design_file = f"{design_dir}/{design_name}.v"
                    with open(design_file, 'w') as f:
                        f.write(response)

                    # Change to design directory
                    os.chdir(design_dir)

                    # Clean previous compilation results
                    os.system("make clean > /dev/null 2>&1")

                    # Modified syntax check - more lenient approach
                    # Run vlog and check both return code and log content
                    if self.exec_shell("make modelsim > syntax_check.log 2>/dev/null") == 1:
                        with open("syntax_check.log", "r") as f:
                            log_content = f.read()
                            # Consider it a syntax success if either:
                            # 1. vlog returns 0 (success)
                            # 2. No fatal/error messages in log (allowing warnings)
                            if "Errors: 0, Warnings: 0" in log_content:
                                result[design_name]['syntax_success'] += 1

                    # Run functional test regardless of syntax check result
                    if self.exec_shell("make sim > output.txt 2>/dev/null") == 1:
                        with open("output.txt", "r") as f:
                            if "Your Design Passed" in f.read():
                                result[design_name]['func_success'] += 1

                    # Cleanup - redirect output to /dev/null
                    os.system("make clean > /dev/null 2>&1")
                    os.chdir(original_dir)

                except Exception as e:
                    print(f"Error evaluating {design_name} response: {str(e)}")
                    os.chdir(original_dir)
                finally:
                    pbar.update(1)

            pbar.close()

        except Exception as e:
            print(f"Error processing design {design_name}: {str(e)}")
            os.chdir(original_dir)

        return result

    def evaluate_from_json(self, json_file: str) -> Dict:
        """Evaluate all designs from JSON file with parallel processing"""
        with open(json_file, 'r') as f:
            designs = json.load(f)

        print(f"Evaluating {len(designs)} designs with batch size {self.batch_size}")
        # Process designs in parallel with task-level progress bar
        task_pbar = tqdm.tqdm(
            total=len(designs),
            desc="Total progress",
            position=0,
            leave=True
        )

        # Process designs in parallel
        with Pool(processes=self.batch_size) as pool:
            results = []
            for result in pool.imap_unordered(self.evaluate_design, designs):
                results.append(result)
                task_pbar.update(1)

        task_pbar.close()

        # Merge results
        for result in results:
            self.result_dic.update(result)

        return self.result_dic

    def calculate_pass_at_k(self, n: int, k_str: str):
        """
        Calculate pass@k metrics for multiple k values, both per-task and overall
        Args:
            n: number of samples per task
            k_str: comma-separated string of k values, e.g. "1,5"
        """
        try:
            k_values = [int(k) for k in k_str.split(',')]
        except ValueError:
            raise ValueError(f"Invalid k values: {k_str}. Please provide comma-separated integers.")
        if any(k > n for k in k_values):
            raise ValueError(f"Some k values are larger than n={n}")

        results = {
            'overall': {},
            'per_task': {}
        }
        for k in k_values:
            # Per-task pass@k
            task_results = {}
            syntax_sum = []
            func_sum = []
            for design in self.result_dic:
                # Calculate syntax pass@k for this task
                c_syntax = self.result_dic[design]['syntax_success']
                syntax_passk = 1 - comb(n - c_syntax, k) / comb(n, k)
                syntax_sum.append(syntax_passk)

                # Calculate functional pass@k for this task
                c_func = self.result_dic[design]['func_success']
                func_passk = 1 - comb(n - c_func, k) / comb(n, k)
                func_sum.append(func_passk)

                # Store per-task results
                task_results[design] = {
                    'syntax': float(syntax_passk),
                    'functional': float(func_passk)
                }

            # Calculate overall pass@k
            overall_syntax = float(sum(syntax_sum) / len(syntax_sum))
            overall_func = float(sum(func_sum) / len(func_sum))

            # Store results
            results['overall'][k] = {
                'syntax': overall_syntax,
                'functional': overall_func
            }
            results['per_task'][k] = task_results

            # Print overall results
            print(f'pass@{k:<2}: syntax={overall_syntax:.4f}, functional={overall_func:.4f}')

        return results

    def save_results(self, output_path: str, pass_at_k_results: dict):
        """Save evaluation results to JSON file"""
        os.makedirs(os.path.dirname(output_path), exist_ok=True)

        output_data = {
            'results': self.result_dic,
            'pass_at_k': pass_at_k_results
        }

        print(f"Results will be stored in {output_path}")
        with open(output_path, 'w') as f:
            json.dump(output_data, f, indent=2)


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description='Evaluate Verilog designs in parallel')
    parser.add_argument('--batch_size', type=int, default=32, help='Number of parallel processes (default: 4)')
    parser.add_argument('--base_path', type=str, default="./benchmark/rtllm2", help='Base path for benchmark directory')
    parser.add_argument('--gen_name', type=str, default="claude_37", help='Output directory for results')
    parser.add_argument('--input_json', type=str, default="./gens/rtllm2/gen.json", help='Input JSON file path')
    parser.add_argument('--output_json', type=str, default="./results/rtllm2/dfg_0.7.json", help='Output JSON file path')
    parser.add_argument('--n_samples', type=int, default=20, help='Number of samples per task')
    parser.add_argument('--k_values', type=str, default="1,5", help='Comma-separated k values for pass@k calculation')

    args = parser.parse_args()
    args.input_json = f"{args.input_json}/{args.gen_name}.json"
    args.output_json = f"{args.output_json}/{args.gen_name}.json"

    evaluator = VerilogEvaluator(base_path=args.base_path, batch_size=args.batch_size)

    # Run evaluation from JSON file
    results = evaluator.evaluate_from_json(args.input_json)

    # Calculate pass@k metrics
    pass_at_k_results = evaluator.calculate_pass_at_k(n=args.n_samples, k_str=args.k_values)

    # Save results
    evaluator.save_results(args.output_json, pass_at_k_results)
