# Story 1.3: Windows Installer for One-Click Deployment - Brownfield Enhancement

**Epic**: Epic 1 - Developer Experience Improvements
**Story Type**: Brownfield Enhancement
**Status**: In Progress
**Created**: 2025-11-05
**Testing Environment**: Windows 11, Azure Subscription

---

## User Story

As a **Windows developer wanting to use the Azure AI Foundry Agents project**,
I want **a simple executable installer that handles all prerequisites, dependencies, and deployment automatically**,
so that **I can go from zero to running notebooks in under 30 minutes without manually installing tools or running multiple commands**.

---

## Story Context

### Existing System Integration

**Integrates with**:
- Existing Bicep infrastructure deployment (`azd up` workflow)
- `azure.yaml` with post-provision hooks
- `scripts/populate_env.ps1` for automated .env creation
- Windows setup documentation from Story 1.1
- All 7 Python notebooks (ultimate consumers)

**Technology**: PowerShell, Windows Installer (EXE or MSI), Azure Developer CLI, Azure CLI, Python, uv

**Follows pattern**: Windows installer best practices with prerequisite checking and automated installation

**Touch points**:
- Windows Package Manager (winget) for dependency installation
- Azure authentication flows (`azd auth login`)
- Git repository cloning or bundled source extraction
- Bicep deployment via `azd up`
- Python environment setup with `uv sync`

### Problem Statement

**Current Issues:**
1. Users must manually install multiple prerequisites (azd, az CLI, Python, uv)
2. Multiple manual commands required (clone repo, authenticate, deploy, install deps)
3. No guided experience for Azure tenant/subscription configuration
4. Error-prone manual process with many places to make mistakes
5. High barrier to entry for non-technical Windows users

**Desired End State:**
- Single executable installer users can download and run
- Installer checks for and installs all missing prerequisites
- Guided wizard prompts for Azure credentials (tenant/subscription IDs)
- Automated deployment with progress indication
- User ends up with working environment ready to run notebooks

---

## Acceptance Criteria

### Functional Requirements - Installer Capabilities

**AC1**: Windows installer executable (`.exe` or `.msi`) can be downloaded and launched by users with standard (non-admin) privileges

**AC2**: Installer checks for required dependencies and their versions:
- Azure Developer CLI (azd) - latest version
- Azure CLI (az) - version 2.50.0 or higher
- Python - version 3.11 or higher
- uv package manager - latest version
- Git - latest version (optional but recommended)

**AC3**: For missing dependencies, installer either:
- **Option A (Preferred)**: Automatically installs them using Windows Package Manager (winget)
- **Option B**: Provides clear download links and instructions for manual installation
- **Must handle**: Cases where user lacks admin rights (use portable/user-scoped installations where possible)

**AC4**: Installer provides a configuration screen that prompts for:
- Azure Tenant ID (optional - can be auto-detected during azd login)
- Azure Subscription ID (optional - can be selected during azd up)
- Preferred Azure region (e.g., eastus, westus2, westeurope)
- Resource group name (optional - defaults to auto-generated name)
- Installation directory (defaults to `C:\Users\<username>\azure-ai-foundry-agents`)

**AC5**: Installer handles repository acquisition:
- **Option A**: Clone from GitHub using Git (if installed)
- **Option B**: Bundle repository files in installer and extract to installation directory
- **Option C**: Download ZIP from GitHub and extract

**AC6**: Installer orchestrates the complete deployment process:
- Authenticates with Azure (`azd auth login`)
- Sets Azure environment variables if provided (tenant ID, subscription ID, region)
- Runs infrastructure deployment (`azd up`)
- Installs Python dependencies (`uv sync`)
- Verifies `.env` file was created successfully

**AC7**: Installer provides progress indication throughout all steps:
- Prerequisite checking phase
- Dependency installation phase
- Repository acquisition phase
- Azure authentication phase
- Infrastructure deployment phase (this can take 15-25 minutes)
- Python environment setup phase

