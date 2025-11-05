# Coding Standards - Azure AI Foundry Agents

## Overview

This document defines the coding standards, conventions, and best practices for the Azure AI Foundry Agents educational repository. These standards ensure consistency, maintainability, and clarity across all code contributions.

---

## Python Standards

### Code Formatting

**Formatter**: Black

- **Configuration**: Defined in `pyproject.toml`:
  ```toml
  [tool.uv]
  dev-dependencies = [
      "black[jupyter]>=25.1.0",
  ]
  ```
- **Usage**: Run `black .` to format all Python files
- **Jupyter Support**: Black includes Jupyter notebook formatting support
- **Line Length**: Black default (88 characters)
- **Quote Style**: Black default (double quotes)

**No Additional Linters**: This educational project uses Black for formatting only. No explicit linting configuration (pylint, flake8) is enforced to maintain simplicity.

### Python Version

- **Minimum**: Python 3.11
- **Specification**: Defined in `pyproject.toml`: `requires-python = ">=3.11"`
- **Version Pinning**: `.python-version` file specifies exact version for project

### Import Organization

**Standard Library First, Then Third-Party, Then Local**:
```python
# Standard library
from datetime import date
import os

# Third-party
from dotenv import load_dotenv
from azure.identity.aio import DefaultAzureCredential
from semantic_kernel import Kernel

# Local modules
from setup import get_credentials
```

**Async Imports**: Use `aio` (asynchronous) versions of Azure clients for async/await patterns:
```python
from azure.identity.aio import DefaultAzureCredential
from azure.ai.projects.aio import AIProjectClient
```

### Naming Conventions

**Functions and Variables**: `snake_case`
```python
def get_project_client():
    """Get the Azure AI Agent client."""
    pass

user_input = "Tell me a joke."
```

**Classes**: `PascalCase`
```python
class AzureAIAgent:
    pass
```

**Constants**: `UPPER_SNAKE_CASE`
```python
AZURE_OPENAI_API_VERSION = "2024-05-01-preview"
```

**Private Functions/Variables**: Leading underscore
```python
def _internal_helper():
    pass

_cache = {}
```

### Docstrings

**Style**: Google-style docstrings (when present)

```python
async def create_agent(
    agent_name: str,
    agent_instructions: str,
    client: AIProjectClient,
    tools: list[Tool | ToolDefinition] = [],
    plugins: list[KernelPlugin] = [],
    kernel: Kernel = None,
) -> AzureAIAgent:
    """Create or update an Azure AI agent.

    Args:
        agent_name: Name for the agent
        agent_instructions: System instructions for the agent
        client: Azure AI Project client instance
        tools: List of tools or tool definitions
        plugins: List of kernel plugins
        kernel: Semantic Kernel instance

    Returns:
        Configured AzureAIAgent instance
    """
    pass
```

**Educational Note**: Not all functions have docstrings in this educational codebase. Prioritize docstrings for complex or non-obvious functions.

### Async/Await Patterns

**Consistent Async Usage**: Azure AI Foundry SDK and Semantic Kernel use async patterns extensively.

```python
async def get_project_client() -> AIProjectClient:
    """Async function for client creation."""
    client = AzureAIAgent.create_client(
        credential=creds,
        endpoint=ai_agent_settings.endpoint,
    )
    return client

# Usage in notebooks
client = await get_project_client()
```

**Async Iteration**: Use `async for` for Azure SDK list operations:
```python
async for agent in client.agents.list_agents():
    print(f"Agent ID: {agent.id}, Name: {agent.name}")
```

### Error Handling

**Try-Except for Agent Invocations**:
```python
try:
    async for agent_response in agent.invoke(messages=user_message, thread=thread):
        # Process response
        pass
except Exception as e:
    print(f"Agent error: {e}")
```

**Graceful Degradation**: Educational code should catch exceptions and print informative errors rather than crashing notebooks.

### Environment Variable Handling

