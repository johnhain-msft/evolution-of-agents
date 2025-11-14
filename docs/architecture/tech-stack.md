# Technology Stack - Azure AI Foundry Agents

## Overview

This document provides a comprehensive reference of all technologies, frameworks, libraries, and Azure services used in the Azure AI Foundry Agents educational repository. This serves as a quick reference for developers understanding the project's technical foundation.

---

## Core Technologies

### Programming Languages

| Language | Version | Purpose | Configuration |
|----------|---------|---------|---------------|
| **Python** | >= 3.11 | Primary language for all code | `pyproject.toml`: `requires-python = ">=3.11"` |
| **Bicep** | Latest | Infrastructure as code | `/infra` directory (being fixed/enhanced) |
| **Bash/PowerShell** | >= 5.1 (PS) | Automation scripts | `/scripts` directory (new automation) |
| **Markdown** | N/A | Documentation | README, docs/, notebooks |

### Python Package Manager

| Tool | Version | Purpose | Notes |
|------|---------|---------|-------|
| **uv** | Latest | Modern Python package manager | Faster than pip, replaces pip/pip-tools |

**Key Commands**:
```bash
uv sync          # Install dependencies from uv.lock
uv add <package> # Add new dependency
uv lock          # Update lock file
```

---

## Python Dependencies

### Core Azure AI Dependencies

| Package | Version | Purpose | Documentation |
|---------|---------|---------|---------------|
| **azure-ai-agents** | >= 1.2.0b1 | Azure AI Foundry Agents SDK | Agent creation, tool integration, multi-agent orchestration |
| **azure-search-documents** | >= 11.6.0b12 | Azure AI Search integration | Vector search for RAG (notebook 2) |
| **semantic-kernel** | >= 1.35.2 | Microsoft Semantic Kernel | LLM orchestration, plugin system, Azure integration |

**semantic-kernel Extras**:
- `[azure]`: Azure OpenAI and Azure AI integration
- `[mcp]`: Model Context Protocol support

### Supporting Libraries

| Package | Version | Purpose |
|---------|---------|---------|
| **ipykernel** | >= 6.30.1 | Jupyter notebook kernel support |
| **jsonref** | >= 1.1.0 | JSON reference resolution (for OpenAPI specs) |
| **pandas** | >= 2.3.1 | Data manipulation (for books dataset in notebooks) |
| **duckdb** | >= 1.0.0 | Embedded analytics database (notebook 6-mcp-pg) |

### Development Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| **black[jupyter]** | >= 25.1.0 | Code formatter with Jupyter support |

---

## Azure Services

### AI and Machine Learning

| Service | Purpose | Configuration | Notebooks |
|---------|---------|---------------|-----------|
| **Azure AI Foundry (Hub)** | Central AI resource management | Deployed via fixed Bicep | All |
| **Azure AI Foundry (Project)** | Agent workspace and orchestration | Child resource of Hub | All |
| **Azure OpenAI Service** | LLM hosting and inference | GPT deployments within Foundry | All |

**Model Deployments**:
| Model | Version | Deployment Name | SKU | Notebooks |
|-------|---------|-----------------|-----|-----------|
| GPT-3.5-turbo | 0125 | `gpt-35-turbo` | Standard | 1-4 |
| GPT-4.1 | 2025-04-14 | `gpt-4.1` | GlobalStandard (20 capacity) | 5-7 (primary) |
| GPT-5-mini | 2025-08-07 | `gpt-5-mini` | GlobalStandard (20 capacity) | 7 (optional) |

### Data and Search

| Service | Purpose | Notebooks |
|---------|---------|-----------|
| **Azure AI Search** | Vector search for RAG | 2 (RAG demo) |
| **Azure Storage Account** | Blob storage for AI dependencies | All (via Foundry) |
| **DuckDB** (local) | Embedded database for MCP demo | 6-mcp-pg |

### Integration and Automation

| Service | Purpose | Configuration | Notebooks |
|---------|---------|---------------|-----------|
| **Azure Logic Apps Standard** | Serverless workflow automation | Function App-based, deployed in VNet | 7 |
| **Office 365 Connectors** | Email and calendar integration | API connections within Logic Apps | 7 |

