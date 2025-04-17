#!/bin/bash

if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <model> <base url> <save file key>"
    exit 1
fi

MODEL=$1
BASE_URL=$2
# Warmup: precompute KV and store inside CPU mem
# CONFIGURATION
NUM_USERS_WARMUP=400
NUM_USERS=320
NUM_ROUNDS=20

SYSTEM_PROMPT=0 # Shared system prompt length
CHAT_HISTORY=256 # User specific chat history length
ANSWER_LEN=20 # Generation length per round

warmup() {
    # Warm up the vLLM with a lot of user queries
    python3 ./multi-round-qa.py \
        --num-users 1 \
        --num-rounds 2 \
        --qps 2 \
        --shared-system-prompt $SYSTEM_PROMPT \
        --user-history-prompt $CHAT_HISTORY \
        --answer-len $ANSWER_LEN \
        --model "$MODEL" \
        --base-url "$BASE_URL" \
        --output /tmp/warmup.csv \
        --log-interval 30 \
        --time $((NUM_USERS_WARMUP / 2))
}

run_benchmark() {

    warmup

    # $1: qps
    # $2: output file

    # Real run
    python3 ./multi-round-qa.py \
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

    sleep 10
}

KEY=$3

# Run benchmarks for different QPS values
QPS_VALUES=(15) # Set your QPS values here

# Run benchmarks for the determined QPS values
for qps in "${QPS_VALUES[@]}"; do
    output_file="${KEY}_output_${qps}.csv"
    run_benchmark "$qps" "$output_file"
done
