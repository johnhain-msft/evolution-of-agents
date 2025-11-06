#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Azure AI Foundry Agents - Windows Installer
.DESCRIPTION
    One-click installer for Azure AI Foundry Agents project.
    Handles prerequisites, Azure deployment, and environment setup.
.NOTES
    Version: 1.0
    Requires: Windows 10 1809+ or Windows 11
#>

# Stop on errors
$ErrorActionPreference = "Stop"

# Setup logging
$LogFile = Join-Path $env:TEMP "azure-ai-foundry-agents-installer.log"
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "$Timestamp [$Level] $Message"
    Add-Content -Path $LogFile -Value $LogMessage

    switch ($Level) {
        "ERROR" { Write-Host $Message -ForegroundColor Red }
        "SUCCESS" { Write-Host $Message -ForegroundColor Green }
        "WARNING" { Write-Host $Message -ForegroundColor Yellow }
        default { Write-Host $Message }
    }
}

# Initialize log
Write-Log "=========================================="
Write-Log "Azure AI Foundry Agents Installer Started"
Write-Log "=========================================="
Write-Log "Log file: $LogFile"

# Add Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Global state
$Global:Config = @{
    InstallDir = Join-Path $env:USERPROFILE "azure-ai-foundry-agents"
    EnvironmentName = "agents-env"
    TenantId = ""
    SubscriptionId = ""
    Location = "eastus"
    ResourceGroup = ""
    GitHubRepo = "https://github.com/azure-samples/azure-ai-foundry-agents"
}

$Global:Prerequisites = @{
    azd = @{ Installed = $false; Version = ""; Command = "azd"; WingetId = "Microsoft.Azd" }
    az = @{ Installed = $false; Version = ""; Command = "az"; WingetId = "Microsoft.AzureCLI" }
    python = @{ Installed = $false; Version = ""; Command = "python"; WingetId = "Python.Python.3.11" }
    git = @{ Installed = $false; Version = ""; Command = "git"; WingetId = "Git.Git" }
    uv = @{ Installed = $false; Version = ""; Command = "uv"; WingetId = "" }
}

#region Helper Functions

function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Test-Prerequisite {
    param([string]$Command)

    try {
        $null = Get-Command $Command -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Get-PrerequisiteVersion {
    param([string]$Command)

    try {
        switch ($Command) {
            "azd" { $version = (azd version 2>&1 | Select-String -Pattern "azd version (\S+)" | ForEach-Object { $_.Matches.Groups[1].Value }); return $version }
            "az" { $version = (az version 2>&1 | ConvertFrom-Json).'"azure-cli"'; return $version }
            "python" { $version = (python --version 2>&1).Split()[1]; return $version }
            "git" { $version = (git --version 2>&1).Split()[2]; return $version }
            "uv" { $version = (uv --version 2>&1).Split()[1]; return $version }
            default { return "Unknown" }
        }
    }
    catch {
        return "Error"
    }
}

function Test-WingetAvailable {
    return (Test-Prerequisite "winget")
}

function Install-Winget {
    Write-Log "Installing winget (Windows Package Manager)..."

    try {
        # Check if already installed
        if (Test-WingetAvailable) {
            Write-Log "winget already installed"
            return $true
        }

        # Check for admin rights
        if (-not (Test-Administrator)) {
            Write-Log "Administrator privileges required to install winget" "WARNING"

            # Try to elevate
            $scriptPath = $MyInvocation.MyCommand.Path
            Write-Log "Attempting to restart with administrator privileges..."

            $result = [System.Windows.Forms.MessageBox]::Show(
                "Administrator privileges are required to install Windows Package Manager (winget).`n`nWould you like to restart the installer with administrator privileges?",
                "Administrator Required",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )

            if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
                Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
                exit
            }
            else {
                return $false
            }
        }

        # Download winget
        Write-Log "Downloading winget package..."
        $wingetUrl = "https://aka.ms/getwinget"
        $wingetPath = Join-Path $env:TEMP "winget.msixbundle"

        Invoke-WebRequest -Uri $wingetUrl -OutFile $wingetPath -UseBasicParsing
        Write-Log "Downloaded winget to $wingetPath"

        # Install winget
        Write-Log "Installing winget package..."
        Add-AppxPackage -Path $wingetPath

        # Cleanup
        Remove-Item -Path $wingetPath -Force -ErrorAction SilentlyContinue

        # Verify installation
        if (Test-WingetAvailable) {
            Write-Log "winget installed successfully" "SUCCESS"
            return $true
        }
        else {
            Write-Log "winget installation verification failed" "ERROR"
            return $false
        }
    }
    catch {
        Write-Log "Failed to install winget: $_" "ERROR"
        return $false
    }
}

function Install-Prerequisite {
    param([string]$Name, [string]$WingetId)

    Write-Log "Installing $Name via winget..."

    if (-not (Test-WingetAvailable)) {
        Write-Log "winget not available. Attempting to install winget first..." "WARNING"

        if (-not (Install-Winget)) {
            Write-Log "Cannot proceed without winget. Manual installation required." "ERROR"
            return $false
        }
    }

    try {
        if ($Name -eq "uv") {
            # uv requires special installation
            Write-Log "Installing uv via PowerShell script..."
            Invoke-RestMethod -Uri "https://astral.sh/uv/install.ps1" | Invoke-Expression

            # Refresh environment PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")

            return $true
        }
        else {
            Write-Log "Running: winget install --id $WingetId"
            $result = winget install --id $WingetId --accept-package-agreements --accept-source-agreements --silent 2>&1
            Write-Log "winget output: $result"

            # Refresh environment PATH
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "User") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "Machine")

            return $true
        }
    }
    catch {
        Write-Log "Failed to install $Name : $_" "ERROR"
        return $false
    }
}

