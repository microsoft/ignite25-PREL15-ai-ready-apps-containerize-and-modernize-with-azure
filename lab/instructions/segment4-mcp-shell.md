# Segment 4 — Use an MCP server with shell dynamic sessions in Azure Container Apps (45 minutes)

> Audience: platform and infra engineers who will provision and operate shell based session pools using MCP to enable agents and tools to connect and run shell commands remotely.

## Overview
This segment walks through creating a Shell container type Session Pool with the MCP Server enabled, retrieving the MCP endpoint and API key, and exercising the MCP JSON-RPC tools to launch and run remote shells.

Estimated duration: 45 minutes

---

## Learning Objectives
- Deploy a Shell session pool ARM template (2025-02-02-preview API)
- Retrieve the MCP server endpoint and API key using `az rest`
- Initialize the MCP server and launch a remote shell environment via JSON-RPC
- Run commands in the remote shell and fetch results



## Login to Azure
Open VS Code and use the wsl terminal for the folllowing commands.

If you are not logged into Azure already, run the following command to login. Use the credentials from the Resources tab in the lab to login.

```azure cli
az login
```

---

## 1. Set Up Environment Variables

Start by opening **Visual Studio Code** from your desktop and navigating to the terminal at the bottom of the window.

Click on the down arrow next to the **+** button and select **Git Bash**. This will open a bash terminal that we'll use to create our resources.

In your terminal, set the following environment variables for your subscription, resource group, session pool name, and location to be used for creating resources.

First, query for your Azure subscription ID and set the value to a variable:

```sh
export SUBSCRIPTION_ID=$(az account show --query id --output tsv | tr -d '\r')
```

Set the variables used in this procedure.

```sh
export RESOURCE_GROUP=my-shell-session-rg
export SESSION_POOL_NAME=myshellpool
export LOCATION=westus3
```

You'll use these variables to create the resources in the following steps.

Next, create a resource group:

```sh
az group create --name $RESOURCE_GROUP --location $LOCATION
```

> Note: If creating the resource group fails, run `az login` and use the credentials in the Resources tab of the lab.

---

## 2. Create a shell session pool with an MCP server endpoint (ARM template)
In this step you'll use the ARM template below to create a shell session pool resource with MCP server enabled.

- In Visual Studio Code, check for a file called deploy.json.  
- If It's there, verify that it matches the file below.  
- Otherwise, click on New File in the Start menu and create a new file named `deploy.json` . Once created, copy the following contents into the file and save it.

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
                "containerType": "Shell",
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
                    "isMCPServerEnabled": true
                }
            }
        }
    ]
}
```

After the file is saved you can go back to the terminal and navigate to the file path where you saved the json file. Then run the following command to deploy the ARM template to your existing resource group:

```azurecli
az deployment group create --resource-group $RESOURCE_GROUP --template-file deploy.json --name $SESSION_POOL_NAME --parameters name=$SESSION_POOL_NAME location=$LOCATION
```

---

## 3. Retrieve the MCP Server Endpoint
After the resource is created, obtain the MCP endpoint using `az rest` against the session pool ARM resource (2025-02-02-preview API). Example:

```bash
export MCP_ENDPOINT=$(az rest --method GET --uri "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.App/sessionPools/$SESSION_POOL_NAME?api-version=2025-02-02-preview" --query "properties.mcpServerSettings.mcpServerEndpoint" -o tsv | tr -d '\r')
echo $MCP_ENDPOINT
```

This will query the MCP server endpoint and store it in the `MCP_ENDPOINT` environment variable.

---

## 4. Fetch an API Key (MCP credentials)
To interact with the MCP server, request credentials by calling the `fetchMCPServerCredentials` action on the session pool resource:

```bash
export API_KEY=$(az rest --method POST --uri "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.App/sessionPools/$SESSION_POOL_NAME/fetchMCPServerCredentials?api-version=2025-02-02-preview" --query "apiKey" -o tsv | tr -d '\r')
echo $API_KEY
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

## 6. Set Environment variables

Run the following commands in the VS Code wsl terminal:

```bash
export ENVIRONMENT_RESPONSE=$(curl -sS -X POST "$MCP_ENDPOINT" \
  -H "Content-Type: application/json" \
  -H "x-ms-apikey: $API_KEY" \
  -d '{ "jsonrpc": "2.0", "id": "2", "method": "tools/call", "params": { "name": "launchShellEnvironment", "arguments": {} } }')
echo $ENVIRONMENT_RESPONSE
```

View the output from the previous commands, extract/copy the `environmentId` from the response and set it as an environment variable:

```bash
export ENVIRONMENT_ID="<paste-your-environment-id-here>"
echo $ENVIRONMENT_ID
```

---

## 7. Run Commands in the Remote Shell
Run commands in your remote shell environment. :

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
        "environmentId": "$ENVIRONMENT_ID",
        "shellCommand": "echo Hello from Azure Container Apps shell dynamic session!"
      }
    }
  }'
```

You should see output that includes the command results in the `stdout` field.

Output:
```json
{"jsonrpc":"2.0","id":"3","result":{"content":[{"type":"text","text":"stdout: Hello from Azure Container Apps Shell Session!\n\nstderr: "}],"structuredContent":{"stdout":"Hello from Azure Container Apps Shell Session!\n","stderr":""}}}
```

---

## 8. Practical Exercises (optional)
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