**AC8**: Installer handles common error scenarios gracefully:
- Missing prerequisites and installation failures
- Azure authentication failures
- Bicep deployment errors
- Network connectivity issues
- Insufficient Azure permissions or quota limits
- Provides clear error messages and remediation guidance

### Quality Requirements - User Experience

**AC9**: Installer provides a GUI wizard interface (not just CLI):
- Welcome screen explaining what will be installed
- Prerequisites check screen with status indicators
- Configuration input screen for Azure settings
- Progress screen with real-time status updates
- Completion screen with next steps (how to open VS Code, run notebooks)

**AC10**: Installation process is resumable:
- If deployment fails partway through, user can retry without reinstalling prerequisites
- Installer detects existing partial installations and offers to continue or start fresh

**AC11**: Installer creates Windows Start Menu shortcuts:
- "Azure AI Foundry Agents" folder with shortcuts to:
  - Launch VS Code in project directory
  - Open project documentation (README.md)
  - Uninstall/cleanup script

**AC12**: Installer logs all actions to a log file for troubleshooting:
- Log location: `%TEMP%\azure-ai-foundry-agents-installer.log`
- Logs include: timestamps, actions taken, errors encountered, system information

### Documentation Requirements

**AC13**: Installer includes an embedded "Help" button or menu with:
- System requirements
- Troubleshooting common issues
- Link to GitHub issues for support
- Azure subscription requirements and estimated costs

**AC14**: README.md is updated with new "Quick Install (Windows)" section:
- Direct download link to installer executable
- System requirements
- Expected installation time
- Troubleshooting installer-specific issues

**AC15**: Installer provides end-of-installation guidance:
- Clear next steps (launch VS Code, open notebook, etc.)
- Link to notebook execution guide
- How to verify deployment succeeded
- Where to find logs if issues occur

### Integration Requirements

**AC16**: Installer integrates seamlessly with existing `azd` workflow:
- Uses existing `azure.yaml` configuration
- Leverages existing `populate_env.ps1` automation script
- Does not require modifications to Bicep infrastructure
- Works with existing post-provision hooks

**AC17**: Installed environment is identical to manual setup:
- Same directory structure
- Same virtual environment configuration
- Same `.env` file format
- All 7 notebooks work identically after installer vs manual setup

---

## Technical Notes

### Integration Approach

**Installer Technology Options:**

**Option 1: PowerShell-based GUI Installer (Recommended for MVP)**
- Create PowerShell script with Windows Forms GUI
- Package as self-contained `.exe` using tools like PS2EXE or Advanced Installer
- **Pros**: Quick to develop, full control, easy to modify
- **Cons**: May trigger antivirus warnings, less polished than native installer

**Option 2: Native Windows Installer (MSI)**
- Build using WiX Toolset or Advanced Installer
- Professional-grade installer with standard Windows installer experience
- **Pros**: Professional appearance, trusted by antivirus software, standard uninstall experience
- **Cons**: More complex to develop, steeper learning curve

**Option 3: Electron-based Installer**
- Web technologies (HTML/CSS/JS) with Electron framework
- Cross-platform installer framework (can extend to Mac/Linux later)
- **Pros**: Modern UI, cross-platform potential, rich interactivity
- **Cons**: Larger file size, more development overhead

**Recommended**: Start with **Option 1 (PowerShell GUI)** for MVP, evaluate Option 2 for production release.

### Installer Workflow

