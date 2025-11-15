# Segment 5 - Deploy the Goose Open Source Agent on Azure Container Apps (≤60 minutes)

> This segment extends the earlier GPU work by standing up the Goose AI agent stack (auth proxy, Goose web UI/CLI, Ollama-backed model server, optional MCP extensions) using the ready-to-run `goose-on-aca` template. Expect 45-60 minutes depending on whether you enable MCP integrations.

---

## Learning Objectives
- Provision the Goose agent architecture with Azure Developer CLI (`azd`)
- Understand the core services (auth proxy, Goose agent, Ollama GPU server) and how they interconnect
- Configure persistence, authentication, and workload profile settings
- Enable optional MCP extensions (GitHub and Email) and understand their environment variables
- Validate agent functionality via the web UI and CLI, then perform post-deployment maintenance

---

## Prerequisites
- Azure CLI and Azure Developer CLI (`azd`) installed and logged in
- Subscription with `Microsoft.App`, `Microsoft.ContainerRegistry`, and `Microsoft.Storage` providers registered
- GPU workload profile quota available in one of the supported regions (West US 3, Australia East, Sweden Central, or other current GPU regions)
- Ollama running in the same ACA environment (from Segment 2) or another accessible endpoint for model hosting
- Basic auth password you are comfortable sharing with lab participants (prompted during `azd up`)

> 💡 **Time budget**: 10 minutes for repo prep, 15 minutes for deployment, 10 minutes for validation, 15 minutes for MCP integrations, 5 minutes for cleanup/recap.

---

## Task 1 - Prepare the Deployment Workspace (10 minutes)
1. In the wsl terminal in VS Code, change into the goose-on-aca directory:
```bash
cd goose-on-aca
```
2. Review the project structure in the explorer on the left:
   - `azure.yaml` orchestrates Azure resources and application components.
   - `infra/` contains Bicep definitions for Container Apps, storage, and networking.
   - `app/goose/` packages the Goose agent, Nginx auth proxy, and Ollama model puller.
3. Confirm Ollama ingress URL or internal hostname from Segment 2; you will need it when prompted during `azd up`.

---

## Task 2 - Deploy Goose with Azure Developer CLI (15 minutes)
1. Run `azd up` from the repo root:
```bash
azd up
```
2. Login to azd:
```bash
azd auth login
```
3. Supply prompted parameters:

**Note** - If you make any mistakes, start over by typing CTRL+C, then `azd down --purge` then start over with `azd up` 

  - **Environment name** (e.g., `goose-prod`) (press enter)
  - If asked for the **Azure subscription** choose the current subscription. (press enter)
  - if asked for a **Resource Group** - choose 1. add a new group and enter a name (e.g., `goosegroup`) (press enter)
  - If asked for a **location** type `westus3`(press enter)
  - If asked, provide a **Proxy Auth Password** - becomes the basic auth credential for the Nginx gateway. (e.g., `goosepw`)
  - **Note** - please remember the password!
  
3. The deployment provisions:
   - Container Apps environment + GPU workload profile.
   - Azure Container Registry, Storage (Azure Files) for model/config persistence.
   - Goose agent container, auth proxy, and Ollama model puller revision.
4. Expect 15-20 minutes total; the longest step is pulling and loading the default model (qwen3:14b) on the GPU app.

> 🔍 Tip: Monitor progress in the Azure portal under **Container Apps > Revisions and replicas** to see when the Ollama init container finishes pulling the model.

---

## Task 3 - Validate the Deployment (10 minutes)
1. Retrieve outputs:
   ```bash
   azd env get-values
   ```

2. Browse to the Goose portal (`https://<auth-proxy-url>`) and authenticate using basic auth.

- Get the Goose proxy URL, Admin username (`Admin`) and the password you set.

- The URL looks like this onscreen:

(✓) Done: Deploying service nginx-auth-proxy
Endpoint: https://aka.ms/p-roxy-goose-prod....


3. Launch a CLI session from the portal console or via `az containerapp exec`:
   ```bash
   az containerapp exec \
     --name <goose-app-name> \
     --resource-group <resource-group> \
     --command "goose session"
   ```
4. Confirm the default model (qwen3:14b) is running by checking the Ollama service:
   ```bash
   az containerapp exec ... --command "ollama ps"
   ```
   Use `nvidia-smi` to confirm GPU utilization when issuing Goose requests.

---

## Task 4 - (Optional, 15 minutes) Enable MCP Extensions
Goose supports several MCP servers; this template includes GitHub and Email MCP binaries. Enable them by setting the relevant environment variables on the Goose Container App and restarting the revision.