**Load Environment Variables at Module Level**:
```python
from dotenv import load_dotenv
import os

load_dotenv(override=True)

endpoint = os.environ.get("AZURE_AI_FOUNDRY_CONNECTION_STRING")
deployment_name = os.environ.get("AZURE_OPENAI_CHAT_DEPLOYMENT_NAME")
```

**Fallback Values**: Use `os.environ.get("KEY", default_value)` for optional configuration:
```python
api_version = os.environ.get("AZURE_OPENAI_API_VERSION", None)
is_debug = os.environ.get("DEBUG", "false").lower() == "true"
```

---

## Jupyter Notebook Standards

### Cell Organization

**Markdown Cells for Explanations**:
- First cell: Title and description with image
- Explanatory markdown cells between code cells
- Use headers (`##`, `###`) for section organization

**Code Cells for Execution**:
- One logical unit per cell (e.g., one agent creation, one invocation)
- Cells should be runnable in sequence from top to bottom

**Example Structure**:
```markdown
1. [Markdown] # Title and description
2. [Code] Import statements and setup
3. [Code] Agent creation
4. [Code] Agent invocation example 1
5. [Code] Agent invocation example 2 (commented for optional execution)
```

### Notebook Naming

**Pattern**: `{number}-{descriptive-name}.ipynb`
- `1-just-llm.ipynb`
- `7-agent.ipynb`
- `6-mcp-pg.ipynb` (variant with suffix)

### Output Handling

**Print for Educational Clarity**:
```python
print(f"Agent ID: {agent.id}, Name: {agent.name}")
```

**IPython Display for Rich Output**:
```python
from IPython.display import Image, display
display(Image(f"downloaded__{item.file_id}.png"))
```

**Jupyter Async Execution**: Use top-level `await` in notebook cells:
```python
# This works in Jupyter notebooks
response = await chat(user_input)
```

---

## Bicep Standards

### Formatting and Linting

**Bicep Linter**: Use `az bicep build` to validate syntax and check for warnings

```bash
# Validate Bicep file
az bicep build --file infra/main.bicep

# Build all modules
find infra/modules -name "*.bicep" -exec az bicep build --file {} \;
```

### File Organization

**Standard Files**:
- `main.bicep`: Root infrastructure orchestration
- `main.bicepparam`: Parameters file for customization
- `modules/`: Reusable Bicep components organized by service category

**Module Structure**:
```
infra/modules/
├── networking/
│   └── vnet.bicep
├── ai/
│   ├── ai-foundry.bicep
│   └── ai-project-with-caphost.bicep
└── function/
    └── function-app-with-plan.bicep
```

### Naming Conventions

**Resources**: Follow Azure naming conventions with resource type prefixes
```bicep
resource agentsVnet 'Microsoft.Network/virtualNetworks@2023-05-01' = {
  name: 'vnet-agents-${resourceToken}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: ['10.0.0.0/16']
    }
  }
}
```

**Parameters**: `camelCase`
```bicep
param location string
param resourceToken string
param agentSubnetAddressPrefix string = '10.0.1.0/24'
```

**Outputs**: `camelCase` for Bicep, mapped to `UPPER_SNAKE_CASE` environment variables
```bicep
output aiFoundryConnectionString string = cognitiveAccount.properties.endpoint
output logicAppName string = logicApp.name
```

### Comments

**Module-Level Comments**: Explain purpose and requirements
```bicep
// Agent subnet requires delegation to Microsoft.AI/agents service
// This is required for Foundry Standard mode with VNet integration
resource agentSubnet 'Microsoft.Network/virtualNetworks/subnets@2023-05-01' = {
  parent: agentsVnet
  name: 'snet-agents'
  properties: {
    addressPrefix: agentSubnetAddressPrefix
    delegations: [
      {
        name: 'ai-agents-delegation'
        properties: {
          serviceName: 'Microsoft.AI/agents'
        }
      }
    ]
  }
}
```

### Fixing Existing Bicep (Story 1.2 Guidelines)

