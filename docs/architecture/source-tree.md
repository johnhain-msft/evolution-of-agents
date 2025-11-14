# Source Tree - Azure AI Foundry Agents

## Overview

This document provides a comprehensive guide to the Azure AI Foundry Agents repository structure, explaining the purpose of each directory and file. This serves as a navigation aid for developers working on the project.

---

## Repository Root Structure

```
evolution-of-agents/
├── .gitignore                   # Git ignore rules
├── .python-version              # Python version specification (3.11)
├── .vscode/                     # VS Code workspace settings
├── .env.example                 # Environment variable template
├── .env                         # Environment variables (NOT committed, user-created)
├── pyproject.toml               # Python project configuration
├── uv.lock                      # Python dependency lock file
├── azure.yaml                   # Azure Developer CLI configuration
├── README.md                    # Project documentation (main entry point)
├── 1-just-llm.ipynb            # Notebook 1: Basic LLM
├── 2-rag.ipynb                 # Notebook 2: Retrieval-Augmented Generation
├── 3-tools.ipynb               # Notebook 3: Tool-calling agents
├── 4-better-tools.ipynb        # Notebook 4: Improved tool integration
├── 5-foundry-tools.ipynb       # Notebook 5: Azure Foundry tools
├── 6-mcp.ipynb                 # Notebook 6: Model Context Protocol
├── 6-mcp-pg.ipynb              # Notebook 6 (variant): MCP with database
├── 7-agent.ipynb               # Notebook 7: Multi-agent orchestration
├── setup.py                     # Azure AI agent setup utilities
├── AzureStandardLogicAppTool.py # Logic Apps tool integration
├── books_tool.py                # Books database MCP server
├── books_sql.py                 # Books SQL queries (DuckDB)
├── mcp_mslearn.py               # Microsoft Learn MCP server
├── mcp_playwright.py            # Playwright MCP server config
├── docs/                        # Documentation directory
├── helpers/                     # Helper modules (duplicates of root tools)
├── images/                      # Visual assets for README
├── infra/                       # Bicep infrastructure (being fixed/enhanced)
├── scripts/                     # Setup scripts (bash, PowerShell, automation)
├── src/                         # Additional source (Logic Apps workflows)
└── web-bundles/                 # (Empty/future use)
```

---

## Core Notebooks

### Educational Progression (1-7)

| File | Notebook | Purpose | Key Concepts |
|------|----------|---------|--------------|
| `1-just-llm.ipynb` | Just LLM | Basic LLM inference without tools | Simple chat, prompt engineering, Azure AI Foundry basics |
| `2-rag.ipynb` | RAG | Retrieval-Augmented Generation | Azure AI Search, vector embeddings, grounding in documents |
| `3-tools.ipynb` | Tools | Function calling with basic tools | Tool definitions, function invocation, LLM tool use |
| `4-better-tools.ipynb` | Better Tools | Improved tool integration | OpenAPI tools, better error handling, tool patterns |
| `5-foundry-tools.ipynb` | Foundry Tools | Azure Foundry native tools | Code interpreter, Foundry tool orchestration |
| `6-mcp.ipynb` | MCP | Model Context Protocol integration | MCP servers, standardized tool discovery, books tool |
| `6-mcp-pg.ipynb` | MCP + Database | MCP with SQL database | DuckDB integration, SQL tool pattern, database queries |
| `7-agent.ipynb` | Connected Agents | Multi-agent orchestration | Agent-to-agent communication, specialist agents, full system integration |

**Execution Order**: Notebooks should be run in numerical order (1→7) as each builds conceptual understanding on the previous.

---

## Python Modules

### Root-Level Modules

#### setup.py
**Purpose**: Core setup and utility functions for Azure AI agents

**Key Functions**:
- `get_credentials()`: Returns Azure credential object (DefaultAzureCredential or AzureDeveloperCliCredential)
- `get_project_client()`: Creates Azure AI Project client
- `create_agent()`: Creates or updates an AI agent with tools and plugins
- `create_weather_openapi_tool()`: Creates weather API tool from OpenAPI spec
- `get_connection_by_name()`: Retrieves Azure AI Foundry connection by name
- `test_agent()`: Tests agent with user message and handles streaming responses
- `on_intermediate_message()`: Callback for intermediate agent responses

