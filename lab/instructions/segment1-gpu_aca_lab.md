# Segment 1 - AI Image Generation with Serverless GPUs on Azure Container Apps

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
45-60  minutes

---

## Lab Tasks

### Task 1 - Create GPU-Enabled Container App via Azure Portal

**Description:** In this task, you'll use the Azure Portal to create a new Container Apps environment and deploy a GPU-enabled AI image generation application. You'll configure the app to use serverless GPUs and expose it to the internet.

1. **Open a browser and sign in to Azure:**
   
   - Open your browser and go to the Azure Portal: `https://portal.azure.com`
   - Follow the instructions for signing in.  
   - For credentials, Use the **User Name** and **TAP** from the **Azure Portal** section of the **Resources** tab above.
   

2. **Start creating a new Container App:**
   
   - Once signed in to azure.portal.com, type `Container App` In the search bar at the top.
   - Select **Container App** from the results
   - - Click **Create** button
   - Then select **Container App**
   
   This will open the Container App creation wizard.

3. **Configure Basic settings:**
   
   In the **Basics** tab, enter the following values:
   
   **Project details:**
   - **Subscription:** Select your Azure subscription
   - **Resource group:** Click **Create new resource group** and enter `my-gpu-demo-group`
   - **Container app name:** Enter `my-gpu-demo-app`
  
   - **Deployment source:** Select **Container image**
   
   **Container Apps environment:**
   - **Region:** Select **West US 3**
     
     **Note:** West US 3 is preallocated with GPU availability for this lab. Other supported regions include Sweden Central and Australia East, East US 2, and North Central US.
   
   - **Container Apps environment:** - keep the default
   
   - Click **Next: Container >** to continue

4. **Configure Container settings:**
   
   In the **Container** tab, enter the following values:
   
   - Choose **Use Quickstart Image**
   - Select **GPU Hello World Container** from the drop-down list
      
   **Workload profile and GPU configuration:**
   - Note that these items are enabled with the quickstart image:
    - **Workload profile:** Select **Consumption - Up to 4 vCPUs, 8 GiB memory**
    - **GPU:** Check the **Enable GPU** checkbox
    - **GPU Type:** Select **Consumption-GPU-NC8as-T4 - Up to 8 vCPUs, 56 GiB memory**

   
   The **Consumption-GPU-NC8as-T4** profile provides:
   - Up to 8 vCPUs
   - 56 GiB memory
   - 1x NVIDIA T4 GPU (16GB GPU memory)
   
   - Click **Review + create**

5. **Review and create:**
   
   - Review all your settings on the summary page
   - Ensure all configurations are correct:
     - Resource group: **my-gpu-demo-group**
     - Container app name: **my-gpu-demo-app**
     - Region: West US 3
     - Image: **mcr.microsoft.com/k8se/gpu-quickstart:latest**
     - GPU enabled with Consumption-GPU-NC8as-T4 profile
     - Ingress enabled on port 80
   - Click **Create**
   - There may be a pause as Azure reviews the setup and starts the deployment

6. **Wait for deployment:**
   
   The deployment process will begin. This typically takes 3-5 minutes to complete.
   
   - You'll be forwarded automatically to a **Deployment is in Progress** screen.
   - Wait for the notification **"Deployment is complete"**
   - Click **Go to resource** to view your deployed container app

9. **Open the application in your browser:**
   
   Once on the Container App overview page:
   - Locate the **Application URL** in the Essentials section at the top right
   - Click on this URL to go open the application
---

### Task 2 - Test the GPU Image Generation Application

**Description:** Now that your GPU-enabled container app is deployed, you'll test its image generation capabilities through the web interface. The application uses AI models running on the GPU to generate images from text prompts.

2. **Generate your first image:**
   
   If the app is not open already, click on the **Application URL** from the last step
   - **Note:** The application may take a minute or two to load the first time before displaying in the browser.  You can check the status of the application via the **Running Status** indicator in the **Revisions and Replicas** blade of your container app in the Azure portal. The status should be either **Activating** or **Running**.
   
   Use the web interface to generate an image:
   - Enter a text prompt in the input field (e.g., "A futuristic city at sunset with flying cars")
   - Click the **Generate** button
   - Wait for the GPU to process your request and generate the image
   
   **Note:** The first request may take 60-90 seconds due to GPU cold start. Subsequent requests will be much faster.  The image generation typically takes 5-15 seconds once the GPU is warm.
   
   **What's happening:** The AI model is using the NVIDIA T4 GPU to process your text prompt and generate an image using diffusion models.

3. **Test with different prompts:**
   
   Try various prompts to see the AI's capabilities:
   - "A serene mountain landscape with a lake reflection"
   - "A robot playing chess in a library"
   - "An astronaut riding a horse on Mars"
   - "A steampunk coffee shop in the clouds"
   
   Notice how response times improve after the first generation due to GPU warmup and model caching.

