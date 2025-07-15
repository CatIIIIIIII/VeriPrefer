import os
import re
import json
import time
import boto3
import logging
import argparse
import os.path as osp
import subprocess
from typing_extensions import TypedDict
from botocore.config import Config

from langchain_core.messages import HumanMessage
from langchain_openai import ChatOpenAI
from langgraph.graph import StateGraph, START, END


# Set up logger
def setup_logger(log_file='verilog_tb_gen.log'):
    logger = logging.getLogger('verilog_tb_gen')
    logger.setLevel(logging.INFO)

    # Create file handler
    file_handler = logging.FileHandler(log_file)
    file_handler.setLevel(logging.INFO)
    # Create console handler
    console_handler = logging.StreamHandler()
    console_handler.setLevel(logging.INFO)
    # Create formatter and add it to the handlers
    formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    file_handler.setFormatter(formatter)
    console_handler.setFormatter(formatter)
    # Add handlers to logger
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)

    return logger


def timing_decorator(func):
    def wrapper(*args, **kwargs):
        start_time = time.time()
        result = func(*args, **kwargs)
        end_time = time.time()
        execution_time = end_time - start_time
        logger.info(f"Finished {func.__name__} in {execution_time:.2f} seconds")
        return result
    return wrapper


def extract_content(content, wrapper="json"):
    return content.split(f"```{wrapper}")[1].split("```")[0].strip()


def extract_module_name(content):
    pattern = r'module\s+(\w+)(?:\s*#?\s*\(|\s+)'
    match = re.search(pattern, content)
    return match.group(1)


class TbState(TypedDict):
    spec: str
    dut_header: str
    dut: str
    function_points: str
    testcases: str
    testbench: str

    compile_feedback: str
    compile_status: str
    n_compile_iteration: int
    testbench_sim_feedback: str

    n_simulate_iteration: int
    testbench_sim_status: str

    coverage_info: list[str]
    n_coverage_iteration: int

    status: str


@timing_decorator
def llm_function_points(state: TbState):
    """LLM generates functional points"""
    prompt = f"""{args.prompt_func_point}

This is the specification:
{state["spec"]}
"""
    request = {
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": args.max_tokens,
        "messages": [
            {
                "role": "user",
                "content": [{"type": "text", "text": prompt}],
            }
        ]
    }
    request = json.dumps(request)
    response = llm.invoke_model_with_response_stream(
        modelId="us.anthropic.claude-sonnet-4-20250514-v1:0", body=request
    )
    print("========== Function Points ==========")
    text_chunks = []
    for event in response["body"]:
        chunk = json.loads(event["chunk"]["bytes"])
        if chunk["type"] == "content_block_delta":
            text = chunk["delta"].get("text", "")
            text_chunks.append(text)

    complete_response = "".join(text_chunks)
    print(complete_response)
    return {"function_points": extract_content(response.content)}


@timing_decorator
def llm_testcases(state: TbState):
    """LLM generates testcases"""
    response = llm.invoke([HumanMessage(content=args.prompt_testcase)])
    print("========== Testcases ==========")
    print(response)
    return {"testcases": extract_content(response.content)}


@timing_decorator
def llm_testbench(state: TbState):
    """LLM generates testbench"""
    prompt = args.prompt_testbench + f"""
The module name to be tested is "{extract_module_name(state["dut_header"])}".

This is the module header of Design Under Test (DUT):
```verilog
{state["dut_header"]}

```
You will have the design under test (DUT) in verilog.
```verilog
{state["dut"]}
```
"""

    # If there's compiler feedback, add it to the prompt
    if state.get("compile_feedback"):
        prompt += f"\n\nThe previous testbench had compilation issues. Here's the compiler feedback:\n{state['compile_feedback']}\nPlease fix these issues in your new testbench."
    response = llm.invoke([HumanMessage(content=prompt)])
    # Extract testbench content, trying different wrappers
    testbench = extract_content(response.content, wrapper="verilog")
    # Increment the iteration counter
    n_compile_iteration = state.get("n_compile_iteration", 0) + 1
    print("========== Testbench ==========")
    print(testbench)
    return {
        "testbench": testbench,
        "n_compile_iteration": n_compile_iteration
    }


