import os
import json

def collect_design_descriptions():
    # Get the current directory (where this script is located)
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # List all first-level subfolders
    subfolders = [f for f in os.listdir(current_dir) 
                 if os.path.isdir(os.path.join(current_dir, f))]
    
    result = []
    
    # Process each subfolder
    for subfolder in subfolders:
        subfolder_path = os.path.join(current_dir, subfolder)
        desc_path = os.path.join(subfolder_path, "design_description.txt")
        testbench_path = os.path.join(subfolder_path, "testbench.v")
        
        entry = {"name": subfolder}
        
        # Check if design_description.txt exists in the subfolder
        if os.path.exists(desc_path):
            try:
                # Read the content of the file
                with open(desc_path, 'r', encoding='utf-8') as file:
                    spec_content = file.read()
                entry["spec"] = spec_content
            except Exception as e:
                print(f"Error reading {desc_path}: {e}")
        
        # Check if testbench.v exists in the subfolder
        if os.path.exists(testbench_path):
            try:
                # Read the content of the file
                with open(testbench_path, 'r', encoding='utf-8') as file:
                    testbench_content = file.read()
                entry["testbench"] = testbench_content
            except Exception as e:
                print(f"Error reading {testbench_path}: {e}")
        
        # Add entry to the result if it contains any data
        if "spec" in entry or "testbench" in entry:
            result.append(entry)
    
    return result

def save_as_json(data, output_file="design_descriptions.json"):
    # Get the current directory
    current_dir = os.path.dirname(os.path.abspath(__file__))
    output_path = os.path.join(current_dir, output_file)
    
    # Save as JSON
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
    print(f"JSON saved to {output_path}")

if __name__ == "__main__":
    # Collect descriptions and testbenches from all subfolders
    descriptions = collect_design_descriptions()
    
    # Print summary
    print(f"Found {len(descriptions)} design descriptions and/or testbenches")
    
    # Save as JSON
    save_as_json(descriptions)