```
┌─────────────────────────────────────────┐
│  1. Welcome Screen                      │
│     - Explain what will be installed    │
│     - Estimated time: 30-45 minutes     │
└───────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│  2. Prerequisites Check                 │
│     ✓ Check for azd, az, Python, uv    │
│     ✓ Display status (installed/missing)│
└───────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│  3. Install Missing Prerequisites       │
│     - Use winget to auto-install        │
│     - Show progress for each tool       │
│     - Fallback to manual links if fails │
└───────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│  4. Configuration Input                 │
│     - Azure Tenant ID (optional)        │
│     - Azure Subscription ID (optional)  │
│     - Azure region (dropdown)           │
│     - Resource group name (optional)    │
│     - Installation directory            │
└───────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│  5. Repository Acquisition              │
│     - Clone from GitHub OR              │
│     - Extract bundled files             │
│     - Navigate to installation dir      │
└───────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│  6. Azure Authentication                │
│     - Run: azd auth login               │
│     - Wait for user to complete login   │
│     - Verify authentication succeeded   │
└───────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│  7. Set Azure Environment Variables     │
│     - azd env set AZURE_TENANT_ID       │
│     - azd env set AZURE_SUBSCRIPTION_ID │
│     - azd env set AZURE_LOCATION        │
└───────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│  8. Infrastructure Deployment           │
│     - Run: azd up                       │
│     - Show real-time deployment logs    │
│     - Duration: 15-25 minutes           │
│     - Auto-creates .env file (hook)     │
└───────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│  9. Python Environment Setup            │
│     - Run: uv sync                      │
│     - Install all Python dependencies   │
│     - Verify virtual environment        │
└───────────────┬─────────────────────────┘
                │
┌───────────────▼─────────────────────────┐
│  10. Verification & Completion          │
│     ✓ Verify .env file exists           │
│     ✓ Verify virtual environment exists │
│     ✓ Display next steps                │
│     ✓ Offer to open VS Code             │
└─────────────────────────────────────────┘
```

### Prerequisite Installation Commands

**Using Windows Package Manager (winget):**

```powershell
# Check if winget is available
if (!(Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Error "Windows Package Manager (winget) not found. Please install from Microsoft Store."
    exit 1
}

# Install Azure Developer CLI
winget install Microsoft.Azd

# Install Azure CLI
winget install Microsoft.AzureCLI

# Install Python 3.11 or higher
winget install Python.Python.3.11

# Install Git (optional)
winget install Git.Git

# Install uv (manual installation via script)
irm https://astral.sh/uv/install.ps1 | iex
```

### Configuration Management

**Azure environment configuration:**

```powershell
# Set tenant ID if provided
if ($tenantId) {
    azd env set AZURE_TENANT_ID $tenantId
}

# Set subscription ID if provided
if ($subscriptionId) {
    azd env set AZURE_SUBSCRIPTION_ID $subscriptionId
}

# Set location
azd env set AZURE_LOCATION $location

# Set resource group name (optional, azd will auto-generate if not provided)
if ($resourceGroupName) {
    azd env set AZURE_RESOURCE_GROUP $resourceGroupName
}
```

### Key Constraints

- Installer must work on Windows 10 version 1809 or higher and Windows 11
- Should not require administrator privileges for standard user scenarios
- Must handle corporate environments with restricted permissions
- Total installation time target: under 30 minutes (excluding Azure deployment which is 15-25 min)
- Installer executable size should be reasonable (< 50 MB for bundled, < 5 MB if downloads components)

### Error Handling Strategy

**Critical Error Scenarios:**

1. **Prerequisite Installation Failures**
   - Fallback: Provide manual download links
   - Offer to retry installation
   - Log detailed error for troubleshooting

2. **Azure Authentication Failures**
   - Provide clear instructions for device code flow
   - Offer retry option
   - Link to Azure authentication troubleshooting docs

3. **Bicep Deployment Failures**
   - Capture deployment error messages
   - Provide guidance based on error type (quota, permissions, etc.)
   - Offer to run `azd down` and retry
   - Save deployment logs to file for support

4. **Network Connectivity Issues**
   - Detect offline scenarios early in installation
   - Provide clear "check your internet connection" messaging
   - Offer to pause and resume when connectivity restored

---

## Definition of Done

- [ ] Installer executable created and tested on clean Windows 11 machine
- [ ] All 16 acceptance criteria (AC1-AC17) met and verified
- [ ] Installer successfully completes end-to-end on test system with no prerequisites installed
- [ ] Installed environment verified: all 7 notebooks run successfully
- [ ] Installer handles error scenarios gracefully with clear error messages
- [ ] Installation logs are comprehensive and useful for troubleshooting
- [ ] README.md updated with "Quick Install (Windows)" section and download link
- [ ] Start Menu shortcuts created and functional
- [ ] Uninstall/cleanup process tested and documented
- [ ] Installer tested on both Windows 10 and Windows 11
- [ ] Installer tested in corporate environment with restricted permissions (if possible)
- [ ] Code review approved by maintainer
- [ ] PR merged to main branch

