# Segment 2 — LangChain + Azure Container Apps Dynamic Sessions

## Title
Build a LangChain Agent with Azure Container Apps Dynamic Sessions (Code Interpreter)

---

## Lab Overview
In this part, you will:
- Provision an Azure Container Apps **Dynamic Session Pool** for Python code execution.
- Connect the pool to a **LangChain agent** via the **langchain-azure-dynamic-sessions** package.
- Expose a **FastAPI web API** with endpoints for natural language queries and file analysis.
- Validate with tasks: math calculation, plotting, and CSV summarization.

---

## Estimated Duration
45 minutes

---

## Lab Tasks

### Task 1 — Set up Azure Resources

**Description:** In this task, you'll provision the Azure infrastructure needed for the lab, including a resource group and an Azure Container Apps Dynamic Session Pool that will execute Python code in secure, isolated containers.

1. **Sign in to Azure:**
   
   This command authenticates you with your Azure subscription. Follow the prompts to complete authentication.
   ```bash
   az login
   ```

2. **Create a resource group:**
   
   Set up environment variables for your subscription ID, resource group name, and location. The resource group will contain all the resources for this lab.
   ```bash
   export SUB=$(az account show --query id -o tsv)
   export RG="aca-langchain-rg-${USER}-$RANDOM"
   export LOC=westus2
   az group create -n $RG -l $LOC
   ```

3. **Create a session pool:**
   
   This creates an Azure Container Apps Dynamic Session Pool with Python runtime. The pool provides secure, isolated environments for executing untrusted code with pre-installed data science libraries (pandas, matplotlib, etc.). The `--network-status EgressDisabled` flag prevents outbound network access for additional security.
   ```bash
   export POOL="aca-langchain-py-${USER}-$RANDOM"
   az containerapp sessionpool create \
     --name $POOL \
     --resource-group $RG \
     --location $LOC \
     --container-type PythonLTS \
     --max-sessions 50 \
     --cooldown-period 300 \
     --network-status EgressDisabled
   ```

4. **Retrieve the pool management endpoint:**
   
   This endpoint URL is required to connect your LangChain application to the session pool. Note that it uses the subscription ID in the path.
   ```bash
   export POOL_MGMT=$(az containerapp sessionpool show \
     --name $POOL --resource-group $RG \
     --query 'properties.poolManagementEndpoint' -o tsv | tr -d '\r')
   echo $POOL_MGMT
   ```

# - NOT NEEDED?  5. **Retrieve the session pool resource ID:**
   
  You'll need this full resource ID for role assignments in the next step.
   ```bash
   export POOL_ID=$(az containerapp sessionpool show \
     --name $POOL --resource-group $RG \
     --query id --output tsv | tr -d '\r')
   echo $POOL_ID
   ```

6. **Get your user principal name:**
   
   This retrieves your Azure AD user identity, which you'll need for role assignments.   

   ```bash
   export USER_PRINCIPAL_NAME=$(az ad signed-in-user show --query userPrincipalName -o tsv | tr -d '\r' )
   export USER_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv | tr -d '\r')
   echo "User Principal Name: $USER_PRINCIPAL_NAME"
   echo "Object ID: $USER_OBJECT_ID"
   ```
   
   Note your User PrincipalName from the output (e.g., `user_domain.com#EXT#@tenant.onmicrosoft.com`) 

7. **Assign Azure ContainerApps Session Executor role:**
   
   This role grants permission to create and execute code in the session pool. 

   ```bash
   az role assignment create \
     --role "Azure ContainerApps Session Executor" \
     --assignee "$USER_PRINCIPAL_NAME" \
     --scope $POOL_ID
   ```

8. **Assign Contributor role:**
   
   This role provides additional permissions to manage the session pool resource. Replace `<YOUR_USER_PRINCIPAL_NAME>` with your user principal name.
   ```bash
   az role assignment create \
     --role "Contributor" \
     --assignee "$USER_PRINCIPAL_NAME" \
     --scope $POOL_ID
   ```

9. **Create Azure OpenAI account:**
   
   This creates an Azure OpenAI resource in your resource group. The custom domain must be globally unique, so we'll use a combination of your username and a random number.
   ```bash
   export OPENAI_NAME="openai-aca-${USER}-$RANDOM"
   export OPENAI_DOMAIN="openai-aca-${USER}-$RANDOM"
   
   az cognitiveservices account create \
     --name $OPENAI_NAME \
     --resource-group $RG \
     --location $LOC \
     --kind OpenAI \
     --sku s0 \
     --custom-domain $OPENAI_DOMAIN
   
   echo "Azure OpenAI account created: $OPENAI_NAME"
   ```

