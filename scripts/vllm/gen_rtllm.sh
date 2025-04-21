#!/bin/bash

# Check if at least two arguments are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <model_path> <save_path> [adapter_path]"
    exit 1
fi

# Assign arguments to variables
MODEL_PATH=$1
SAVE_PATH=$2
ADAPTER_PATH=$3  # Optional adapter path

# Set visible GPUs
export CUDA_VISIBLE_DEVICES=4,5,6,7

# Create output directory
# Extract the directory part from the save path
SAVE_DIR=$(dirname "$SAVE_PATH")
mkdir -p "$SAVE_DIR"

# Base command
CMD="python src/generate.py \
    --model \"$MODEL_PATH\" \
    --task \"./data/benchmark/rtllm.json\" \
    --save \"$SAVE_PATH\" \
    --max_length 4096 \
    --temperature 0.8 \
    --top_p 0.95 \
    --num_generations 20 \
    --batch_size 64 \
    --gpu_memory_utilization 0.95 \
    --is_postprocess \
    --seed 0"

# Add adapter path if provided
if [ -n "$ADAPTER_PATH" ]; then
    CMD="$CMD --adapter_path \"$ADAPTER_PATH\""
    echo "Using adapter from: $ADAPTER_PATH"
else
    echo "No adapter path provided, using base model only."
fi

# Execute the command
eval $CMD