@timing_decorator
def vcs_compile(state: TbState):
    """Compile the testbench using VCS"""
    # Save the testbench, the DUT, and create necessary files
    module_name = extract_module_name(state["dut"])
    vcs_dir = args.output_vcs
    with open(osp.join(vcs_dir, "testbench.sv"), "w") as f:
        f.write(state["testbench"])
    with open(osp.join(vcs_dir, f"{module_name}.v"), "w") as f:
        f.write(state["dut"])
    with open(osp.join(vcs_dir, "dut.f"), "w") as f:
        f.write(f"{module_name}.v\ntestbench.sv")
    with open(osp.join(vcs_dir, "makefile"), "w") as f:
        f.write(args.makefile)

    # Change to the VCS directory
    current_dir = os.getcwd()
    os.chdir(vcs_dir)
    # Run make command
    result = subprocess.run(
        ["make", "vcs", "sim"],
        capture_output=True,
        text=True,
        check=False,
        timeout=10
    )
    # Change back to original directory
    os.chdir(current_dir)
    # Get compilation output
    compile_output = result.stdout
    compiler_errors = result.stderr
    # Check if compilation was successful
    if result.returncode == 0:
        compile_status = "SUCCESS"
        feedback = "VCS compilation successful.\n" + compile_output
    else:
        compile_status = "FAILURE"
        feedback = f"VCS compilation failed with return code {result.returncode}.\n"
        feedback += compiler_errors
        feedback += compile_output
    return {
        "compile_feedback": feedback,
        "compile_status": compile_status
    }


def route_compile(state: TbState):
    """Route to end or back to testbench generation based on compilation status and iteration count"""
    # Check if compilation was successful
    if state["compile_status"] == "SUCCESS":
        return "Compilation_Success"
    # Check if we've reached the maximum number of iterations
    if state.get("n_compile_iteration", 0) >= args.max_compile_iterations:
        logger.info(f"Reached maximum iterations ({args.max_compile_iterations}). Stopping retry loop.")
        return "Max_Iterations_Reached"
    # Otherwise, try again

    return "Compilation_Failure"


@timing_decorator
def vcs_simulate(state: TbState):
    """Simulate the testbench using VCS"""
    # Change to the VCS directory
    current_dir = os.getcwd()
    os.chdir(args.output_vcs)
    # Run make command
    result = subprocess.run(
        ["make", "sim"],
        capture_output=True,
        text=True,
        check=False,
        timeout=10
    )
    # Change back to original directory
    os.chdir(current_dir)
    # Get compilation output
    compile_output = result.stdout
    # Check if compilation was successful
    feedback = compile_output.split("===========TestCases===========")[1].split("$finish")[0]

    return {"testbench_sim_feedback": feedback}


@timing_decorator
def llm_testbench_align(state: TbState):
    """LLM align testbench"""
    prompt = args.prompt_testbench_align + f"""
The module name to be tested is {extract_module_name(state["dut_header"])}.

You have the actual simulation:
{state["testbench_sim_feedback"]}

And this is the original testbench:
```verilog
{state["testbench"]}
```
"""
    response = llm.invoke([HumanMessage(content=prompt)])
    # Extract testbench content, trying different wrappers
    testbench = extract_content(response.content, wrapper="verilog")
    with open(osp.join(args.output_vcs, "testbench.sv"), "w") as f:
        f.write(testbench)
    # Increment the iteration counter
    n_simulate_iteration = state.get("n_simulate_iteration", 0) + 1
    print("========== Testbench Alignment ==========")
    print(testbench)
    return {
        "n_simulate_iteration": n_simulate_iteration,
        "testbench": testbench
    }


@timing_decorator
def vcs_simulate_align(state: TbState):
    """Simulate the testbench using VCS"""
    # Change to the VCS directory
    current_dir = os.getcwd()
    os.chdir(args.output_vcs)
    # Run make command
    result = subprocess.run(
        ["make", "vcs", "sim"],
        capture_output=True,
        text=True,
        check=False,
        timeout=10
    )
    # Change back to original directory
    os.chdir(current_dir)
    # Get compilation output
    simulate_output = result.stdout
    feedback = simulate_output.split("===========TestCases===========")[1].split("$finish")[0]
    if "Your Design Passed" in feedback:
        return {"testbench_sim_feedback": feedback, "status": "Success"}
    else:
        return {"testbench_sim_feedback": feedback, "status": "Failure"}


def route_simulate(state: TbState):
    """Route to end or back to testbench generation based on simulation status"""
    # Check if simulation was successful
    if state["status"] == "Success":
        return "Simulate_Success"
    # Check if we've reached the maximum number of iterations
    if state.get("n_simulate_iteration", 0) >= args.max_simulate_iterations:
        logger.info(f"Reached maximum iterations ({args.max_simulate_iterations}). Stopping retry loop.")
        return "Max_Iterations_Reached"
    return "Simulate_Failure"


