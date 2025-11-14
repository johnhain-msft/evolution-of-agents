# <img src="https://azure.microsoft.com/svghandler/ai-studio/?width=600&height=315" alt="Azure AI Foundry Agents" style="height:180px;" /> Azure AI Foundry Agents

> **Empowering the evolution of intelligent agents with Azure AI, MCP, and modern tool orchestration.**

---

## 🚀 Evolution of AI Agents

<p align="center">
   <a href="1-just-llm.ipynb"><img src="images/baby_llm.png" alt="Just LLM" style="height:160px;vertical-align:middle;" /></a>   <span style="font-size:2em;vertical-align:middle;">→</span>
   <a href="7-agent.ipynb"><img src="images/multi_agent.png" alt="Connected Agents" style="height:160px;vertical-align:middle;" /></a>
</p>

AI agents have evolved from simple LLMs to powerful, multi-tool orchestrators. This repo demonstrates the journey—step by step—using real code, interactive notebooks, and visual guides.

### Stages of Evolution

| Stage | Description | Visual |
|-------|-------------|--------|
| [1. Just LLM](1-just-llm.ipynb) | Basic language model, no external tools | <a href="1-just-llm.ipynb"><img src="images/baby_llm.png" alt="Just LLM" style="height:120px;" /></a> |
| [2. RAG](2-rag.ipynb) | Retrieval-Augmented Generation, smarter context | <a href="2-rag.ipynb"><img src="images/rag.png" alt="RAG" style="height:120px;" /></a> |
| [3. Tools](3-tools.ipynb) | Tool-calling agents | <a href="3-tools.ipynb"><img src="images/student_basic_tools.png" alt="Tools" style="height:120px;" /></a> |
| [4. Smart Tools](4-better-tools.ipynb) | Improved tool integration | <a href="4-better-tools.ipynb"><img src="images/student_tools.png" alt="Smart Tools" style="height:120px;" /></a> |
| [5. Foundry Tools](5-foundry-tools.ipynb) | Azure Foundry tool orchestration | <a href="5-foundry-tools.ipynb"><img src="images/foundry_tools.png" alt="Foundry Tools" style="height:120px;" /></a> |
| [6. MCP](6-mcp.ipynb) | Model Context Protocol integration | <a href="6-mcp.ipynb"><img src="images/agent_actions.png" alt="MCP" style="height:120px;" /></a> |
| [7. Connected Agents](7-agent.ipynb) | Multi-agent orchestration and automation | <a href="7-agent.ipynb"><img src="images/multi_agent.png" alt="Connected Agents" style="height:120px;" /></a> |

---

## 📚 Interactive Notebooks

Explore each stage with hands-on Jupyter notebooks:

| Notebook | Description | Link |
|----------|-------------|------|
| 1. Just LLM | Basic LLM usage | [1-just-llm.ipynb](1-just-llm.ipynb) |
| 2. RAG | Retrieval-Augmented Generation | [2-rag.ipynb](2-rag.ipynb) |
| 3. Tools | Tool-calling agents | [3-tools.ipynb](3-tools.ipynb) |
| 4. Smart Tools | Improved tool integration | [4-better-tools.ipynb](4-better-tools.ipynb) |
| 5. Foundry Tools | Azure Foundry tool orchestration | [5-foundry-tools.ipynb](5-foundry-tools.ipynb) |
| 6. MCP | Model Context Protocol integration | [6-mcp.ipynb](6-mcp.ipynb) |
| 7. Connected Agents | Multi-agent orchestration and automation | [7-agent.ipynb](7-agent.ipynb) |

---


## 🖼️ Visual Gallery

