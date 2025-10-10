# Segment 1 — AI Image Generation with Serverless GPUs on Azure Container Apps

## Title
Deploy an AI Image Generation App Using Serverless GPUs in Azure Container Apps

---

## Overview
In this part, you will:
- Provision an Azure Container Apps environment with **serverless GPU support**
- Deploy a pre-built AI image generation application using the **GPU quickstart container image**
- Configure **ingress** to expose the application to the internet
- Test the GPU-powered image generation capabilities
- Monitor GPU utilization and performance
- Learn best practices for optimizing GPU cold start times

**Note:** GPU quota and Azure subscription access have been pre-configured for this Skillable lab environment.

---

## Estimated Duration
45 minutes

---

## Lab Tasks

### Task 1 — Create GPU-Enabled Container App via Azure Portal

**Description:** In this task, you'll use the Azure Portal to create a new Container Apps environment and deploy a GPU-enabled AI image generation application. You'll configure the app to use serverless GPUs and expose it to the internet.

1. **Navigate to Azure Container Apps:**
   
   - Open your browser and go to the Azure Portal: https://portal.azure.com
   - In the search bar at the top, type **Container Apps**
   - Select **Container Apps** from the results

2. **Start creating a new Container App:**
   
   - Click **+ Create** button
   - Then select **Container App**
   
   This will open the Container App creation wizard.

3. **Configure Basic settings:**
   
   In the **Basics** tab, enter the following values:
   
   **Project details:**
   - **Subscription:** Select your Azure subscription
   - **Resource group:** Click **Create new** and enter `my-gpu-demo-group`
   - **Container app name:** Enter `my-gpu-demo-app`
  
   - **Deployment source:** Select **Container image**
   
   **Container Apps environment:**
   - **Region:** Select **Sweden Central**
     
     **Note:** Sweden Central is recommended for GPU availability. Other supported regions include Australia East, East US 2, North Central US, and West US 3.
   
   - **Container Apps environment:** Click **Create new environment**

4. **Create the Container Apps environment:**
   
   In the **Create Container Apps environment** dialog:
   - **Environment name:** Enter `my-gpu-demo-env`
   - Click **Create**
   
   This creates a new environment that will host your GPU-enabled container app.
   
   - Click **Next: Container >** to continue

5. **Configure Container settings:**
   
   In the **Container** tab, enter the following values:
   
   - Choose **Use Quickstart Image**
   - Select **GPU Hello World Container** from the drop-down list
      
   **Workload profile and GPU configuration:**
   - Note that these items are enabled with the quickstart image:
    - **Workload profile:** Select **Consumption - Up to 4 vCPUs, 8 GiB memory**
    - **GPU:** Check the **Enable GPU** checkbox
    - **GPU Type:** Select **Consumption-GPU-NC8as-T4 - Up to 8 vCPUs, 56 GiB memory**

   
   The `Consumption-GPU-NC8as-T4` profile provides:
   - Up to 8 vCPUs
   - 56 GiB memory
   - 1x NVIDIA T4 GPU (16GB GPU memory)
   
   - Click **Review + create**

7. **Review and create:**
   
   - Review all your settings on the summary page
   - Ensure all configurations are correct:
     - Resource group: `my-gpu-demo-group`
     - Container app name: `my-gpu-demo-app`
     - Region: Sweden Central
     - Image: `mcr.microsoft.com/k8se/gpu-quickstart:latest`
     - GPU enabled with Consumption-GPU-NC8as-T4 profile
     - Ingress enabled on port 80
   - Click **Create**

8. **Wait for deployment:**
   
   The deployment process will begin. This typically takes 3-5 minutes to complete.
   
   - Wait for the notification **"Deployment is complete"**
   - Click **Go to resource** to view your deployed container app

9. **Retrieve the application URL:**
   
   Once on the Container App overview page:
   - Locate the **Application URL** in the Essentials section at the top
   - Copy this URL - you'll use it in the next task to test the application
   
   The URL will be in the format: `https://my-gpu-demo-app.[unique-id].[region].azurecontainerapps.io`

---

### Task 2 — Test the GPU Image Generation Application