**Logic App Workflows** (4 total):
1. **create_event**: Create calendar events
2. **get_events**: Retrieve calendar events
3. **email_me**: Send emails
4. **get_current_time**: Get current date/time

### External Integrations

| Integration | Type | Purpose | Notebooks |
|-------------|------|---------|-----------|
| **Bing Search** | Azure AI Foundry Connection | Web research grounding | 7 (news agent) |
| **Playwright (Browser Automation)** | Azure AI Foundry Connection | Web scraping and automation | 7 (blog agent) |
| **Weather API** | OpenAPI Tool | Weather information retrieval | 7 (weather agent) |

### Networking

| Service | Purpose | Configuration |
|---------|---------|---------------|
| **Azure Virtual Network** | Network isolation for AI services | CIDR: 10.0.0.0/16 (configurable) |
| **Agent Subnet** | Delegated subnet for AI Foundry agents | Delegation: `Microsoft.AI/agents` |
| **Private Endpoint Subnet** | Private connectivity for storage/search | Private endpoints for security |
| **Private DNS Zones** | DNS resolution for private endpoints | Blob storage, websites |

### Monitoring and Observability

| Service | Purpose | Integration |
|---------|---------|-------------|
| **Azure Log Analytics** | Centralized logging | Collects telemetry from all services |
| **Azure Application Insights** | Application performance monitoring | Semantic Kernel OTEL diagnostics |

**Semantic Kernel Telemetry Configuration**:
```bash
SEMANTICKERNEL_EXPERIMENTAL_GENAI_ENABLE_OTEL_DIAGNOSTICS=true
SEMANTICKERNEL_EXPERIMENTAL_GENAI_ENABLE_OTEL_DIAGNOSTICS_SENSITIVE=true
```

### Identity and Access Management

| Service | Purpose | Implementation |
|---------|---------|----------------|
| **Managed Identity** (User-Assigned) | Azure resource authentication | Created by infrastructure deployment |
| **Azure Active Directory** (Azure AD) | User authentication | DefaultAzureCredential chain |

**Authentication Methods Supported**:
1. **Azure Developer CLI** (`azd`): For Bicep deployment workflow
2. **Azure CLI** (`az`): For manual operations and Bicep deployment
3. **VS Code Azure Extension**: For local development
4. **Environment Variables**: Service principal (advanced users)
5. **Managed Identity**: For Azure-hosted scenarios

---

## Infrastructure as Code

### Bicep (Existing)

| Component | Purpose | Location |
|-----------|---------|----------|
| **main.bicep** | Root infrastructure definition | `/infra/main.bicep` |
| **Azure Verified Modules (AVM)** | Reusable, tested Bicep modules | Referenced via `br/public:avm/...` |

**Bicep Modules**:
- `/infra/modules/networking/vnet.bicep`: Virtual network configuration
- `/infra/modules/ai/ai-foundry.bicep`: AI Foundry hub deployment
- `/infra/modules/ai/ai-project-with-caphost.bicep`: AI project with capability hosts
- `/infra/modules/ai/ai-dependencies-with-dns.bicep`: Storage, search, DNS setup
- `/infra/modules/function/function-app-with-plan.bicep`: Logic Apps deployment
- `/infra/modules/monitor/loganalytics.bicep`: Monitoring resources

**Deployment Tool**: Azure Developer CLI (`azd`)
```bash
azd up     # Deploy infrastructure and auto-populate .env
azd down   # Destroy infrastructure
```

**Deployment Enhancement (Story 1.2)**:
- **Post-Provision Hooks**: Configured in `azure.yaml` to automatically create `.env` file after deployment
- **Automation Scripts**:
  - `scripts/populate_env.sh`: Bash script for Linux/Mac
  - `scripts/populate_env.ps1`: PowerShell script for Windows
- **Workflow**: `azd up` → Bicep deployment → Post-provision hook → Automated `.env` creation

---

## Development Tools

### IDEs and Editors

| Tool | Purpose | Configuration |
|------|---------|---------------|
| **VS Code** | Primary IDE | Recommended for Jupyter, Python debugging, Azure extensions |
| **Jupyter Lab** | Alternative notebook interface | Can be used instead of VS Code |

