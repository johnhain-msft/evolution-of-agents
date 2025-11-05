# Azure AI Foundry Agents - Brownfield Enhancement PRD

## Intro Project Analysis and Context

### Existing Project Overview

#### Analysis Source
- **Source**: Fresh IDE-based analysis combined with existing repository documentation
- **Date**: 2025-11-04
- **Analyst**: PM John & Architect Winston

#### Current Project State

**Azure AI Foundry Agents** is an educational Python repository that demonstrates the evolution of AI agents from basic LLMs to sophisticated multi-agent orchestration systems. The project serves as a hands-on learning resource with 7 progressive Jupyter notebooks, each building upon the previous to showcase increasingly advanced agent capabilities.

**Current Functionality:**
- **Educational Journey**: 7 sequential notebooks demonstrating agent evolution
- **Technology Showcase**: Azure AI Foundry, Semantic Kernel, MCP integration
- **Real-world Integration**: Logic Apps workflows, Bing grounding, browser automation
- **Infrastructure**: Bicep-based Infrastructure as Code for Azure deployment

### Available Documentation Analysis

**Existing Documentation:**
- ✓ README.md with project overview and basic setup instructions (Linux/Mac focus)
- ✓ Tech Stack defined in pyproject.toml
- ✓ Bicep infrastructure modules (comprehensive Azure resource definitions)
- ✓ .env.example showing required configuration
- ✓ Setup scripts (setup_local.sh for bash, minimal setup_local.ps1 for PowerShell)
- ✓ API Documentation (weather.json OpenAPI spec)
- ✗ Windows-specific setup instructions (MISSING)
- ✗ Fully automated infrastructure deployment (Bicep may have issues)
- ✗ Comprehensive developer onboarding guide

**Critical Gaps Identified:**
1. The project currently assumes Linux/Mac development environment. Windows developers face friction during setup without PowerShell-equivalent commands and Windows-specific troubleshooting guidance.
2. Bicep infrastructure deployment may be broken or incomplete, requiring manual configuration steps that create friction for new developers.

### Enhancement Scope Definition

#### Enhancement Type
- ☑ Developer Experience Enhancement
- ☐ New Feature Addition
- ☐ Major Feature Modification
- ☐ Integration with New Systems
- ☐ Performance/Scalability Improvements
- ☐ UI/UX Overhaul
- ☐ Technology Stack Upgrade
- ☐ Bug Fix and Stability Improvements

#### Enhancement Description

This brownfield enhancement improves developer experience by (1) adding comprehensive Windows setup documentation to enable Windows developers to successfully run all 7 notebooks, and (2) fixing and enhancing the existing Bicep infrastructure to achieve fully automated one-command deployment with auto-populated environment variables.

#### Impact Assessment
- ☑ Minimal Impact (isolated additions + targeted Bicep fixes)
- ☐ Moderate Impact (some existing code changes)
- ☐ Significant Impact (substantial existing code changes)
- ☐ Major Impact (architectural changes required)

**Rationale**: Enhancements are primarily additive. Windows documentation extends README. Bicep fixes are targeted updates to existing `/infra` modules to resolve deployment issues. Automation scripts add new post-provision hooks. No Python code or notebook changes required.

### Goals and Background Context

#### Goals

- Enable Windows developers to successfully set up and run all 7 notebooks without friction
- Provide parity between Linux/Mac and Windows setup experiences
- Achieve one-command infrastructure deployment (`azd up` provisions everything)
- Eliminate manual environment variable configuration (auto-populate `.env` file)
- Reduce onboarding time for all developers regardless of OS
- Fix broken/incomplete Bicep infrastructure to support all 7 notebooks
- Ensure all Azure resources across all 7 notebooks can be deployed successfully

#### Background Context

**Why This Enhancement is Needed:**

The Azure AI Foundry Agents project has seen growing interest from the developer community, particularly those working in Windows-dominated enterprise environments. Feedback indicates that Windows developers encounter setup friction due to bash-centric documentation and commands. Additionally, the existing Bicep infrastructure deployment may fail or require manual configuration steps, creating barriers to adoption for developers who want to use this educational resource.

**Problem Being Solved:**

