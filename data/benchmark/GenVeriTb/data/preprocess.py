import re
import json


def extract_header(output):
    try:
        # 尝试使用原始的分割方法
        parts = inst.split("\n\nGive me the complete code.\n\n")
        if len(parts) > 1:
            header = parts[1].strip()
            return header
    except IndexError:
        pass
    
    # 如果原始方法失败，使用正则表达式提取模块头部
    # 修改正则表达式以匹配带有参数化的模块定义，并处理多行参数
    pattern = r'module\s+[\w_]+\s*(?:#\s*\([^)]*\))?\s*\([^;]*\);|module\s+[\w_]+\s*(?:#\s*\([^)]*\))?\s*\([^)]*\)'
    match = re.search(pattern, output, re.DOTALL)
    if match:
        return inst, match.group(0)
    else:
        # 如果正则表达式也无法匹配，则回退到提取模块名称
        # 尝试更宽松的模式匹配
        loose_pattern = r'module\s+[\w_]+\s*(?:#\s*\([^)]*\))?\s*\('
        loose_match = re.search(loose_pattern, output, re.DOTALL)
        if loose_match:
            # 找到模块声明的开始，尝试提取整个声明
            start = loose_match.start()
            # 寻找匹配的闭合括号
            open_count = 1
            end = start + loose_match.end() - loose_match.start()
            
            while end < len(output) and open_count > 0:
                if output[end] == '(':
                    open_count += 1
                elif output[end] == ')':
                    open_count -= 1
                end += 1
            
            if open_count == 0:
                # 找到了匹配的闭合括号
                header = output[start:end]
                return header
        
def extract_module_name(content):
    # 修改正则表达式以匹配带有参数化的模块名
    pattern = r'module\s+([\w_]+)\s*(?:#\s*\(|#|$|\(|\s+)'
    match = re.search(pattern, content)
    if match:
        return match.group(1)
    else:
        print(f"Could not extract module name from: {content[:100]}...")
        return None


file_path = 'data/filtered_sft.json'
with open(file_path, 'r') as file:
    dataset = json.load(file)
print(dataset[0])
print("===========================")

new_dataset = []
for i, data in enumerate(dataset):
    inst = data['instruction']
    inst = inst.split("Give me the complete code.")[0].strip().strip("\n")

    header = extract_header(data['output'])
    output = data['output'].replace("```verilog", "").replace("```", "").strip()
    new_dataset.append({
        "id": i,
        "instruction": inst,
        'output': output,
        'dut_header': header,
    })


with open('data/rlvr_sft.json', 'w') as file:
    json.dump(new_dataset, file, indent=4)

print(new_dataset[0])