**VS Code Extensions (Recommended)**:
- Python (Microsoft)
- Jupyter (Microsoft)
- Azure Account
- Azure Resources
- Bicep (for infrastructure work)

### Version Control

| Tool | Purpose |
|------|---------|
| **Git** | Version control |
| **GitHub** | Repository hosting and collaboration |

**Important Git Files**:
- `.gitignore`: Excludes `.env`, Python cache, etc.
- `.python-version`: Python version specification for pyenv/asdf

### Azure CLI Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| **Azure CLI (`az`)** | Azure resource management | https://learn.microsoft.com/cli/azure/install-azure-cli |
| **Azure Developer CLI (`azd`)** | Bicep workflow orchestration | https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd |

---

## Key Python Modules (Project-Specific)

### setup.py

**Purpose**: Azure AI agent setup utilities and helper functions

**Key Functions**:
| Function | Purpose | Usage |
|----------|---------|-------|
| `get_credentials()` | Returns Azure credential object | Authentication for Azure services |
| `get_project_client()` | Creates Azure AI Project client | Access to Foundry APIs |
| `create_agent()` | Creates or updates an AI agent | Agent instantiation with tools |
| `create_weather_openapi_tool()` | Creates weather API tool | OpenAPI tool from JSON spec |
| `get_connection_by_name()` | Retrieves connection by name | Find Bing/Playwright connections |
| `test_agent()` | Tests agent with user message | Agent invocation with streaming |
| `on_intermediate_message()` | Handles intermediate responses | Debugging and function call visibility |

### AzureStandardLogicAppTool.py

**Purpose**: Integration with Azure Logic Apps Standard workflows

**Functionality**:
- Discovers Logic App workflows
- Generates OpenAPI specifications for workflows
- Creates Semantic Kernel tools from workflows
- Authenticates with managed identity or Azure credentials

**Usage**: Creates tools for Office 365 integration (calendar, email)

### books_tool.py

**Purpose**: MCP server for books database

**Functionality**:
- Provides books data via Model Context Protocol
- Demonstrates MCP integration pattern
- Used in notebook 6 (MCP)

### books_sql.py

**Purpose**: SQL query interface for books database

**Functionality**:
- DuckDB integration for books dataset
- Demonstrates SQL tool pattern
- Used in notebook 6-mcp-pg (MCP with database)

### mcp_mslearn.py

**Purpose**: MCP server for Microsoft Learn documentation

**Functionality**:
- Provides access to Microsoft Learn content
- Demonstrates external content integration via MCP

### mcp_playwright.py

**Purpose**: MCP server configuration for Playwright browser automation

**Functionality**:
- Configures Playwright MCP server
- Used for blog agent in notebook 7

---

## Environment Configuration

### Required Environment Variables

Defined in `.env.example`, populated in `.env`:

| Variable | Purpose | Example | Source |
|----------|---------|---------|--------|
| `AZURE_OPENAI_CHAT_DEPLOYMENT_NAME` | Model deployment name | `gpt-4.1` | Infrastructure output |
| `AZURE_AI_FOUNDRY_CONNECTION_STRING` | Foundry endpoint URL | `https://<resource>.services.ai.azure.com/api/projects/<project>` | Infrastructure output |
| `AZURE_AI_FOUNDRY_SUBSCRIPTION_ID` | Azure subscription ID | `00000000-0000-0000-0000-000000000000` | Infrastructure output |
| `AZURE_AI_FOUNDRY_RESOURCE_GROUP` | Resource group name | `rg-agents-dev` | Infrastructure output |
| `AZURE_AI_FOUNDRY_NAME` | Foundry hub name | `ai-foundry-abc123` | Infrastructure output |
| `AZURE_AI_FOUNDRY_PROJECT_NAME` | Project name | `agents-project-1` | Infrastructure output |
| `AZURE_TENANT_ID` | Azure AD tenant ID | `00000000-0000-0000-0000-000000000000` | Infrastructure output |
| `LOGIC_APP_SUBSCRIPTION_ID` | Logic App subscription | Same as above or different | Infrastructure output |
| `LOGIC_APP_RESOURCE_GROUP` | Logic App resource group | `rg-agents-dev` | Infrastructure output |
| `LOGIC_APP_NAME` | Logic App name | `logic-apps-abc123` | Infrastructure output |
| `BLOG_URL` | Blog URL for automation | `https://yourblog.com` | User-provided |