10. **Deploy GPT-3.5 Turbo model:**
    
    This deploys the GPT-3.5 Turbo model to your Azure OpenAI account. This model will be used by your LangChain agent for natural language processing.
    ```bash
    export DEPLOYMENT_NAME="gpt-35-turbo"
    
    az cognitiveservices account deployment create \
      --resource-group $RG \
      --name $OPENAI_NAME \
      --deployment-name $DEPLOYMENT_NAME \
      --model-name gpt-35-turbo \
      --model-version "1106" \
      --model-format OpenAI \
      --sku-capacity "30" \
      --sku-name "Standard"
    
    echo "Model deployment created: $DEPLOYMENT_NAME"
    ```

11. **Retrieve your Azure OpenAI endpoint:**
    
    This endpoint URL will be used to connect your application to Azure OpenAI.
    ```bash
    export OPENAI_ENDPOINT=$(az cognitiveservices account show \
      --name $OPENAI_NAME \
      --resource-group $RG \
      --query properties.endpoint --output tsv)
    echo $OPENAI_ENDPOINT
    ```
    
    The endpoint will be in the format: `https://<your-custom-domain>.openai.azure.com/`

12. **Retrieve your Azure OpenAI account resource ID:**
   
   You'll need this to assign permissions to access the Azure OpenAI service.
   ```bash
   export OPENAI_ID=$(az cognitiveservices account show \
     --name $OPENAI_NAME \
     --resource-group $RG \
     --query id --output tsv)
   echo $OPENAI_ID
   ```

13. **Assign Cognitive Services OpenAI User role:**
    
    This role grants permission to make API calls to your Azure OpenAI resource.
    ```bash
    az role assignment create \
      --role "Cognitive Services OpenAI User" \
      --assignee "$USER_PRINCIPAL_NAME" \
      --scope $OPENAI_ID
    ```

---

### Task 2 — Open Reference Samples

**Description:** The official Azure Container Apps Dynamic Sessions sample repository is already pre-loade don this machine, which contains reference implementations and examples you can use as guidance for your implementation.

1. **Open the samples repository:**
   
   This repository contains example applications demonstrating various patterns for using Azure Container Apps Dynamic Sessions with different frameworks.
   ```bash
   git clone https://github.com/Azure-Samples/container-apps-dynamic-sessions-samples
   ```

---

### Task 3 — Build the Application

**Description:** In this task, you'll create a Python application that integrates LangChain with Azure Container Apps Dynamic Sessions. The application uses FastAPI to expose REST endpoints that allow natural language queries to be processed by an AI agent with code execution capabilities.

1. **Create project folder and virtual environment:**
   
   Set up an isolated Python environment for the project to manage dependencies cleanly.
   ```bash
   mkdir aca-langchain-lab && cd $_
   python -m venv .venv
   source .venv/bin/activate   # Windows: .venv\Scripts\activate
   ```

2. **Install required dependencies:**
   
   Install the necessary Python packages:
   - `fastapi` and `uvicorn`: Web framework and server
   - `langchain` and `langchain-openai`: LangChain framework and OpenAI integration
   - `langchain-azure-dynamic-sessions`: Azure Container Apps Dynamic Sessions integration for LangChain
   - `pydantic`: Data validation
   - `python-multipart`: For file uploads
   ```bash
   pip install -U fastapi uvicorn langchain langchain-openai \
     langchain-azure-dynamic-sessions pydantic python-multipart
   ```

3. **Export environment variables:**
   
   Configure the application with your session pool endpoint and Azure OpenAI settings. The session pool endpoint and OpenAI endpoint were retrieved in Task 1. Replace `<your-deployment-name>` with the name of your deployed model (e.g., `gpt-35-turbo`).
   ```bash
   export DS_POOL_ENDPOINT="$POOL_MGMT"
   export AZURE_OPENAI_ENDPOINT="$OPENAI_ENDPOINT"
   export AZURE_OPENAI_DEPLOYMENT_NAME="<your-deployment-name>"
   export AZURE_OPENAI_API_VERSION="2024-02-15-preview"
   ```

4. **Create `app.py` (FastAPI + LangChain integration):**
   
   Create the main application file that defines the FastAPI endpoints and integrates the LangChain agent with the Azure Dynamic Sessions code execution tool. The application will expose endpoints for natural language queries and file analysis.
   
   _(Note: Refer to the sample code provided or the cloned repository for the complete implementation)_

5. **Run the application locally:**
   
   Start the FastAPI development server. The `--reload` flag enables automatic reloading when code changes are detected.
   ```bash
   uvicorn app:app --reload --port 8000
   ```
   
   You should see output indicating the server is running at `http://127.0.0.1:8000`.

---

### Task 4 — Validate the API

**Description:** This task verifies that your LangChain agent can successfully execute Python code in the Azure Dynamic Sessions pool. You'll test three scenarios: mathematical calculations, data visualization, and CSV file analysis.

1. **Math calculation test:**
   
   Test the agent's ability to execute Python code for mathematical operations. This query asks the agent to use Python to calculate the mean of a list of numbers. The agent should recognize it needs to use the code execution tool and return the computed result.
   ```bash
   curl -s http://localhost:8000/ask \
     -H "Content-Type: application/json" \
     -d '{"input":"Compute the mean of [1,2,3,100] using Python in the tool"}'
   ```
   
   Expected result: The agent should return approximately 26.5 as the mean value.