1. **Windows Developer Friction**: Setup instructions assume bash shell, leaving Windows developers to translate commands and troubleshoot Windows-specific issues independently
2. **Manual Configuration Overhead**: Developers must manually copy environment variables from deployment outputs to `.env` file, which is error-prone and time-consuming
3. **Infrastructure Deployment Issues**: Bicep deployment may fail or provision incomplete resources, blocking notebook execution
4. **Incomplete Multi-Platform Support**: Educational projects should be accessible across all major development platforms

**How It Fits with Existing Project:**

This enhancement aligns perfectly with the project's educational mission by removing barriers to learning. By supporting Windows developers and automating infrastructure deployment, we expand the project's accessibility while maintaining all existing functionality and improving reliability.

### Change Log

| Change | Date | Version | Description | Author |
|--------|------|---------|-------------|--------|
| Initial PRD | 2025-11-04 | 1.0 | Created brownfield enhancement PRD for Developer Experience Improvements | PM John |
| Scope Correction | 2025-11-05 | 1.1 | Corrected Story 1.2 from "Terraform Alternative" to "Bicep Infrastructure Fixes & Automation Enhancement" | PM John |

---

## Requirements

### Functional Requirements

**FR1**: README.md shall include a dedicated "Windows Setup Instructions" section providing step-by-step guidance for Windows developers, including PowerShell command equivalents for all setup operations.

**FR2**: Windows setup instructions shall cover all critical setup steps: Python environment setup with `uv`, virtual environment creation, dependency installation via `uv sync`, `.env` file creation and configuration, and Jupyter kernel selection in VS Code.

**FR3**: Windows setup instructions shall include a troubleshooting section addressing common Windows-specific issues: path separator differences, PowerShell execution policies, Windows Defender/antivirus interference, and WSL vs native Windows considerations.

**FR4**: Bicep infrastructure deployment (`azd up`) shall successfully provision all Azure resources required across all 7 notebooks without errors, including: Azure AI Foundry instance, AI Project with capability hosts, GPT model deployments (gpt-35-turbo minimum, gpt-4.1 preferred), VNet with appropriate subnets (agent subnet with Microsoft.AI/agents delegation), Azure Logic Apps Standard with 4 workflows (create_event, get_events, email_me, get_current_time), Bing grounding connection, browser automation (Playwright) connection, Azure AI Search (for RAG), Azure Storage, Log Analytics workspace, and Application Insights.

**FR5**: Bicep deployment shall fix any existing errors in `/infra` modules preventing successful resource provisioning, ensuring idempotent deployment in clean Azure subscriptions.

**FR6**: Environment variables shall be automatically populated in `.env` file after deployment completes, eliminating manual copying from `azd env get-values` output.

**FR7**: Automation scripts shall be cross-platform compatible (bash for Linux/Mac, PowerShell for Windows), executed via `azure.yaml` post-provision hooks.

**FR8**: README documentation shall clearly explain the complete setup process including any unavoidable manual steps (e.g., Office 365 OAuth consent for Logic Apps connectors).

### Non-Functional Requirements

**NFR1**: Windows setup instructions shall be written at a beginner-friendly level, assuming minimal PowerShell knowledge and providing clear explanations for each step.

**NFR2**: Bicep infrastructure fixes shall maintain backwards compatibility with existing deployments where possible, avoiding breaking changes for users who have already deployed.

**NFR3**: Complete infrastructure deployment (`azd up`) shall not exceed 25 minutes from authentication to fully provisioned and configured environment (including `.env` auto-population).

**NFR4**: Documentation additions shall follow the existing README.md style, formatting, and tone to maintain consistency.

**NFR5**: Bicep module updates shall follow Azure Bicep best practices and maintain the existing modular organization structure in `/infra/modules/`.

**NFR6**: All Bicep infrastructure fixes and automation scripts shall be validated and tested in a clean Azure subscription to ensure successful deployment from scratch.

### Compatibility Requirements

**CR1: Existing Setup Process Compatibility**: Windows setup instructions shall complement, not replace, existing Linux/Mac instructions. Both shall coexist in the README with clear OS-specific sections.

**CR2: Infrastructure Backwards Compatibility**: Bicep infrastructure fixes shall maintain compatibility with existing deployments where possible, minimizing disruption for users who have already provisioned resources.

**CR3: Environment Variable Consistency**: Auto-populated `.env` file shall contain all environment variables in the same format and names as currently expected by notebooks and `setup.py`.

**CR4: Cross-Platform Automation**: Automation scripts shall work identically on Linux, macOS, and Windows 11, detecting OS and using appropriate commands (bash vs PowerShell).