**Usage**: Imported by all notebooks for agent creation and management
```python
from setup import get_project_client, create_agent, test_agent
```

#### AzureStandardLogicAppTool.py
**Purpose**: Integration with Azure Logic Apps Standard workflows

**Functionality**:
- Discovers Logic App workflows in Azure subscription
- Generates OpenAPI specifications for workflows
- Creates Semantic Kernel tools from workflow definitions
- Handles authentication via managed identity or Azure credentials

**Usage**: Used in notebook 7 for Office 365 integration (calendar, email)
```python
from AzureStandardLogicAppTool import create_logic_app_tools

logic_app_tools = create_logic_app_tools(
    logic_app_subscription_id=os.environ.get("LOGIC_APP_SUBSCRIPTION_ID"),
    logic_app_resource_group=os.environ.get("LOGIC_APP_RESOURCE_GROUP"),
    logic_app_name=os.environ.get("LOGIC_APP_NAME"),
    # ... foundry parameters
)
```

#### books_tool.py
**Purpose**: MCP server for books database

**Functionality**:
- Provides books data via Model Context Protocol
- Demonstrates MCP server implementation pattern
- Exposes books dataset as MCP resource

**Usage**: Used in notebook 6 (MCP) via MCP protocol

#### books_sql.py
**Purpose**: SQL query interface for books database

**Functionality**:
- DuckDB integration for books dataset
- SQL-based tool pattern for database queries
- Demonstrates SQL tool creation for LLMs

**Usage**: Used in notebook 6-mcp-pg (MCP with database)

#### mcp_mslearn.py
**Purpose**: MCP server configuration for Microsoft Learn documentation

**Functionality**:
- Provides access to Microsoft Learn content via MCP
- Demonstrates external content integration pattern

**Usage**: MCP server for accessing Microsoft documentation

#### mcp_playwright.py
**Purpose**: MCP server configuration for Playwright browser automation

**Functionality**:
- Configures Playwright MCP server for browser automation
- Used for blog agent web interactions

**Usage**: Used in notebook 7 for blog management agent

---

## Configuration Files

### Python Configuration

#### pyproject.toml
**Purpose**: Python project metadata and dependency specification

**Contents**:
- Project name, version, description
- Python version requirement: `>= 3.11`
- Production dependencies (azure-ai-agents, semantic-kernel, etc.)
- Development dependencies (black formatter)

**Package Manager**: Configured for `uv`

#### uv.lock
**Purpose**: Dependency lock file for reproducible builds

**Generated by**: `uv sync` command
**Do not edit manually**: Auto-generated and updated by uv

#### .python-version
**Purpose**: Specifies Python version for pyenv/asdf/rtx

**Contents**: Single line with Python version (e.g., `3.11`)

### Azure Configuration

#### .env.example
**Purpose**: Template for environment variables

**Contents**: Placeholder values for all required environment variables
- Azure AI Foundry connection details
- Logic Apps configuration
- Blog URL
- Debug settings

**Usage**: Copy to `.env` and populate with real values

#### .env
**Purpose**: Actual environment variables (NOT committed)

**Generated by**:
- **Automated** (Story 1.2): Post-provision hooks via `scripts/populate_env.sh` or `scripts/populate_env.ps1`
- **Manual** (legacy): `scripts/setup_local.sh` (from azd outputs)
- **Manual** (fallback): Direct user creation

**Security**: Excluded via `.gitignore`

#### azure.yaml
**Purpose**: Azure Developer CLI (azd) configuration

**Contents**:
- Service definitions for azd
- Infrastructure location
- Deployment settings

**Usage**: Used by `azd up` and `azd down` commands

---

## Infrastructure

### Bicep (Existing)

