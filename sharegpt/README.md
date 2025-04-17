# ShareGPT Datasets

1. **Download and prepare the ShareGPT dataset**
You can specify the number of users to include, exclude users with fewer than a given number of rounds, and choose which round to start from for each remaining user:

    ```bash
    bash prepare_sharegpt_data.sh -l 200 -m 5 -s 3
    ```

2. **Run the round‑robin workload against your LLM**
Each filtered user will submit their questions in turn. Modify the `QPS` in `run.sh`. We tested on 2xA100 (80GB) GPUs.

    ```bash
    bash run.sh meta-llama/Llama-3.1-70B-Instruct http://localhost:30080/v1/ stack
    ```

> **Note**: The above command requires there is a serving engine with the model served locally at ``http://localhost:30080/v1``. Here's an example command to launch the serving engine with vLLM Production Stack:
> 
> ```bash
> helm repo add vllm https://vllm-project.github.io/production-stack
> helm install vllm vllm/vllm-stack -f stack.yaml
> ```
> 
> And then do port-forwarding with the following command:
> 
> ```bash
> kubectl port-forward svc/vllm-router-service 30080:80
> ```

> **Note**: The warm‑up phase of the benchmark exists solely to preload the first xxx rounds (determined by `-s` in Step 1) of all users.

## Processing results

To get the average TTFT:

```bash
python3 ../synthetic-multi-round-qa/multi-round-qa.py --process-summary <YOUR CSV>
```

To get the average ITL, change the file name in `./synthetic-multi-round-qa/calculat_itl.py` and run:

```bash
python3 ./synthetic-multi-round-qa/calculat_itl.py
```