**Optional Debug Variables**:
```bash
DEBUG=true  # Enable debug logging in setup.py
USE_AZURE_DEV_CLI=true  # Use AzureDeveloperCliCredential instead of DefaultAzureCredential
```

---

## Notebook Progression and Technology Usage

### Notebook 1: Just LLM

**Technologies**: Azure AI Inference, Semantic Kernel, basic chat
**Demonstrates**: Simple LLM inference without tools

### Notebook 2: RAG

**Technologies**: Azure AI Search, vector embeddings, retrieval
**Demonstrates**: Retrieval-Augmented Generation pattern

### Notebook 3: Tools

**Technologies**: Function calling, basic tools
**Demonstrates**: LLM with external tool invocation

### Notebook 4: Better Tools

**Technologies**: Improved tool integration, OpenAPI tools
**Demonstrates**: Enhanced tool patterns and error handling

### Notebook 5: Foundry Tools

**Technologies**: Azure AI Foundry tool orchestration, code interpreter
**Demonstrates**: Foundry-native tool capabilities

### Notebook 6: MCP

**Technologies**: Model Context Protocol, MCP servers, books database
**Demonstrates**: MCP integration for standardized tool discovery

**Variants**:
- **6-mcp.ipynb**: Basic MCP with books tool
- **6-mcp-pg.ipynb**: MCP with DuckDB (SQL) integration

### Notebook 7: Connected Agents

**Technologies**: Multi-agent orchestration, all previous tools + Logic Apps + Bing + Playwright
**Demonstrates**: Complete multi-agent system with specialized agents

**Agents in Notebook 7**:
1. **Main Agent**: Orchestrator (AdvisorGPT)
2. **Office Agent**: Calendar and email (Logic Apps)
3. **Weather Agent**: Weather information (OpenAPI tool)
4. **News Agent**: Web research (Bing grounding)
5. **Blog Agent**: Blog management (Playwright browser automation)

---

## Performance Considerations

### LLM Inference

- **Model Size Impact**: GPT-4.1 slower than GPT-3.5-turbo, but higher quality
- **GlobalStandard SKU**: Provides global load balancing and better availability
- **Capacity**: 20 TPM (Tokens Per Minute) configured for GPT-4.1 and GPT-5-mini

### Network Latency

- **VNet Integration**: Reduces latency for Foundry Standard mode
- **Private Endpoints**: Secure but may add minimal latency

### Infrastructure Deployment Time

- **Bicep Deployment**: ~15-25 minutes for full infrastructure (includes all Azure resources for 7 notebooks)
- **Automation Scripts**: < 5 seconds for `.env` file creation after deployment

---

## Security and Compliance

### Authentication

- **Azure Identity**: Uses credential chain (Azure CLI → VS Code → Managed Identity)
- **No Hardcoded Secrets**: All credentials via environment variables or Azure authentication

### Data Protection

- **Environment Variables**: `.env` excluded from Git
- **Private Endpoints**: Storage and search accessible only via VNet
- **Managed Identity**: Preferred for Azure-to-Azure authentication

### Azure RBAC

**Required Role**:
- **AI User**: Role assignment on AI Foundry Project for user running notebooks

---

## External Documentation Links

### Azure Services
- [Azure AI Foundry Documentation](https://learn.microsoft.com/azure/ai-foundry/)
- [Azure OpenAI Service](https://learn.microsoft.com/azure/ai-services/openai/)
- [Semantic Kernel](https://learn.microsoft.com/semantic-kernel/)
- [Azure Logic Apps Standard](https://learn.microsoft.com/azure/logic-apps/single-tenant-overview-single-tenant)
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io/)

### Tools and Libraries
- [uv Package Manager](https://github.com/astral-sh/uv)
- [Black Code Formatter](https://black.readthedocs.io/)
- [Bicep Documentation](https://learn.microsoft.com/azure/azure-resource-manager/bicep/)
- [Azure Developer CLI (azd)](https://learn.microsoft.com/azure/developer/azure-developer-cli/)

---

**END OF TECH STACK**

*This technology stack document provides comprehensive reference for all technologies used in the Azure AI Foundry Agents educational project.*
