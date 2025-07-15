import os
import os.path as osp

import json

vcs_path = "./outputs/vcs"
START_IDX = 0
END_IDX = 8000

suc_state = {}
dataset = []
failure_ids = []
# for every subfolder in the vcs folder
for i in range(START_IDX, END_IDX):
    folder_path = os.path.join(vcs_path, f"{i}")

    data_file = osp.join(folder_path, "data.json")
    if not osp.exists(data_file):
        failure_ids.append(i)
        continue
    with open(data_file, "r") as f:
        data = json.load(f)[0]

    if data["status"] == "Success":
        state = data["state"]
        if isinstance(state["coverage_info"], dict):
            state["coverage_info"] = [state["coverage_info"]]
        suc_state[i] = {
            "n_compile": state["n_compile_iteration"],
            "n_coverage": state.get("n_coverage_iteration", 1),
            "n_simulate": len(state["coverage_info"]),
            "line_coverage": [info["overall"]["line"] for info in state["coverage_info"]],
        }

        dataset.append({
            "id": data["id"],
            "num": data["num"],
            "instruction": f"""Please act as a professional verilog designer.\n\n{data["instruction"]}""",
            "input": "",
            "output": "",
            "testbench": data["testbench"],
        })

print(f"Fails: {len(failure_ids)}")

with open("outputs/pyra_spec_ast_medium_wtb.json", "w") as f:
    json.dump(dataset, f, indent=4)

with open("outputs/pyra_spec_ast_medium_wtbstate.json", "w") as f:
    json.dump(suc_state, f, indent=4)