**CR5: No Breaking Changes to Code**: This enhancement shall not modify any existing Python code or notebook cells. All changes limited to infrastructure, automation scripts, and documentation.

---

## Technical Constraints and Integration Requirements

### Existing Technology Stack

**Languages & Runtimes:**
- Python: >= 3.11 (specified in pyproject.toml)
- PowerShell: >= 5.1 (for Windows setup and automation scripts)
- Bash: >= 4.0 (for Linux/Mac automation scripts)

**Frameworks & SDKs:**
- azure-ai-agents: >= 1.2.0b1
- azure-search-documents: >= 11.6.0b12
- semantic-kernel[azure,mcp]: >= 1.35.2
- ipykernel: >= 6.30.1
- pandas: >= 2.3.1
- duckdb: >= 1.0.0
- jsonref: >= 1.1.0

**Development Tools:**
- Package Manager: `uv` (modern Python package manager)
- Formatter: black[jupyter] >= 25.1.0
- IDE: VS Code (primary), Jupyter Lab (alternative)

**Azure Services:**
- Azure AI Foundry
- Azure OpenAI Service (GPT-35-turbo, GPT-4.1, GPT-5-mini)
- Azure Logic Apps Standard
- Azure Virtual Network
- Azure Application Insights
- Azure Log Analytics
- Azure Storage (for AI dependencies)
- Azure Search (for AI dependencies)

**Infrastructure as Code:**
- Bicep with Azure Verified Modules (AVM) - to be fixed and enhanced
- Azure Developer CLI (`azd`) - orchestrates Bicep deployment and automation hooks

### Integration Approach

**Documentation Integration Strategy**:
- Windows setup section will be added to README.md after the existing "How to Use" section
- Clear visual separation with appropriate headers and formatting
- Cross-reference to existing setup steps where procedures overlap
- Troubleshooting subsection specific to Windows issues
- Document complete one-command deployment process (`azd auth login` + `azd up`)

**Infrastructure Fix & Automation Strategy**:
- Fix existing Bicep modules in `/infra` directory (targeted updates)
- Enhance `azure.yaml` with post-provision hooks for automation
- Create cross-platform scripts: `scripts/populate_env.sh` (bash) and `scripts/populate_env.ps1` (PowerShell)
- Scripts auto-populate `.env` file from `azd env get-values` output
- Maintain backwards compatibility with existing deployments where possible

**Testing Integration Strategy**:
- Windows setup instructions shall be validated on actual Windows 11 systems
- Bicep deployment fixes shall be tested in clean Azure subscription
- Automation scripts tested on Linux, macOS, and Windows 11
- Verification checklist: all notebooks run successfully after automated deployment
- Environment variable validation to ensure `.env` file has correct format and values

### Code Organization and Standards

**File Structure Approach**:
```
evolution-of-agents/
├── README.md                    # ENHANCED - Windows setup section added
├── azure.yaml                   # ENHANCED - Post-provision hooks added
├── scripts/
│   ├── setup_local.sh          # EXISTING - May need enhancement
│   ├── populate_env.sh         # NEW - Auto-populate .env (bash)
│   └── populate_env.ps1        # NEW - Auto-populate .env (PowerShell)
├── infra/                       # FIXED - Bicep modules corrected
│   ├── main.bicep              # Fixes applied as needed
│   └── modules/                # Fixes applied to relevant modules
│       ├── networking/
│       ├── ai/
│       ├── function/
│       └── monitor/
├── .env                         # AUTO-GENERATED - Created by automation scripts
└── (all other existing files)   # UNCHANGED
```

**Naming Conventions**:
- Bicep files: kebab-case (existing convention, e.g., `ai-foundry.bicep`)
- Script files: snake_case (e.g., `populate_env.sh`, `populate_env.ps1`)
- Azure resources: Follow existing Bicep naming patterns
- Environment variables: UPPER_SNAKE_CASE (e.g., `AZURE_AI_FOUNDRY_CONNECTION_STRING`)

**Coding Standards**:
- Bicep: Follow Azure Bicep best practices and existing project patterns
- PowerShell: Follow PowerShell style guide for automation scripts
- Bash: Follow shell scripting best practices for automation scripts
- Documentation: Markdown with GitHub-flavored syntax
- Code comments: Explain WHY for complex configurations, not WHAT
- Resource dependencies: Use explicit `dependsOn` in Bicep where needed

