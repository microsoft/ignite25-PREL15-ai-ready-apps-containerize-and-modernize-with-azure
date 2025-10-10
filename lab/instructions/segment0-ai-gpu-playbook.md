# Segment 0 — AI-Accelerated Azure Container Apps Playbook (15 minutes)

> Note: This content is being covered via slides and live in session.

> Audience: Practitioners who already understand Azure Container Apps fundamentals and need a fast, GPU-focused refresher before diving into the labs.

## Agenda Overview

| Time | Topic | Takeaway |
| --- | --- | --- |
| 2 min | Context & Scenarios | Why AI workloads benefit from ACA + GPUs |
| 4 min | GPU Workload Profiles | Pick the right SKU, manage cold starts, baseline costs |
| 3 min | Model Packaging & Runtime Optimization | Container patterns for large models, trimming image size |
| 3 min | Hybrid Orchestration | Combine Azure OpenAI + OSS models securely |
| 3 min | Observability & Cost Controls | Monitor GPUs, keep spend predictable |

## 1. Context & Scenarios (2 min)
- **Objective**: Frame the types of AI workloads that justify ACA serverless GPUs.
- **Talking Points**:
  - Image generation, RAG inferencing, and custom fine-tuned models with bursty demand.
  - Serverless GPUs reduce idle burn; container boundaries keep deployment consistent across environments.
  - Contrast ACA with AKS for the same workloads (operational overhead, scale-to-zero vs. always-on).
- **Call to Action**: Audience should identify one candidate workload in their portfolio for GPU offload.

## 2. GPU Workload Profiles & Scheduling (4 min)
- **Objective**: Show how to choose and configure GPU-enabled revisions for reliable throughput.
- **Talking Points**:
  - Managed GPU workload profiles (NCas, ND, preview SKUs) and limits per environment.
  - Setting `minReplicas` > 0 for hot-start scenarios; leveraging `pre-provisioned` revisions for predictable latency.
  - Using `az containerapp revision list` + labels to stage GPU upgrades safely.
- **Demo Snippet**:
  ```bash
  az containerapp update \
    --name $APP \
    --resource-group $RG \
    --workload-profile-name gp1 \
    --min-replicas 1 \
    --max-replicas 3 \
    --revision-suffix gpu-rollout
  ```
- **Pro Tip**: Pair GPU revisions with a CPU-only revision for fallback traffic when GPU capacity is exhausted.

## 3. Model Packaging & Runtime Optimization (3 min)
- **Objective**: Teach container image practices that keep GPU deployments lean.
- **Talking Points**:
  - Base images: `mcr.microsoft.com/azureml/minimal-ubuntu18.04-py37-cuda11.0` or NVIDIA CUDA runtime images.
  - Stage large model weights in Azure Files or Blob Storage; mount with secrets-managed SAS tokens.
  - Convert models to ONNX/TensorRT where possible; enable `--gpu-memory 80%` flags to avoid OOM.
- **Code Skeleton**:
  ```dockerfile
  FROM nvcr.io/nvidia/pytorch:24.02-py3
  COPY requirements.txt .
  RUN pip install -r requirements.txt && \
      python -m bitsandbytes
  COPY app/ /app
  CMD ["python", "app/server.py"]
  ```
- **Pro Tip**: Use async batching libraries (vLLM, Text-Generation-Inference) to drive higher tokens/sec per replica.

## 4. Hybrid Model Orchestration (3 min)
- **Objective**: Blend managed and self-hosted AI models behind a single ACA ingress.
- **Talking Points**:
  - Call Azure OpenAI for regulated workloads; route specialized prompts to self-hosted OSS models.
  - Use Dapr secrets + service invocation for cross-revision calls.
  - Secure outbound calls with managed identity; restrict inbound to private endpoints.
- **Architecture Sketch**:
  - API Gateway revision → (a) Azure OpenAI endpoint, (b) GPU-backed Stable Diffusion revision.
  - Log prompt/response metadata to Application Insights for drift detection.

## 5. Observability & Cost Controls (3 min)
- **Objective**: Keep GPU usage visible and affordable.
- **Talking Points**:
  - Inspect GPU metrics: `azure.containerapp/revisionGpuUtilization`, `revisionQueueLength`.
  - Emit structured logs (per request tokens, latency) via OpenTelemetry → Azure Monitor.
  - Implement scheduled scale policies (e.g., scale-to-zero overnight) and budget alerts in Cost Management.
- **Dashboard Tip**:
  - Create Grafana panels for GPU utilization vs. requests/sec to right-size `maxReplicas`.

## Wrap-Up Checklist
- ✅ Identify workloads suited for ACA GPUs
- ✅ Configure GPU workload profiles with predictable scale
- ✅ Package models leanly with externalized weights
- ✅ Combine Azure OpenAI and OSS models securely
- ✅ Monitor cost and utilization from day one

> **Next Action**: Jump to Segment 1 lab to deploy the GPU-backed image generation workflow.