```
infra/
├── main.bicep                   # Root Bicep template
├── main.bicepparam              # Bicep parameters file
└── modules/                     # Bicep modules
    ├── ai/
    │   ├── ai-foundry.bicep                  # AI Foundry hub
    │   ├── ai-project-with-caphost.bicep     # AI project
    │   └── ai-dependencies-with-dns.bicep    # Storage, search, DNS
    ├── ai-dependencies/         # Additional AI dependencies
    ├── function/
    │   └── function-app-with-plan.bicep      # Logic Apps Standard
    ├── iam/                     # Identity and access management
    ├── keyvault/                # Key Vault (if used)
    ├── monitor/
    │   └── loganalytics.bicep               # Log Analytics, App Insights
    ├── networking/
    │   └── vnet.bicep                       # Virtual network, subnets
    ├── storage/                 # Storage account modules
    └── types/                   # Bicep type definitions
```

**Deployment Method**: Azure Developer CLI (`azd up`)

**Key Files**:
- `main.bicep`: Orchestrates all modules, deploys complete infrastructure
- `main.bicepparam`: Parameter file for customization
- Modules: Reusable Bicep components for each Azure service

**Enhancement (Story 1.2)**: Bicep modules will be audited and fixed for reliability and completeness

---

## Documentation

```
docs/
├── architecture.md              # Architecture documentation
├── architecture/                # Architecture shards
│   ├── coding-standards.md      # Development standards
│   ├── tech-stack.md            # Technology reference
│   └── source-tree.md           # This document
├── BUGBUSTER.md                 # Sample document for RAG demo (notebook 2)
├── weather.json                 # Weather API OpenAPI specification
└── book1-100k.csv               # Books dataset (100k rows)
```

**Purpose**:
- `architecture.md`: Comprehensive architecture documentation
- `architecture/`: Sharded documents for detailed technical reference
- `BUGBUSTER.md`: Demo content for RAG retrieval (fictional product spec)
- `weather.json`: OpenAPI spec for weather tool (notebook 7)
- `book1-100k.csv`: Books data for MCP demos (notebooks 6, 6-mcp-pg)

---

## Scripts

```
scripts/
├── setup_local.sh               # Bash setup script (Linux/Mac) - LEGACY
├── setup_local.ps1              # PowerShell setup script (Windows, minimal) - LEGACY
├── populate_env.sh              # NEW (Story 1.2): Automated .env creation (bash)
└── populate_env.ps1             # NEW (Story 1.2): Automated .env creation (PowerShell)
```

### populate_env.sh (NEW - Story 1.2)
**Purpose**: Automatically populates `.env` file after `azd up` deployment (Linux/Mac)

**Triggered by**: Post-provision hook in `azure.yaml` (automatic, no manual invocation)

**Functionality**:
- Runs `azd env get-values`
- Parses environment variables
- Creates `.env` file with all required values
- Handles errors gracefully

**Usage**: Runs automatically after `azd up` completes successfully

### populate_env.ps1 (NEW - Story 1.2)
**Purpose**: Automatically populates `.env` file after `azd up` deployment (Windows)

**Triggered by**: Post-provision hook in `azure.yaml` (automatic, no manual invocation)

**Functionality**:
- PowerShell equivalent of `populate_env.sh`
- Runs `azd env get-values`
- Creates `.env` file with all required values
- Cross-platform consistency with bash version

**Usage**: Runs automatically after `azd up` completes successfully on Windows

### setup_local.sh (LEGACY)
**Purpose**: Manual `.env` population from Azure Developer CLI outputs

**Status**: Kept for backward compatibility; superseded by automated `populate_env.sh`

**Usage**:
```bash
# Manual fallback (if automation fails):
./scripts/setup_local.sh
```

### setup_local.ps1 (LEGACY)
**Purpose**: Minimal PowerShell setup script

**Status**: Kept for backward compatibility; superseded by automated `populate_env.ps1`

---

## Additional Source

```
src/
└── workflows/                   # Logic Apps workflow definitions
    ├── create_event/            # Calendar event creation workflow
    ├── get_events/              # Calendar event retrieval workflow
    ├── email_me/                # Email sending workflow
    └── get_current_time/        # Current time workflow
```

**Purpose**: Logic Apps workflow definitions deployed to Azure Logic Apps Standard

**Deployment**: Workflows deployed via `azd` (Bicep infrastructure)

**Usage**: Invoked by Office Agent in notebook 7 via Logic App tools