**Documentation Standards**:
- All new sections follow existing README structure and tone
- Code blocks use appropriate syntax highlighting
- Step-by-step instructions numbered for clarity
- Prerequisites clearly listed before procedural steps
- External links use descriptive text, not raw URLs

### Deployment and Operations

**Build Process Integration**:
- Windows setup: No build process changes, pure documentation
- Bicep fixes: Targeted updates to existing `/infra` modules
- Automation: Post-provision scripts triggered by `azd` hooks
- Enhanced deployment process maintains simplicity (single command)

**Deployment Strategy**:
- **Enhanced Bicep Deployment**: `azd auth login` → `azd up` → automated `.env` creation
- Post-provision hooks automatically run cross-platform scripts
- Scripts detect OS and use appropriate commands (bash or PowerShell)
- Complete setup achieved with minimal user intervention

**Configuration Management**:
- `.env` file automatically created and populated after `azd up` completes
- Automation scripts extract values from `azd env get-values`
- Format matches `.env.example` template structure
- Manual configuration steps eliminated (except unavoidable items like OAuth consent)
- `.env.example` remains the source of truth for required variables

**Monitoring and Logging**:
- No changes to existing monitoring configuration
- Fixed Bicep ensures Log Analytics and Application Insights deploy correctly
- Notebook telemetry configuration unchanged

### Risk Assessment and Mitigation

**Technical Risks**:
1. **Risk**: Windows-specific environment issues not covered in documentation
   - **Mitigation**: Test on Windows 11 systems and document discovered issues
   - **Mitigation**: Include WSL as fallback option in troubleshooting

2. **Risk**: Bicep infrastructure fixes introduce breaking changes for existing users
   - **Mitigation**: Test fixes in clean subscription AND update existing deployment
   - **Mitigation**: Maintain backwards compatibility where possible
   - **Mitigation**: Document any required migration steps if breaking changes unavoidable

3. **Risk**: Cross-platform automation scripts fail on certain OS configurations
   - **Mitigation**: Test on Linux (Ubuntu), macOS, and Windows 11
   - **Mitigation**: Include OS detection and appropriate fallback mechanisms
   - **Mitigation**: Document manual `.env` creation as fallback if automation fails

**Integration Risks**:
1. **Risk**: Auto-populated `.env` file missing variables or incorrect format
   - **Mitigation**: Create explicit validation checklist during testing
   - **Mitigation**: Compare output against `.env.example` template
   - **Mitigation**: Test all 7 notebooks after automated setup

2. **Risk**: Bicep fixes don't cover all 7 notebooks' resource requirements
   - **Mitigation**: Systematic validation of each notebook's Azure resource needs
   - **Mitigation**: Test all 7 notebooks end-to-end after deployment
   - **Mitigation**: Document any known limitations or manual steps

**Deployment Risks**:
1. **Risk**: Office 365 connectors require interactive OAuth that can't be automated
   - **Mitigation**: Clearly document OAuth consent flow in README troubleshooting
   - **Mitigation**: Provide step-by-step guidance with screenshots if needed
   - **Mitigation**: Explain that this is one-time setup per Logic App deployment

**Mitigation Strategies Summary**:
- Comprehensive testing on target platforms before PR merge
- Detailed troubleshooting sections in documentation
- Clear deployment method selection guidance
- Validation checklists for testers and users

---

## Epic and Story Structure

### Epic Approach

**Epic Structure Decision**: Single comprehensive epic ("Developer Experience Improvements") with 2 focused stories.

**Rationale**: Both enhancements share the common goal of improving developer onboarding and experience. They are independent implementations (documentation vs infrastructure), but both contribute to the same strategic objective: making the project accessible to a broader developer audience. A single epic provides clear tracking of the overall developer experience initiative while allowing independent story execution.

**Story Sequencing**: Stories are independent and can be executed in parallel or either-first order. Recommended sequence is Story 1.1 → Story 1.2 to establish Windows setup documentation before fixing infrastructure, but no technical dependency exists.

---

## Epic 1: Developer Experience Improvements

**Epic Goal**: Expand the accessibility and usability of the Azure AI Foundry Agents educational project by providing comprehensive Windows developer support and fixing/enhancing Bicep infrastructure automation, enabling all developers to set up and run the 7 notebooks with minimal friction.

