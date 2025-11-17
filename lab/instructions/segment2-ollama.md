# Segment 2 - Explore Ollama on Azure Container Apps (30 minutes)

> Reuse the GPU-enabled Container App from Segment 0/1 (`my-gpu-demo-app`) so you don't provision an additional GPU revision. These steps assume that app is still deployed in the same resource group and region.

---

## Overview

In this segment you will:

- Reconfigure the existing Container App to run the official Ollama container image with GPU access
- Enable ingress on port `11434` for remote API calls
- Pull multiple models (SmolLM2 1.7B, DeepSeek-R1 14B, GPT-OSS 20B) from inside the container
- Compare model quality with a curated prompt pack
- Exercise Ollama's HTTP API using `curl`, `wget`, and PowerShell commands

Estimated duration: **30 minutes**

---

## Prerequisites

- Segment 0 & Segment 1 completed (Azure Container Apps environment + GPU quota ready)
- Existing Container App `my-gpu-demo-app` deployed in `my-gpu-demo-group`
- Azure subscription with GPU workload profile enabled (already set up in the Skillable lab)

---

## Task 1 - Reconfigure the GPU App to Run Ollama

**Goal:** Swap the container image in `my-gpu-demo-app` to `ollama/ollama`, expose port `11434`, and keep GPU acceleration enabled.

1. **Open the Container App in Azure Portal**

    - Go to `https://portal.azure.com` and navigate to **Resource groups > my-gpu-demo-group > my-gpu-demo-app**.

1. **Verify your app is on a T4 GPU workload profile**

    The following steps demonstrate how you can switch between workload profiles (different compute types) in Azure Container Apps.

    - In the navigation blade on the left, select **Overview**. In the **Overview**, click on the **Properties** tab.
    - Confirm the **Workload profile** is set to `t4` with GPU enabled.
    - Select **Change** for the workload profile. You should see that the GPU box is selected, and the GPU type is `Consumption-GPU-NC8as-T4`. Select **Discard**.

1. **Update the container image**

    - In the navigation blade on the left, select **Application > Containers**.
    - Update **Registry login server** to `docker.io`.
    - Update **Image and tag** to `ollama/ollama:latest`.
    - Ensure that the **CPU cores** are set to `8` and **Memory** is set to `56`.

1. **Set environment variables**

    - Select the **Environment variables** tab.
    - Select **Add** and provide the following environment variables:

        - Set **Name** to `OLLAMA_HOST`, choose **Manual entry**, and enter the value `0.0.0.0`.

    - Click **Save as a new revision**. 
    - This will take a few moments to deploy the new revision. Select the notification bell in the top right to see the status of the ongoing deployment.

1. **Change the port the app receives traffic on**

    - Once the revision has been deployed, select **Networking > Ingress** in the navigation blade on the left.
    - In the **Ingress** section, ensure the checkbox for **Ingress** is selected.
    - Set **Ingress traffic** to **Accepting traffic from anywhere**.
    - Change the **Target port** to `11434`.
    - Select **Save**.

1. **Verify the application is running**

    Once your application's ingress has been updated, verify the application is running.

    - Select **Application > Revisions and replicas**.
    - Under **Running status**, the latest revision you deployed should show as `Activating`. Once it shows as **Running**, your application is ready. If after waiting a few minutes it is still not running, refresh the page.

---

## Task 2 - Pull Ollama Models from the Portal Console

**Goal:** Shell into the running container and pre-load the models you'll test.

1. **Open the container console**

    - In the Container App blade, select **Monitoring > Console**.
    - If you select the field for **Based on revision**, you should see the latest revision selected. Choose the newest revision and replica (e.g., `gpuquickstart--0000004`).
    - For **Choose start up command**, select `/bin/bash` and select **Connect** to launch a `/bin/bash` session.

1. **Verify Ollama is running**

Type the following commands into the console:

```bash
  ps aux | grep ollama
  ollama --version

```
You should get a response like this: 

  **ollama --version is x.xx.xx**



1. **Pull the requested models**

Type the following commands into the console:

```bash
 ollama pull smollm2:1.7b
 ollama pull deepseek-r1:14b
 ollama pull gpt-oss:20b

 ```

 **Note** Each download can take several minutes. Keep the console open until all pulls complete.

1. **List installed models**

Type the following commands into the console:

```bash
 ollama list
```

You should see all three models with the **latest** digest.

---

## Task 3 - Compare Model Quality with Prompt Pack

