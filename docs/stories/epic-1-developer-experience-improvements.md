# Epic 1: Developer Experience Improvements - Brownfield Enhancement

**Epic Type**: Brownfield Enhancement
**Status**: Draft
**Created**: 2025-11-04
**Project**: Azure AI Foundry Agents Educational Repository
**Testing Environment**: Windows 11, Azure Subscription

---

## Epic Goal

Expand the accessibility and usability of the Azure AI Foundry Agents educational project by providing comprehensive Windows developer support and fixing/enhancing Bicep infrastructure automation, enabling all developers to set up and run the 7 notebooks with minimal friction.

---

## Epic Description

### Existing System Context

**Current relevant functionality**:
- Educational Python repository with 7 Jupyter notebooks demonstrating AI agent evolution
- Setup instructions focused on Linux/Mac environments with bash commands
- Bicep-based Infrastructure as Code for Azure resource deployment (may have issues)
- Environment configuration via `.env` file populated manually from infrastructure outputs

**Technology stack**:
- Python 3.11+, Azure AI Foundry SDK, Semantic Kernel, MCP
- Bicep IaC deployed via Azure Developer CLI (`azd`)
- Jupyter notebooks in VS Code or Jupyter Lab
- Azure services: AI Foundry, Logic Apps, OpenAI, VNet, monitoring

**Integration points**:
- README.md: Main documentation entry point (to be enhanced with Windows setup)
- `/infra`: Existing Bicep infrastructure (to be fixed and enhanced with automation)
- `.env.example`: Environment variable template (to be auto-populated)
- Python notebooks: Consumers of infrastructure (must work after deployment fixes)

### Enhancement Details

**What's being added/changed**:

1. **Windows Setup Documentation**: Comprehensive Windows-specific setup instructions added to README.md, including PowerShell command equivalents, Windows path conventions, and troubleshooting guidance for common Windows issues.

2. **Bicep Infrastructure Fixes & Automation Enhancement**: Fix broken/incomplete Bicep deployments and enhance automation so `azd up` handles everything (provisions all resources, auto-populates `.env` file), requiring only minimal manual setup.

**How it integrates**:
- Windows docs: Appended to existing README.md, no modification of existing sections
- Bicep fixes: Updates to existing `/infra` directory modules to fix deployment issues
- Automation: Enhanced `azure.yaml` hooks and scripts to auto-create `.env` after deployment
- Both enhancements maintain compatibility - zero modifications to Python code or notebooks

**Success criteria**:
- Windows 11 developers can successfully set up and run all 7 notebooks following new documentation
- `azd auth login` + `azd up` provides complete working environment (all resources + .env auto-populated)
- All 7 notebooks run successfully after one-command deployment
- Documentation clearly explains any unavoidable manual steps

---

## Stories

### 1. Story 1.1: Add Windows Setup Instructions to README

**Brief Description**: Create comprehensive Windows-specific setup documentation in README.md with PowerShell equivalents for all commands, Windows path conventions, kernel selection guidance, and troubleshooting section for common Windows issues.

**Key Deliverables**:
- Windows Setup Instructions section in README.md
- PowerShell command examples for all setup steps
- Windows troubleshooting subsection
- Verification tested on Windows 11

**Estimated Complexity**: Small (documentation only, no code changes)

---

### 2. Story 1.2: Fix Bicep Infrastructure and Enhance Deployment Automation

**Brief Description**: Fix broken/incomplete Bicep infrastructure deployments and enhance automation to achieve one-command deployment (`azd up`) that provisions all Azure resources and auto-populates the `.env` file, enabling immediate notebook execution with minimal manual setup.

**Key Deliverables**:
- Fixed Bicep modules in `/infra` directory (deployment completes without errors)
- Enhanced `azure.yaml` with post-provision hooks for automation
- Auto-populated `.env` file creation scripts (cross-platform: bash + PowerShell)
- README documentation of complete setup process and any required manual steps
- Tested deployment in clean Azure subscription with all 7 notebooks on Windows 11

**Estimated Complexity**: Medium (infrastructure fixes + automation scripting, requires Azure testing)

---

## Compatibility Requirements

- [x] **Existing APIs remain unchanged**: ✅ No API changes (Python code unchanged)
- [x] **Database schema changes are backward compatible**: ✅ No database changes
- [x] **UI changes follow existing patterns**: ✅ Documentation follows README style; Bicep enhancements follow Azure best practices
- [x] **Performance impact is minimal**: ✅ Zero runtime performance impact; improved deployment automation reduces manual setup time

---

## Risk Mitigation

### Primary Risk
**Risk**: Windows-specific environment issues or Bicep infrastructure fixes introduce breaking changes preventing successful notebook execution

**Mitigation**:
- Test Windows setup on Windows 11 machine
- Test Bicep fixes in clean Azure subscription first
- Maintain backwards compatibility for existing Bicep users
- Run all 7 notebooks end-to-end on Windows 11 after both enhancements
- Include comprehensive troubleshooting sections in documentation

