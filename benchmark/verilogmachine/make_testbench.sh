#!/bin/bash

# Resolve the absolute path of the directory where the script is located
START_DIR=$(cd "$(dirname "$(readlink -f "$0")")" && pwd)
EXP_DIR="${START_DIR}/$1"
cd "$EXP_DIR"

echo "# Start sim"
make sim