#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ $# -lt 3 ]]; then
    echo "Usage: $0 <model> <base url> <save file key> [qps_values...]"
    echo "Example: $0 meta-llama/Llama-3.1-8B-Instruct http://localhost:8000 /mnt/requests/synthetic-run1 0.1 0.2 0.3"
    exit 1
fi

MODEL=$1
BASE_URL=$2
KEY=$3

# If QPS values are provided, use them; otherwise use default
if [[ $# -gt 3 ]]; then
    QPS_VALUES=("${@:4}")
else
    QPS_VALUES=(0.1)  # Default QPS value
fi

# CONFIGURATION
NUM_USERS=15
NUM_ROUNDS=20

SYSTEM_PROMPT=1000 # Shared system prompt length
CHAT_HISTORY=20000 # User specific chat history length
ANSWER_LEN=100 # Generation length per round

run_benchmark() {
    # $1: qps
    # $2: output file
    python3 "${SCRIPT_DIR}/multi-round-qa.py" \
        --num-users $NUM_USERS \
        --num-rounds $NUM_ROUNDS \
        --qps "$1" \
        --shared-system-prompt "$SYSTEM_PROMPT" \
        --user-history-prompt "$CHAT_HISTORY" \
        --answer-len $ANSWER_LEN \
        --model "$MODEL" \
        --base-url "$BASE_URL" \
        --output "$2" \
        --log-interval 30 \
        --time 100
}

# Run benchmarks for the specified QPS values
for qps in "${QPS_VALUES[@]}"; do
    output_file="${KEY}_output_${qps}.csv"
    run_benchmark "$qps" "$output_file"
done