---

### Task 3 - Keep One Replica Warm (Reduce Cold Start)

Azure Container Apps serverless GPUs automatically scale your application to zero when idle to save costs. Scaling back out from zero triggers a GPU cold start: provisioning the container, initializing drivers, and loading model assets adding cold start time to the first request. To ensure the lab completes without waiting on cold starts, you'll configure a minimum replica of 1 so one GPU instance stays warm during the exercise. We'll discuss cold start improvement strategies later in the lab.

1. **Open Scale settings:**
   - In the left menu under **Application**, select **Scale**.

2. **Set replica counts:**
   - **Min replicas:** `1`
   - Select **Save as a new revision**.

3. **Confirm running replica:**
   - Go to **Revisions and replicas**.
   - Ensure the latest revision shows **Running** with at least one replica.

**Result:** A single GPU-backed container remains online, eliminating cold start delays for subsequent image generations during the lab.

> [!Note] Setting **Min replicas = 1** keeps a GPU instance allocated at all times which is great for eliminating cold starts, but it incurs continuous GPU charges. This is fine for the lab, but is important to keep in mind when doing your own development.

---

### Task 4 - Monitor GPU Performance

**Description:** Azure Container Apps provides tools to monitor your GPU utilization and performance. In this task, you'll use the console to access your running container and check GPU metrics using NVIDIA's monitoring tools.

1. **Access the container console via Azure Portal:**
   
   - Navigate to the Azure Portal: `https://portal.azure.com`
   - Go to your container app: **Resource Groups** → **my-gpu-demo-group** → **my-gpu-demo-app**
   - In the left menu, under **Monitoring**, select **Console**
   - For the console, choose **App Container**
   - If not displayed by default:
       - Select your active **replica** from the dropdown
       - Select your **container** (**my-gpu-demo-container**)
       - Click **Reconnect** if needed

2. **Connect to the container shell:**
   
   - In the **Choose startup command** dialog, select `/bin/bash`
   - Click **Connect**
   - Wait for the shell prompt to appear. This is the Container App Console, which is useful for troubleshooting your application inside a container. 
   - Enter the following command to check NVIDIA GPU status including utilization, memory usage, and running processes: `nvidia-smi`
   - Now enter, `nslookup ollama.com`. Since we're in the container app console, you should see nslookup fail as the container doesn't have access to network access tools.

3. **Check out the Debug Console**
   We'll now explore the debug console which helps you troubleshoot when you can't connect to the target container and comes pre-installed with a number of tools such as network connectivity tools. These can be used to verify connectivity to your AI model endpoints if you run into issues pulling models or calling APIs from within your container app.
   - At the top of the page, choose **Debug** and repeat steps 1 and 2 from Task 4.
   - Now enter, `nslookup ollama.com` – verifies DNS name resolution to ollama.com

---

## Troubleshooting

### Common Issues and Solutions

- **"Workload profile not found" or GPU option not available**
   - **Cause:** GPU workload profiles are not available in your selected region, or GPU quota hasn't been approved.
   - **Solution:**
      1. Ensure you're using West US 3.

- **Very slow first image generation (2+ minutes)**
   - **Cause:** This is expected as the app hasn't been optimized for cold start yet. The GPU, drivers, and AI model all need to initialize.
   - **Solution:**
      1. For production, enable minimum replicas (see Task 3).
      2. Implement artifact streaming to reduce image pull time.
      3. Consider using warm-up requests after deployment.
      4. Wait 60-90 seconds for the first generation—subsequent ones will be much faster.

- **"Failed to pull image" error**
   - **Cause:** Network connectivity issues or incorrect image name.
   - **Solution:**
      1. Verify the image name is exactly: `mcr.microsoft.com/k8se/gpu-quickstart:latest`.
      2. In the Portal, go to your container app → **Revision management** → select your revision.
      3. Check **Logs** in the Monitoring section for detailed error messages.
      4. If the issue persists, try recreating the container app with the correct image details.

- **Application is running but images aren't generating**
   - **Cause:** The GPU may not be properly allocated or the model failed to load.
   - **Solution:**
      1. Connect to the console (Task 3) and run `nvidia-smi` to verify GPU is accessible.
      2. In the Portal, navigate to **Monitoring** → **Log stream** to check application logs for errors.
      3. Check **Metrics** to see if replicas are running.
      4. Try restarting: Go to **Revision management** → click the **...** menu → **Restart**.

- **"Cannot access container console" error**
   - **Cause:** The replica may not be running or console access is temporarily unavailable.
   - **Solution:**
      1. In the Portal, go to **Revision management** and verify the revision status is "Running".
      2. Check that at least one replica is active under **Replicas**.
      3. Wait a moment and try refreshing the Console page.
      4. If the issue persists, try the **Log stream** option instead under **Monitoring**.

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