**When Fixing Bicep Modules**:
1. **Document Changes**: Add comment explaining what was fixed and why
   ```bicep
   // FIXED (Story 1.2): Added missing Bing grounding connection
   resource bingConnection '...' = {
     // ...
   }
   ```

2. **Test Fixes in Isolation**: Validate individual modules before integration
   ```bash
   az bicep build --file infra/modules/ai/ai-foundry.bicep
   ```

3. **Maintain Backwards Compatibility**: Where possible, make fixes additive or use conditional logic
   ```bicep
   param enableBingConnection bool = true

   resource bingConnection '...' = if (enableBingConnection) {
     // ...
   }
   ```

---

## Automation Script Standards

### Bash Scripts (Linux/Mac)

**File Naming**: `snake_case.sh`
- Example: `populate_env.sh`, `setup_local.sh`

**Shebang and Error Handling**:
```bash
#!/bin/bash
set -e  # Exit on error

echo "Populating .env file from deployment outputs..."

# Error handling example
if ! command -v azd &> /dev/null; then
    echo "Error: Azure Developer CLI (azd) not found"
    exit 1
fi
```

**Comments for Clarity**:
```bash
# Extract deployment outputs from Azure Developer CLI
azd env get-values > .env

# Verify .env file was created successfully
if [ ! -f .env ]; then
    echo "Error: Failed to create .env file"
    exit 1
fi

echo ".env file created successfully!"
```

### PowerShell Scripts (Windows)

**File Naming**: `snake_case.ps1`
- Example: `populate_env.ps1`, `setup_local.ps1`

**Error Handling and Output**:
```powershell
# Stop on errors
$ErrorActionPreference = "Stop"

Write-Host "Populating .env file from deployment outputs..."

# Check azd is installed
if (!(Get-Command azd -ErrorAction SilentlyContinue)) {
    Write-Error "Azure Developer CLI (azd) not found"
    exit 1
}

# Extract deployment outputs
azd env get-values | Out-File -FilePath .env -Encoding utf8

Write-Host ".env file created successfully!"
```

### Cross-Platform Consistency

**Bash and PowerShell scripts must**:
1. Produce identical `.env` file output
2. Handle errors gracefully with clear messages
3. Exit with appropriate status codes (0 = success, 1 = error)
4. Provide user-friendly progress messages

**Example Parity**:
- Both scripts call `azd env get-values`
- Both write to `.env` file in repository root
- Both verify successful completion
- Both handle missing `azd` CLI gracefully

---

## Documentation Standards

### Markdown Formatting

**Headers**: Use ATX-style headers (`#`, `##`, `###`)

**Code Blocks**: Always specify language for syntax highlighting
```markdown
\```python
def example():
    pass
\```

\```bash
azd up
\```

\```powershell
$env:VARIABLE = "value"
\```
```

**Lists**: Use `-` for unordered lists, `1.` for ordered lists

**Links**: Use descriptive text, not raw URLs
```markdown
<!-- Good -->
See the [Azure AI Foundry documentation](https://learn.microsoft.com/azure/ai-foundry/)

<!-- Avoid -->
See https://learn.microsoft.com/azure/ai-foundry/
```

### README Structure

**Consistent Sections**:
1. Title and badges/logo
2. Overview/description
3. Features or stages (with visuals)
4. Setup instructions (OS-specific sections)
5. Usage examples
6. Contributing
7. License

**Visual Elements**: Use tables, images, and emojis for clarity and engagement (educational project)

---

## Git Commit Standards

### Commit Messages

**Format**: `type: brief description`

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

**Examples**:
```
feat: add Windows setup instructions to README
fix: correct Bicep output variable for AI Foundry endpoint
docs: update architecture with Bicep automation enhancement
chore: add automated .env population scripts
```

### Branch Naming

**Pattern**: `feature/descriptive-name` or `fix/descriptive-name`
- `feature/windows-setup-docs`
- `feature/bicep-infrastructure-automation`

---