@timing_decorator
def vcs_coverage(state: TbState):
    vcs_dir = args.output_vcs
    current_dir = os.getcwd()
    os.chdir(vcs_dir)
    # Run make command
    _ = subprocess.run(
        ["make", "vcs", "sim"],
        capture_output=True,
        text=True,
        check=False,
        timeout=10
    )
    _ = subprocess.run(
        ["urg", "-dir", "coverage/cov.vdb"],
        capture_output=True,
        text=True,
        check=False,
        timeout=10
    )
    # Change back to original directory
    os.chdir(current_dir)
    # Open the report
    with open(osp.join(vcs_dir, "urgReport", "mod0.html")) as f:
        html_content = f.read()

    # Define regex patterns for each coverage metric
    # Updated patterns to match the actual HTML structure
    score_pattern = r'<td class="s\d+ cl rt">(\s*\d+\.\d+)</td>'
    line_pattern = r'<td class="s\d+ cl rt"><a href="mod0\.html#Line"\s*>(\s*\d+\.\d+)</a></td>'
    cond_pattern = r'<td class="s\d+ cl rt"><a href="mod0\.html#Cond"\s*>(\s*\d+\.\d+)</a></td>'
    toggle_pattern = r'<td class="s\d+ cl rt"><a href="mod0\.html#Toggle"\s*>(\s*\d+\.\d+)</a></td>'
    branch_pattern = r'<td class="s\d+ cl rt"><a href="mod0\.html#Branch"\s*>(\s*\d+\.\d+)</a></td>'

    # Extract values using regex
    score_match = re.search(score_pattern, html_content)
    line_match = re.search(line_pattern, html_content)
    cond_match = re.search(cond_pattern, html_content)
    toggle_match = re.search(toggle_pattern, html_content)
    branch_match = re.search(branch_pattern, html_content)

    # Add error handling in case patterns don't match
    score = float(score_match.group(1)) if score_match else 0.0
    line = float(line_match.group(1)) if line_match else 0.0
    condition = float(cond_match.group(1)) if cond_match else 0.0
    toggle = float(toggle_match.group(1)) if toggle_match else 0.0
    branch = float(branch_match.group(1)) if branch_match else 0.0

    # Extract line information
    lines_sections = html_content.split("<tr><th></th><th>Line No.</th><th>Total</th><th>Covered</th><th>Percent</th></tr>")
    lines = []
    if len(lines_sections) > 1:
        lines_content = lines_sections[1].split("</pre>")[0]
        if '<pre class="code"><br clear=all>' in lines_content:
            lines = lines_content.split('<pre class="code"><br clear=all>')[1:]

    # Create coverage information
    coverage_info = {
        "overall": {
            "score": score,
            "line": line,
            "condition": condition,
            "toggle": toggle,
            "branch": branch
        },
        "lines": lines
    }
    # logger.info(f"Line coverage at iteration {state["n_coverage_iteration"]} is {coverage_info['overall']['line']}%")
    coverage_info = state.get("coverage_info", []) + [coverage_info]

    return {"coverage_info": coverage_info}


def route_coverage(state: TbState):
    """Route to end or back to testbench generation based on simulation status"""
    coverage_info = state['coverage_info'][-1]
    if coverage_info['overall']['line'] >= args.coverage_threshold:
        return "Coverage_Success"
    if state.get("n_coverage_iteration", 0) >= args.max_coverage_iterations:
        logger.info(f"Reached maximum iterations ({args.max_coverage_iterations}). Stopping retry loop.")
        return "Max_Iterations_Reached"
    else:
        return "Coverage_Failure"


@timing_decorator
def llm_coverage(state: TbState):
    """LLM improve testbench"""
    coverage_info = state["coverage_info"][-1]
    prompt = args.prompt_testbench_coverage.format(
        threshold=args.coverage_threshold,
        line_coverage=coverage_info['overall']['line'],
        line_coverage_info=coverage_info['lines'],
        testbench=state["testbench"]
    )
    response = llm.invoke([HumanMessage(content=prompt)])
    # Extract testbench content, trying different wrappers
    testbench = extract_content(response.content, wrapper="verilog")
    with open(osp.join(args.output_vcs, "testbench.sv"), "w") as f:
        f.write(testbench)
    # Increment the iteration counter
    n_coverage_iteration = state.get("n_coverage_iteration", 0) + 1
    print("========== Testbench Coverage ==========")
    print(testbench)
    return {
        "n_coverage_iteration": n_coverage_iteration,
        "testbench": testbench
    }


