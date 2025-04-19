#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ $# -lt 3 ]]; then
    echo "Usage: $0 <model> <base url> <save file key> [qps_values...]"
    echo "Example: $0 meta-llama/Llama-3.1-8B-Instruct http://localhost:8000 test 15 20 25"
    exit 1
fi

MODEL=$1
BASE_URL=$2
KEY=$3

# Configuration
NUM_USERS=10
NUM_ROUNDS=5
SYSTEM_PROMPT="You are a helpful assistant."
CHAT_HISTORY=""
ANSWER_LEN=100

# If QPS values are provided, use them; otherwise use default
if [ $# -gt 3 ]; then
    QPS_VALUES=("${@:4}")
else
    QPS_VALUES=(15)  # Default QPS value
fi

run_benchmark() {
    local qps=$1
    local output_file="${KEY}_qps${qps}.csv"
    
    echo "Running benchmark with QPS=$qps..."
    python3 "${SCRIPT_DIR}/multi-round-qa.py" \
        --num-users "$NUM_USERS" \
        --shared-system-prompt "$(echo -n "$SYSTEM_PROMPT" | wc -w)" \
        --user-history-prompt "$(echo -n "$CHAT_HISTORY" | wc -w)" \
        --answer-len "$ANSWER_LEN" \
        --num-rounds "$NUM_ROUNDS" \
        --qps "$qps" \
        --model "$MODEL" \
        --base-url "$BASE_URL" \
        --output "$output_file" \
        --time 60
}

# Run benchmarks for each QPS value
for qps in "${QPS_VALUES[@]}"; do
    run_benchmark "$qps"
done
