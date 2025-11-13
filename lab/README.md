# Lab: AI-Ready Apps - Containerize and Modernize with Azure

## 🎯 Lab Overview

Welcome to the hands-on lab for **AI-Ready Apps: Containerize and Modernize with Azure**! 

In this lab, you'll build and deploy an AI-powered Python application using Azure Container Apps Dynamic Sessions and Azure OpenAI. You'll learn how to safely execute untrusted code in isolated environments while leveraging the power of large language models (LLMs) through LangChain.

### Learning Objectives

By the end of this lab, you will be able to:

- ✅ Create and configure Azure OpenAI resources with GPT-3.5 Turbo models
- ✅ Set up Azure Container Apps Dynamic Session Pools for secure code execution
- ✅ Build a LangChain-powered application that combines AI with code execution
- ✅ Configure proper RBAC (Role-Based Access Control) for Azure resources
- ✅ Deploy and test containerized AI applications
- ✅ Understand security best practices for dynamic code execution

### What is Azure Container Apps Dynamic Sessions?

Azure Container Apps Dynamic Sessions provides secure, isolated Python environments where you can execute untrusted code safely. This is perfect for:

- 🔒 Running AI-generated code in sandboxed environments
- 🧪 Building interactive coding tutorials and learning platforms
- 🤖 Creating AI agents that can write and execute code
- 📊 Data analysis applications that process user-submitted code

## 📋 Prerequisites

### Azure Requirements

- Active Azure subscription with the following permissions:
  - Create resource groups and resources
  - Assign roles (Contributor, Azure Container Apps Session Executor, Cognitive Services OpenAI User)
- Azure OpenAI access (approved subscription)
  - If you don't have access, apply at: https://aka.ms/oai/access
- Registered resource providers:
  - Microsoft.App
  - Microsoft.CognitiveServices
  - Microsoft.OperationalInsights

### Local Development Environment

- **Operating System**: Windows with WSL2, Linux, or macOS
- **Tools**:
  - Azure CLI 2.50.0 or later
  - Python 3.12+
  - Git
  - VS Code (recommended) or preferred IDE
- **Skills**:
  - Basic Python knowledge
  - Familiarity with Azure CLI
  - Understanding of REST APIs

### Pre-Lab Setup

Before starting the lab, complete these setup steps:

1. **Install Azure CLI**
   ```bash
   # Follow instructions at: https://learn.microsoft.com/cli/azure/install-azure-cli
   az --version
   ```

2. **Login to Azure**
   ```bash
   az login
   az account show
   ```

3. **Register Resource Providers** (one-time per subscription)
   ```bash
   az provider register --namespace Microsoft.CognitiveServices --wait
   az provider register --namespace Microsoft.App --wait
   az provider register --namespace Microsoft.OperationalInsights --wait
   ```

4. **Install Python Dependencies**
   ```bash
   sudo apt update
   sudo apt install -y python3-pip python3-venv python3-dev build-essential
   ```

5. **Fix Line Endings** (for WSL users)
   ```bash
   sudo apt install dos2unix
   ```

## 🗂️ Lab Structure

The lab is organized into the following segments:

### [`instructions/`](instructions/) - Step-by-Step Guides

- **welcome-screen.md** - Lab introduction and overview
- **skillable_langchain_aca_lab_1.md** - Main lab instructions
- **segment0-ai-gpu-playbook.md** - AI and GPU background
- **segment3-ollama.md** - Local LLM setup with Ollama
- **segment4-mcp-shell.md** - MCP Shell integration
- **segment5-goose-agent.md** - Goose AI agent setup

### Key Files

- **lab-script.md** - Complete lab walkthrough script
- **concat_lab_segments.sh** - Script to combine lab segments

## 🚀 Lab Exercises

### Exercise 1: Environment Setup (15 minutes)

Set up your Azure environment and development tools:

1. Create resource group
2. Set environment variables
3. Configure Azure CLI

**Region Note**: Use `eastus` region for this lab as it has Azure OpenAI availability.

### Exercise 2: Deploy Azure OpenAI (20 minutes)

Create and configure Azure OpenAI resources:

1. Create Azure OpenAI account
2. Deploy GPT-3.5 Turbo model (version 0125)
3. Configure API endpoints
4. Assign Cognitive Services OpenAI User role

**Important**: Model version `0125` is confirmed to work in `eastus` region.

### Exercise 3: Azure Container Apps Dynamic Sessions (25 minutes)

Set up secure session pools for code execution:

1. Create Container Apps session pool
2. Configure Python LTS container type
3. Set network isolation (EgressDisabled)
4. Assign required roles:
   - Azure Container Apps Session Executor
   - Contributor

### Exercise 4: Build LangChain Application (30 minutes)

Develop an AI-powered application with code execution:

1. Clone sample repository
2. Install dependencies (LangChain, FastAPI, Azure SDKs)
3. Configure environment variables
4. Implement LangChain agents with Azure OpenAI
5. Test code execution in dynamic sessions

### Exercise 5: Deploy and Test (20 minutes)

Deploy your application and verify functionality:

1. Run FastAPI application locally
2. Test API endpoints
3. Verify code execution in sessions
4. Review security and isolation
5. Monitor application logs

## 🔧 Configuration Guide

### Required Environment Variables

Set these variables for the lab:

```bash
# User Information
export USER_PRINCIPAL_NAME=$(az ad signed-in-user show --query userPrincipalName -o tsv | tr -d '\r')
export USER_OBJECT_ID=$(az ad signed-in-user show --query id -o tsv | tr -d '\r')

# Azure Resources
export RG="aca-langchain-rg-${USER}-$RANDOM"
export LOC="eastus"
export POOL="aca-langchain-py-${USER}-$RANDOM"
export OPENAI_NAME="openai-aca-${USER}-$RANDOM"
export OPENAI_DOMAIN="openai-aca-${USER}-$RANDOM"
export DEPLOYMENT_NAME="gpt-35-turbo"

# Generated after resource creation
export POOL_ID=$(az containerapp sessionpool show --name $POOL --resource-group $RG --query id -o tsv | tr -d '\r')
export POOL_MGMT=$(az containerapp sessionpool show --name $POOL --resource-group $RG --query 'properties.poolManagementEndpoint' -o tsv | tr -d '\r')
export OPENAI_ID=$(az cognitiveservices account show --name $OPENAI_NAME --resource-group $RG --query id -o tsv | tr -d '\r')
export OPENAI_ENDPOINT=$(az cognitiveservices account show --name $OPENAI_NAME --resource-group $RG --query 'properties.endpoint' -o tsv | tr -d '\r')

# Application Configuration
export DS_POOL_ENDPOINT="$POOL_MGMT"
export AZURE_OPENAI_ENDPOINT="$OPENAI_ENDPOINT"
export AZURE_OPENAI_DEPLOYMENT_NAME="gpt-35-turbo"
export AZURE_OPENAI_API_VERSION="2024-02-15-preview"
```

### Role Assignments

You'll need to assign these roles during the lab:

1. **Azure Container Apps Session Executor** (on Session Pool)
   - Grants permission to execute code in dynamic sessions

2. **Contributor** (on Session Pool)
   - Grants permission to manage the session pool resource

3. **Cognitive Services OpenAI User** (on Azure OpenAI)
   - Grants permission to call Azure OpenAI APIs

**PowerShell Scripts Provided:**
- `AssignContainerAppsRole.ps1` - Assigns session pool roles via GUI
- `AssignCognitiveServicesUserRole.ps1` - Assigns OpenAI role via GUI

### Verification Commands

Check your role assignments:

```bash
# Verify Session Pool roles
az role assignment list \
  --assignee "$USER_PRINCIPAL_NAME" \
  --scope "$POOL_ID" \
  -o table

# Verify Azure OpenAI role
az role assignment list \
  --assignee "$USER_PRINCIPAL_NAME" \
  --scope "$OPENAI_ID" \
  -o table
```

## 🐛 Troubleshooting

### Common Issues

**Issue**: Line ending errors (`/usr/bin/env: 'bash\r': No such file or directory`)
```bash
# Fix with dos2unix
dos2unix concat_lab_segments.sh
# Or with sed
sed -i 's/\r$//' concat_lab_segments.sh
```

**Issue**: Azure OpenAI quota error (`SpecialFeatureOrQuotaIdRequired`)
- **Solution**: Your subscription needs Azure OpenAI access approval
- Apply at: https://aka.ms/oai/access

**Issue**: Model deployment error (`InvalidResourceProperties`)
- **Solution**: Use GPT-3.5 Turbo version `0125` in `eastus` region
- Verified working configuration in lab

**Issue**: Python venv not found (`python3.12-venv not available`)
```bash
# Install generic Python venv
sudo apt install python3-venv python3-pip
```

**Issue**: Role assignment fails (`BadRequest` or `Forbidden`)
- **Solution**: Verify you're using the Pool ID (resource path), not Pool Management Endpoint (URL)
- Use: `/subscriptions/.../providers/Microsoft.App/sessionPools/...`
- Not: `https://...dynamicsessions.io/...`

### Getting Help

- Check Azure resource status in Azure Portal
- Review application logs with `az containerapp logs`
- Verify environment variables are set correctly
- Ensure all resource providers are registered

## 📚 Additional Resources

### Azure Documentation

- [Azure Container Apps Overview](https://learn.microsoft.com/azure/container-apps/overview)
- [Dynamic Sessions Documentation](https://learn.microsoft.com/azure/container-apps/sessions)
- [Azure OpenAI Service](https://learn.microsoft.com/azure/cognitive-services/openai/)
- [Azure RBAC](https://learn.microsoft.com/azure/role-based-access-control/)

### Sample Code & Tutorials

- [Container Apps Dynamic Sessions Samples](https://github.com/Azure-Samples/container-apps-dynamic-sessions-samples)
- [LangChain Python Documentation](https://python.langchain.com/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)

### Tools & SDKs

- [Azure CLI Reference](https://learn.microsoft.com/cli/azure/)
- [Azure SDK for Python](https://learn.microsoft.com/python/azure/)
- [LangChain Azure Integration](https://python.langchain.com/docs/integrations/platforms/microsoft)

## 🎓 Lab Completion

Upon completing this lab, you will have:

- ✅ Deployed a fully functional AI-powered application on Azure
- ✅ Implemented secure code execution using dynamic sessions
- ✅ Integrated Azure OpenAI with LangChain
- ✅ Configured proper security and RBAC
- ✅ Gained hands-on experience with cloud-native AI applications

### Clean Up Resources

After completing the lab, clean up to avoid charges:

```bash
# Delete the resource group and all resources
az group delete --name $RG --yes --no-wait

# Verify deletion
az group list --query "[?name=='$RG']" -o table
```

## 🤝 Feedback

We value your feedback! Please share your experience with this lab to help us improve.

---

**Ready to start?** Open [`instructions/skillable_langchain_aca_lab_1.md`](instructions/skillable_langchain_aca_lab_1.md) to begin the lab!

**Microsoft Ignite 2025** | Session PREL15