---

## Testing Checklist

### Prerequisites Testing

- [ ] **Test on Clean Windows 11 System**:
  - [ ] No prerequisites installed (fresh VM or clean install)
  - [ ] Installer detects all missing prerequisites correctly
  - [ ] Installer installs all prerequisites successfully via winget
  - [ ] Installation completes without errors

- [ ] **Test on Windows 10 System**:
  - [ ] Installer runs on Windows 10 version 1809 or higher
  - [ ] All features work identically to Windows 11

- [ ] **Test with Partial Prerequisites**:
  - [ ] Some prerequisites already installed (e.g., Python but not azd)
  - [ ] Installer detects existing installations correctly
  - [ ] Installer only installs missing prerequisites

### Configuration Testing

- [ ] **Test Azure Configuration Scenarios**:
  - [ ] User provides tenant ID and subscription ID upfront
  - [ ] User skips tenant/subscription IDs (selects during azd up)
  - [ ] User provides custom resource group name
  - [ ] User uses default resource group name (auto-generated)
  - [ ] User selects different Azure regions (eastus, westus2, westeurope)

### Deployment Testing

- [ ] **Test Full Installation Flow**:
  - [ ] Repository acquisition succeeds (clone or extract)
  - [ ] Azure authentication completes successfully
  - [ ] Infrastructure deployment (`azd up`) completes successfully
  - [ ] `.env` file is created and populated correctly
  - [ ] Python dependencies installed via `uv sync`
  - [ ] All 7 notebooks run successfully after installation

- [ ] **Test Resume After Failure**:
  - [ ] Simulate deployment failure (e.g., quota exceeded)
  - [ ] Rerun installer → Detects partial installation
  - [ ] Installer offers to continue from where it left off
  - [ ] Retry completes successfully after fixing issue

### Error Handling Testing

- [ ] **Test Network Failure Scenarios**:
  - [ ] Disconnect network during prerequisite installation
  - [ ] Disconnect network during repository clone
  - [ ] Verify clear error messaging and recovery instructions

- [ ] **Test Azure Authentication Failures**:
  - [ ] Invalid Azure credentials
  - [ ] User cancels authentication
  - [ ] Verify clear error messaging and retry option

- [ ] **Test Insufficient Permissions**:
  - [ ] Azure account lacks Contributor role
  - [ ] Verify clear error message about required permissions

- [ ] **Test Azure Quota Limits**:
  - [ ] Deployment fails due to GPT model quota
  - [ ] Verify error message explains quota issue
  - [ ] Verify guidance on requesting quota increase

### User Experience Testing

- [ ] **Test GUI Wizard**:
  - [ ] All screens display correctly
  - [ ] Navigation works (Next, Back, Cancel buttons)
  - [ ] Progress indication is accurate and real-time
  - [ ] Completion screen shows correct next steps

- [ ] **Test Start Menu Shortcuts**:
  - [ ] Shortcuts created in Start Menu
  - [ ] "Launch VS Code" shortcut works
  - [ ] "Open Documentation" shortcut works
  - [ ] Shortcuts have appropriate icons

### Cleanup Testing

- [ ] **Test Uninstall Process**:
  - [ ] Uninstall script removes Start Menu shortcuts
  - [ ] Uninstall offers to delete Azure resources (`azd down`)
  - [ ] Uninstall offers to delete installation directory
  - [ ] User can choose to keep or remove components

---

## Implementation Guidance

### Phase 1: Installer Skeleton & Prerequisites

1. **Create PowerShell Installer Script**:
   - Set up Windows Forms GUI framework
   - Implement welcome screen with installation overview
   - Create prerequisite detection logic for azd, az, Python, uv, Git

