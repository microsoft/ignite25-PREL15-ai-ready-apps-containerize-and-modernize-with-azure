# Segment 4 — Use an MCP server with shell dynamic sessions in Azure Container Apps (45 minutes)

> Audience: platform and infra engineers who will provision and operate shell based session pools using MCP to enable agents and tools to connect and run shell commands remotely.

## Overview
This segment walks through creating a Shell-type Session Pool with the MCP Server enabled, retrieving the MCP endpoint and API key, and exercising the MCP JSON-RPC tools to launch and run remote shells.

Estimated duration: 45 minutes

---

## Learning Objectives
- Deploy a Shell session pool ARM template (2025-02-02-preview API)
- Retrieve the MCP server endpoint and API key using `az rest`
- Initialize the MCP server and launch a remote shell environment via JSON-RPC
- Run commands in the remote shell and fetch results

---

## Prerequisites
- Azure CLI installed and logged in
- Familiarity with ARM deployments and basic Azure CLI usage

---

## 1. Install Azure Container Apps CLI Extension

Open a local terminal and install the latest version of the Azure Container Apps CLI extension:

```azurecli
az extension add --name containerapp --allow-preview true --upgrade
```

---

## 2. Set Up Environment Variables

In your terminal, set the following environment variables for your subscription, resource group, session pool name, and location to be used for creating resources.

Query for your Azure subscription ID and set the value to a variable:

```sh
SUBSCRIPTION_ID=$(az account show --query id --output tsv)
```

Set the variables used in this procedure. Replace the placeholders surrounded by `<>` with your own values:

```sh
RESOURCE_GROUP=<RESOURCE_GROUP_NAME>
SESSION_POOL_NAME=<SESSION_POOL_NAME>
LOCATION=<LOCATION>
```

You use these variables to create the resources in the following steps.

Set the subscription you want to use for creating the resource group:

```sh
az account set -s $SUBSCRIPTION_ID
```

Create a resource group:

```sh
az group create --name $RESOURCE_GROUP --location $LOCATION
```
---

## 2. Create a shell session pool with an MCP server endpoint (ARM template)
Use the ARM template below to create a shell session pool with MCP server enabled.

Open a text editor and create a deployment template file named `deploy.json` and copy the following content into it:

```json
{
    "$schema": "http://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "name": { "type": "String" },
        "location": { "type": "String" }
    },
    "resources": [
        {
            "type": "Microsoft.App/sessionPools",
            "apiVersion": "2025-02-02-preview",
            "name": "[parameters('name')]",
            "location": "[parameters('location')]",
            "properties": {
                "poolManagementType": "Dynamic",
                "containerType": "Shell", // Set the "containerType" property to "Shell"
                "scaleConfiguration": {
                    "maxConcurrentSessions": 5
                },
                "sessionNetworkConfiguration": {
                    "status": "EgressEnabled"
                },
                "dynamicPoolConfiguration": {
                    "lifecycleConfiguration": {
                        "lifecycleType": "Timed",
                        "coolDownPeriodInSeconds": 300
                    }
                },
                "mcpServerSettings": { 
                    "isMCPServerEnabled": true // Add the "mcpServerSettings" section to enable the MCP server
                }
            }
        }
    ]
}
```

Save the file and close the editor.

In your terminal, navigate to where you saved the json file and run the following command to deploy the ARM template:

```azurecli
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file deploy.json \
  --name $SESSION_POOL_NAME \
  --location $LOCATION
```

---

## 3. Retrieve the MCP Server Endpoint
After the resource is created, obtain the MCP endpoint using `az rest` against the session pool ARM resource (2025-02-02-preview API). Example:

```bash
MCP_ENDPOINT=$(az rest --method GET --uri "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.App/sessionPools/$SESSION_POOL_NAME?api-version=2025-02-02-preview" --query "properties.mcpServerSettings.mcpServerEndpoint" -o tsv)
```

This will query the MCP server endpoint and store it in the `MCP_ENDPOINT` environment variable.

---

## 4. Fetch an API Key (MCP credentials)
To interact with the MCP server, request credentials by calling the `fetchMCPServerCredentials` action on the session pool resource:

```bash
API_KEY=$(az rest --method POST --uri "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.App/sessionPools/$SESSION_POOL_NAME/fetchMCPServerCredentials?api-version=2025-02-02-preview" --query "apiKey" -o tsv)
```

The response includes an `apiKey` value that will be stored in the `API_KEY` environment variable.

---

## 5. Initialize the MCP Server (JSON-RPC)

Initialize the MCP server connection using JSON-RPC. Run the following `curl` command, `$MCP_ENDPOINT` and `$API_KEY` will be referenced as values obtained in previous steps:

```bash
curl -sS -X POST "$MCP_ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "x-ms-apikey: $API_KEY" \
  -d '{ "jsonrpc": "2.0", "id": "1", "method": "initialize" }'
```

A successful response will include `protocolVersion` and `serverInfo`.

---

## 6. Launch a Shell Environment
Call the `tools/call` method to launch a shell environment. The response includes an `environmentId` you must use for further shell actions. Run the following command:

```bash
ENVIRONMENT_RESPONSE=$(curl -sS -X POST "$MCP_ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "x-ms-apikey: $API_KEY" \
  -d '{ "jsonrpc": "2.0", "id": "2", "method": "tools/call", "params": { "name": "launchShell", "arguments": {} } }')

echo $ENVIRONMENT_RESPONSE
```

Extract the `environmentId` from the response for use in subsequent commands.

---

## 7. Run Commands in the Remote Shell
Run commands in your remote shell environment. Replace `<ENVIRONMENT_ID>` with the ID returned from the previous step:

```bash
curl -sS -X POST "$MCP_ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "x-ms-apikey: $API_KEY" \
  -d '{
    "jsonrpc": "2.0",
    "id": "3",
    "method": "tools/call",
    "params": {
      "name": "runShellCommandInRemoteEnvironment",
      "arguments": {
        "environmentId": "<ENVIRONMENT_ID>",
        "shellCommand": "echo Hello from Azure Container Apps shell dynamic session!"
      }
    }
  }'
```

You should see output that includes the command results in the `stdout` field.

---

## 8. Practical Exercises (optional)
- Install a small toolset in the shell (e.g., `jq`, `git`) and verify installations
- Create a file in the remote shell and read it back using the RPC method
- Run a short script and capture its output

---

## 9. Cleanup
When finished, delete the session pool resource group to avoid lingering costs:

```bash
az group delete --name $RESOURCE_GROUP --no-wait --yes
```

---

## References
- MCP JSON-RPC examples (see lab template)
- Azure ARM reference for `Microsoft.App/sessionPools` (2025-02-02-preview)