Use the console  to run these prompts against each model. The goal is to spot differences across the models.

 ```bash
 ollama run smollm2:1.7b "Explain the concept of vector databases to a new data engineer in under three sentences."
 ```
 ```bash
 ollama run deepseek-r1:14b "Write a Python function that generates a haiku using a small in-memory word list."
 ```
 ```bash
 ollama run gpt-oss:20b "Reason through this riddle: You see me once in a year, twice in a week, and never in a day. What am I?"`
```

Pay attention to latency, depth of reasoning, and hallucination risk for each model. Experiment with your own prompts as well!
| Prompt | What to Look For |
| --- | --- |
| Explain the concept of vector databases to a new data engineer in under three sentences. | Clarity + factual accuracy |
| Write a Python function that generates a haiku using a small in-memory word list. | Code correctness + creativity |
| Reason through this riddle: You see me once in a year, twice in a week, and never in a day. What am I? | Chain-of-thought reasoning |

---

## Task 4 - Explore the Ollama REST API

**Goal:** Interact with the Ollama server remotely using typical dev tooling.

### 4.1 Set the container app endpoint as an environment variable

1. **Get your container app URL**
   - In the Azure Portal, select **Overview** in the left-hand navigation blade.
   - Use the copy icon to the right of the **Application URL** to copy the Application URL to the clipboard.

2. **Set the environment variable**
   - Open VS Code on the lab host.
   - Open the WSL terminal.
   - Run the following command, replacing `<Your Container App URL>` with the URL you copied:

    ```bash
    export OLLAMA_URL="<Your Container App URL>"
    ```

3. **Verify the variable is set**

    ```bash
    echo $OLLAMA_URL
    ```

   You should see your container app URL displayed.

### 4.2 List installed models

Run the following command in the WSL terminal:

```bash
curl -s $OLLAMA_URL/api/tags | jq
```
This will display all models currently available on your Ollama server.

### 4.3 Generate text via streaming inference
Run the following command to test text generation:

- **Using curl:**

  ```bash
  curl -N $OLLAMA_URL/api/generate \
  -H "Content-Type: application/json" \
  -d '{"model":"smollm2:1.7b","prompt":"Explain the concept of vector databases."}'
  ```
You'll see the response stream in real-time as the model generates text.


### 4.4 Show model metadata (pick any deployed model)

- **Using curl:**

  ```bash
  curl $OLLAMA_URL/api/show \
  -H "Content-Type: application/json" \
  -d '{"model":"gpt-oss:20b"}'
  ```

- **Using wget:**

  ```bash
  wget -qO- --method=POST --header="Content-Type: application/json" \
  --body-data='{"model":"smollm2:1.7b"}' \
  $OLLAMA_URL/api/show    
  ```

Both commands will return detailed metadata about the specified model, including its parameters, architecture, and system requirements.

> Tip: For production deployments, you can deploy your inferencing server applications (in this case the Ollama app) in a virtual network integrated environment or behind private endpoints. This ensures your data is secure which is particularly important if you have trained your own models with sensitive information.

---

## Persist models and reduce cold starts in production

Serverless scaling in Azure Container Apps are great as they can autoscale into zero. However, the storage isn't persisted which means you have to redownload models after each scale-to-zero event which can cause significant coldstart. Below, are patterns we see customers adopt to improve their cold start times in production. These are also our recommendations.

1. Add an [Azure Files volume mount](https://learn.microsoft.com/azure/container-apps/storage-mounts-azure-files?tabs=bash) to your Azure Container App - By adding a volume mount, your models can be stored persistently, preventing the need to redownload them after scaling to zero. Instead, models are loaded from the mounted volume, significantly reducing cold start times. For an Ollama contianer image, you would mount the volume at `/var/lib/ollama`.
1. Customers also will set cron scalars and other scalars to ensure that the GPUs are pre-warmed prior to expected traffic spikes.
1. Use Azure Container Registry artifact streaming to enable your container to startup faster by streaming layers on demand.
1. Set a minimum replica count during business hours - By configuring your Container App to maintain at least one running replica during peak usage times, you can ensure that the application is always ready to handle requests without the latency associated with cold starts.

---

## Wrap-Up

- ✅ Ollama now runs inside your GPU-backed Container App with external ingress
- ✅ Required models are pre-pulled and ready for inference testing
- ✅ Prompt pack highlights capability differences across 1.7B, 14B, and 20B parameter models
- ✅ You called the Ollama REST API using multiple tools

## Additional resources

- [Gpt-oss on Azure Container Apps](https://techcommunity.microsoft.com/blog/appsonazureblog/open-ais-gpt-oss-models-on-azure-container-apps-serverless-gpus/4440836)
- [Deepseek-r1 on Azure Container Apps](https://techcommunity.microsoft.com/blog/appsonazureblog/deepseek-r1-on-azure-container-apps-serverless-gpus/4371463)