### GitHub MCP Server
```bash
az containerapp update \
  --name <goose-app-name> \
  --resource-group <resource-group> \
  --set-env-vars GITHUB_PERSONAL_ACCESS_TOKEN="ghp_your_token"
```
- Use a low-privilege PAT scoped to the repositories you want the agent to manage.

### Email MCP Server (Gmail example)
```bash
az containerapp update \
  --name <goose-app-name> \
  --resource-group <resource-group> \
  --set-env-vars \
    MCP_EMAIL_SERVER_PASSWORD="your_app_password" \
    MCP_EMAIL_SERVER_EMAIL_ADDRESS="your-email@gmail.com" \
    MCP_EMAIL_SERVER_FULL_NAME="Your Name" \
    MCP_EMAIL_SERVER_USER_NAME="your-email@gmail.com"
```
- App password required for Gmail; adjust for other providers by editing `/root/.config/goose/config.yaml`.

### Verify MCP Activation
1. Open the portal console for the Goose container.
2. Run `ps aux` to confirm MCP processes are running.
3. Execute `goose configure` to inspect generated config at `/root/.config/goose/config.yaml`.
4. For GitHub MCP, validate connectivity using `goose session` to list issues or PRs.

---

## Task 5 - Customize Models and Persistence (5 minutes)
1. To switch to Azure OpenAI, add the following environment variables (matching your deployment):
   ```bash
   az containerapp update \
     --name <goose-app-name> \
     --resource-group <resource-group> \
     --set-env-vars \
       AZURE_OPENAI_ENDPOINT="https://<resource>.openai.azure.com/" \
       AZURE_OPENAI_API_VERSION="2024-05-01-preview" \
       AZURE_OPENAI_DEPLOYMENT_NAME="<deployment-name>" \
       GOOSE_PROVIDER="azure_openai" \
       GOOSE_MODEL="gpt-4o"
   ```
   Store `AZURE_OPENAI_API_KEY` in Key Vault or Azure App Configuration and reference it securely if moving beyond the lab.
2. Persistence directories mounted via Azure Files:
   - Config: `/root/.config/goose/config.yaml`
   - Sessions: `/root/.local/share/goose/sessions`
   - Logs: `/root/.local/state/goose/logs`
   Use these paths to back up configurations or inspect state.


---

## Troubleshooting Quick Hits
| Symptom | Action |
| --- | --- |
| `azd up` appears stuck during deployment | Check Container App revision logs; Ollama model pulls can take 10+ minutes. |
| Goose UI responds slowly or fails requests | Confirm Ollama model loaded (`ollama ps`) and GPU utilization (`nvidia-smi`). |
| MCP servers do not appear | Ensure required environment variables are present and not set to `"NA"`; rerun `goose configure`. |
| Authentication fails | Reset the basic auth password by updating the Nginx proxy Container App environment variables and redeploying the revision. |

---

## References
- Goose on ACA repository: https://github.com/simonjj/goose-on-aca
- Goose Agent in Action: https://techcommunity.microsoft.com/t5/s/gxcuf89792/images/bS00NDYwMjE1LTRqYkt4Sg?revision=7
- Goose component docs: https://block.github.io/goose/
- Azure Container Apps GPU workload profiles: https://learn.microsoft.com/azure/container-apps/workload-profiles-overview#gpu-workload-profiles

---

## Bonus Exercise - Enable MCP Servers (Optional)

To enable GitHub or Email MCP servers, update the environment variables in your deployed Container App:


> **Important Note**
> The current default model optimized to run on T4 (qwen3:14b) does not work with the Github MCP server (both stdio and streaming). It is hence suggested to upgrade both GPU profile and model if the user intends to use the Github MCP server.
>
> The default email provider is currently configured to be Gmail. The full configuration for the email servers (SMTP/IMAP), ports, SSL can be accessed via the default Goose configuration file located on the NFS file share (`/root/.config/goose/config.yaml`).


Running the commands below will set the environment variables and regenerate the configuration (upon restart of the app) to include the appropriate section needed for the respective MCP server to be added to the Goose configuration.

```bash
# Update GitHub MCP 
az containerapp update \
  --name <goose-app-name> \
  --resource-group <resource-group-name> \
  --set-env-vars GITHUB_PERSONAL_ACCESS_TOKEN="ghp_your_token_here"

# Update Email MCP 
az containerapp update \
  --name <goose-app-name> \
  --resource-group <resource-group-name> \
  --set-env-vars \
    MCP_EMAIL_SERVER_PASSWORD="your_app_password" \
    MCP_EMAIL_SERVER_EMAIL_ADDRESS="your-email@gmail.com" \
    MCP_EMAIL_SERVER_FULL_NAME="Your Name" \
    MCP_EMAIL_SERVER_USER_NAME="your-email@gmail.com"
```
