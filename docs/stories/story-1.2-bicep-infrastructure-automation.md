# Story 1.2: Fix Bicep Infrastructure and Enhance Deployment Automation - Brownfield Enhancement

**Epic**: Epic 1 - Developer Experience Improvements
**Story Type**: Brownfield Infrastructure Fix & Enhancement
**Status**: Draft
**Created**: 2025-11-05
**Updated**: 2025-11-05 (Scope corrected from Terraform to Bicep enhancement)
**Testing Environment**: Azure Subscription, Windows 11

---

## User Story

As a **developer setting up the Azure AI Foundry Agents project**,
I want **one-command infrastructure deployment that automatically provisions all resources and configures my environment**,
so that **I can start running all 7 notebooks immediately without manual configuration steps, troubleshooting deployment errors, or copying environment variables**.

---

## Story Context

### Existing System Integration

**Integrates with**:
- Existing Bicep infrastructure in `/infra` directory (to be fixed and enhanced)
- `azure.yaml` configuration (Azure Developer CLI orchestration)
- `.env.example` (environment variable template)
- All 7 Python notebooks (infrastructure consumers)
- `scripts/setup_local.sh` (post-deployment automation)

**Technology**: Bicep IaC, Azure Developer CLI (azd), Azure platform services, PowerShell/Bash scripts

**Follows pattern**: Azure Developer CLI best practices for infrastructure automation

**Touch points**:
- `/infra/` directory (fix broken Bicep modules)
- `azure.yaml` (enhance azd hooks for automation)
- `.env` file (auto-populate from deployment outputs)
- All 7 notebooks (verify complete infrastructure support)
- README.md (document minimal manual setup requirements)

### Problem Statement

**Current Issues:**
1. Bicep deployment may fail or provision incomplete infrastructure
2. Not all 7 notebooks are fully supported by current infrastructure
3. Manual `.env` file population required (error-prone, slow)
4. `azd up` doesn't fully automate the setup process
5. Missing documentation for required manual steps

**Desired End State:**
- `azd auth login` + `azd up` = complete working environment
- All 7 notebooks run successfully after deployment
- `.env` file auto-populated with all required variables
- Clear documentation for any unavoidable manual steps (e.g., Office 365 OAuth)

---

## Acceptance Criteria

### Functional Requirements - Infrastructure Completeness

**AC1**: Bicep deployment completes successfully without errors when running `azd up` in a clean Azure subscription

**AC2**: All Azure resources required for **notebook 7** (most comprehensive) are provisioned:
- Azure AI Foundry Hub with AI Project
- GPT model deployments: gpt-35-turbo (minimum), gpt-4.1 (preferred)
- Bing grounding connection for AI Foundry
- Browser automation (Playwright) connection for AI Foundry
- Azure Logic App Standard with **4 workflows**: create_event, get_events, email_me, get_current_time
- Office 365 API connections for Logic Apps (with setup documentation)

**AC3**: All Azure resources required for notebooks 1-6 are provisioned:
- VNet with appropriate subnets (agent subnet with Microsoft.AI/agents delegation, private endpoint subnet)
- Azure Storage Account (for AI dependencies)
- Azure AI Search (for RAG in notebook 2)
- Log Analytics Workspace
- Application Insights
- Managed Identity (user-assigned) for Azure authentication
- Private DNS zones for private endpoints (blob storage, websites)

**AC4**: Resource configurations are validated to work with all notebooks:
- AI Search supports vector search (notebook 2)
- Logic Apps workflows are deployed and accessible (notebook 7)
- Bing connection is configured correctly (notebook 7 news agent)
- Playwright connection is configured correctly (notebook 7 blog agent)

### Functional Requirements - Automation & Environment Setup

**AC5**: `.env` file is **automatically created and populated** with all required environment variables after `azd up` completes:
- No manual copying from `azd env get-values` required
- All variables from `.env.example` are populated with actual values
- Automation via `azd` post-provision hooks or enhanced `scripts/setup_local.sh`

**AC6**: Environment variable population includes:
- `AZURE_OPENAI_CHAT_DEPLOYMENT_NAME`
- `AZURE_AI_FOUNDRY_CONNECTION_STRING`
- `AZURE_AI_FOUNDRY_SUBSCRIPTION_ID`
- `AZURE_AI_FOUNDRY_RESOURCE_GROUP`
- `AZURE_AI_FOUNDRY_NAME`
- `AZURE_AI_FOUNDRY_PROJECT_NAME`
- `AZURE_TENANT_ID`
- `LOGIC_APP_SUBSCRIPTION_ID`
- `LOGIC_APP_RESOURCE_GROUP`
- `LOGIC_APP_NAME`
- Any other variables required by notebooks