**Integration Requirements**:
- Enhancements must maintain compatibility with existing functionality where possible
- Windows setup must achieve parity with Linux/Mac setup experience
- Fixed Bicep deployment must provision all resources required for 7 notebooks
- `.env` file must be auto-populated to eliminate manual configuration
- All 7 notebooks must run successfully after implementing both enhancements

### Story 1.1: Add Windows Setup Instructions to README

**User Story**:
As a **Windows-based developer**,
I want **comprehensive Windows-specific setup instructions in the README**,
so that **I can successfully configure my development environment and run all 7 notebooks without needing to translate Linux/Mac commands or troubleshoot Windows-specific issues independently**.

#### Acceptance Criteria

1. README.md contains a new "Windows Setup Instructions" section placed after the existing "How to Use" section
2. Windows setup section includes PowerShell command equivalents for all setup operations: `uv` installation, virtual environment setup, `uv sync` execution, `.env` file creation and editing
3. Windows setup includes explicit instructions for Jupyter kernel selection in VS Code on Windows, including screenshots or step-by-step path navigation
4. Windows path conventions are documented (backslashes vs forward slashes, path separator differences)
5. A "Windows Troubleshooting" subsection addresses common issues: PowerShell execution policy errors, path-related issues, Windows Defender/antivirus interference, WSL vs native Windows decision guidance
6. Documentation includes verification steps to confirm successful setup (e.g., running a simple Python import test)
7. Windows setup instructions maintain consistency with existing README style, tone, and formatting
8. All Windows-specific commands are tested on Windows 10 and Windows 11 systems

#### Integration Verification

**IV1: Existing Documentation Remains Intact**: All existing README sections (Linux/Mac setup, project description, visual gallery, etc.) remain unchanged and functional. No content is removed or modified outside the new Windows section.

**IV2: Linux/Mac Setup Unaffected**: Linux and Mac users can still follow existing setup instructions without confusion. Clear section headers differentiate OS-specific instructions.

**IV3: Notebook Functionality Preserved**: All 7 notebooks continue to function identically on Linux/Mac after README changes. Windows setup enables identical notebook functionality on Windows systems.

---

### Story 1.2: Fix Bicep Infrastructure and Enhance Deployment Automation

**User Story**:
As a **developer setting up the Azure AI Foundry Agents project**,
I want **one-command infrastructure deployment that automatically provisions all resources and configures my environment**,
so that **I can start running all 7 notebooks immediately without manual configuration steps, troubleshooting deployment errors, or copying environment variables**.

#### Acceptance Criteria

1. Bicep deployment (`azd up`) completes successfully without errors in clean Azure subscription
2. All Azure resources required for notebook 7 are provisioned: Azure AI Foundry with GPT deployments (gpt-35-turbo minimum, gpt-4.1 preferred), Bing grounding connection, browser automation (Playwright) connection, Logic App Standard with 4 workflows (create_event, get_events, email_me, get_current_time)
3. All Azure resources required for notebooks 1-6 are provisioned: VNet with agent subnet (Microsoft.AI/agents delegation), private endpoint subnet, AI Project, Log Analytics, Application Insights, Azure Storage, Azure AI Search (vector search capable)
4. `.env` file is automatically created and populated with all required environment variables after `azd up` completes (no manual copying from outputs)
5. Automation is cross-platform: works on Linux, macOS, and Windows 11 (bash and PowerShell scripts)
6. Post-provision hooks in `azure.yaml` trigger automation scripts that extract values from `azd env get-values` and create `.env` file
7. README.md documents complete setup process: prerequisites, `azd auth login`, `azd up`, `uv sync`, kernel selection
8. README.md documents any required manual steps that cannot be automated (e.g., Office 365 OAuth consent for Logic Apps connectors)
9. Bicep modules in `/infra` are fixed to resolve any deployment errors or missing resource configurations
10. Deployment is tested in clean Azure subscription with standard Contributor role permissions
11. All 7 notebooks are tested end-to-end on Windows 11 after automated deployment
12. Cross-platform automation tested on Linux, macOS, and Windows 11

#### Integration Verification

**IV1: Backwards Compatibility Maintained**: Bicep infrastructure fixes maintain compatibility with existing deployments where possible. Breaking changes are documented with migration guidance.

**IV2: Environment Variable Completeness Verified**: Auto-populated `.env` file contains all variables from `.env.example` with correct names and formats. All notebooks can load configuration successfully.