**Rollback Plan**:
- Windows docs: Simple Git revert of README changes
- Bicep fixes: Git revert of `/infra` changes; test before merging to main
- Automation scripts: Git revert of `azure.yaml` and scripts changes
- Changes are targeted and reversible; low risk to existing functionality

---

## Definition of Done

### Epic-Level DoD

- [ ] **Story 1.1 Completed**: Windows setup instructions merged into main branch
- [ ] **Story 1.2 Completed**: Bicep fixes and automation enhancements merged into main branch
- [ ] **All Stories Acceptance Criteria Met**: Every AC verified and checked off
- [ ] **Integration Verification Passed**: All IVs for both stories completed
- [ ] **Windows 11 Testing Passed**: All 7 notebooks run successfully on Windows 11 following new setup docs
- [ ] **Automated Deployment Testing Passed**: `azd up` completes successfully, `.env` auto-populated, all 7 notebooks work
- [ ] **Documentation Quality Verified**: All new docs are clear, accurate, and consistent with project style
- [ ] **Code Review Approved**: All PRs reviewed and approved by maintainer(s)

---

## Technical Notes

### Existing System Dependencies

**Files that will be modified**:
- `README.md`: Windows setup section appended

**New files that will be created**:
- `scripts/populate_env.sh`: Bash script to auto-populate `.env` file
- `scripts/populate_env.ps1`: PowerShell script to auto-populate `.env` file
- `.env`: Auto-generated environment variables file (gitignored)
- `docs/prd.md`: This epic's PRD (already created)
- `docs/architecture.md`: Architecture document (already created)
- `docs/architecture/*.md`: Architecture shards (already created)
- `docs/stories/epic-1-*.md`: This epic file (already created)
- `docs/stories/story-1.1-*.md`: Story 1 file (already created)
- `docs/stories/story-1.2-*.md`: Story 2 file (already created - scope corrected)

**Existing patterns to follow**:
- README.md: Markdown structure with headers, code blocks, tables
- Bicep modules: Azure infrastructure best practices, modular organization
- Azure Developer CLI: azd hooks and automation patterns
- `.env.example`: Environment variable template format

### Critical Integration Points

1. **Environment Variable Auto-Population**: Automation scripts must extract all output variables from `azd env get-values` and populate `.env` file with correct format

2. **Infrastructure Completeness**: Fixed Bicep must provision ALL resources required for all 7 notebooks to function correctly

3. **Documentation Clarity**: README must document complete setup flow for both Linux/Mac and Windows 11, including any required manual steps

---

## Dependencies and Blockers

### Dependencies
- None (stories are independent and can be implemented in parallel)

### Recommended Sequence
1. **Story 1.1 (Windows Setup)** → **Story 1.2 (Terraform)**: Logical user experience flow
2. Or implement in parallel (no technical dependencies)

### Blockers
- None identified

---

## Testing Strategy

### Testing Environment
- **OS**: Windows 11 only
- **Infrastructure**: Azure subscription
- **No cross-platform testing**: Linux/Mac testing not in scope

### Story 1.1 Testing
- [ ] Test on Windows 11 machine (clean or existing)
- [ ] Verify PowerShell commands execute correctly
- [ ] Follow Windows setup docs step-by-step
- [ ] Run all 7 notebooks on Windows 11 after setup (using existing Bicep infrastructure or Terraform)

### Story 1.2 Testing
- [ ] Test Terraform deployment in Azure subscription
- [ ] Verify all resources provision successfully
- [ ] Verify Terraform outputs match expected environment variable names/formats
- [ ] Create `.env` from Terraform outputs
- [ ] Run all 7 notebooks on Windows 11 using Terraform-deployed infrastructure

### Integration Testing
- [ ] **Combined Test**: Deploy via Terraform, follow Windows setup docs, run all 7 notebooks on Windows 11 (validates both stories together)

---

## Acceptance Criteria (Epic-Level)

1. ✅ **Epic Goal Achieved**: Windows 11 developers and Terraform users can successfully use the project
2. ✅ **All Stories Delivered**: Both Story 1.1 and Story 1.2 completed with all ACs met
3. ✅ **Quality Verified**: Documentation is clear for Windows 11, Terraform is validated in Azure
4. ✅ **Windows 11 Functional**: All 7 notebooks run end-to-end on Windows 11 with both setup methods
5. ✅ **Production Ready**: Enhancements are ready for community use

---

## Notes

- **Educational Project Context**: Enhancements prioritize clarity and accessibility over optimization
- **Additive Only**: This epic is purely additive - no existing code or infrastructure is modified
- **Platform Focus**: Windows 11 support; existing Linux/Mac support assumed to continue working (not actively tested in this epic)
- **Testing Scope**: Pragmatic testing on available environment (Windows 11 + Azure) rather than exhaustive cross-platform testing
- **Future Considerations**: Community users on Linux/Mac can validate those platforms; CI/CD could add automated cross-platform testing in future

---

**END OF EPIC**

*Created by PM John using brownfield-create-epic task*
*Ready for Story Manager to develop detailed user stories*