**AC7**: `azd up` is the **only command** needed for infrastructure deployment (post-authentication with `azd auth login`):
- No additional manual Azure CLI commands required
- No manual resource configuration via Azure Portal required
- Deployment time is reasonable (≤25 minutes for full infrastructure)

**AC8**: Cross-platform automation support:
- Automation works on Linux/Mac (bash scripts)
- Automation works on Windows 11 (PowerShell scripts or cross-platform approach)
- Scripts detect OS and use appropriate commands

### Quality Requirements - Reliability & Testing

**AC9**: All 7 notebooks execute successfully on **Windows 11** after infrastructure deployment:
- Notebook 1 (Just LLM): Basic chat works
- Notebook 2 (RAG): Azure AI Search vector retrieval works
- Notebook 3-4 (Tools): Function calling and tool integrations work
- Notebook 5 (Foundry Tools): Code interpreter and Foundry tools work
- Notebook 6 (MCP): Model Context Protocol integration works
- Notebook 7 (Multi-agent): All 5 agents work (main orchestrator, office, weather, news, blog)

**AC10**: End-to-end deployment is tested in **clean Azure subscription** (no pre-existing resources):
- Test account has only Contributor role (standard developer permissions)
- Deployment succeeds without requiring elevated permissions or manual Azure Portal steps
- Cleanup via `azd down` removes all resources successfully

**AC11**: Bicep configuration passes validation:
- `az bicep build` succeeds for all Bicep files
- No warnings or errors in Bicep linter
- Follows Azure Bicep best practices

### Documentation Requirements

**AC12**: README.md clearly documents the **complete setup process**:
- Prerequisites listed (Azure subscription, Azure Developer CLI, Python, uv)
- Setup steps clearly ordered: `azd auth login`, `azd up`, `uv sync`, notebook kernel selection
- Sections for both Linux/Mac and Windows 11

**AC13**: README.md documents any **required manual steps** that cannot be automated:
- Office 365 OAuth consent flow for Logic Apps connectors (if applicable)
- Azure subscription selection during `azd up` (if multiple subscriptions)
- Tenant ID or subscription ID if required upfront
- Any Azure quota increase requests if needed (e.g., GPT-4 models)

**AC14**: Troubleshooting section updated in README:
- Common deployment errors and solutions
- How to verify deployment success
- How to clean up and retry deployment (`azd down`, `azd up`)
- Where to check logs if deployment fails

### Integration Requirements

**AC15**: Existing Python code, notebooks, and `setup.py` remain **completely unmodified**:
- No code changes required to support enhanced infrastructure
- Notebooks work identically before and after infrastructure enhancements
- `setup.py` helper functions continue to work with enhanced infrastructure

**AC16**: Git diff shows only infrastructure and automation changes:
- Changes limited to `/infra/`, `azure.yaml`, `scripts/`, and README.md
- No changes to notebook files (`.ipynb`)
- No changes to Python source files (`.py`)

---

## Technical Notes

### Integration Approach

**Bicep Infrastructure Fixes** (Priority 1):
- Audit all Bicep modules in `/infra/modules/` for correctness
- Fix any syntax errors, missing dependencies, or misconfigured resources
- Validate that all 7 notebooks' resource requirements are met
- Test deployment in clean Azure subscription

**Automation Enhancement** (Priority 2):
- Enhance `azure.yaml` with post-provision hooks to auto-create `.env`
- Option A: Use `azd` hooks to run script after deployment
- Option B: Enhance `scripts/setup_local.sh` to auto-run after `azd up`
- Option C: Create new cross-platform script called by `azd` hooks

**Environment Variable Automation Logic**:
```bash
# Example approach (bash):
# Post-provision hook in azure.yaml runs this script
azd env get-values > .env.temp
# Parse and format into .env
cat .env.temp | while read line; do
  echo "$line" >> .env
done
rm .env.temp
echo ".env file created successfully"
```

**Windows 11 Compatibility**:
- Provide PowerShell equivalent for any bash-specific automation
- OR: Use Python script for cross-platform compatibility
- Test on Windows 11 to verify automation works

### Key Constraints

- Must not break existing Bicep deployment for users who have already deployed
- Must work with Azure Developer CLI standard workflow
- Must support both Windows and Linux/Mac environments
- Cannot require elevated permissions beyond Contributor role
- Office 365 connections may require user interaction (document clearly)

### Bicep Resources to Validate

**Networking** (`/infra/modules/networking/`):
- VNet with correct address space
- Agent subnet with Microsoft.AI/agents delegation
- Private endpoint subnet
- NSGs configured correctly
- Private DNS zones for blob.core.windows.net, websites

