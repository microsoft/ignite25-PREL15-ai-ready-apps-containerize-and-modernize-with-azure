# Segment 4 — MCP Shell Session Pool (45 minutes)

> Audience: platform and infra engineers who will provision and operate Shell-based MCP session pools for interactive labs and remote shells.

## Overview
This segment walks through creating a Shell-type Session Pool with the MCP Server enabled, retrieving the MCP endpoint and API key, and exercising the MCP JSON-RPC tools to launch and run remote shells.

Estimated duration: 45 minutes

---

## Learning Objectives
- Enable required AFEC flags for MCP Shell session pools
- Deploy a Shell session pool ARM template (2025-02-02-preview API)
- Retrieve the MCP server endpoint and API key using `az rest`
- Initialize the MCP server and launch a remote shell environment via JSON-RPC
- Run commands in the remote shell and fetch results

---

## Prerequisites
- Azure CLI installed and logged in
- Owner or Contributor rights on the chosen subscription (to set AFEC flags and create resources)
- Familiarity with ARM deployments and basic Azure CLI usage

---

## 1. Enable AFEC Flags (high-level)
These flags must be set by the ACA team for the subscription (share with platform team):
- `Microsoft.App/SessionPoolsSupportShell`
- `Microsoft.App/SessionPoolsSupportMCP`
- For EUAP-specific workloads, ensure `Microsoft.Resources/EUAPParticipation` is enabled

Note: AFEC flags are managed by Microsoft platform teams—if you don't control them, file a request with the platform team including the subscription ID and the flags listed above.

---

## 2. Create a Shell Session Pool (ARM template)
Use the ARM template below with API version `2025-02-02-preview`. Customize `name` and `location` parameters.

Save this payload as `sessionpool-template.json` and deploy with:

```bash
az deployment group create \
  --resource-group <rg-name> \
  --template-file sessionpool-template.json \
  --parameters name=<pool-name> location=<region>
```

sessionpool-template.json (excerpt):

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
        "dynamicPoolConfiguration": {
          "lifecycleConfiguration": { "lifecycleType": "Timed", "coolDownPeriodInSeconds": 300 }
        },
        "sessionNetworkConfiguration": { "status": "EgressEnabled" },
        "mcpServerSettings": { "isMCPServerEnabled": true }
      }
    }
  ]
}
```

---

## 3. Retrieve the MCP Server Endpoint
After the resource is created, obtain the MCP endpoint using `az rest` against the session pool ARM resource (2025-02-02-preview API). Example:

```bash
az rest --method GET \
  --uri "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.App/sessionPools/<poolName>?api-version=2025-02-02-preview"
```

Look for `properties.mcpServerEndpoint` in the JSON response; that is your MCP base URL.

---

## 4. Fetch an API Key (MCP credentials)
To interact with the MCP server, request credentials by calling the `fetchMCPServerCredentials` action on the session pool resource:

```bash
az rest --method POST \
  --uri "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.App/sessionPools/<poolName>/fetchMCPServerCredentials?api-version=2025-02-02-preview"
```

The response includes an `apiKey` value. Store this in an environment variable for subsequent calls.

---

## 5. Initialize the MCP Server (JSON-RPC)
Use the MCP endpoint and API key to initialize a session. Example environment setup:

```bash
export MCP_URL="https://<region>.dynamicsessions.io/subscriptions/<sub>/resourceGroups/<rg>/sessionPools/<poolName>/mcp"
export API_KEY="<apiKey_from_previous_step>"
```

Initialize:

```bash
curl -sS -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "x-ms-apikey: $API_KEY" \
  -d '{ "jsonrpc": "2.0", "id": "1", "method": "initialize" }'
```

A successful response will include `protocolVersion` and `serverInfo`.

---

## 6. Launch a Shell Environment
Call the `tools/call` method to launch a shell environment. The response includes an `environmentId` you must use for further shell actions:

```bash
curl -sS -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "x-ms-apikey: $API_KEY" \
  -d '{ "jsonrpc": "2.0", "id": "2", "method": "tools/call", "params": { "name": "launchShell", "arguments": {} } }'
```

Store the returned `environmentId`:

```bash
export ENV_ID="<environmentId>"
```

---

## 7. Run Commands in the Remote Shell
Use `runShellCommandInRemoteEnvironment` for all remote shell operations. The `command` parameter is an array of arguments (e.g., `["ls","-la"]`). Example:

```bash
curl -sS -X POST "$MCP_URL" \
  -H "Content-Type: application/json" \
  -H "x-ms-apikey: $API_KEY" \
  -d "{ \"jsonrpc\": \"2.0\", \"id\": \"3\", \"method\": \"tools/call\", \"params\": { \"name\": \"runShellCommandInRemoteEnvironment\", \"arguments\": { \"environmentId\": \"${ENV_ID}\", \"command\": [\"echo\", \"hello-from-mcp\"] } } }"
```

The response includes `stdout` and `stderr` fields with the command output.

---

## 8. Practical Exercises (optional)
- Install a small toolset in the shell (e.g., `jq`, `git`) and verify installations
- Create a file in the remote shell and read it back using the RPC method
- Run a short script and capture its output

---

## 9. Cleanup
When finished, delete the session pool resource group to avoid lingering costs:

```bash
az group delete --name <rg> --no-wait --yes
```

---

## References
- MCP JSON-RPC examples (see lab template)
- Azure ARM reference for `Microsoft.App/sessionPools` (2025-02-02-preview)