**Description:** Now that your GPU-enabled container app is deployed, you'll test its image generation capabilities through the web interface. The application uses AI models running on the GPU to generate images from text prompts.

1. **Open the application in your browser:**
   
   Using the Application URL you copied from the previous task, open it in a new browser tab.
   
   The URL format is: `https://my-gpu-demo-app.[unique-id].[region].azurecontainerapps.io`
   
   You should see a web interface for the AI image generation application.
   
   **Note:** The first request may take 60-90 seconds due to GPU cold start. Subsequent requests will be much faster.

2. **Generate your first image:**
   
   Use the web interface to generate an image:
   - Enter a text prompt in the input field (e.g., "A futuristic city at sunset with flying cars")
   - Click the **Generate** button
   - Wait for the GPU to process your request and generate the image
   
   The image generation typically takes 5-15 seconds once the GPU is warm.
   
   **What's happening:** The AI model is using the NVIDIA T4 GPU to process your text prompt and generate an image using diffusion models.

3. **Test with different prompts:**
   
   Try various prompts to see the AI's capabilities:
   - "A serene mountain landscape with a lake reflection"
   - "A robot playing chess in a library"
   - "An astronaut riding a horse on Mars"
   - "A steampunk coffee shop in the clouds"
   
   Notice how response times improve after the first generation due to GPU warmup and model caching.

---

### Task 3 — Monitor GPU Performance

**Description:** Azure Container Apps provides tools to monitor your GPU utilization and performance. In this task, you'll use the console to access your running container and check GPU metrics using NVIDIA's monitoring tools.

1. **Access the container console via Azure Portal:**
   
   - Navigate to the Azure Portal: https://portal.azure.com
   - Go to your container app: **Resource Groups** → `my-gpu-demo-group` → `my-gpu-demo-app`
   - In the left menu, under **Monitoring**, select **Console**
   - Select your active **replica** from the dropdown
   - Select your **container** (`my-gpu-demo-container`)
   - Click **Reconnect** if needed

2. **Connect to the container shell:**
   
   - In the **Choose startup command** dialog, select `/bin/bash`
   - Click **Connect**
   - Wait for the shell prompt to appear

### Task 4 — Optimize GPU Cold Start (Advanced)

**Description:** GPU cold start (the time it takes for the first request after idle) can be significant. In this task, you'll learn about strategies to improve cold start performance for production applications using the Azure Portal.

1. **Navigate to Scale and Replicas settings:**
   
   - In the Azure Portal, go to your container app: `my-gpu-demo-app`
   - In the left menu, under **Application**, select **Scale**

2. **Enable minimum replicas (reduce cold start):**
   
   Configure your app to always keep at least one replica running. This eliminates cold starts but incurs continuous costs.
   
   - Under **Scale**, set:
     - **Min replicas:** `1`
     - **Max replicas:** `3`
   - Click **Save**
   
   **Note:** With minimum replicas set to 1, at least one instance with GPU will always be running, eliminating cold starts but increasing costs.

3. **Configure HTTP scaling rules:**
   
   Increase up HTTP-based scaling to handle varying loads:
   
   - In the **Scale** tab, scroll to **Scale rule**
      - Edit:
     - **Rule name:** `http-scaler`
     - **Type:** `HTTP scaling`
     - **Concurrent requests:** `100`
   - Click **Add Scale Rule** to deploy the revision
   
   This scales your app based on concurrent HTTP requests, allowing it to handle traffic spikes while scaling down during low usage (but never below 1 replica).

3. **Review cold start optimization best practices:**
   
   Additional strategies to consider for production:
   - **Artifact streaming**: Reduces container image pull time (covered in Microsoft docs)
   - **Model preloading**: Ensure your AI model is loaded into GPU memory on startup
   - **Warm-up requests**: Send a dummy request after deployment to initialize the GPU
   - **Horizontal scaling**: Use multiple replicas to distribute load
   
   For detailed guidance, see: https://learn.microsoft.com/en-us/azure/container-apps/gpu-serverless-overview#improve-gpu-cold-start

4. **Test improved response times:**
   
   With minimum replicas enabled, generate a new image and notice the faster response time compared to your initial test.

---

## Troubleshooting

### Common Issues and Solutions