function Show-ManualInstallLinks {
    param([string]$Name)

    $links = @{
        "azd" = "https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd"
        "az" = "https://learn.microsoft.com/cli/azure/install-azure-cli-windows"
        "python" = "https://www.python.org/downloads/"
        "git" = "https://git-scm.com/download/win"
        "uv" = "https://github.com/astral-sh/uv#installation"
    }

    if ($links.ContainsKey($Name)) {
        Write-Log "Manual installation link for $Name : $($links[$Name])" "INFO"
        return $links[$Name]
    }
    return ""
}

function Get-AzureRegions {
    return @("eastus", "eastus2", "westus", "westus2", "westus3", "centralus", "northcentralus", "southcentralus",
             "westeurope", "northeurope", "uksouth", "ukwest", "francecentral", "germanywestcentral",
             "switzerlandnorth", "norwayeast", "swedencentral", "australiaeast", "australiasoutheast",
             "southeastasia", "eastasia", "japaneast", "japanwest", "koreacentral", "canadacentral",
             "canadaeast", "brazilsouth", "southafricanorth", "uaenorth", "centralindia", "southindia")
}

function Test-GuidFormat {
    param([string]$Guid)

    if ([string]::IsNullOrWhiteSpace($Guid)) {
        return $true # Allow empty
    }

    try {
        [System.Guid]::Parse($Guid) | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

function Test-EnvironmentNameValid {
    param([string]$Name)

    if ([string]::IsNullOrWhiteSpace($Name)) {
        return $false
    }

    # Environment name should be alphanumeric with hyphens/underscores
    return $Name -match '^[a-zA-Z0-9][a-zA-Z0-9_-]*$'
}

#endregion

#region GUI Functions

function Show-WelcomeScreen {
    Write-Log "Creating welcome screen form..."
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Azure AI Foundry Agents Installer"
    $form.Size = New-Object System.Drawing.Size(600, 450)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    Write-Log "Form created successfully"

    # Logo/Title
    Write-Log "Creating title label..."
    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text = "Azure AI Foundry Agents"
    $lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $lblTitle.Location = New-Object System.Drawing.Point(20, 20)
    $lblTitle.Size = New-Object System.Drawing.Size(560, 40)
    $lblTitle.TextAlign = "MiddleCenter"
    Write-Log "Adding title to form..."
    $form.Controls.Add($lblTitle)
    Write-Log "Title added successfully"

    # Description
    Write-Log "Creating description textbox..."
    $lblDesc = New-Object System.Windows.Forms.TextBox
    $lblDesc.Multiline = $true
    $lblDesc.ReadOnly = $true
    $lblDesc.BorderStyle = "None"
    $lblDesc.BackColor = $form.BackColor
    $lblDesc.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $lblDesc.Location = New-Object System.Drawing.Point(40, 80)
    $lblDesc.Size = New-Object System.Drawing.Size(520, 200)
    $lblDesc.Text = @"
Welcome to the Azure AI Foundry Agents installer!

This installer will:
- Check and install required prerequisites (Azure CLI, Python, etc.)
- Clone or download the repository
- Guide you through Azure authentication
- Deploy Azure infrastructure (AI Foundry, OpenAI, Logic Apps)
- Set up your local Python environment
- Create your .env configuration file

Estimated time: 30-45 minutes
(Most time is spent on Azure infrastructure deployment: 15-25 min)

Please ensure you have:
- Active Azure subscription with Contributor access
- Stable internet connection
- ~2 GB free disk space
"@
    Write-Log "Adding description to form..."
    $form.Controls.Add($lblDesc)
    Write-Log "Description added successfully"

    # Log file info
    Write-Log "Creating log label..."
    $lblLog = New-Object System.Windows.Forms.Label
    $lblLog.Text = "Installation log: $LogFile"
    $lblLog.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $lblLog.ForeColor = [System.Drawing.Color]::Gray
    $lblLog.Location = New-Object System.Drawing.Point(40, 290)
    $lblLog.Size = New-Object System.Drawing.Size(520, 20)
    Write-Log "Adding log label to form..."
    $form.Controls.Add($lblLog)
    Write-Log "Log label added successfully"

    # Next button
    Write-Log "Creating Next button..."
    $btnNext = New-Object System.Windows.Forms.Button
    $btnNext.Text = "Next"
    $btnNext.Size = New-Object System.Drawing.Size(100, 30)
    $btnNext.Location = New-Object System.Drawing.Point(370, 360)
    $btnNext.DialogResult = [System.Windows.Forms.DialogResult]::OK
    Write-Log "Adding Next button to form..."
    $form.Controls.Add($btnNext)
    Write-Log "Next button added successfully"

    # Cancel button
    Write-Log "Creating Cancel button..."
    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"
    $btnCancel.Size = New-Object System.Drawing.Size(100, 30)
    $btnCancel.Location = New-Object System.Drawing.Point(480, 360)
    $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    Write-Log "Adding Cancel button to form..."
    $form.Controls.Add($btnCancel)
    Write-Log "Cancel button added successfully"

    $form.AcceptButton = $btnNext
    $form.CancelButton = $btnCancel

    Write-Log "Showing welcome screen dialog..."
    $result = $form.ShowDialog()
    Write-Log "Dialog closed with result: $result"
    $form.Dispose()

    return ($result -eq [System.Windows.Forms.DialogResult]::OK)
}

function Show-PrerequisitesScreen {
    Write-Log "Creating prerequisites screen form..."
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Prerequisites Check"
    $form.Size = New-Object System.Drawing.Size(700, 650)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.AutoScroll = $true

    # Add mouse wheel scrolling support
    $form.Add_MouseWheel({
        param($sender, $e)
        $currentScroll = $form.AutoScrollPosition
        $newY = [Math]::Max(0, -$currentScroll.Y - ($e.Delta / 3))
        $form.AutoScrollPosition = New-Object System.Drawing.Point(0, $newY)
    })

    Write-Log "Prerequisites form created"

    # Title
    Write-Log "Creating title label..."
    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text = "Checking Prerequisites"
    $lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $lblTitle.Location = New-Object System.Drawing.Point(20, 20)
    $lblTitle.Size = New-Object System.Drawing.Size(660, 30)
    $form.Controls.Add($lblTitle)

    # Status list
    $listView = New-Object System.Windows.Forms.ListView
    $listView.Location = New-Object System.Drawing.Point(20, 60)
    $listView.Size = New-Object System.Drawing.Size(660, 250)
    $listView.View = [System.Windows.Forms.View]::Details
    $listView.FullRowSelect = $true
    $listView.GridLines = $true

    $listView.Columns.Add("Tool", 150) | Out-Null
    $listView.Columns.Add("Status", 120) | Out-Null
    $listView.Columns.Add("Version", 150) | Out-Null
    $listView.Columns.Add("Action", 200) | Out-Null

    $form.Controls.Add($listView)

    # Progress text
    $txtProgress = New-Object System.Windows.Forms.TextBox
    $txtProgress.Multiline = $true
    $txtProgress.ScrollBars = "Vertical"
    $txtProgress.ReadOnly = $true
    $txtProgress.Location = New-Object System.Drawing.Point(20, 320)
    $txtProgress.Size = New-Object System.Drawing.Size(660, 160)
    $txtProgress.Font = New-Object System.Drawing.Font("Consolas", 9)
    $form.Controls.Add($txtProgress)

    # Buttons
    $btnInstall = New-Object System.Windows.Forms.Button
    $btnInstall.Text = "Install Missing"
    $btnInstall.Size = New-Object System.Drawing.Size(120, 30)
    $btnInstall.Location = New-Object System.Drawing.Point(240, 500)
    $form.Controls.Add($btnInstall)

    $btnNext = New-Object System.Windows.Forms.Button
    $btnNext.Text = "Next"
    $btnNext.Size = New-Object System.Drawing.Size(100, 30)
    $btnNext.Location = New-Object System.Drawing.Point(460, 500)
    $btnNext.Enabled = $false
    $form.Controls.Add($btnNext)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"
    $btnCancel.Size = New-Object System.Drawing.Size(100, 30)
    $btnCancel.Location = New-Object System.Drawing.Point(570, 500)
    $form.Controls.Add($btnCancel)

    # Check prerequisites
    function Update-PrerequisiteList {
        Write-Log "Updating prerequisite list..."
        $listView.Items.Clear()
        $allInstalled = $true

        foreach ($key in $Global:Prerequisites.Keys) {
            Write-Log "Checking prerequisite: $key"
            $prereq = $Global:Prerequisites[$key]
            $prereq.Installed = Test-Prerequisite $prereq.Command

            if ($prereq.Installed) {
                $prereq.Version = Get-PrerequisiteVersion $prereq.Command
            }
            else {
                $prereq.Version = ""
            }

            Write-Log "Creating ListViewItem for $key (Installed: $($prereq.Installed), Version: $($prereq.Version))..."
            $item = New-Object System.Windows.Forms.ListViewItem($key)

            Write-Log "Adding status SubItem..."
            $item.SubItems.Add($(if ($prereq.Installed) { "Installed" } else { "Missing" })) | Out-Null

            Write-Log "Adding version SubItem..."
            $versionText = if ([string]::IsNullOrWhiteSpace($prereq.Version)) { "N/A" } else { $prereq.Version }
            $item.SubItems.Add($versionText) | Out-Null

            Write-Log "Adding action SubItem..."
            $item.SubItems.Add($(if ($prereq.Installed) { "OK" } else { "Needs installation" })) | Out-Null

            if ($prereq.Installed) {
                $item.ForeColor = [System.Drawing.Color]::Green
            }
            else {
                $item.ForeColor = [System.Drawing.Color]::Red
                $allInstalled = $false
            }

            Write-Log "Adding item to ListView..."
            $listView.Items.Add($item) | Out-Null
            Write-Log "Item added successfully"
        }

        Write-Log "Setting btnNext.Enabled = $allInstalled"
        $btnNext.Enabled = $allInstalled
        Write-Log "Prerequisite list update complete"
        return $allInstalled
    }

    # Install button click
    $btnInstall.Add_Click({
        $btnInstall.Enabled = $false
        $txtProgress.AppendText("Starting installation...`r`n")

        # Check winget first
        if (-not (Test-WingetAvailable)) {
            $txtProgress.AppendText("Windows Package Manager (winget) not found.`r`n")
            $txtProgress.AppendText("Attempting to install winget...`r`n")
            $txtProgress.Refresh()

            if (Install-Winget) {
                $txtProgress.AppendText("[OK] winget installed successfully`r`n")
            }
            else {
                $txtProgress.AppendText("[X] Failed to install winget. Manual installation required.`r`n")
                $txtProgress.AppendText("https://aka.ms/getwinget`r`n")
            }
        }

        foreach ($key in $Global:Prerequisites.Keys) {
            $prereq = $Global:Prerequisites[$key]

            if (-not $prereq.Installed) {
                $txtProgress.AppendText("Installing $key...`r`n")
                $txtProgress.Refresh()

                if ($prereq.WingetId) {
                    $success = Install-Prerequisite $key $prereq.WingetId
                }
                else {
                    $success = Install-Prerequisite $key ""
                }

                if ($success) {
                    $txtProgress.AppendText("[OK] $key installed successfully`r`n")
                }
                else {
                    $txtProgress.AppendText("[X] Failed to install $key`r`n")
                    $link = Show-ManualInstallLinks $key
                    $txtProgress.AppendText("  Manual install: $link`r`n")
                }

                $txtProgress.Refresh()
            }
        }

        $txtProgress.AppendText("`r`nRechecking prerequisites...`r`n")
        $allInstalled = Update-PrerequisiteList

        if ($allInstalled) {
            $txtProgress.AppendText("`r`n[OK] All prerequisites installed!`r`n")
            $btnNext.Enabled = $true
        }
        else {
            $txtProgress.AppendText("`r`n[WARNING] Some prerequisites could not be installed automatically.`r`n")
            $txtProgress.AppendText("Please install them manually and restart the installer.`r`n")
        }

        $btnInstall.Enabled = $true
    })

    $btnNext.Add_Click({
        $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.Close()
    })

    $btnCancel.Add_Click({
        $form.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $form.Close()
    })

    # Initial check
    Write-Log "Running initial prerequisite check..."
    try {
        Update-PrerequisiteList
        Write-Log "Initial check complete"
    }
    catch {
        Write-Log "Error during initial prerequisite check: $_" "ERROR"
        Write-Log "Stack trace: $($_.ScriptStackTrace)" "ERROR"
        throw
    }

    Write-Log "Showing prerequisites dialog..."
    $result = $form.ShowDialog()
    Write-Log "Prerequisites dialog closed with result: $result"
    $form.Dispose()

    return ($result -eq [System.Windows.Forms.DialogResult]::OK)
}

function Show-ConfigurationScreen {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Azure Configuration"
    $form.Size = New-Object System.Drawing.Size(600, 550)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false

    # Title
    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text = "Azure Configuration"
    $lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $lblTitle.Location = New-Object System.Drawing.Point(20, 20)
    $lblTitle.Size = New-Object System.Drawing.Size(560, 30)
    $form.Controls.Add($lblTitle)

    $yPos = 70

    # Environment Name
    $lblEnvName = New-Object System.Windows.Forms.Label
    $lblEnvName.Text = "Environment Name: *"
    $lblEnvName.Location = New-Object System.Drawing.Point(40, $yPos)
    $lblEnvName.Size = New-Object System.Drawing.Size(200, 20)
    $form.Controls.Add($lblEnvName)

    $txtEnvName = New-Object System.Windows.Forms.TextBox
    $txtEnvName.Location = New-Object System.Drawing.Point(260, $yPos)
    $txtEnvName.Size = New-Object System.Drawing.Size(280, 20)
    $txtEnvName.Text = $Global:Config.EnvironmentName
    $form.Controls.Add($txtEnvName)

    $yPos += 40

    # Tenant ID
    $lblTenant = New-Object System.Windows.Forms.Label
    $lblTenant.Text = "Azure Tenant ID: *"
    $lblTenant.Location = New-Object System.Drawing.Point(40, $yPos)
    $lblTenant.Size = New-Object System.Drawing.Size(200, 20)
    $form.Controls.Add($lblTenant)

    $txtTenant = New-Object System.Windows.Forms.TextBox
    $txtTenant.Location = New-Object System.Drawing.Point(260, $yPos)
    $txtTenant.Size = New-Object System.Drawing.Size(280, 20)
    $txtTenant.Text = $Global:Config.TenantId
    $form.Controls.Add($txtTenant)

    $yPos += 40

    # Subscription ID
    $lblSubscription = New-Object System.Windows.Forms.Label
    $lblSubscription.Text = "Azure Subscription ID: *"
    $lblSubscription.Location = New-Object System.Drawing.Point(40, $yPos)
    $lblSubscription.Size = New-Object System.Drawing.Size(200, 20)
    $form.Controls.Add($lblSubscription)

    $txtSubscription = New-Object System.Windows.Forms.TextBox
    $txtSubscription.Location = New-Object System.Drawing.Point(260, $yPos)
    $txtSubscription.Size = New-Object System.Drawing.Size(280, 20)
    $txtSubscription.Text = $Global:Config.SubscriptionId
    $form.Controls.Add($txtSubscription)

    $yPos += 40

    # Location
    $lblLocation = New-Object System.Windows.Forms.Label
    $lblLocation.Text = "Azure Region: *"
    $lblLocation.Location = New-Object System.Drawing.Point(40, $yPos)
    $lblLocation.Size = New-Object System.Drawing.Size(200, 20)
    $form.Controls.Add($lblLocation)

    $cmbLocation = New-Object System.Windows.Forms.ComboBox
    $cmbLocation.Location = New-Object System.Drawing.Point(260, $yPos)
    $cmbLocation.Size = New-Object System.Drawing.Size(280, 20)
    $cmbLocation.DropDownStyle = "DropDownList"
    Get-AzureRegions | ForEach-Object { $cmbLocation.Items.Add($_) | Out-Null }
    $cmbLocation.SelectedItem = $Global:Config.Location
    $form.Controls.Add($cmbLocation)

    $yPos += 40

    # Resource Group
    $lblResourceGroup = New-Object System.Windows.Forms.Label
    $lblResourceGroup.Text = "Resource Group Name: *"
    $lblResourceGroup.Location = New-Object System.Drawing.Point(40, $yPos)
    $lblResourceGroup.Size = New-Object System.Drawing.Size(200, 20)
    $form.Controls.Add($lblResourceGroup)

    $txtResourceGroup = New-Object System.Windows.Forms.TextBox
    $txtResourceGroup.Location = New-Object System.Drawing.Point(260, $yPos)
    $txtResourceGroup.Size = New-Object System.Drawing.Size(280, 20)
    $txtResourceGroup.Text = $Global:Config.ResourceGroup
    $form.Controls.Add($txtResourceGroup)

    $yPos += 40

    # Installation Directory
    $lblInstallDir = New-Object System.Windows.Forms.Label
    $lblInstallDir.Text = "Installation Directory: *"
    $lblInstallDir.Location = New-Object System.Drawing.Point(40, $yPos)
    $lblInstallDir.Size = New-Object System.Drawing.Size(200, 20)
    $form.Controls.Add($lblInstallDir)

    $txtInstallDir = New-Object System.Windows.Forms.TextBox
    $txtInstallDir.Location = New-Object System.Drawing.Point(260, $yPos)
    $txtInstallDir.Size = New-Object System.Drawing.Size(240, 20)
    $txtInstallDir.Text = $Global:Config.InstallDir
    $form.Controls.Add($txtInstallDir)

    $btnBrowse = New-Object System.Windows.Forms.Button
    $btnBrowse.Text = "..."
    $btnBrowse.Size = New-Object System.Drawing.Size(30, 22)
    $btnBrowse.Location = New-Object System.Drawing.Point(510, $yPos)
    $btnBrowse.Add_Click({
        $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
        $folderBrowser.SelectedPath = $txtInstallDir.Text
        if ($folderBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $txtInstallDir.Text = $folderBrowser.SelectedPath
        }
    })
    $form.Controls.Add($btnBrowse)

    $yPos += 50

    # Info text
    $lblInfo = New-Object System.Windows.Forms.TextBox
    $lblInfo.Multiline = $true
    $lblInfo.ReadOnly = $true
    $lblInfo.BorderStyle = "None"
    $lblInfo.BackColor = $form.BackColor
    $lblInfo.Text = "* All fields are required`n`nEnvironment Name is used by Azure Developer CLI to track your deployment.`n`nYou can find your Tenant and Subscription IDs in the Azure Portal."
    $lblInfo.ForeColor = [System.Drawing.Color]::Gray
    $lblInfo.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $lblInfo.Location = New-Object System.Drawing.Point(40, $yPos)
    $lblInfo.Size = New-Object System.Drawing.Size(500, 70)
    $form.Controls.Add($lblInfo)

    # Buttons
    $btnBack = New-Object System.Windows.Forms.Button
    $btnBack.Text = "Back"
    $btnBack.Size = New-Object System.Drawing.Size(100, 30)
    $btnBack.Location = New-Object System.Drawing.Point(260, 450)
    $btnBack.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $form.Controls.Add($btnBack)

    $btnNext = New-Object System.Windows.Forms.Button
    $btnNext.Text = "Next"
    $btnNext.Size = New-Object System.Drawing.Size(100, 30)
    $btnNext.Location = New-Object System.Drawing.Point(370, 450)
    $form.Controls.Add($btnNext)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"
    $btnCancel.Size = New-Object System.Drawing.Size(100, 30)
    $btnCancel.Location = New-Object System.Drawing.Point(480, 450)
    $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.Controls.Add($btnCancel)

    $btnNext.Add_Click({
        # Validate inputs
        $valid = $true
        $errorMsg = ""

        if (-not (Test-EnvironmentNameValid $txtEnvName.Text)) {
            $valid = $false
            $errorMsg += "Environment name is required and must be alphanumeric (can include hyphens/underscores)`n"
        }

        if ([string]::IsNullOrWhiteSpace($txtTenant.Text)) {
            $valid = $false
            $errorMsg += "Azure Tenant ID is required`n"
        }
        elseif (-not (Test-GuidFormat $txtTenant.Text)) {
            $valid = $false
            $errorMsg += "Invalid Tenant ID format (must be a valid GUID)`n"
        }

        if ([string]::IsNullOrWhiteSpace($txtSubscription.Text)) {
            $valid = $false
            $errorMsg += "Azure Subscription ID is required`n"
        }
        elseif (-not (Test-GuidFormat $txtSubscription.Text)) {
            $valid = $false
            $errorMsg += "Invalid Subscription ID format (must be a valid GUID)`n"
        }

        if ([string]::IsNullOrWhiteSpace($txtResourceGroup.Text)) {
            $valid = $false
            $errorMsg += "Resource Group Name is required`n"
        }

        if ([string]::IsNullOrWhiteSpace($txtInstallDir.Text)) {
            $valid = $false
            $errorMsg += "Installation directory cannot be empty`n"
        }

        if ($valid) {
            $Global:Config.EnvironmentName = $txtEnvName.Text.Trim()
            $Global:Config.TenantId = $txtTenant.Text.Trim()
            $Global:Config.SubscriptionId = $txtSubscription.Text.Trim()
            $Global:Config.Location = $cmbLocation.SelectedItem
            $Global:Config.ResourceGroup = $txtResourceGroup.Text.Trim()
            $Global:Config.InstallDir = $txtInstallDir.Text.Trim()

            $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $form.Close()
        }
        else {
            [System.Windows.Forms.MessageBox]::Show($errorMsg, "Validation Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })

    $form.AcceptButton = $btnNext
    $result = $form.ShowDialog()
    $form.Dispose()

    return $result
}

function Show-ProgressScreen {
    param([scriptblock]$WorkScript)

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Installation Progress"
    $form.Size = New-Object System.Drawing.Size(700, 500)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.ControlBox = $false

    # Title
    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text = "Installing Azure AI Foundry Agents..."
    $lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $lblTitle.Location = New-Object System.Drawing.Point(20, 20)
    $lblTitle.Size = New-Object System.Drawing.Size(660, 30)
    $form.Controls.Add($lblTitle)

    # Progress bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(20, 60)
    $progressBar.Size = New-Object System.Drawing.Size(660, 30)
    $progressBar.Style = "Marquee"
    $form.Controls.Add($progressBar)

    # Status label
    $lblStatus = New-Object System.Windows.Forms.Label
    $lblStatus.Text = "Initializing..."
    $lblStatus.Location = New-Object System.Drawing.Point(20, 100)
    $lblStatus.Size = New-Object System.Drawing.Size(660, 20)
    $form.Controls.Add($lblStatus)

    # Output text
    $txtOutput = New-Object System.Windows.Forms.TextBox
    $txtOutput.Multiline = $true
    $txtOutput.ScrollBars = "Vertical"
    $txtOutput.ReadOnly = $true
    $txtOutput.Location = New-Object System.Drawing.Point(20, 130)
    $txtOutput.Size = New-Object System.Drawing.Size(660, 290)
    $txtOutput.Font = New-Object System.Drawing.Font("Consolas", 9)
    $form.Controls.Add($txtOutput)

    # Close button (initially disabled)
    $btnClose = New-Object System.Windows.Forms.Button
    $btnClose.Text = "Close"
    $btnClose.Size = New-Object System.Drawing.Size(100, 30)
    $btnClose.Location = New-Object System.Drawing.Point(580, 430)
    $btnClose.Enabled = $false
    $btnClose.Add_Click({ $form.Close() })
    $form.Controls.Add($btnClose)

    # Create functions to update UI
    $Global:UpdateStatus = {
        param([string]$Status)
        $lblStatus.Text = $Status
        $form.Refresh()
    }

    $Global:AppendOutput = {
        param([string]$Text)
        $txtOutput.AppendText("$Text`r`n")
        $txtOutput.SelectionStart = $txtOutput.TextLength
        $txtOutput.ScrollToCaret()
        $form.Refresh()
    }

    $Global:EnableClose = {
        $btnClose.Enabled = $true
        $progressBar.Style = "Continuous"
        $progressBar.Value = 100
    }

    # Execute work in background
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 100
    $timer.Add_Tick({
        $timer.Stop()
        try {
            & $WorkScript
            & $Global:UpdateStatus "Installation complete!"
            & $Global:AppendOutput "`r`n[OK] Installation completed successfully!"
        }
        catch {
            & $Global:UpdateStatus "Installation failed"
            & $Global:AppendOutput "`r`n[X] Error: $_"
            Write-Log "Installation failed: $_" "ERROR"
        }
        finally {
            & $Global:EnableClose
        }
    })

    $form.Add_Shown({ $timer.Start() })

    $form.ShowDialog()
    $form.Dispose()
}

function Show-CompletionScreen {
    param([bool]$Success)

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Installation Complete"
    $form.Size = New-Object System.Drawing.Size(600, 400)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false

    # Title
    $lblTitle = New-Object System.Windows.Forms.Label
    if ($Success) {
        $lblTitle.Text = "[OK] Installation Completed Successfully!"
        $lblTitle.ForeColor = [System.Drawing.Color]::Green
    }
    else {
        $lblTitle.Text = "[X] Installation Encountered Errors"
        $lblTitle.ForeColor = [System.Drawing.Color]::Red
    }
    $lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $lblTitle.Location = New-Object System.Drawing.Point(20, 20)
    $lblTitle.Size = New-Object System.Drawing.Size(560, 40)
    $lblTitle.TextAlign = "MiddleCenter"
    $form.Controls.Add($lblTitle)

    # Next steps
    $lblNextSteps = New-Object System.Windows.Forms.TextBox
    $lblNextSteps.Multiline = $true
    $lblNextSteps.ReadOnly = $true
    $lblNextSteps.ScrollBars = "Vertical"
    $lblNextSteps.BorderStyle = "None"
    $lblNextSteps.BackColor = $form.BackColor
    $lblNextSteps.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $lblNextSteps.Location = New-Object System.Drawing.Point(40, 80)
    $lblNextSteps.Size = New-Object System.Drawing.Size(520, 220)

    if ($Success) {
        $lblNextSteps.Text = @"
Next Steps:

1. Open VS Code in the project directory:
   cd $($Global:Config.InstallDir)
   code .

2. Select the Python interpreter:
   - Press Ctrl+Shift+P
   - Type "Python: Select Interpreter"
   - Choose .venv\Scripts\python.exe

3. Run the notebooks in sequence:
   - Open 1-just-llm.ipynb
   - Run all cells (Shift+Enter or Run All)
   - Continue with notebooks 2-7 in order

Installation directory: $($Global:Config.InstallDir)
Log file: $LogFile

For troubleshooting, see: README.md
"@
    }
    else {
        $lblNextSteps.Text = @"
Installation encountered errors. Please review the log file for details:

Log file: $LogFile

Common issues:
- Azure authentication failed: Run 'azd auth login' manually
- Deployment errors: Check Azure portal for resource quotas
- Network issues: Verify internet connection and firewall settings

For help:
- Check README.md for manual setup instructions
- Review the log file for error details
- Report issues: https://github.com/azure-samples/azure-ai-foundry-agents/issues
"@
    }
    $form.Controls.Add($lblNextSteps)

    # Buttons
    $btnOpenVSCode = New-Object System.Windows.Forms.Button
    $btnOpenVSCode.Text = "Open VS Code"
    $btnOpenVSCode.Size = New-Object System.Drawing.Size(120, 30)
    $btnOpenVSCode.Location = New-Object System.Drawing.Point(240, 320)
    $btnOpenVSCode.Enabled = $Success
    $btnOpenVSCode.Add_Click({
        try {
            Start-Process "code" -ArgumentList "`"$($Global:Config.InstallDir)`""
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to launch VS Code. Please open it manually.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        }
        $form.Close()
    })
    $form.Controls.Add($btnOpenVSCode)

    $btnFinish = New-Object System.Windows.Forms.Button
    $btnFinish.Text = "Finish"
    $btnFinish.Size = New-Object System.Drawing.Size(100, 30)
    $btnFinish.Location = New-Object System.Drawing.Point(370, 320)
    $btnFinish.Add_Click({ $form.Close() })
    $form.Controls.Add($btnFinish)

    $form.ShowDialog()
    $form.Dispose()
}

#endregion

#region Installation Functions

function Install-Repository {
    & $Global:UpdateStatus "Acquiring repository..."
    & $Global:AppendOutput "Repository URL: $($Global:Config.GitHubRepo)"
    & $Global:AppendOutput "Installation directory: $($Global:Config.InstallDir)"

    Write-Log "Installing repository to: $($Global:Config.InstallDir)"

    # Check if directory exists
    if (Test-Path $Global:Config.InstallDir) {
        & $Global:AppendOutput "Directory already exists. Checking for existing installation..."

        if (Test-Path (Join-Path $Global:Config.InstallDir ".git")) {
            & $Global:AppendOutput "Existing Git repository found. Pulling latest changes..."
            Set-Location $Global:Config.InstallDir
            git pull 2>&1 | ForEach-Object { & $Global:AppendOutput $_ }
        }
        else {
            & $Global:AppendOutput "[WARNING] Directory exists but is not a Git repository."
            & $Global:AppendOutput "Using existing directory..."
        }
    }
    else {
        # Try Git clone first
        if (Test-Prerequisite "git") {
            & $Global:AppendOutput "Cloning repository via Git..."
            Write-Log "Cloning repository via Git"

            try {
                git clone $Global:Config.GitHubRepo $Global:Config.InstallDir 2>&1 | ForEach-Object {
                    & $Global:AppendOutput $_
                }
                & $Global:AppendOutput "[OK] Repository cloned successfully"
                Write-Log "Repository cloned successfully"
            }
            catch {
                & $Global:AppendOutput "[X] Git clone failed: $_"
                Write-Log "Git clone failed: $_" "ERROR"
                throw
            }
        }
        else {
            # Fallback to ZIP download
            & $Global:AppendOutput "Git not available. Downloading ZIP archive..."
            Write-Log "Downloading repository as ZIP"

            $zipUrl = "$($Global:Config.GitHubRepo)/archive/refs/heads/main.zip"
            $zipPath = Join-Path $env:TEMP "azure-ai-foundry-agents.zip"

            try {
                Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
                & $Global:AppendOutput "[OK] Downloaded ZIP archive"

                # Extract ZIP
                & $Global:AppendOutput "Extracting archive..."
                Expand-Archive -Path $zipPath -DestinationPath $env:TEMP -Force

                # Move to final location
                $extractedDir = Join-Path $env:TEMP "azure-ai-foundry-agents-main"
                Move-Item -Path $extractedDir -Destination $Global:Config.InstallDir -Force

                Remove-Item -Path $zipPath -Force

                & $Global:AppendOutput "[OK] Repository extracted successfully"
                Write-Log "Repository extracted successfully"
            }
            catch {
                & $Global:AppendOutput "[X] ZIP download failed: $_"
                Write-Log "ZIP download failed: $_" "ERROR"
                throw
            }
        }
    }

    Set-Location $Global:Config.InstallDir
}

function Invoke-AzureAuthentication {
    & $Global:UpdateStatus "Authenticating with Azure..."
    & $Global:AppendOutput "Opening Azure authentication..."

    Write-Log "Starting Azure authentication"

    try {
        azd auth login 2>&1 | ForEach-Object {
            & $Global:AppendOutput $_
        }

        # Verify authentication
        $authStatus = azd auth login --check-status 2>&1
        if ($LASTEXITCODE -eq 0) {
            & $Global:AppendOutput "[OK] Azure authentication successful"
            Write-Log "Azure authentication successful"
        }
        else {
            throw "Authentication verification failed"
        }
    }
    catch {
        & $Global:AppendOutput "[X] Azure authentication failed: $_"
        Write-Log "Azure authentication failed: $_" "ERROR"
        throw
    }
}

function Initialize-AzureEnvironment {
    & $Global:UpdateStatus "Initializing Azure Developer CLI environment..."
    & $Global:AppendOutput "Creating azd environment: $($Global:Config.EnvironmentName)"

    Write-Log "Initializing azd environment: $($Global:Config.EnvironmentName)"

    try {
        # Check if environment already exists
        $existingEnvs = azd env list 2>&1 | Select-String -Pattern $Global:Config.EnvironmentName

        if ($existingEnvs) {
            & $Global:AppendOutput "Environment already exists. Selecting it..."
            azd env select $Global:Config.EnvironmentName 2>&1 | ForEach-Object { & $Global:AppendOutput $_ }
        }
        else {
            & $Global:AppendOutput "Creating new environment..."
            azd env new $Global:Config.EnvironmentName 2>&1 | ForEach-Object { & $Global:AppendOutput $_ }
        }

        & $Global:AppendOutput "[OK] Azure environment initialized"
        Write-Log "Azure environment initialized"
    }
    catch {
        & $Global:AppendOutput "[X] Environment initialization failed: $_"
        Write-Log "Environment initialization failed: $_" "ERROR"
        throw
    }
}

function Set-AzureEnvironment {
    & $Global:UpdateStatus "Configuring Azure environment..."
    & $Global:AppendOutput "Setting Azure environment variables..."

    Write-Log "Configuring Azure environment"

    try {
        if (![string]::IsNullOrWhiteSpace($Global:Config.TenantId)) {
            & $Global:AppendOutput "Setting AZURE_TENANT_ID..."
            azd env set AZURE_TENANT_ID $Global:Config.TenantId
        }

        if (![string]::IsNullOrWhiteSpace($Global:Config.SubscriptionId)) {
            & $Global:AppendOutput "Setting AZURE_SUBSCRIPTION_ID..."
            azd env set AZURE_SUBSCRIPTION_ID $Global:Config.SubscriptionId
        }

        & $Global:AppendOutput "Setting AZURE_LOCATION to $($Global:Config.Location)..."
        azd env set AZURE_LOCATION $Global:Config.Location

        if (![string]::IsNullOrWhiteSpace($Global:Config.ResourceGroup)) {
            & $Global:AppendOutput "Setting AZURE_RESOURCE_GROUP..."
            azd env set AZURE_RESOURCE_GROUP $Global:Config.ResourceGroup
        }

        & $Global:AppendOutput "[OK] Azure environment configured"
        Write-Log "Azure environment configured"
    }
    catch {
        & $Global:AppendOutput "[X] Environment configuration failed: $_"
        Write-Log "Environment configuration failed: $_" "ERROR"
        throw
    }
}

function Invoke-InfrastructureDeployment {
    & $Global:UpdateStatus "Deploying Azure infrastructure (this will take 15-25 minutes)..."
    & $Global:AppendOutput "Starting infrastructure deployment..."
    & $Global:AppendOutput "This may take 15-25 minutes. Please be patient..."

    Write-Log "Starting infrastructure deployment"

    try {
        azd up --no-prompt 2>&1 | ForEach-Object {
            & $Global:AppendOutput $_
            Write-Log "azd up: $_"
        }

        if ($LASTEXITCODE -eq 0) {
            & $Global:AppendOutput "[OK] Infrastructure deployed successfully"
            Write-Log "Infrastructure deployment successful"
        }
        else {
            throw "Deployment exited with code $LASTEXITCODE"
        }
    }
    catch {
        & $Global:AppendOutput "[X] Infrastructure deployment failed: $_"
        Write-Log "Infrastructure deployment failed: $_" "ERROR"
        throw
    }
}

function Install-PythonEnvironment {
    & $Global:UpdateStatus "Setting up Python environment..."
    & $Global:AppendOutput "Installing Python dependencies with uv..."

    Write-Log "Installing Python dependencies"

    try {
        uv sync 2>&1 | ForEach-Object {
            & $Global:AppendOutput $_
        }

        if ($LASTEXITCODE -eq 0) {
            & $Global:AppendOutput "[OK] Python environment set up successfully"
            Write-Log "Python environment setup successful"
        }
        else {
            throw "uv sync exited with code $LASTEXITCODE"
        }
    }
    catch {
        & $Global:AppendOutput "[X] Python environment setup failed: $_"
        Write-Log "Python environment setup failed: $_" "ERROR"
        throw
    }
}

function Test-Installation {
    & $Global:UpdateStatus "Verifying installation..."
    & $Global:AppendOutput "Checking installation..."

    Write-Log "Verifying installation"

    $envFile = Join-Path $Global:Config.InstallDir ".env"
    $venvDir = Join-Path $Global:Config.InstallDir ".venv"

    $success = $true

    if (Test-Path $envFile) {
        & $Global:AppendOutput "[OK] .env file found"
        Write-Log ".env file verified"
    }
    else {
        & $Global:AppendOutput "[X] .env file not found"
        Write-Log ".env file not found" "ERROR"
        $success = $false
    }

    if (Test-Path $venvDir) {
        & $Global:AppendOutput "[OK] Python virtual environment found"
        Write-Log "Virtual environment verified"
    }
    else {
        & $Global:AppendOutput "[X] Python virtual environment not found"
        Write-Log "Virtual environment not found" "ERROR"
        $success = $false
    }

    return $success
}

#endregion

#region Main Installation Flow

function Start-Installation {
    Write-Log "Starting installation workflow"

    # Welcome screen
    if (-not (Show-WelcomeScreen)) {
        Write-Log "Installation cancelled by user at welcome screen"
        return
    }

    # Prerequisites check
    if (-not (Show-PrerequisitesScreen)) {
        Write-Log "Installation cancelled by user at prerequisites screen"
        return
    }

    # Configuration
    $configResult = Show-ConfigurationScreen
    while ($configResult -eq [System.Windows.Forms.DialogResult]::Retry) {
        $configResult = Show-ConfigurationScreen
    }

    if ($configResult -ne [System.Windows.Forms.DialogResult]::OK) {
        Write-Log "Installation cancelled by user at configuration screen"
        return
    }

    Write-Log "Configuration: InstallDir=$($Global:Config.InstallDir), Env=$($Global:Config.EnvironmentName), Location=$($Global:Config.Location)"

    # Installation progress
    $Global:InstallSuccess = $false

    Show-ProgressScreen -WorkScript {
        try {
            Install-Repository
            Invoke-AzureAuthentication
            Initialize-AzureEnvironment
            Set-AzureEnvironment
            Invoke-InfrastructureDeployment
            Install-PythonEnvironment
            $Global:InstallSuccess = Test-Installation

            if ($Global:InstallSuccess) {
                Write-Log "Installation completed successfully" "SUCCESS"
            }
            else {
                Write-Log "Installation completed with errors" "WARNING"
            }
        }
        catch {
            Write-Log "Installation failed: $_" "ERROR"
            $Global:InstallSuccess = $false
        }
    }

    # Completion screen
    Show-CompletionScreen -Success $Global:InstallSuccess

    Write-Log "Installation workflow completed"
}

#endregion

# Run installer
try {
    Start-Installation
}
catch {
    Write-Log "Installer crashed: $_" "ERROR"
    Write-Log "Error type: $($_.Exception.GetType().FullName)" "ERROR"
    Write-Log "Stack trace: $($_.ScriptStackTrace)" "ERROR"
    Write-Log "Inner exception: $($_.Exception.InnerException)" "ERROR"

    $errorMessage = @"
Installer encountered a fatal error:

$_

Please check the log file for details:
$LogFile
"@

    # Try to show message box, but don't fail if GUI isn't working
    try {
        [System.Windows.Forms.MessageBox]::Show($errorMessage, "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
    catch {
        Write-Host $errorMessage -ForegroundColor Red
    }
}
finally {
    Write-Log "=========================================="
    Write-Log "Installer Finished"
    Write-Log "=========================================="
}
