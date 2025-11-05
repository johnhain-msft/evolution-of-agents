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

## 📝 How to Use

1. Clone the repo
2. Install dependencies (`uv sync`)
3. Create `.env` file based on `.env.example`
4. Open notebooks in VS Code or Jupyter Lab
5. Select kernel from `.venv/bin/python`
4. Follow each notebook to see the evolution in action

### Setup for demo 7

Workbook for multi-agents requires additional steps:
- Foundry has connection to bing grounding
- Foundry has connection to [browser automation](https://learn.microsoft.com/en-us/azure/ai-foundry/agents/how-to/tools/browser-automation#setup)
- Logic App Standard with 4 workflows:
  - create_event, get_events, email_me, get_current_time

---

## 🪟 Windows Setup Instructions

This section provides comprehensive setup instructions specifically for Windows 11 developers. If you're using Linux or Mac, refer to the standard "How to Use" section above.

### Prerequisites

Before starting, ensure you have:
- **Windows 11** (or Windows 10 with latest updates)
- **VS Code** with Python and Jupyter extensions installed
- **Azure subscription** (for infrastructure deployment)

### Step 1: Install uv Package Manager

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

### Step 2: Get the Repository

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

### Step 3: Install Dependencies

Install Python dependencies using `uv`:

```powershell
# Install all project dependencies
uv sync
```

This command will:
- Create a virtual environment in `.venv\` directory
- Install all required packages from `pyproject.toml`
- Lock dependencies in `uv.lock`

### Step 4: Deploy Azure Infrastructure with Bicep

Deploy the required Azure resources using Azure Developer CLI (azd) and Bicep:

```powershell
# Install Azure Developer CLI (azd)
winget install Microsoft.Azd

# Install Azure CLI if not already installed
winget install Microsoft.AzureCLI

# Authenticate with Azure
azd auth login

# Deploy infrastructure (will prompt for subscription/region)
azd up
```

**Note**: The deployment will take approximately 15-20 minutes to complete. The `azd up` command will create all necessary Azure resources including:
- Azure AI Foundry hub and project
- Azure OpenAI deployments
- Azure Logic Apps Standard with workflows
- Networking resources (VNet, subnets)
- Monitoring and logging resources

### Step 5: Configure Environment Variables

After infrastructure deployment, create and configure your `.env` file:

```powershell
# Copy the example file to create .env
Copy-Item .env.example .env

# Edit the .env file using VS Code
code .env
```

Populate the `.env` file with the output values from your Azure deployment:

```powershell
# View Azure deployment outputs
azd env get-values
```

Copy the relevant values into your `.env` file. Required variables include:
- `AZURE_AI_FOUNDRY_CONNECTION_STRING`
- `AZURE_OPENAI_CHAT_DEPLOYMENT_NAME`
- `AZURE_AI_FOUNDRY_SUBSCRIPTION_ID`
- `AZURE_AI_FOUNDRY_RESOURCE_GROUP`
- `AZURE_AI_FOUNDRY_NAME`
- `AZURE_AI_FOUNDRY_PROJECT_NAME`
- `AZURE_TENANT_ID`
- `LOGIC_APP_SUBSCRIPTION_ID`
- `LOGIC_APP_RESOURCE_GROUP`
- `LOGIC_APP_NAME`

### Step 6: Select Jupyter Kernel in VS Code

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

### Step 7: Verify Setup

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

### Step 8: Run Notebooks

You're all set! Open the notebooks in VS Code and run them sequentially:

1. Start with [1-just-llm.ipynb](1-just-llm.ipynb)
2. Progress through notebooks 2-6
3. Finish with [7-agent.ipynb](7-agent.ipynb) for the full multi-agent experience

**To run a notebook:**
- Open the `.ipynb` file in VS Code
- Ensure the correct kernel is selected (see Step 6)
- Click "Run All" or execute cells individually with `Shift+Enter`

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