**IV3: No Code Changes Required**: No changes to Python code, notebook cells, or `setup.py` are necessary. Notebooks work identically before and after infrastructure enhancements.

**IV4: Automation Reliability Validated**: Automation scripts work consistently across Linux (Ubuntu), macOS, and Windows 11. Fallback to manual `.env` creation is documented if automation fails.

**IV5: Complete Infrastructure Coverage**: All 7 notebooks run successfully after deployment, validating that Bicep provisions complete and correct Azure resources.

---

## Definition of Done (Epic Level)

- ✅ Story 1.1 completed: Windows setup instructions merged into README.md
- ✅ Story 1.2 completed: Bicep fixes and automation enhancements validated and merged
- ✅ All acceptance criteria for both stories met and verified
- ✅ Integration verification checklists completed for both stories
- ✅ Regression testing: All 7 notebooks run successfully on Linux, Mac, AND Windows 11
- ✅ Infrastructure testing: All 7 notebooks run successfully after automated `azd up` deployment
- ✅ Automation testing: `.env` file auto-populated correctly on Linux, macOS, and Windows 11
- ✅ Documentation review: All new documentation is clear, accurate, and consistent with project style
- ✅ No existing functionality broken or degraded by enhancements
- ✅ Pull request(s) approved and merged into main branch
- ✅ Community testing: At least one Windows user validates the complete automated setup externally (if possible)

---

## Appendix: Azure Resources Detailed Inventory

### Resources Required for All Notebooks

| Resource Type | Purpose | Notebook(s) | Notes |
|---------------|---------|-------------|-------|
| Azure AI Foundry Hub | Central AI management | All | Parent resource |
| AI Foundry Project | Agent workspace | All | Contains agent definitions |
| GPT-35-turbo deployment | LLM for notebooks 1-4 | 1, 2, 3, 4 | OpenAI model |
| GPT-4.1 deployment | Advanced LLM | 5, 6, 7 | GlobalStandard SKU |
| GPT-5-mini deployment | Latest model option | 7 | GlobalStandard SKU |
| Virtual Network | Network isolation | 7 | With delegated subnet for agents |
| Agent Subnet | AI Foundry agents networking | 7 | Delegated to Microsoft.AI/agents |
| Private Endpoint Subnet | PE connectivity | 7 | For storage, search, etc. |
| Azure Storage Account | AI dependencies | All | For AI Foundry |
| Azure AI Search | RAG capabilities | 2 | Vector search |
| Log Analytics Workspace | Monitoring | All | Telemetry collection |
| Application Insights | Application monitoring | All | Semantic Kernel telemetry |
| Bing Grounding Connection | Web search | 7 | External API connection |
| Playwright Connection | Browser automation | 7 | For blog management |
| Logic App Standard | Workflow automation | 7 | Function app-based |
| Logic App Workflows (4x) | Office 365 integration | 7 | create_event, get_events, email_me, get_current_time |
| Office 365 API Connection | Email/calendar access | 7 | For Logic App workflows |
| Managed Identity | Azure authentication | All | User-assigned for app |
| Private DNS Zones | Private endpoint DNS | 7 | For blob storage, websites |

### Notebook 7 Specific Requirements (Most Complex)

Notebook 7 requires ALL of the above resources. The fixed Bicep configuration must ensure complete notebook 7 functionality, which will automatically satisfy requirements for notebooks 1-6.

**Critical Connections for Notebook 7:**
- Bing grounding connection (for news agent web research)
- Playwright connection (for blog agent browser automation)
- Logic App workflows (for calendar/email agent Office 365 integration)
- Custom date/time workflow (get_current_time)

**Testing Validation**: If notebook 7 runs end-to-end successfully with all agent interactions working (weather, news, calendar, email, blog), the infrastructure is complete.

---

**END OF PRD**

*This Product Requirements Document provides comprehensive guidance for enhancing the Azure AI Foundry Agents project with Windows developer support and Bicep infrastructure fixes/automation. Both enhancements are designed to expand project accessibility and reduce developer friction while maintaining full compatibility with existing functionality.*

**Scope Correction Note (2025-11-05)**: Original v1.0 incorrectly scoped Story 1.2 as "Terraform Alternative". Corrected in v1.1 to "Bicep Infrastructure Fixes & Automation Enhancement" based on actual project requirements and existing Bicep infrastructure.