2. **Implement Prerequisite Installation**:
   - Use `winget` to install missing tools
   - Implement progress indication for each installation
   - Create fallback to manual installation with download links

3. **Package as Executable**:
   - Use PS2EXE or similar tool to create `.exe` from PowerShell script
   - Test executable on clean Windows system
   - Verify antivirus compatibility

### Phase 2: Configuration & Repository Acquisition

1. **Implement Configuration Screen**:
   - Create form inputs for tenant ID, subscription ID, region, resource group
   - Validate user inputs (e.g., GUID format for IDs)
   - Save configuration for use in deployment phase

2. **Implement Repository Acquisition**:
   - **Option A**: Git clone from GitHub (if Git installed)
   - **Option B**: Extract bundled repository files (embedded in installer)
   - Verify repository structure after acquisition

### Phase 3: Deployment Automation

1. **Implement Azure Authentication**:
   - Run `azd auth login` and wait for user completion
   - Verify authentication succeeded (check `azd auth login --check-status`)
   - Handle authentication errors gracefully

2. **Implement Azure Environment Setup**:
   - Set environment variables in azd environment (`azd env set`)
   - Apply user-provided configuration (tenant, subscription, region)

3. **Implement Infrastructure Deployment**:
   - Run `azd up` with real-time log streaming to GUI
   - Parse deployment output for progress indication
   - Handle deployment errors and provide clear guidance

4. **Implement Python Environment Setup**:
   - Run `uv sync` to install dependencies
   - Verify virtual environment was created successfully
   - Verify `.env` file exists and is populated

### Phase 4: Finalization & Testing

1. **Implement Completion Screen**:
   - Display success message with next steps
   - Provide buttons to "Open VS Code", "View Documentation", "Finish"
   - Create Start Menu shortcuts

2. **Implement Uninstall Script**:
   - Create PowerShell script for cleanup (`uninstall.ps1`)
   - Offer to delete Azure resources, installation directory, Start Menu shortcuts
   - Add uninstall entry to Windows Programs & Features (if using MSI)

3. **End-to-End Testing**:
   - Test on clean Windows 10 and Windows 11 systems
   - Test all error scenarios and recovery paths
   - Verify installed environment works identically to manual setup

---

## Risk Assessment

### Technical Risks

**Risk 1**: Windows Package Manager (winget) not available on older Windows 10 versions
- **Likelihood**: Medium
- **Impact**: High (prerequisite installation fails)
- **Mitigation**: Implement fallback to manual installation with download links
- **Detection**: Check winget availability early in installer

**Risk 2**: Antivirus software flags installer as potentially unwanted program (PUP)
- **Likelihood**: High (common for PowerShell-based executables)
- **Impact**: High (users cannot run installer)
- **Mitigation**: Code-sign the executable with trusted certificate, use native installer (MSI) instead of PS2EXE
- **Detection**: Test with Windows Defender and popular antivirus software

**Risk 3**: Corporate firewalls block prerequisite downloads or Azure connections
- **Likelihood**: Medium
- **Impact**: High (installation cannot complete)
- **Mitigation**: Provide clear error messages about network requirements, offer offline installation option
- **Detection**: Test in corporate environment with restricted network

**Risk 4**: User lacks permissions to install prerequisites (even user-scoped)
- **Likelihood**: Low-Medium
- **Impact**: High (cannot complete installation)
- **Mitigation**: Document minimum permissions required, provide manual installation guide as alternative
- **Detection**: Test in locked-down corporate environment

### User Experience Risks

**Risk 5**: Installer takes too long (> 45 minutes) and users abandon
- **Likelihood**: Medium
- **Impact**: Medium (poor user experience)
- **Mitigation**: Set clear expectations upfront (30-45 min), provide accurate progress indication
- **Detection**: Time full installation on test system

**Risk 6**: Deployment errors are not actionable (unclear error messages)
- **Likelihood**: Medium
- **Impact**: Medium (users cannot recover from errors)
- **Mitigation**: Map common error codes to user-friendly messages with remediation steps
- **Detection**: Test common error scenarios (quota limits, permissions, etc.)

