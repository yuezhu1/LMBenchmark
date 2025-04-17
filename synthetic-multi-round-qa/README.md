# Benchmarking vLLM Production Stack Performance with multi-round QA

## Overview

This repository contains benchmarking tools for evaluating vLLM Production Stack's performance (e.g., latency, throughput). The initial focus of this benchmark is on the multi-round QA (Question Answering) use case. The script `multi-round-qa.py` simulates multiple users interacting with a language model concurrently for multiple rounds, allowing you to analyze the serving engine's throughput and latency.

The overall workflow of this script is shown below ![Illustration](multi-round.png)

## Setup

Installing the required packages needed to run the benchmark by:

```bash
pip install -r requirements.txt
```

## Running benchmarks

To run the short input short output benchmark, modify the `QPS` in `short_input_short_output.sh` and use the following example command. We tested on 2xA100 (80GB) GPUs.

```bash
bash short_input_short_output.sh meta-llama/Llama-3.1-70B-Instruct http://localhost:30080/v1/ stack
```

To run the long input short output benchmark, modify the `QPS` in `long_input_short_output_run.sh` and use the following example command. We tested on 1xA100 (40GB) GPU.

```bash
bash long_input_short_output_warmup.sh meta-llama/Llama-3.1-8B-Instruct http://localhost:30080/v1/
bash long_input_short_output_run.sh meta-llama/Llama-3.1-8B-Instruct http://localhost:30080/v1/ stack
```

> **Note**: The above command requires there is a serving engine with the model served locally at ``http://localhost:30080/v1``. Here's an example command to launch the serving engine with vLLM Production Stack:
> 
> ```bash
> helm repo add vllm https://vllm-project.github.io/production-stack
> helm install vllm vllm/vllm-stack -f <YOUR STACK.YAML>
> ```
> 
> And then do port-forwarding with the following command:
> 
> ```bash
> kubectl port-forward svc/vllm-router-service 30080:80
> ```

> **Note**: The warm‑up phase of both benchmarks exists solely to preload the **user-specific chatting history** of all users in the tested session.

## Processing results

To get the average TTFT:

```bash
python3 multi-round-qa.py --process-summary <YOUR CSV>
```

To get the average ITL, change the file name in `calculat_itl.py` and run:

```bash
python3 calculat_itl.py
```