---

## Helpers Directory

```
helpers/
├── AzureStandardLogicAppTool.py # Duplicate of root file
└── books_tool.py                # Duplicate of root file
```

**Note**: Contains duplicates of root-level tool files. Purpose unclear; may be legacy or alternate import path.

---

## Images

```
images/
├── baby_llm.png                 # Visual for notebook 1
├── rag.png                      # Visual for notebook 2
├── student_basic_tools.png      # Visual for notebook 3
├── student_tools.png            # Visual for notebook 4
├── foundry_tools.png            # Visual for notebook 5
├── agent_actions.png            # Visual for notebook 6
└── multi_agent.png              # Visual for notebook 7
```

**Purpose**: Visual assets used in README and notebook markdown cells

**Usage**: Displayed via markdown image tags in notebooks and README

---

## VS Code

```
.vscode/
└── settings.json                # VS Code workspace settings
```

**Purpose**: VS Code configuration (Python interpreter, formatters, etc.)

---

## Gitignore

### .gitignore
**Excluded from Git**:
- `.env` (secrets)
- `.venv/`, `venv/`, `env/` (virtual environments)
- `__pycache__/`, `*.pyc` (Python cache)
- `.DS_Store` (macOS)
- `downloaded__*.png` (notebook output files)

**Included in Git**:
- `.env.example` (template)
- `uv.lock` (for reproducible builds)
- All notebooks, Python code, infrastructure

---

## File Naming Conventions

### Notebooks
**Pattern**: `{number}-{descriptive-name}.ipynb`
- Sequential numbering (1-7)
- Hyphen-separated descriptive name
- Variants use number + suffix (e.g., `6-mcp-pg.ipynb`)

### Python Modules
**Pattern**: `snake_case.py`
- Lowercase with underscores
- Descriptive names (e.g., `books_tool.py`, `mcp_playwright.py`)

### Infrastructure
**Bicep**: `kebab-case.bicep`
- Example: `ai-foundry.bicep`, `function-app-with-plan.bicep`

**Scripts**: `snake_case.sh` or `snake_case.ps1`
- Example: `populate_env.sh`, `populate_env.ps1`, `setup_local.sh`

### Documentation
**Pattern**: `kebab-case.md` or `PascalCase.md`
- Example: `coding-standards.md`, `README.md`, `BUGBUSTER.md`

---

## Directory Navigation Tips

### Finding Agent Setup Code
Look in: `setup.py` (root level)

### Finding Infrastructure
- **Bicep**: `/infra/main.bicep` and `/infra/modules/`
- **Automation Scripts**: `/scripts/populate_env.sh` and `/scripts/populate_env.ps1`

### Finding Tools
- **Root level**: `*_tool.py`, `*_sql.py`, `AzureStandardLogicAppTool.py`
- **Helpers**: `/helpers/` (duplicates)

### Finding Documentation
- **Project Docs**: `/docs/`
- **Notebooks**: Root level (`*.ipynb`)
- **README**: `/README.md`

### Finding Configuration
- **Python**: `pyproject.toml`, `.python-version`
- **Azure**: `.env.example`, `azure.yaml`
- **Automation**: `azure.yaml` (post-provision hooks)

---

## Important Files for Development

### Must Read Before Starting
1. `README.md`: Project overview and setup instructions
2. `docs/architecture.md`: Technical architecture
3. `docs/architecture/coding-standards.md`: Coding conventions
4. `docs/architecture/tech-stack.md`: Technology reference
5. `docs/architecture/source-tree.md`: This document

### Key Configuration Files
1. `.env.example`: Required environment variables
2. `pyproject.toml`: Python dependencies
3. `infra/main.bicep`: Infrastructure definition
4. `azure.yaml`: Azure Developer CLI configuration

### Entry Points for Code Understanding
1. `setup.py`: Core agent utilities
2. `7-agent.ipynb`: Complete multi-agent example
3. `AzureStandardLogicAppTool.py`: Logic Apps integration pattern

---

**END OF SOURCE TREE**

*This source tree document provides comprehensive navigation guidance for the Azure AI Foundry Agents repository structure.*