**AI Foundry** (`/infra/modules/ai/`):
- Cognitive Account (AI Foundry Hub) with correct SKU
- AI Project with capability hosts (Foundry Standard mode)
- Model deployments (GPT-35-turbo, GPT-4.1) with correct parameters
- Bing grounding connection
- Playwright connection
- Storage account for AI dependencies

**Logic Apps** (`/infra/modules/function/`):
- App Service Plan (Workflow Standard SKU: WS1)
- Logic App Standard (Function App-based)
- 4 workflow definitions deployed from `/src/workflows/`
- Office 365 API connections
- Managed identity for authentication
- VNet integration

**Monitoring** (`/infra/modules/monitor/`):
- Log Analytics Workspace
- Application Insights linked to workspace

---

## Definition of Done

- [x] **Story scope corrected** from Terraform to Bicep enhancement (PM task completed)
- [ ] Bicep infrastructure audited and all errors fixed
- [ ] All 16 acceptance criteria (AC1-AC16) met and verified
- [ ] `azd up` tested in clean Azure subscription → completes successfully
- [ ] `.env` file auto-populated after deployment (no manual steps)
- [ ] All 7 notebooks tested on Windows 11 → run successfully
- [ ] README.md updated with complete setup documentation
- [ ] Troubleshooting section added to README
- [ ] Cross-platform automation tested (Linux/Mac and Windows 11)
- [ ] Git diff reviewed: Only `/infra/`, `azure.yaml`, `scripts/`, README.md changed
- [ ] Code review approved by maintainer
- [ ] PR merged to main branch

---

## Testing Checklist

### Infrastructure Deployment Testing

- [ ] **Prerequisites Verified**:
  - [ ] Clean Azure subscription (no pre-existing resources in target resource group)
  - [ ] Azure Developer CLI installed (`azd version`)
  - [ ] Azure CLI installed (`az --version`)
  - [ ] Authenticated with Azure (`azd auth login`)

- [ ] **Deployment Test (Linux/Mac)**:
  - [ ] Run `azd up` from repository root
  - [ ] Deployment completes without errors (allow up to 25 minutes)
  - [ ] Verify all Azure resources created in Azure Portal
  - [ ] Verify `.env` file created automatically in repository root
  - [ ] Verify `.env` file contains all required variables

- [ ] **Deployment Test (Windows 11)**:
  - [ ] Run `azd up` from repository root in PowerShell
  - [ ] Deployment completes without errors
  - [ ] Verify `.env` file created automatically
  - [ ] Verify `.env` file contains all required variables

### Notebook Execution Testing (Windows 11)

- [ ] **Environment Setup**:
  - [ ] `.env` file exists and is populated
  - [ ] Python dependencies installed (`uv sync`)
  - [ ] VS Code Jupyter kernel selected (`.venv\Scripts\python.exe`)

- [ ] **Notebook Tests**:
  - [ ] **Notebook 1 (Just LLM)**: Run all cells → Basic chat works
  - [ ] **Notebook 2 (RAG)**: Run all cells → Azure AI Search retrieval works
  - [ ] **Notebook 3 (Tools)**: Run all cells → Function calling works
  - [ ] **Notebook 4 (Better Tools)**: Run all cells → Improved tools work
  - [ ] **Notebook 5 (Foundry Tools)**: Run all cells → Code interpreter works
  - [ ] **Notebook 6 (MCP)**: Run all cells → MCP integration works
  - [ ] **Notebook 7 (Multi-agent)**: Run all cells → All agents work:
    - [ ] Main orchestrator agent (AdvisorGPT)
    - [ ] Office agent (calendar + email via Logic Apps)
    - [ ] Weather agent (OpenAPI tool)
    - [ ] News agent (Bing grounding)
    - [ ] Blog agent (Playwright automation)

### Automation Testing

- [ ] **Environment Variable Automation**:
  - [ ] Delete `.env` file if exists
  - [ ] Run `azd up` (or post-provision script)
  - [ ] Verify `.env` file auto-created
  - [ ] Verify all variables match `azd env get-values` output
  - [ ] Verify variable format matches `.env.example` structure

- [ ] **Cross-Platform Compatibility**:
  - [ ] Automation works on Linux (Ubuntu/Debian)
  - [ ] Automation works on macOS
  - [ ] Automation works on Windows 11 (PowerShell)

### Cleanup & Retry Testing

- [ ] **Infrastructure Cleanup**:
  - [ ] Run `azd down` → Resources deleted successfully
  - [ ] Verify in Azure Portal: Resource group deleted or empty
  - [ ] Run `azd up` again → Deployment succeeds (idempotency test)

---

## Implementation Guidance

### Phase 1: Audit & Fix Bicep Infrastructure

1. **Test Current Deployment**:
   - Run `azd up` in clean subscription
   - Document all errors encountered
   - Identify missing or misconfigured resources

