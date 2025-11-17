
# Segment 3 - LangChain + Azure Container Apps Dynamic Sessions

## Title
Build a LangChain Agent with Azure Container Apps Dynamic Sessions (Code Interpreter)

---

## Lab Overview

In this part, you will:
- Use a pre-provisioned Azure Container Apps **Dynamic Session Pool** for Python code execution in a code interpreter.
- Connect the pool to a **LangChain agent** via the **langchain-azure-dynamic-sessions** package.
- Expose a **FastAPI web API** with endpoints for natural language queries and file analysis.
- Validate with tasks: math calculation, plotting, and CSV summarization.

### What is LangChain?

**LangChain** is a powerful framework for building applications powered by large language models (LLMs). It provides a standardized interface for connecting LLMs with external tools, data sources, and APIs. In this lab, LangChain acts as the orchestration layer that:
- Connects Azure OpenAI's GPT models with the Azure Container Apps Dynamic Sessions code execution environment
- Manages the conversation flow between user queries and code interpreters
- Handles tool selection and parameter passing automatically
- Provides built-in retry logic, error handling, and response parsing

> [!Note] LangChain is the focus for this section of the lab, but the same patterns apply to other agents. Microsoft's newly released [Microsoft Agent Framework](https://learn.microsoft.com/agent-framework/overview/agent-framework-overview) is a great alternative, and you'll experiment with [Goose](https://github.com/block/goose) later in the lab as well.

### What are Code Interpreters?

**Code interpreters** are secure, isolated environments that allow AI agents to write and execute code dynamically in response to user queries. Unlike traditional chatbots that can only generate text responses, code interpreters enable AI systems to perform actual computations, analyze data, create visualizations, and manipulate files in real-time. This capability transforms AI agents from conversational tools into powerful problem-solving assistants that can handle complex mathematical calculations, data analysis tasks, and generate visual outputs like charts and graphs. Azure Container Apps Dynamic Sessions provides enterprise-grade code interpreter functionality with built-in security, scalability, and integration with popular AI frameworks like LangChain.

By using LangChain with code interpreters, you can build sophisticated AI agents that reason about when to execute code, what code to write, and how to interpret the results-all with minimal custom code.

---

## Estimated Duration
45 minutes

---

## Lab Tasks

### Task 1 - Authenticate with Azure

---

#### Step 1: Sign in to Azure

Open VS Code and authenticate with your Azure subscription using the Azure CLI.  Use the wsl terminal and type:

```bash
az login
```
- Follow the instructions for signing in.  
- If credentials are requested, open the **Resources** tab above and use the credentials from the **Azure Portal** section.

---

#### Step 2: Verify your Azure subscription

Confirm you're using the correct Azure subscription for this lab.

```bash
az account show
```

**Expected output:** You should see your subscription ID, name, and tenant information. Verify this matches the subscription provided for the lab environment.

---

### Task 2 - Set Up the Application Environment

**Description:** In this task, you'll use a pre-provisioned sample application directory and Python virtual environment, with pre-installed dependencies. 


---

#### Step 3: Navigate to the sample application directory

Change to the directory containing the LangChain Python web API sample code.

```bash
cd container-apps-dynamic-sessions-samples/langchain-python-webapi
```

**What this does:** The sample code has been pre-cloned into your lab environment at this location. This directory contains:
- **main.py** - The FastAPI application with LangChain integration
- **.env.sample** - Sample configuration file with Azure resource endpoints and credentials
- **requirements.txt** - Python package dependencies
- Additional helper modules and documentation

---

---

### Task 3 - Creating and populating the .env file

**Description:** Before running the application, let's understand the key resources that make it work.

---

#### Understanding the **.env** file

The **.env** file contains all the configuration settings needed to connect your application to Azure services. It stores:

- **POOL_MANAGEMENT_ENDPOINT** - The management endpoint for your Azure Container Apps Dynamic Session Pool
- **AZURE_OPENAI_ENDPOINT** - The endpoint URL for your Azure OpenAI service
- **AZURE_OPENAI_DEPLOYMENT** - The name of your deployed GPT model (e.g., **gpt-4o-mini**)
- **AZURE_OPENAI_API_KEY** - The API key to use for Azure OpenAI calls

**Why this is valuable:** 
- Separates configuration from code, making it easy to switch between development, staging, and production environments
- Keeps sensitive information (endpoints and identifiers) out of source code
- Follows the "twelve-factor app" methodology for cloud-native applications
- The **.env** file has been pre-configured with your lab environment's resource endpoints

**Security note:** In production environments, you would use Azure Key Vault or managed identities instead of storing credentials in files.

---

#### Populating the **.env** file

Create a new **.env** file using the VS Code wsl terminal:

 ```bash
 cd container-apps-dynamic-sessions-samples/langchain-python-webapi
 cp .env.sample .env
```

And open the new .env file in the explorer on the left.

1. If you are not already logged in to Azure, **Open a browser and sign in:**
   
   - Open your browser and go to the Azure Portal: `https://portal.azure.com`
   - Follow the instructions for signing in.  
   - For credentials, Use the **User Name** and **TAP** from the **Azure Portal** section of the **Resources** tab above.

Loocate and copy/paste the following variables into your .env file:

2. **Pool Management Endpoint** 
- In the Azure Portal, search for `Container App Session Pool` and click on **Container App Session Pool** .  Open the Container App Session Pool resource displayed, then copy the Pool Management Endpoint displayed on the top right and paste it into the .env file.  

```bash
POOL_MANAGEMENT_ENDPOINT=<Pool Management Endpoint>
```


3. **OpenAI Endpoint and Key**
- In the Azure Portal, search for `Azure OpenAI` and click on **Azure OpenAI** .  Open the Azure OpenAI resource displayed. On the left, go to **Resource Management > Keys and Endpoint**  and copy/paste the following values:

```bash
AZURE_OPENAI_ENDPOINT=<Endpoint>
AZURE_OPENAI_API_KEY=<KEY 1>  
```
4. **Model Name**

-From Keys and Endpoint, click on **Overview** on the top left then click on **Go to Azure AI Foundry Portal** towards the top on the left.   
-If you are asked to log in again, follow the same steps from the previous login process.  
-Once in the foundry, click on **Deployments** on the left, and copy and paste the **Model Name** into the .env file.

```bash
AZURE_OPENAI_DEPLOYMENT=<Model Endpoint>
```

- Once complete, you should have four values in your new .env file.  
- save the .env file

```bash
POOL_MANAGEMENT_ENDPOINT=<Pool Management Endpoint>
AZURE_OPENAI_ENDPOINT=<Endpoint>
AZURE_OPENAI_API_KEY=<KEY 1>  
AZURE_OPENAI_DEPLOYMENT=<Model Endpoint>
```
**Security note:** In production environments, you would use Azure Key Vault or managed identities instead of storing credentials in files.

---

#### Step 4: Review the Python virtual environment

An isolated Python environment has already been created and populated with application dependencies.

**What this is:** A new directory called **venv** contains a complete Python environment. This keeps the lab dependencies separate from your system Python installation, preventing version conflicts.

**Why this is valuable:** Virtual environments are a Python best practice that ensure reproducible builds and prevent dependency conflicts between different projects.

---

#### Step 5: Activate the virtual environment

Activate the virtual environment so that Python commands use the isolated environment.

Make sure that you are in the application directory:

**ACASamples/container-apps-dynamic-sessions-samples/langchain-python-webapi**

```bash
source venv/bin/activate
```

**What this does:** Modifies your shell's PATH to prioritize the virtual environment's Python interpreter and packages. You'll see **(venv)** appear at the beginning of your command prompt.

**Note:** You'll need to run this command again if you open a new terminal session.

---

#### Step 6: Review Installed application dependencies

the command **pip install -r requirements.txt** preinstalled all required Python packages from the requirements file.

**What this did:** Installs the following key packages:
- **fastapi** - Modern web framework for building APIs
- **uvicorn** - ASGI server for running FastAPI applications
- **langchain** & **langchain-openai** - LangChain framework with Azure OpenAI integration
- **langchain-azure-dynamic-sessions** - Integration with Azure Container Apps Dynamic Sessions
- **pydantic** - Data validation and settings management
- **python-multipart** - File upload support for FastAPI

**Note:** Dependencies are preinstalled, as it typically takes 10 minutes or more to download and install all dependencies.


### Task 4 - Run the Application

**Description:** In this task, you'll start the FastAPI application and prepare to test its endpoints.

---

#### Understanding **main.py**

The **main.py** file is the heart of your application. It:

1. **Imports and initializes LangChain components:**
   - Creates an Azure OpenAI chat model instance
   - Initializes the Azure Dynamic Sessions code execution tool
   - Configures a LangChain agent with the code execution capability

2. **Defines FastAPI endpoints:**
   - **/ask** - Accepts natural language queries and routes them to the LangChain agent
   - **/summarize-csv** - Handles CSV file uploads and uses the agent to analyze the data
   - **/health** - Provides a health check endpoint for monitoring

3. **Manages the agent execution flow:**
   - Receives user input
   - Determines if code execution is needed
   - Generates Python code dynamically based on the query
   - Executes code in the secure Azure Container Apps Dynamic Sessions environment
   - Returns results back to the user

**Why this is valuable:**
- Demonstrates how to build production-ready AI agents with proper error handling
- Shows best practices for integrating Azure services with LangChain
- Provides a reusable pattern for building code-execution-powered AI applications
- Exposes a REST API that can be consumed by web frontends, mobile apps, or other services

---

#### Step 7: Start the development server

Launch the FastAPI application with auto-reload enabled.

```bash
uvicorn main:app --reload
```

Once you see this message, the application is running:

**INFO:     Application startup complete.**

**What this does:**
- Starts the FastAPI application defined in **main.py**
- The **--reload** flag watches for file changes and automatically restarts the server
- By default, the server runs on **http://127.0.0.1:8000**

**Expected output:** You should see startup messages indicating the server is running, including:
```bash
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
INFO:     Started reloader process
INFO:     Started server process
INFO:     Waiting for application startup.
INFO:     Application startup complete.
```

**Note:** Keep this terminal window open. The application will continue running and display request logs as you test the endpoints.

---

### Task 5 - Validate the API

**Description:** This task verifies that your LangChain agent can successfully execute Python code in the Azure Dynamic Sessions pool. You'll test three scenarios: mathematical calculations, data visualization, and CSV file analysis.

#### 1. **Test in your browser:**
   
- Navigate to `http://localhost:8000` to access the automatically generated FastAPI interactive documentation, where you can test the endpoints by expanding and using the web interface.


#### 2. **Test using curl:**

- In VS Code, open a new wsl terminal with the **+** symbol above the existing terminal, and paste in the following curl commands 
- After executing curl commands, check back on the original wsl terminal to see the execution and response from the application

1. **Math calculation test:**
   
   Test the agent's ability to execute Python code for mathematical operations. This query asks the agent to use Python to calculate the mean of a list of numbers. The agent should recognize it needs to use the code execution tool and return the computed result.
   ```bash
   curl 'http://localhost:8000/chat?message=Calculate%20the%20mean%20of%201,2,3,100%20using%20Python'
   ```
   
   Expected result: The agent should return approximately 26.5 as the mean value.

2. **Data visualization test:**
   
   Test the agent's ability to generate plots and analyze visualizations. This query requires the agent to use matplotlib to create a plot and analyze the results.
   ```bash
   curl 'http://localhost:8000/chat?message=Plot%20sin(x)%20from%20-1%20to%201%20and%20report%20the%20peak%20value'
   ```
   
   Expected result: Plot sin(x) from -1 to 1 and calculate that the peak value is approximately 0.8415.".

---

## Troubleshooting

### Common Issues and Solutions

- **Verify prerequisites**

- Active Azure subscription  
- Azure CLI with Container Apps extension
- Check to see if the extension is installed:
(`az extension show --name containerapp`)  
- If its not installed, install it via this command:
(`az extension add --name containerapp --upgrade --allow-preview true -y`)  
- Python 3.10+ and Git installed locally  - type `python3`
- Azure OpenAI resource with a deployed model (e.g., gpt-4o-mini)

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
  - **Cause:** Invalid or missing .env file configuration, or the deployment doesn't exist.
  - **Solution:** Verify your environment variables are set correctly in the .env file:
    ```bash
    POOL_MANAGEMENT_ENDPOINT=<Pool Management Endpoint>
    AZURE_OPENAI_ENDPOINT=<Endpoint>
    AZURE_OPENAI_API_KEY=<KEY 1>  
    AZURE_OPENAI_DEPLOYMENT=<Model Endpoint>
    
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

## Bonus Exercise: Complete End-to-End Setup at Home

> **Note:** This lab uses pre-provisioned resources to save time during the session. Use this section to recreate the complete environment from scratch on your own Azure subscription.

This bonus exercise walks you through the complete infrastructure setup, including creating the resource group, session pool, Azure OpenAI service, and all necessary role assignments. This is ideal for practicing at home or deploying to your own environment.

---

### Part 1: Infrastructure Setup

#### Step 1: Authenticate and Set Environment Variables

Sign in to Azure and configure your environment variables for the deployment.

```bash
# Sign in to Azure
az login

# Set environment variables
export SUB=$(az account show --query id -o tsv | tr -d '\r')
export RG="aca-langchain-rg-${USER}-$RANDOM"
export LOC=westus2

echo "Subscription: $SUB"
echo "Resource Group: $RG"
echo "Location: $LOC"
```

#### Step 2: Create Resource Group

Create a resource group to contain all lab resources.

```bash
az group create -n $RG -l $LOC
```

---

### Part 2: Dynamic Session Pool Setup

#### Step 3: Create Azure Container Apps Session Pool

Create a Dynamic Session Pool with Python runtime for secure code execution.

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

echo "Session Pool created: $POOL"
```

**What this does:**
- Creates an isolated Python environment with pre-installed data science libraries (pandas, matplotlib, numpy)
- `--max-sessions 50`: Supports up to 50 concurrent code execution sessions
- `--cooldown-period 300`: Sessions remain available for 5 minutes after use
- `--network-status EgressDisabled`: Blocks outbound internet access for security

#### Step 4: Retrieve Session Pool Endpoints

Get the pool management endpoint and resource ID needed for configuration and role assignments.

```bash
# Get pool management endpoint
export POOL_MGMT=$(az containerapp sessionpool show \
  --name $POOL --resource-group $RG \
  --query 'properties.poolManagementEndpoint' -o tsv | tr -d '\r')
echo "Pool Management Endpoint: $POOL_MGMT"

# Get pool resource ID
export POOL_ID=$(az containerapp sessionpool show \
  --name $POOL --resource-group $RG \
  --query id --output tsv | tr -d '\r')
echo "Pool Resource ID: $POOL_ID"
```

---

### Part 3: User Identity and Permissions

#### Step 5: Retrieve User Identity

Get your Azure AD user information for role assignments.

```bash
export USER_PRINCIPAL_NAME=$(az ad signed-in-user show --query userPrincipalName -o tsv | tr -d '\r')
export USER_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv | tr -d '\r')

echo "User Principal Name: $USER_PRINCIPAL_NAME"
echo "Object ID: $USER_OBJECT_ID"
```

**Note:** Your User Principal Name will look like `user@domain.com` or `user_domain.com#EXT#@tenant.onmicrosoft.com` for external users.

#### Step 6: Assign Session Pool Permissions

Grant yourself permissions to execute code in the session pool.

```bash
# Assign Session Executor role
az role assignment create \
  --role "Azure Container Apps Session Executor" \
  --assignee "$USER_PRINCIPAL_NAME" \
  --scope $POOL_ID

# Assign Contributor role for pool management
az role assignment create \
  --role "Contributor" \
  --assignee "$USER_PRINCIPAL_NAME" \
  --scope $POOL_ID

echo "✓ Session pool permissions assigned"
```

**Roles explained:**
- **Azure Container Apps Session Executor**: Allows creating and executing code in sessions
- **Contributor**: Allows managing the session pool resource

---

### Part 4: Azure OpenAI Setup

#### Step 7: Create Azure OpenAI Resource

Provision an Azure OpenAI account in your resource group.

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

echo "✓ Azure OpenAI account created: $OPENAI_NAME"
```

**Note:** The custom domain must be globally unique, so we append a random number.

#### Step 8: Deploy GPT-3.5 Turbo Model

Deploy the language model that will power your LangChain agent.

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

echo "✓ Model deployment created: $DEPLOYMENT_NAME"
```

**Model details:**
- **Model**: GPT-3.5 Turbo (version 1106)
- **Capacity**: 30K tokens per minute (TPM)
- **SKU**: Standard (pay-as-you-go)

#### Step 9: Retrieve Azure OpenAI Configuration

Get the endpoint and resource ID for connecting your application.

```bash
# Get OpenAI endpoint
export OPENAI_ENDPOINT=$(az cognitiveservices account show \
  --name $OPENAI_NAME \
  --resource-group $RG \
  --query properties.endpoint --output tsv | tr -d '\r')
echo "OpenAI Endpoint: $OPENAI_ENDPOINT"

# Get OpenAI resource ID
export OPENAI_ID=$(az cognitiveservices account show \
  --name $OPENAI_NAME \
  --resource-group $RG \
  --query id --output tsv | tr -d '\r')
echo "OpenAI Resource ID: $OPENAI_ID"
```

The endpoint will be in the format: `https://<your-custom-domain>.openai.azure.com/`

#### Step 10: Assign Azure OpenAI Permissions

Grant yourself permission to call the Azure OpenAI API.

```bash
az role assignment create \
  --role "Cognitive Services OpenAI User" \
  --assignee "$USER_PRINCIPAL_NAME" \
  --scope $OPENAI_ID

echo "✓ Azure OpenAI permissions assigned"
```

**Why this is needed:** This role allows your identity to make API calls to Azure OpenAI without requiring API keys (uses Azure AD authentication instead).

---

### Part 5: Application Development

#### Step 11: Clone Sample Repository

Get reference implementations and examples from the official Microsoft samples.

```bash
cd ~/Documents
git clone https://github.com/Azure-Samples/container-apps-dynamic-sessions-samples
cd container-apps-dynamic-sessions-samples

echo "✓ Sample repository cloned"
```

**Repository contents:**
- Python FastAPI examples
- LangChain integration patterns
- Code execution samples
- MCP server examples

#### Step 12: Create Application Project

Set up your application development environment.

```bash
mkdir ~/Documents/aca-langchain-lab && cd $_
python3 -m venv .venv
source .venv/bin/activate

echo "✓ Project environment created"
```

#### Step 13: Install Dependencies

Install all required Python packages for the application.

```bash
pip install -U \
  fastapi \
  uvicorn \
  langchain \
  langchain-openai \
  langchain-azure-dynamic-sessions \
  pydantic \
  python-multipart

echo "✓ Dependencies installed"
```

**Packages installed:**
- **fastapi** & **uvicorn**: Web framework and ASGI server
- **langchain** & **langchain-openai**: LangChain framework with Azure OpenAI integration
- **langchain-azure-dynamic-sessions**: Azure Container Apps Dynamic Sessions integration
- **pydantic**: Data validation and settings management
- **python-multipart**: File upload support for FastAPI

#### Step 14: Configure Application Environment

Set up environment variables for your application to connect to Azure services.

```bash
export DS_POOL_ENDPOINT="$POOL_MGMT"
export AZURE_OPENAI_ENDPOINT="$OPENAI_ENDPOINT"
export AZURE_OPENAI_DEPLOYMENT_NAME="$DEPLOYMENT_NAME"
export AZURE_OPENAI_API_VERSION="2024-02-15-preview"

# Verify configuration
echo "Session Pool Endpoint: $DS_POOL_ENDPOINT"
echo "Azure OpenAI Endpoint: $AZURE_OPENAI_ENDPOINT"
echo "Deployment Name: $AZURE_OPENAI_DEPLOYMENT_NAME"
```

---

### Part 6: Verification

#### Step 15: Verify Setup

Confirm all resources are properly configured and accessible.

```bash
# Check session pool status
az containerapp sessionpool show --name $POOL --resource-group $RG --query "properties.provisioningState" -o tsv

# Check OpenAI deployment
az cognitiveservices account deployment list \
  --name $OPENAI_NAME \
  --resource-group $RG \
  --query "[].name" -o tsv

# Check role assignments
az role assignment list --scope $POOL_ID --query "[].roleDefinitionName" -o tsv
az role assignment list --scope $OPENAI_ID --query "[].roleDefinitionName" -o tsv

echo "✓ Setup verification complete"
```

**Expected results:**
- Session pool provisioning state: `Succeeded`
- OpenAI deployment shows: `gpt-35-turbo`
- Role assignments include all required roles

---

### Summary

You have now successfully:

✅ Created a resource group and Azure infrastructure  
✅ Deployed an Azure Container Apps Dynamic Session Pool  
✅ Configured Azure OpenAI with GPT-3.5 Turbo  
✅ Assigned all necessary RBAC permissions  
✅ Set up your development environment with required dependencies  
✅ Configured application environment variables  

**Next Steps:** Proceed to implement your FastAPI application following the patterns in the sample repository, or return to the main lab to use the pre-provisioned resources.

---