## Testing Standards

### Manual Testing Requirements

**For Notebooks**:
1. Run notebook from top to bottom in clean kernel
2. Verify all cells execute without errors
3. Check outputs are sensible and educational

**For Infrastructure**:
1. Deploy to clean Azure subscription/resource group
2. Verify all resources provision successfully
3. Run notebooks after infrastructure deployment to verify completeness
4. Verify `.env` file population works correctly

**For Documentation**:
1. Follow documentation steps exactly as written on target platform
2. Verify commands work without modification
3. Check for typos, broken links, and formatting issues

### Cross-Platform Testing

**Required Platforms**:
- **Notebooks**: Test on Linux, Mac, and Windows (after Windows setup docs added)
- **Infrastructure**: Test fixed Bicep deployment on clean Azure subscription
- **Automation**: Test automated `.env` creation on Windows 11, Linux (Ubuntu), and macOS
- **Documentation**: Test setup instructions on actual target OS versions

---

## Dependencies and Package Management

### Python Package Manager

**Tool**: `uv` (modern Python package manager)

**Commands**:
```bash
# Install dependencies
uv sync

# Add new dependency
uv add package-name

# Add dev dependency
uv add --dev package-name
```

**Lock File**: `uv.lock` - committed to repository for reproducible builds

### Dependency Pinning

**Minimum Versions**: Use `>=` for flexibility with security updates
```toml
dependencies = [
    "azure-ai-agents>=1.2.0b1",
    "semantic-kernel[azure,mcp]>=1.35.2",
]
```

**Exact Versions**: Avoid unless necessary (educational project benefits from latest features/fixes)

---

## Security Best Practices

### Credentials

**Never Commit Secrets**:
- `.env` file excluded via `.gitignore`
- Use `.env.example` with placeholder values only

**Azure Authentication**:
```python
# Good: Use Azure Identity with default credential chain
from azure.identity.aio import DefaultAzureCredential
creds = DefaultAzureCredential()

# Avoid: Hardcoded credentials or API keys
api_key = "sk-..." # NEVER do this
```

### Environment Variable Naming

**Use Descriptive, Uppercase Names**:
```bash
AZURE_AI_FOUNDRY_CONNECTION_STRING=https://...
AZURE_OPENAI_CHAT_DEPLOYMENT_NAME=gpt-4.1
LOGIC_APP_SUBSCRIPTION_ID=00000000-0000-0000-0000-000000000000
```

---

## Code Review Checklist

Before submitting code, verify:

- [ ] Python code formatted with Black
- [ ] Bicep code validated with `az bicep build`
- [ ] Automation scripts tested on target platforms (bash on Linux/Mac, PowerShell on Windows)
- [ ] No hardcoded credentials or secrets
- [ ] `.env` file not committed (check `.gitignore`)
- [ ] Notebooks run from top to bottom without errors
- [ ] Documentation follows markdown standards
- [ ] Commit messages follow convention
- [ ] New dependencies added to `pyproject.toml`
- [ ] Environment variables added to `.env.example` if new

---

## Educational Project Considerations

**Favor Clarity Over Optimization**: This is an educational project. Code should be clear and demonstrative, even if not production-optimized.

**Comments for Learning**: Include explanatory comments for complex Azure configurations or agent patterns:
```python
# Multi-agent orchestration: Main agent delegates to specialist agents
# Each specialist has access to specific tools (calendar, weather, blog)
connected_agents = [
    ConnectedAgentTool(
        id=office_agent.id,
        name="calendar_email_agent",
        description="Calendar and email management..."
    ),
    # ... other agents
]
```

**Simplicity**: Avoid over-engineering. If a simpler approach demonstrates the concept effectively, prefer it.

**Progressive Complexity**: Early notebooks (1-4) should be simpler; later notebooks (5-7) can introduce more advanced patterns.

---

**END OF CODING STANDARDS**

*Follow these standards to maintain consistency and quality across the Azure AI Foundry Agents educational project.*
