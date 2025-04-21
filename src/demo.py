import torch
import re
from transformers import AutoTokenizer, AutoModelForCausalLM

model_path = "./outputs/Qwen2.5-Coder-7B/TB/merged"
max_new_tokens = 2048
temperature = 0.5
top_p = 0.95

verilog_prompt = """
Please act as a professional verilog designer.

Implement a module to achieve serial input data accumulation output, input is 8bit data. The valid_in will be set to 1 before the first data comes in. Whenever the module receives 4 input data, the data_out outputs 4 received data accumulation results and sets the valid_out to be 1 (will last only 1 cycle).

Module name:  
    accu               
Input ports:
	clk: Clock input for synchronization.
	rst_n: Active-low reset signal.
	data_in[7:0]: 8-bit input data for addition.
	valid_in: Input signal indicating readiness for new data.   
Output ports:
    valid_out: Output signal indicating when 4 input data accumulation is reached.
	data_out[9:0]: 10-bit output data representing the accumulated sum.

Implementation:
When valid_in is 1, data_in is a valid input. Accumulate four valid input data_in values and calculate the output data_out by adding these four values together. 
There is no output when there are fewer than four data_in inputs in the interim. Along with the output data_out, a cycle of valid_out=1 will appear as a signal. 
The valid_out signal is set to 1 when the data_out outputs 4 received data accumulation results. Otherwise, it is set to 0.

Give me the complete code.

module accu(
    input               clk         ,   
    input               rst_n       ,
    input       [7:0]   data_in     ,
    input               valid_in     ,
    output  reg         valid_out     ,
    output  reg [9:0]   data_out
);
"""

print(f"Loading model from {model_path}")
tokenizer = AutoTokenizer.from_pretrained(model_path, trust_remote_code=True)
model = AutoModelForCausalLM.from_pretrained(
    model_path,
    torch_dtype=torch.bfloat16,
    device_map="auto",
    trust_remote_code=True
)

if hasattr(tokenizer, 'chat_template'):
    messages = [{"role": "user", "content": verilog_prompt}]
    formatted_prompt = tokenizer.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
else:
    formatted_prompt = verilog_prompt

input_ids = tokenizer(formatted_prompt, return_tensors="pt").input_ids.to(model.device)

with torch.no_grad():
    output_ids = model.generate(
        input_ids,
        max_new_tokens=max_new_tokens,
        do_sample=temperature > 0,
        temperature=temperature,
        top_p=top_p,
        pad_token_id=tokenizer.eos_token_id
    )
full_output = tokenizer.decode(output_ids[0], skip_special_tokens=True)

prompt_text = tokenizer.decode(input_ids[0], skip_special_tokens=True)
generated_text = full_output[len(prompt_text):]
if "```verilog" in generated_text:
    generated_text = generated_text.split("```verilog")[1]
if "```" in generated_text:
    generated_text = generated_text.split('```')[0]

header = verilog_prompt.split("\n\nGive me the complete code.\n\n")[1]
generated_text = f"{header}\n{generated_text}"

print("\nGenerated Verilog Code:")
print(generated_text.strip())