2. **Data visualization test:**
   
   Test the agent's ability to generate plots and analyze visualizations. This query requires the agent to use matplotlib to create a plot and analyze the results.
   ```bash
   curl -s http://localhost:8000/ask \
     -H "Content-Type: application/json" \
     -d '{"input":"Plot sin(x) from -1 to 1 and report the peak value."}'
   ```
   
   Expected result: The agent should create a sine wave plot and report that the peak value is 1.0 (at x ≈ π/2 ≈ 1.57, but since the range is -1 to 1, it should note the function is increasing throughout).

3. **CSV file analysis test:**
   
   Test the agent's ability to analyze uploaded CSV files. Replace `/path/to/file.csv` with the path to an actual CSV file. The agent will load the file and provide a summary using pandas.
   ```bash
   curl -s -F "file=@/path/to/file.csv" \
     http://localhost:8000/summarize-csv
   ```
   
   Expected result: The agent should return statistical summaries and insights about the CSV data, such as column names, data types, row counts, and basic statistics.

4. **Test in your browser (optional):**
   
   You can also navigate to `http://localhost:8000/docs` to access the automatically generated FastAPI interactive documentation, where you can test the endpoints using a web interface.

---

## Troubleshooting

### Common Issues and Solutions

- **Verify preprequisites**

- Active Azure subscription  
- Azure CLI with Container Apps extension
- Check to see if the extension is installed:
(`az extension show --name containerapp`)  
- If its not installed, installi it via this command:
(`az extension add --name containerapp --upgrade --allow-preview true -y`)  
- Python 3.10+ and Git installed locally  - type `python3`
- Azure OpenAI resource with a deployed model (e.g., gpt-35-turbo or gpt-4)

- **Sample source code is not located at documents/ACASamples**
  - **Cause:** For some reason the sample code was not automatically cloned into your local lab environment 
  - **Solution:** Clone the repo manually
        
        ```bash
        git clone https://github.com/Azure-Samples/container-apps-dynamic-sessions-samples
        ```

- **403 Unauthorized / Permission Denied**
  - **Cause:** Your user identity lacks the required permissions to execute code in the session pool or access Azure OpenAI.
  - **Solution:** Ensure you've assigned the following roles as shown in Task 1:
    - `Azure ContainerApps Session Executor` (step 7)
    - `Contributor` (step 8)
    - `Cognitive Services OpenAI User` (step 10)
  - It may take a few minutes for role assignments to propagate.
  - **Verification:** Run these commands to confirm your role assignments:
    ```bash
    az role assignment list --scope $POOL_ID
    az role assignment list --scope $OPENAI_ID
    ```

- **Missing CLI command / "containerapp: command not found"**
  - **Cause:** The Azure Container Apps CLI extension is not installed or is outdated.
  - **Solution:** Install or upgrade the extension:
    ```bash
    az extension remove --name containerapp
    az extension add --name containerapp --upgrade --allow-preview true -y
    ```

- **Missing or invalid pool endpoint**
  - **Cause:** The pool management endpoint was not properly retrieved or saved.
  - **Solution:** Re-run the session pool show command:
    ```bash
    az containerapp sessionpool show --name $POOL --resource-group $RG \
      --query 'properties.poolManagementEndpoint' -o tsv
    ```

- **Connection timeout or "Failed to connect to session pool"**
  - **Cause:** Network connectivity issues or the session pool hasn't finished provisioning.
  - **Solution:** 
    1. Verify the pool status: `az containerapp sessionpool show --name $POOL --resource-group $RG`
    2. Check that `provisioningState` is `Succeeded`
    3. Wait a few minutes if the pool was just created

- **"No module named 'langchain_azure_dynamic_sessions'"**
  - **Cause:** The required Python package is not installed or the virtual environment is not activated.
  - **Solution:** 
    1. Activate your virtual environment: `source .venv/bin/activate`
    2. Reinstall dependencies: `pip install -U langchain-azure-dynamic-sessions`

- **Azure OpenAI API errors**
  - **Cause:** Invalid or missing Azure OpenAI configuration, or the deployment doesn't exist.
  - **Solution:** Verify your environment variables are set correctly:
    ```bash
    echo $DS_POOL_ENDPOINT
    echo $AZURE_OPENAI_ENDPOINT
    echo $AZURE_OPENAI_DEPLOYMENT_NAME
    echo $AZURE_OPENAI_API_VERSION
    ```
  - Verify your deployment exists:
    ```bash
    az cognitiveservices account deployment list \
      --name <YOUR_OPENAI_ACCOUNT_NAME> \
      --resource-group $RG \
      --query "[].name" -o tsv
    ```
  - Ensure you have the `Cognitive Services OpenAI User` role assigned (Task 1, step 10).

---