---

## Story Dependencies

### Dependencies
- **Story 1.2 (Bicep Infrastructure Automation)**: Must be completed and working correctly before installer can leverage `azd up` workflow

### Benefits from
- **Story 1.1 (Windows Setup Documentation)**: Provides manual fallback instructions if installer fails
- **Story 1.2 (Bicep Automation)**: Provides reliable `azd up` workflow and `.env` automation

### Enables
- Dramatically lower barrier to entry for Windows users
- Faster onboarding for workshops, demos, and educational scenarios
- Reduced support burden (fewer setup-related issues)

---

## Notes

- **Target Audience**: Windows developers who want minimal friction setup, potentially non-technical users
- **MVP vs Full Release**: MVP can be PowerShell-based GUI, full release could be professional MSI installer
- **Code Signing**: Production installer should be code-signed to avoid antivirus warnings and build user trust
- **Offline Installation**: Future enhancement could support fully offline installation with bundled prerequisites
- **Telemetry**: Consider adding optional telemetry to understand common installation failure points
- **Localization**: Future enhancement could support multiple languages (start with English)

---

## Dev Agent Record

### Agent Model Used
- claude-sonnet-4-5-20250929

### Tasks

#### Phase 1: Core Installer Development
- [x] Create PowerShell installer script with Windows Forms GUI (installer.ps1)
- [x] Implement welcome screen
- [x] Implement prerequisite detection (azd, az, Python, uv, Git)
- [x] Implement prerequisite installation via winget with fallback
- [x] Implement logging system to %TEMP%
- [x] Implement winget auto-installation if missing

#### Phase 2: Configuration & Repository
- [x] Implement configuration screen (tenant ID, subscription ID, region, resource group, install dir)
- [x] Add environment name configuration for azd
- [x] Implement input validation for Azure IDs and environment name
- [x] Implement repository acquisition (Git clone with ZIP download fallback)

#### Phase 3: Deployment Orchestration
- [x] Implement Azure authentication flow (azd auth login)
- [x] Implement azd environment initialization (azd env new)
- [x] Implement Azure environment variable configuration (azd env set)
- [x] Implement infrastructure deployment with progress tracking (azd up --no-prompt)
- [x] Implement Python environment setup (uv sync)
- [x] Implement .env file verification

#### Phase 4: Completion & Documentation
- [x] Implement completion screen with next steps
- [x] Create uninstall script (uninstall.ps1) with Azure resource cleanup
- [x] Update README.md with Quick Install (Windows) section
- [ ] End-to-end testing on Windows (requires user testing)

### Debug Log References
- See: .ai/debug-log.md

### Completion Notes
- Story started: 2025-11-06
- Development environment: WSL (testing will be done on Windows by user)
- Start Menu shortcuts: Not implemented per user request
- All core functionality implemented
- Key improvements over story requirements:
  - Auto-installs winget if missing (with admin elevation prompt)
  - Captures environment name for azd
  - Pre-configures ALL azd settings for fully non-interactive deployment
  - Comprehensive error handling and logging
  - GUI wizard with progress tracking
  - Uninstall script with optional Azure resource cleanup

### File List
- `installer.ps1` (NEW) - Main PowerShell installer with GUI wizard
- `uninstall.ps1` (NEW) - Uninstall script with Azure resource cleanup
- `README.md` (MODIFIED) - Added "Quick Install (Windows)" section
- `docs/stories/story-1.3-windows-installer.md` (MODIFIED) - Updated status and tasks

### Change Log
- 2025-11-06: Status changed to In Progress, development started
- 2025-11-06: Core installer implementation completed (installer.ps1)
- 2025-11-06: Uninstall script implemented (uninstall.ps1)
- 2025-11-06: README.md updated with Windows Quick Install section
- 2025-11-06: Ready for testing on Windows by user

---

**END OF STORY 1.3**

*Created by PM John using brownfield-create-story task*
*Ready for Dev agent implementation*