- **"Workload profile not found" or GPU option not available**
  - **Cause:** GPU workload profiles are not available in your selected region, or GPU quota hasn't been approved.
  - **Solution:** 
    1. Ensure you're using a supported region: Sweden Central, East US 2, North Central US, or West US 3
    2. Verify the GPU checkbox is available in the Container creation wizard
    3. If GPU options don't appear, the quota may not be approved for your subscription (should be pre-configured in Skillable)

- **Very slow first image generation (2+ minutes)**
  - **Cause:** This is expected GPU cold start behavior. The GPU, drivers, and AI model all need to initialize.
  - **Solution:** 
    1. For production, enable minimum replicas (see Task 7)
    2. Implement artifact streaming to reduce image pull time
    3. Consider using warm-up requests after deployment
    4. Wait 60-90 seconds for the first generation - subsequent ones will be much faster

- **"Failed to pull image" error**
  - **Cause:** Network connectivity issues or incorrect image name.
  - **Solution:** 
    1. Verify the image name is exactly: `mcr.microsoft.com/k8se/gpu-quickstart:latest`
    2. In the Portal, go to your container app → **Revision management** → select your revision
    3. Check **Logs** in the Monitoring section for detailed error messages
    4. If the issue persists, try recreating the container app with the correct image details

- **Application is running but images aren't generating**
  - **Cause:** The GPU may not be properly allocated or the model failed to load.
  - **Solution:** 
    1. Connect to the console (Task 3) and run `nvidia-smi` to verify GPU is accessible
    2. In the Portal, navigate to **Monitoring** → **Log stream** to check application logs for errors
    3. Check **Metrics** to see if replicas are running
    4. Try restarting: Go to **Revision management** → click the **...** menu → **Restart**

- **"Cannot access container console" error**
  - **Cause:** The replica may not be running or console access is temporarily unavailable.
  - **Solution:** 
    1. In the Portal, go to **Revision management** and verify the revision status is "Running"
    2. Check that at least one replica is active under **Replicas**
    3. Wait a moment and try refreshing the Console page
    4. If the issue persists, try the **Log stream** option instead under **Monitoring**

- **High costs / unexpected billing**
  - **Cause:** Minimum replicas are enabled (from Task 4), keeping GPU resources running continuously.
  - **Solution:** 
    1. In the Portal, go to **Scale and replicas**
    2. Edit your revision and change **Min replicas** to `0` to allow scaling to zero
    3. Deploy the change
    4. Always delete the resource group when done with the lab to stop all charges

---

## Advanced Exercises (Optional)

### Exercise 1: Deploy Your Own AI Model
Modify the deployment to use a different AI model or create your own container image with a custom model.

### Exercise 2: Add Authentication
Secure your image generation API using Azure Container Apps built-in authentication with Microsoft Entra ID.

### Exercise 3: Implement Caching
Add a caching layer (e.g., Azure Redis) to cache generated images and reduce GPU usage for repeated prompts.

### Exercise 4: Multi-Region Deployment
Deploy the same application to multiple regions with GPU support and use Azure Front Door for global load balancing.

---

## Key Takeaways

✅ **Serverless GPUs** in Azure Container Apps provide on-demand GPU compute without infrastructure management

✅ **Cold start optimization** is critical for production applications - use minimum replicas and artifact streaming

✅ **Cost management** is important - GPU resources are expensive, so scale to zero when not in use

✅ **nvidia-smi** is your primary tool for monitoring GPU utilization and troubleshooting

✅ **Multiple GPU regions** are available - choose based on latency and availability requirements

---

## Additional Resources

- [Azure Container Apps GPU Documentation](https://learn.microsoft.com/en-us/azure/container-apps/gpu-serverless-overview)
- [Improve GPU Cold Start Performance](https://learn.microsoft.com/en-us/azure/container-apps/gpu-serverless-overview#improve-gpu-cold-start)
- [Azure Container Apps Pricing](https://azure.microsoft.com/en-us/pricing/details/container-apps/)
- [NVIDIA GPU Monitoring Guide](https://developer.nvidia.com/nvidia-system-management-interface)
- [Azure Container Apps Best Practices](https://learn.microsoft.com/en-us/azure/container-apps/best-practices)

---

