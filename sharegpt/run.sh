#!/bin/bash

if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <model> <base url> <save file key>"
    exit 1
fi

MODEL=$1
BASE_URL=$2

warm_up() {
    # $1: qps
    # $2: output file

    python3 ./sharegpt-qa.py \
        --qps 2 \
        --model "$MODEL" \
        --base-url "$BASE_URL" \
        --output /tmp/warmup.csv \
        --log-interval 30 \
        --sharegpt-file "warmup.json"

    sleep 10
}

warm_up

run_benchmark() {
    # $1: qps
    # $2: output file

    # Real run
    python3 ./sharegpt-qa.py \
        --qps "$1" \
        --model "$MODEL" \
        --base-url "$BASE_URL" \
        --output "$2" \
        --log-interval 30 \
        --sharegpt-file "run.json"

    sleep 10
}

KEY=$3

# Run benchmarks for different QPS values
QPS_VALUES=(1.34) # Set your QPS

# Run benchmarks for the determined QPS values
for qps in "${QPS_VALUES[@]}"; do
    output_file="${KEY}_output_${qps}.csv"
    run_benchmark "$qps" "$output_file"
done