2. **Fix Bicep Modules**:
   - Review `/infra/main.bicep` for orchestration issues
   - Fix individual modules in `/infra/modules/` based on errors
   - Validate Bicep syntax: `az bicep build --file infra/main.bicep`

3. **Verify Resource Completeness**:
   - Compare deployed resources against notebook requirements
   - Add any missing resources (e.g., Bing connection, Playwright connection)
   - Ensure model deployments are correct

### Phase 2: Enhance Automation

1. **Implement .env Auto-Population**:

   **Option A - azd Hooks (Recommended)**:
   Update `azure.yaml`:
   ```yaml
   hooks:
     postprovision:
       windows:
         shell: pwsh
         run: ./scripts/populate_env.ps1
       posix:
         shell: sh
         run: ./scripts/populate_env.sh
   ```

   Create `scripts/populate_env.sh`:
   ```bash
   #!/bin/bash
   echo "Populating .env file from deployment outputs..."
   azd env get-values > .env
   echo ".env file created successfully!"
   ```

   Create `scripts/populate_env.ps1`:
   ```powershell
   Write-Host "Populating .env file from deployment outputs..."
   azd env get-values | Out-File -FilePath .env -Encoding utf8
   Write-Host ".env file created successfully!"
   ```

2. **Test Automation**:
   - Delete `.env` if exists
   - Run `azd up`
   - Verify `.env` auto-created after deployment
   - Verify content matches `azd env get-values` output

### Phase 3: Documentation & Testing

1. **Update README.md**:
   - Add prerequisites section
   - Document complete setup process (auth, deploy, install dependencies, run notebooks)
   - Add troubleshooting section
   - Document any manual steps (Office 365 OAuth, etc.)

2. **End-to-End Testing**:
   - Test on Windows 11 following README exactly
   - Test on Linux/Mac following README exactly
   - Document any issues encountered and solutions

---

## Risk Assessment

### Technical Risks

**Risk 1**: Current Bicep infrastructure has fundamental design flaws requiring significant rework
- **Likelihood**: Medium
- **Impact**: High (extends implementation time)
- **Mitigation**: Thorough audit phase first; if major issues found, consult with Architect agent
- **Detection**: Multiple deployment failures during testing

**Risk 2**: Office 365 API connections require interactive OAuth that cannot be fully automated
- **Likelihood**: High
- **Impact**: Medium (requires manual step documentation)
- **Mitigation**: Clearly document OAuth consent flow in README troubleshooting section
- **Detection**: Logic Apps workflows fail in notebook 7

**Risk 3**: Azure quota limits prevent model deployments (especially GPT-4)
- **Likelihood**: Medium
- **Impact**: Medium (users can't complete notebook testing)
- **Mitigation**: Document quota requirements and request process in README
- **Detection**: Deployment fails with quota exceeded errors

**Risk 4**: Cross-platform script automation introduces compatibility issues
- **Likelihood**: Low
- **Impact**: Medium (automation fails on one platform)
- **Mitigation**: Test thoroughly on Windows 11, Linux, and macOS; use Python for true cross-platform if needed
- **Detection**: `.env` not created on certain platforms

### Deployment Risks

**Risk 5**: Infrastructure costs exceed expectations during testing
- **Likelihood**: Low
- **Impact**: Low (educational project, short-term deployment)
- **Mitigation**: Document expected costs, use smallest viable SKUs, destroy resources after testing
- **Detection**: Azure cost monitoring

---

## Story Dependencies

### Dependencies
- None (independent story, can be implemented first or second)

### Benefits from
- Story 1.1 (Windows Setup): Windows setup docs reference the automated deployment

### Enables
- Story 1.1 users can follow Windows setup instructions with confidence (infrastructure will work)
- All future developers have smooth onboarding experience

---

## Notes

- **Scope Correction**: This story was originally incorrectly scoped as "Add Terraform Alternative" (Story 1.2 v1). Corrected on 2025-11-05 to focus on fixing and enhancing existing Bicep infrastructure.
- **Automation Philosophy**: Prioritize full automation over documentation of manual steps. Only document manual steps when automation is truly impossible (e.g., user OAuth consent).
- **Testing Priority**: Windows 11 testing is highest priority since Story 1.1 targets Windows developers.
- **Bicep as Source of Truth**: Bicep in `/infra` directory is the project's infrastructure standard. No Terraform alternative needed.
- **Azure Developer CLI Best Practices**: Follow `azd` conventions for hooks, environment variables, and project structure.

---

**END OF STORY 1.2**

*Created by PM John using brownfield-create-story task*
*Scope corrected 2025-11-05: Terraform → Bicep enhancement*
*Ready for Dev agent implementation*