def build_graph():
    # Build workflow
    graph_builder = StateGraph(TbState)

    # Add the nodes
    graph_builder.add_node("llm_function_points", llm_function_points)
    graph_builder.add_node("llm_testcases", llm_testcases)
    graph_builder.add_node("llm_testbench", llm_testbench)
    graph_builder.add_node("vcs_compile", vcs_compile)
    graph_builder.add_node("vcs_simulate", vcs_simulate)
    graph_builder.add_node("llm_testbench_align", llm_testbench_align)
    graph_builder.add_node("vcs_simulate_align", vcs_simulate_align)
    graph_builder.add_node("vcs_coverage", vcs_coverage)
    graph_builder.add_node("llm_coverage", llm_coverage)

    # Add edges to connect nodes
    graph_builder.add_edge(START, "llm_function_points")
    graph_builder.add_edge("llm_function_points", "llm_testcases")
    graph_builder.add_edge("llm_testcases", "llm_testbench")
    graph_builder.add_edge("llm_testbench", "vcs_compile")
    graph_builder.add_edge("llm_coverage", "vcs_coverage")
    graph_builder.add_edge("vcs_simulate", "llm_testbench_align")
    graph_builder.add_edge("llm_testbench_align", "vcs_simulate_align")

    # Add conditional edges
    graph_builder.add_conditional_edges(
        "vcs_compile",
        route_compile,
        {
            "Compilation_Success": "vcs_coverage",
            "Max_Iterations_Reached": END,  # End even if compilation failed after max iterations
            "Compilation_Failure": "llm_testbench",
        },
    )
    graph_builder.add_conditional_edges(
        "vcs_coverage",
        route_coverage,
        {
            "Coverage_Success": "vcs_simulate",
            "Max_Iterations_Reached": "vcs_simulate",  # End even if simulation failed after max iterations
            "Coverage_Failure": "llm_coverage",
        },
    )
    graph_builder.add_conditional_edges(
        "vcs_simulate_align",
        route_simulate,
        {
            "Simulate_Success": END,
            "Max_Iterations_Reached": END,  # End even if simulation failed after max iterations
            "Simulate_Failure": "llm_testbench_align",
        },
    )

    # Compile the workflow
    graph = graph_builder.compile()

    # visualize the graph
    mermaid_syntax = graph.get_graph().draw_mermaid()
    graph_file = osp.join(args.output_lang, "graph.mmd")
    with open(graph_file, "w") as f:
        f.write(mermaid_syntax)

    logger.info(f"Save graph to {graph_file} You can paste this code to https://mermaid.live to generate the chart.")

    return graph


def ds_invoke(args, graph, dataset):
    """Invoke the workflow by dataset"""
    default_output_vcs = args.output_vcs
    for data in dataset[args.start_idx: args.end_idx]:
        st_time = time.time()
        idx = int(data["id"])
        logger.info(f"==================== Generate data: {idx} ====================")
        output_vcs = osp.join(args.output_vcs, f"{idx}")
        args.output_vcs = output_vcs
        os.makedirs(output_vcs, exist_ok=True)
        print("Create output directory:", output_vcs)
        # clean
        current_dir = os.getcwd()
        os.chdir(output_vcs)
        _ = subprocess.run(
            ["make", "clean"],
            capture_output=True,
            text=True,
            check=False,
            timeout=10
        )
        os.chdir(current_dir)

        # Initialize the state
        # llm = ChatOpenAI(model=args.model, max_tokens=args.max_tokens, temperature=args.temperature)
        state = {
            "id": data["id"],
            "spec": data["instruction"],
            "dut_header": data["dut_header"],
            "dut": data["output"],
            # Initialize iteration counter
            "n_compile_iteration": 0,
            "n_simulate_iteration": 0,
            "n_coverage_iteration": 0,
            "status": "Failure",
            "testbench_sim_feedback": "",
            "coverage_info": []
        }

        # Invoke the workflow
        try:
            state = graph.invoke(state)
            testbench = state.pop("testbench")
            with open(osp.join(output_vcs, "data.json"), 'w') as f:
                instance = [{
                    "testbench": testbench,
                    "status": state["status"],
                    "state": {
                        "function_points": state["function_points"],
                        "testcases": state["testcases"],
                        "n_simulate_iteration": state["n_simulate_iteration"],
                        "n_compile_iteration": state["n_compile_iteration"],
                        "n_coverage_iteration": state["n_coverage_iteration"],
                        "coverage_info": state["coverage_info"],
                        "testbench_sim_feedback": state["testbench_sim_feedback"],
                    }
                }]
                json.dump(instance, f, indent=4)
            if state["status"] == "Success":
                logger.info(f"Successfully generated testbench for {data['id']}")
            elif state["n_simulate_iteration"] == args.max_simulate_iterations:
                # logger.info(f"Generated testbench for {data['id']} coverst {state["coverage_info"][-1]}%")
                logger.info(f"Failed to generate testbench for {data['id']}")
            else:
                logger.info(f"Failed to generate testbench for {data['id']}")

            # clean the vcs
            current_dir = os.getcwd()
            os.chdir(output_vcs)
            _ = subprocess.run(
                ["make", "clean"],
                capture_output=True,
                text=True,
                check=False,
                timeout=10
            )
            os.chdir(current_dir)

        except Exception as e:
            logger.info(f"===== Error for {data['id']} =====")
            logger.info(e)

        args.output_vcs = default_output_vcs
        cost = time.time() - st_time
        logger.info(f"==================== Time Cost: {cost} ====================")


