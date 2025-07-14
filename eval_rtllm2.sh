#!/bin/bash

# Check if at least two arguments are provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <input_json>"
    exit 1
fi

# Assign arguments to variables
INPUT_JSON=$1

# Base command
CMD="python src/eval_benchmark.py \
    --base_path "./benchmark/rtllm2" \
    --input_json \"$INPUT_JSON\" \
    --k_values 1,5,10 \
    --n_samples 20"

# Execute the command
eval $CMD