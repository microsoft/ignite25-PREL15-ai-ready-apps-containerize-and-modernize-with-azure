# Segment 3 — Explore Ollama on Azure Container Apps (30 minutes)

> Reuse the GPU-enabled Container App from Segment 0/1 (`my-gpu-demo-app`) so you don’t provision an additional GPU revision. These steps assume that app is still deployed in the same resource group and region.

---

## Overview
In this segment you will:
- Reconfigure the existing Container App to run the official Ollama container image with GPU access
- Enable ingress on port `11434` for remote API calls
- Pull multiple models (SmolLM2 1.7B, DeepSeek-R1 14B, GPT-OSS 20B) from inside the container
- Compare model quality with a curated prompt pack
- Exercise Ollama’s HTTP API using `curl`, `wget`, and PowerShell commands

Estimated duration: **30 minutes**

---

## Prerequisites
- Segment 0 & Segment 1 completed (Azure Container Apps environment + GPU quota ready)
- Existing Container App `my-gpu-demo-app` deployed in `my-gpu-demo-group`
- Azure subscription with GPU workload profile enabled (already set up in the Skillable lab)

> ⚠️ **Cost note:** Leaving the GPU-enabled revision running will continue to accrue charges. Remember to scale to zero or delete the resource group after completing the lab.

---

## Task 1 — Reconfigure the GPU App to Run Ollama

**Goal:** Swap the container image in `my-gpu-demo-app` to `ollama/ollama`, expose port `11434`, and keep GPU acceleration enabled.

1. **Open the Container App in Azure Portal**
   - Go to https://portal.azure.com and navigate to **Resource groups > my-gpu-demo-group > my-gpu-demo-app**.

2. **Edit the active revision**
   - Select **Application > Containers** and click **Edit and deploy a revision**.

3. **Update container image & command**
   - Under **Container image**, replace the image with `ollama/ollama:latest`.
   - Expand **Advanced** settings and verify the command stays empty (Ollama default entrypoint).

4. **Expose port 11434**
   - In the **Ingress** section, enable ingress if it is not already enabled.
   - Set **Ingress type** to **External**.
   - Change the **Target port** to `11434`.

5. **Set environment variables**
   - Under **Environment variables**, add:
     - `Name: OLLAMA_HOST` → `Value: 0.0.0.0`
     - (Optional) `Name: OLLAMA_NUM_PARALLEL` → `Value: 2` to allow two concurrent GPU generations.

6. **Confirm GPU workload profile**
   - In **Compute**, ensure the **Workload profile** remains `Consumption-GPU-NC8as-T4` with GPU enabled.

7. **Deploy the new revision**
   - Click **Review + deploy** and then **Create** to publish the new revision.
   - Wait until the revision status shows **Running**. This can take 2–3 minutes.

---

## Task 2 — Pull Ollama Models from the Portal Console

**Goal:** Shell into the running container and pre-load the models you’ll test.

1. **Open the container console**
   - In the Container App blade, select **Monitoring > Console**.
   - Choose the newest revision and replica (e.g., `defaultRevision | replica 0`).
   - Launch a `/bin/bash` session.

2. **Verify Ollama is running**
   ```bash
   ps aux | grep ollama
   ollama --version
   ```

3. **Pull the requested models**
   ```bash
   ollama pull smollm2:1.7b
   ollama pull deepseek-r1:14b
   ollama pull gpt-oss:20b
   ```
   > Each download can take several minutes. Keep the console open until all pulls complete.

4. **List installed models**
   ```bash
   ollama list
   ```
   You should see all three models with the `latest` digest.

---

## Task 3 — Compare Model Quality with Prompt Pack

Use the console (or API) to run these prompts against each model. The goal is to spot differences across model sizes.

| Prompt | What to Look For |
| --- | --- |
| `Explain the concept of vector databases to a new data engineer in under three sentences.` | Clarity + factual accuracy |
| `Write a Python function that generates a haiku using a small in-memory word list.` | Code correctness + creativity |
| `Reason through this riddle: You see me once in a year, twice in a week, and never in a day. What am I?` | Chain-of-thought reasoning |

Example CLI usage inside the console:
```bash
ollama run smollm2:1.7b "Explain the concept of vector databases to a new data engineer in under three sentences."
ollama run deepseek-r1:14b "Write a Python function that generates a haiku using a small in-memory word list."
ollama run gpt-oss:20b "Reason through this riddle: You see me once in a year, twice in a week, and never in a day. What am I?"
```
Take notes on latency, depth of reasoning, and hallucination risk for each model.

---

## Task 4 — Explore the Ollama REST API

**Goal:** Interact with the Ollama server remotely using typical dev tooling.

> Ensure ingress is working by browsing to `https://my-gpu-demo-app.<unique-id>.<region>.azurecontainerapps.io`. The endpoint will respond once the GPU revision is warm. Append the API path (`/api/*`) to the base URL for the calls below.

### 4.1 List installed models
- **curl (Cloud Shell / Linux / WSL):**
  ```bash
  curl -s https://my-gpu-demo-app.<unique-id>.<region>.azurecontainerapps.io/api/tags | jq
  ```
- **wget (any bash):**
  ```bash
  wget -qO- https://my-gpu-demo-app.<unique-id>.<region>.azurecontainerapps.io/api/tags
  ```
- **PowerShell:**
  ```powershell
  Invoke-RestMethod -Uri "https://my-gpu-demo-app.<unique-id>.<region>.azurecontainerapps.io/api/tags" -Method Get
  ```

### 4.2 Generate text via streaming inference
- **curl:**
  ```bash
  curl -N https://my-gpu-demo-app.<unique-id>.<region>.azurecontainerapps.io/api/generate \
    -H "Content-Type: application/json" \
    -d '{"model":"smollm2:1.7b","prompt":"Explain the concept of vector databases."}'
  ```
- **PowerShell:**
  ```powershell
  Invoke-RestMethod -Uri "https://my-gpu-demo-app.<unique-id>.<region>.azurecontainerapps.io/api/generate" `
    -Method Post `
    -Body (@{ model = "deepseek-r1:14b"; prompt = "Write a short play about cloud elasticity." } | ConvertTo-Json) `
    -ContentType "application/json"
  ```

### 4.3 Show model metadata (pick any deployed model)
- **curl:**
  ```bash
  curl https://my-gpu-demo-app.<unique-id>.<region>.azurecontainerapps.io/api/show \
    -H "Content-Type: application/json" \
    -d '{"model":"gpt-oss:20b"}'
  ```
- **wget:**
  ```bash
  wget -qO- --method=POST --header="Content-Type: application/json" \
    --body-data='{"model":"smollm2:1.7b"}' \
    https://my-gpu-demo-app.<unique-id>.<region>.azurecontainerapps.io/api/show
  ```

> 🔐 Tip: For production deployments, restrict ingress to private endpoints or secure the API with Azure Container Apps authentication.

---

## Wrap-Up
- ✅ Ollama now runs inside your GPU-backed Container App with external ingress
- ✅ Required models are pre-pulled and ready for inference testing
- ✅ Prompt pack highlights capability differences across 1.7B, 14B, and 20B parameter models
- ✅ You called the Ollama REST API using multiple tools

**Next steps:** Consider layering Azure API Management or Dapr in front of Ollama, adding caching (Redis), and wiring Application Insights traces for end-to-end observability.