if __name__ == "__main__":
    def _load_prompt(args, var):
        with open(osp.join(args.prompt_root, getattr(args, var))) as f:
            setattr(args, var, f.read())
        return args

    parser = argparse.ArgumentParser()
    parser.add_argument("--max_tokens", type=int, default=4096, help="The maximum number of tokens to generate")
    parser.add_argument("--temperature", type=float, default=0.0, help="The temperature for sampling")
    parser.add_argument("--timeout", type=int, default=15, help="The timeout in seconds")
    parser.add_argument("--data_root", type=str, default="./data", help="The root directory for data")
    parser.add_argument("--data_file", type=str, default="rlvr_sft.json", help="The data file")
    # prompt settings
    parser.add_argument("--prompt_root", type=str, default="./prompts", help="The root directory for prompts")
    parser.add_argument("--prompt_func_point", type=str, default="func_point.txt", help="The function system prompt")
    parser.add_argument("--prompt_testcase", type=str, default="testcase.txt", help="The testcase prompt prompt")
    parser.add_argument("--prompt_testbench", type=str, default="testbench.txt", help="The testbench prompt prompt")
    parser.add_argument("--prompt_testbench_align", type=str, default="testbench_align.txt", help="The testbench alignment prompt")
    parser.add_argument("--prompt_testbench_coverage", type=str, default="testbench_coverage.txt", help="The coverage prompt")
    # vcs settings
    parser.add_argument("--vcs_root", type=str, default="./vcs_tools", help="The root directory for VCS tools")
    parser.add_argument("--makefile", type=str, default="makefile", help="The makefile")
    parser.add_argument("--output_root", type=str, default="./outputs", help="The root directory for outputs")
    parser.add_argument("--output_lang", type=str, default="lang", help="The language output")
    parser.add_argument("--output_vcs", type=str, default="vcs", help="The testbench output")
    parser.add_argument("--max_compile_iterations", type=int, default=3, help="Maximum number of compilation retry iterations")
    parser.add_argument("--max_simulate_iterations", type=int, default=3, help="Maximum number of simulation retry iterations")
    parser.add_argument("--max_coverage_iterations", type=int, default=3, help="Maximum number of coverage retry iterations")
    parser.add_argument("--coverage_threshold", type=float, default=90., help="The coverage threshold")
    parser.add_argument("--start_idx", type=int, default=0, help="The start index of the dataset")
    parser.add_argument("--end_idx", type=int, default=1, help="The end index of the dataset")
    args = parser.parse_args()

    # data settings
    args.data_file = osp.join(args.data_root, args.data_file)
    # prompt settings
    args = _load_prompt(args, "prompt_func_point")
    args = _load_prompt(args, "prompt_testcase")
    args = _load_prompt(args, "prompt_testbench")
    args = _load_prompt(args, "prompt_testbench_align")
    args = _load_prompt(args, "prompt_testbench_coverage")
    # vcs settings
    with open(osp.join(args.vcs_root, args.makefile)) as f:
        args.makefile = f.read()
    # output settings
    args.output_lang = osp.join(args.output_root, args.output_lang)
    os.makedirs(args.output_lang, exist_ok=True)
    args.output_vcs = osp.join(args.output_root, args.output_vcs)
    os.makedirs(args.output_vcs, exist_ok=True)

    logger = setup_logger()
    proxies = {
     'http': 'http://127.0.0.1:7890',
     'https': 'http://127.0.0.1:7890'
    }
    config = Config(
        connect_timeout=30,
        read_timeout=12000,
        proxies=proxies
    )

    llm = boto3.client(
        "bedrock-runtime",
        region_name="us-west-2",
        aws_access_key_id='',
        aws_secret_access_key='',
        config=config
    )

    # build the graph
    graph = build_graph()

    # load the dataset
    with open(args.data_file) as f:
        dataset = json.load(f)

    ds_invoke(args, graph, dataset)