<table>
	<tr>
		<td align="center">
			<a href="1-just-llm.ipynb"><img src="images/baby_llm.png" alt="Just LLM" style="height:80px;" /></a><br />
			<b><a href="1-just-llm.ipynb">Just LLM</a></b>
		</td>
		<td align="center">
			<a href="2-rag.ipynb"><img src="images/rag.png" alt="RAG" style="height:80px;" /></a><br />
			<b><a href="2-rag.ipynb">RAG</a></b>
		</td>
		<td align="center">
			<a href="3-tools.ipynb"><img src="images/student_basic_tools.png" alt="Tools" style="height:80px;" /></a><br />
			<b><a href="3-tools.ipynb">Tools</a></b>
		</td>
		<td align="center">
			<a href="4-better-tools.ipynb"><img src="images/student_tools.png" alt="Better Tools" style="height:80px;" /></a><br />
			<b><a href="4-better-tools.ipynb">Better Tools</a></b>
		</td>
		<td align="center">
			<a href="5-foundry-tools.ipynb"><img src="images/foundry_tools.png" alt="Foundry Tools" style="height:80px;" /></a><br />
			<b><a href="5-foundry-tools.ipynb">Foundry Tools</a></b>
		</td>
		<td align="center">
			<a href="6-mcp.ipynb"><img src="images/agent_actions.png" alt="MCP" style="height:80px;" /></a><br />
			<b><a href="6-mcp.ipynb">MCP</a></b>
		</td>
		<td align="center">
			<a href="7-agent.ipynb"><img src="images/multi_agent.png" alt="Connected Agents" style="height:80px;" /></a><br />
			<b><a href="7-agent.ipynb">Connected Agents</a></b>
		</td>
	</tr>
</table>



---

## 🌐 Key Technologies

- **Azure AI Foundry**: Enterprise-grade agent platform
- **MCP (Model Context Protocol)**: Standardized tool discovery and invocation
- **Semantic Kernel**: Flexible orchestration for LLMs and tools
- **Azure Logic Apps**: Real-world automation
- **Browser Automation**: Web research and blog management

---

## 📝 Quick Start

### Prerequisites

Before starting, ensure you have the following tools installed:

- **Azure subscription** (required for infrastructure deployment)
- **Azure Developer CLI (azd)**: [Install azd](https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd)
- **Azure CLI (az)**: [Install Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli)
- **Python 3.11+**: [Download Python](https://www.python.org/downloads/)
- **uv package manager**: [Install uv](https://docs.astral.sh/uv/getting-started/installation/)
- **Git** (optional): For cloning the repository
- **VS Code** (recommended): With Python and Jupyter extensions

### Setup Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/Azure-Samples/azure-ai-foundry-agents.git
   cd azure-ai-foundry-agents
   ```

2. **Authenticate with Azure**
   ```bash
   azd auth login
   ```

3. **Deploy infrastructure (one command!)**
   ```bash
   azd up
   ```
   This will:
   - Deploy all Azure resources (AI Foundry, GPT models, Logic Apps, networking)
   - Automatically create and populate your `.env` file
   - Takes ~15-25 minutes

4. **Install Python dependencies**
   ```bash
   uv sync
   ```

5. **Select Python kernel in VS Code**
   - Open any notebook (e.g., `1-just-llm.ipynb`)
   - Press `Ctrl+Shift+P` → `Python: Select Interpreter`
   - Choose `.venv/bin/python` (Linux/Mac) or `.venv\Scripts\python.exe` (Windows)

6. **Run notebooks 1-7 in sequence!** 🎉

### What Gets Deployed

The `azd up` command automatically provisions:
- ✅ Azure AI Foundry Hub with AI Project
- ✅ GPT-3.5-turbo, GPT-4.1, and GPT-5-mini deployments
- ✅ Bing grounding connection for web research (notebook 7)
- ✅ Playwright workspace for browser automation (notebook 7 - requires manual connection setup)
- ✅ Azure Logic Apps Standard with 4 workflows (notebook 7):
  - `create_event`, `get_events`, `email_me`, `get_current_time`
- ✅ Azure AI Search for RAG (notebook 2)
- ✅ VNet with agent subnet delegation
- ✅ Log Analytics and Application Insights
- ✅ All private endpoints and DNS zones

### Post-Deployment: Manual Configuration Required

**IMPORTANT**: Two connectors require manual setup after `azd up` completes:

#### 1. Office 365 Calendar Authentication

The Office 365 connection is created during deployment but will fail with `401 Unauthorized` until you authorize it in the Azure Portal. This is a limitation of the Office 365 connector - it cannot be fully automated with service principals.

**How to authorize:**

1. Open Azure Portal and navigate to your resource group
2. Find the resource named `office365` (type: API Connection)
3. Click on the resource
4. In the left menu, click **Edit API connection**
5. Click the **Authorize** button
6. Sign in with your Office 365 account when prompted
7. Click **Save**

**Reference**: [Azure Logic Apps - Authenticate with Managed Identity](https://learn.microsoft.com/en-us/azure/logic-apps/authenticate-with-managed-identity)

#### 2. Playwright Browser Automation Connection (Optional)

**TBD**: Will complete instructions at later date. Playwright browser automation is optional and only required for blog features in Notebook 7.

---

## 🪟 Windows Setup Instructions

Follow these comprehensive step-by-step instructions for Windows developers. If you're using Linux or Mac, refer to the standard "Quick Start" section above.

### Prerequisites

Before starting, ensure you have:
- **Windows 11** (or Windows 10 with latest updates)
- **VS Code** with Python and Jupyter extensions installed
- **Azure subscription** (for infrastructure deployment)
- **Node.js 18+** (required for MCP notebook with Playwright browser automation)

### Step 1: Install Node.js

Install Node.js for MCP browser automation support:

```powershell
# Install Node.js using Windows Package Manager
winget install OpenJS.NodeJS.LTS
```

After installation, close and reopen PowerShell, then verify:

```powershell
node --version
npm --version
```

**Expected output**: Version numbers for both commands (e.g., `v20.x.x` and `10.x.x`)

### Step 2: Install uv Package Manager

The `uv` package manager is the recommended tool for managing Python dependencies in this project. Install it using PowerShell:

```powershell
# Open PowerShell (no admin rights required) and run:
irm https://astral.sh/uv/install.ps1 | iex
```

After installation, close and reopen PowerShell to refresh your environment variables, then verify `uv` is available:

```powershell
# Verify uv installation
uv --version
```

**Expected output**: `uv 0.x.x` (version number may vary)

**Troubleshooting: If "uv: command not found"**

If PowerShell cannot find the `uv` command after installation and reopening PowerShell:

```powershell
# Manually add uv to PATH for current session:
$env:Path += ";$env:USERPROFILE\.cargo\bin"

# Verify it works now:
uv --version
```

To make this permanent, add `%USERPROFILE%\.cargo\bin` to your system PATH:
1. Search for "Environment Variables" in Windows Start menu
2. Click "Edit the system environment variables"
3. Click "Environment Variables" button
4. Under "User variables", select "Path" and click "Edit"
5. Click "New" and add: `%USERPROFILE%\.cargo\bin`
6. Click OK on all dialogs
7. Close and reopen PowerShell

### Step 3: Get the Repository

You have two options to get the repository code:

**Option A: Using Git (Recommended)**

If you have Git installed:

```powershell
# Clone the repository
git clone https://github.com/Azure-Samples/azure-ai-foundry-agents.git

# Navigate to project directory
cd azure-ai-foundry-agents
```

**Option B: Download ZIP (No Git Required)**

If you don't have Git installed or prefer not to use it:

1. Visit the repository: https://github.com/Azure-Samples/azure-ai-foundry-agents
2. Click the green "Code" button
3. Select "Download ZIP"
4. Extract the ZIP file to your desired location
5. Open PowerShell and navigate to the extracted folder:
   ```powershell
   cd C:\path\to\extracted\azure-ai-foundry-agents
   ```

### Step 4: Install Dependencies

Install Python dependencies using `uv`:

```powershell
# Install all project dependencies
uv sync
```

This command will:
- Create a virtual environment in `.venv\` directory
- Install all required packages from `pyproject.toml`
- Lock dependencies in `uv.lock`

### Step 5: Install Azure CLI Tools

Install the Azure Developer CLI and Azure CLI using Windows Package Manager:

```powershell
# Install Azure Developer CLI (azd)
winget install Microsoft.Azd

# Install Azure CLI if not already installed
winget install Microsoft.AzureCLI
```

After installation, close and reopen PowerShell to refresh your environment.

### Step 6: Deploy Azure Infrastructure

Deploy all Azure resources with one command:

```powershell
# Authenticate with Azure
azd auth login

# Deploy infrastructure (will prompt for subscription/region)
azd up
```

**What happens during deployment:**
- ⏱️ Takes approximately 15-25 minutes
- 🏗️ Creates all Azure resources (AI Foundry, GPT models, Logic Apps, networking)
- ✨ **Automatically creates and populates your `.env` file** (no manual steps!)

The deployment provisions:
- Azure AI Foundry hub and project
- GPT-3.5-turbo, GPT-4.1, and GPT-5-mini deployments
- Bing grounding and Playwright browser automation connections
- Azure Logic Apps Standard with 4 workflows
- Networking resources (VNet, subnets, private endpoints)
- Monitoring and logging resources (Log Analytics, App Insights)

### Step 7: Install MCP Dependencies for Notebook 6

Notebook 6 uses Playwright for browser automation via the MCP protocol. Windows requires explicit environment variable passing, so install these Node.js packages:

```powershell
# Install Playwright test framework
npm install @playwright/test

# Install Chromium browser binaries
npx playwright install chromium

# Install MCP package locally
npm install @playwright/mcp
```

**Note**: Use the provided `6-mcp-windows.py` script instead of the notebook, as it correctly passes environment variables to the MCP subprocess.

### Step 8: Select Jupyter Kernel in VS Code

To run the notebooks in VS Code, you need to select the correct Python interpreter from your virtual environment:

1. Open any notebook file (e.g., `1-just-llm.ipynb`) in VS Code
2. Open the Command Palette: `Ctrl+Shift+P`
3. Type: `Python: Select Interpreter`
4. Choose the interpreter from your virtual environment:
   - Look for: `.venv\Scripts\python.exe`
   - Full path example: `C:\Users\YourName\azure-ai-foundry-agents\.venv\Scripts\python.exe`

**Alternative method:**
1. Click the kernel picker in the top-right corner of the notebook
2. Select "Select Another Kernel"
3. Choose "Python Environments"
4. Select the `.venv\Scripts\python.exe` interpreter

### Step 9: Verify Setup

Run these verification commands to ensure everything is configured correctly:

```powershell
# Verify Python can import Azure AI packages
.\.venv\Scripts\python.exe -c "import azure.ai.agents; print('Azure AI Agents: Success!')"

# Verify uv is working
uv --version

# Check .env file exists
Test-Path .env
```

**Expected results:**
- Python import should print: `Azure AI Agents: Success!`
- `uv --version` should display version number
- `Test-Path .env` should return: `True`

### Step 10: Run Notebooks

You're all set! Open the notebooks in VS Code and run them sequentially:

1. Start with [1-just-llm.ipynb](1-just-llm.ipynb)
2. Progress through notebooks 2-6
3. Finish with [7-agent.ipynb](7-agent.ipynb) for the full multi-agent experience

**To run a notebook:**
- Open the `.ipynb` file in VS Code
- Ensure the correct kernel is selected (see Step 6)
- Click "Run All" or execute cells individually with `Shift+Enter`

---

## 🔧 Troubleshooting

### Deployment Issues

#### Deployment Fails or Times Out

If `azd up` fails during deployment:

```bash
# Check deployment logs for specific errors
azd deploy --debug

# Clean up failed deployment and retry
azd down --purge --force
azd up
```

**Common causes:**
- **Azure quota limits**: GPT-4 models may require quota increase. Check Azure Portal → Quotas
- **Region availability**: Some model SKUs aren't available in all regions. Try different region during `azd up`
- **Permissions**: Ensure you have Contributor role on the subscription

#### .env File Not Created

If the `.env` file wasn't created automatically after `azd up`:

**Option 1: Run the automation script manually**

Linux/Mac:
```bash
./scripts/populate_env.sh
```

Windows PowerShell:
```powershell
.\scripts\populate_env.ps1
```

**Option 2: Use the legacy script**

Linux/Mac:
```bash
./scripts/setup_local.sh
```

Windows PowerShell:
```powershell
.\scripts\setup_local.ps1
```

**Option 3: Create .env manually**
```bash
# View deployment outputs
azd env get-values

# Copy output to .env file
azd env get-values > .env
```

#### Azure CLI Authentication Issues

If you see authentication errors:

```bash
# Clear cached credentials
az account clear
azd auth login

# Or use device code flow
azd auth login --use-device-code
```

### Notebook Execution Issues

#### Kernel Not Found

If VS Code can't find the Python kernel:

1. Ensure virtual environment exists: `ls .venv/` (should show bin/ or Scripts/)
2. Reinstall dependencies: `uv sync`
3. Reload VS Code window: `Ctrl+Shift+P` → `Developer: Reload Window`
4. Manually select interpreter: `Ctrl+Shift+P` → `Python: Select Interpreter` → `.venv/bin/python` or `.venv\Scripts\python.exe`

#### Import Errors

If notebooks fail with import errors:

```bash
# Reinstall dependencies
uv sync

# Verify installation
uv pip list | grep azure-ai-agents
```

#### Connection Errors to Azure

If notebooks can't connect to Azure services:

1. **Check .env file exists and is populated**: `cat .env` (Linux/Mac) or `type .env` (Windows)
2. **Verify Azure credentials**: `az account show`
3. **Re-authenticate**: `azd auth login`
4. **Check network access**: Ensure your IP is allowed (set in `azd up` via `myIpAddress` parameter)

### Infrastructure Validation

#### Verify Deployment Success

Check all resources were created:

```bash
# List all resources in the deployment
az resource list --resource-group <your-rg-name> --output table

# Verify AI Foundry hub
az cognitiveservices account list --resource-group <your-rg-name> --output table

# Verify Logic Apps workflows
az functionapp list --resource-group <your-rg-name> --output table
```

#### Check for Missing Connections

In Azure Portal, navigate to your AI Foundry resource → Connections:
- ✅ ApplicationInsights connection
- ✅ BingGrounding connection

If any are missing, the Bicep deployment may need to be re-run.

### Cleanup and Retry

If you need to start over:

```bash
# Delete all Azure resources
azd down --purge --force

# Delete local environment state
rm -rf .azure .env

# Start fresh
azd auth login
azd up
```

**Note**: `azd down` will delete ALL resources in the resource group. Make sure you don't have other important resources in that group.

### Getting Help

If you're still stuck:

1. **Check deployment logs**: Look in `.azure/` directory for detailed logs
2. **Azure Portal**: Check Activity Log for deployment errors
3. **GitHub Issues**: [Report an issue](https://github.com/Azure-Samples/azure-ai-foundry-agents/issues)
4. **Azure Support**: For quota or subscription-specific issues

---

### Windows Troubleshooting

#### PowerShell Execution Policy

If you encounter errors about script execution being disabled, you may need to adjust your PowerShell execution policy:

```powershell
# Check current execution policy
Get-ExecutionPolicy

# If it's "Restricted", change it to allow script execution
# Option 1: For current user only (recommended)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Option 2: For current session only (temporary)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
```

**Note**: You may need to run PowerShell as Administrator for Option 1.

#### Path Issues

Windows uses different path conventions than Linux/Mac:

| Aspect | Windows | Linux/Mac |
|--------|---------|-----------|
| Path separator | Backslash `\` | Forward slash `/` |
| Virtual environment binaries | `.venv\Scripts\` | `.venv/bin/` |
| Python executable | `.venv\Scripts\python.exe` | `.venv/bin/python` |

**Important**: When working with file paths in PowerShell:
- Use quotes around paths with spaces: `cd "C:\My Projects\agents"`
- PowerShell accepts forward slashes in most cases: `cd C:/Projects/agents`

#### Virtual Environment Activation (Optional)

While not required for running notebooks in VS Code, you can manually activate the virtual environment in PowerShell:

```powershell
# Activate virtual environment
.\.venv\Scripts\Activate.ps1

# Your prompt should change to show (.venv)
# Now you can run Python commands directly:
python -c "import azure.ai.agents; print('Success!')"

# Deactivate when done
deactivate
```

#### Windows Defender / Antivirus Interference

Windows Defender or other antivirus software may occasionally flag Python scripts or slow down package installation:

**Solutions:**
1. **Add exception for project directory**: Add your project folder to Windows Defender exclusions
   - Settings → Privacy & Security → Windows Security → Virus & threat protection
   - Manage settings → Add or remove exclusions → Add folder
2. **Temporarily disable real-time protection** during `uv sync` (re-enable afterward)
3. **Use Windows Security scan**: Run a full scan to ensure no actual threats, then add exclusions

#### WSL (Windows Subsystem for Linux) Alternative

If you encounter persistent issues with native Windows setup, consider using WSL2:

**Pros:**
- Linux-like environment on Windows
- Better compatibility with Linux-first tools
- Can follow standard Linux/Mac setup instructions

**Cons:**
- Additional setup complexity
- Separate filesystem from Windows
- May require WSL-specific VS Code configuration

**To use WSL:**
1. Install WSL2: `wsl --install` (requires admin rights)
2. Install Ubuntu from Microsoft Store
3. Follow Linux setup instructions in WSL terminal
4. Use VS Code Remote - WSL extension to work with notebooks

**We recommend trying native Windows setup first** before considering WSL.

---

## 💡 Inspiration

This project is inspired by the rapid evolution of AI agents and the need for open, interoperable standards. All images and code are provided for educational and research purposes.

---

## 📢 Contributing

Pull requests, issues, and feedback are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

## 📄 License

MIT License. See [LICENSE](LICENSE) for details.

---

> **Made with ❤️ by the Azure AI Foundry community.**
