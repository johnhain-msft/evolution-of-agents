#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Azure AI Foundry Agents - Uninstaller
.DESCRIPTION
    Cleanup script for Azure AI Foundry Agents installation.
    Optionally removes Azure resources, installation directory, and local files.
.NOTES
    Version: 1.0
#>

# Stop on errors
$ErrorActionPreference = "Stop"

# Setup logging
$LogFile = Join-Path $env:TEMP "azure-ai-foundry-agents-uninstall.log"
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
Write-Log "Azure AI Foundry Agents Uninstaller Started"
Write-Log "=========================================="
Write-Log "Log file: $LogFile"

# Add Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Global state
$Global:UninstallOptions = @{
    DeleteAzureResources = $false
    DeleteInstallDirectory = $false
    KeepPrerequisites = $true
}

#region Helper Functions

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

function Find-InstallDirectory {
    # Common installation locations
    $commonPaths = @(
        (Join-Path $env:USERPROFILE "azure-ai-foundry-agents"),
        (Join-Path $env:USERPROFILE "Documents\azure-ai-foundry-agents"),
        "C:\azure-ai-foundry-agents"
    )

    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            return $path
        }
    }

    return $null
}

#endregion

#region GUI Functions

function Show-UninstallOptionsScreen {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Azure AI Foundry Agents - Uninstall"
    $form.Size = New-Object System.Drawing.Size(600, 450)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false

    # Title
    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text = "Uninstall Azure AI Foundry Agents"
    $lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $lblTitle.Location = New-Object System.Drawing.Point(20, 20)
    $lblTitle.Size = New-Object System.Drawing.Size(560, 40)
    $lblTitle.TextAlign = "MiddleCenter"
    $form.Controls.Add($lblTitle)

    # Description
    $lblDesc = New-Object System.Windows.Forms.Label
    $lblDesc.Text = "Select what you want to remove:"
    $lblDesc.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $lblDesc.Location = New-Object System.Drawing.Point(40, 80)
    $lblDesc.Size = New-Object System.Drawing.Size(520, 30)
    $form.Controls.Add($lblDesc)

    $yPos = 120

    # Checkbox: Delete Azure Resources
    $chkAzureResources = New-Object System.Windows.Forms.CheckBox
    $chkAzureResources.Text = "Delete Azure resources (runs 'azd down')"
    $chkAzureResources.Location = New-Object System.Drawing.Point(60, $yPos)
    $chkAzureResources.Size = New-Object System.Drawing.Size(500, 30)
    $chkAzureResources.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $form.Controls.Add($chkAzureResources)

    $yPos += 40

    $lblAzureWarning = New-Object System.Windows.Forms.Label
    $lblAzureWarning.Text = "[WARNING] This will permanently delete all Azure resources created by the installer"
    $lblAzureWarning.ForeColor = [System.Drawing.Color]::Red
    $lblAzureWarning.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $lblAzureWarning.Location = New-Object System.Drawing.Point(80, $yPos)
    $lblAzureWarning.Size = New-Object System.Drawing.Size(480, 20)
    $form.Controls.Add($lblAzureWarning)

    $yPos += 40

    # Checkbox: Delete Installation Directory
    $chkInstallDir = New-Object System.Windows.Forms.CheckBox
    $chkInstallDir.Text = "Delete installation directory and all project files"
    $chkInstallDir.Location = New-Object System.Drawing.Point(60, $yPos)
    $chkInstallDir.Size = New-Object System.Drawing.Size(500, 30)
    $chkInstallDir.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $form.Controls.Add($chkInstallDir)

    $yPos += 40

    # Installation directory display
    $installDir = Find-InstallDirectory
    if ($installDir) {
        $lblInstallDirPath = New-Object System.Windows.Forms.Label
        $lblInstallDirPath.Text = "Found: $installDir"
        $lblInstallDirPath.ForeColor = [System.Drawing.Color]::Gray
        $lblInstallDirPath.Font = New-Object System.Drawing.Font("Segoe UI", 8)
        $lblInstallDirPath.Location = New-Object System.Drawing.Point(80, $yPos)
        $lblInstallDirPath.Size = New-Object System.Drawing.Size(480, 20)
        $form.Controls.Add($lblInstallDirPath)
    }
    else {
        $lblInstallDirPath = New-Object System.Windows.Forms.Label
        $lblInstallDirPath.Text = "Installation directory not found"
        $lblInstallDirPath.ForeColor = [System.Drawing.Color]::Gray
        $lblInstallDirPath.Font = New-Object System.Drawing.Font("Segoe UI", 8)
        $lblInstallDirPath.Location = New-Object System.Drawing.Point(80, $yPos)
        $lblInstallDirPath.Size = New-Object System.Drawing.Size(480, 20)
        $form.Controls.Add($lblInstallDirPath)
        $chkInstallDir.Enabled = $false
    }

    $yPos += 40

    # Info text
    $lblInfo = New-Object System.Windows.Forms.TextBox
    $lblInfo.Multiline = $true
    $lblInfo.ReadOnly = $true
    $lblInfo.BorderStyle = "None"
    $lblInfo.BackColor = $form.BackColor
    $lblInfo.Text = @"
Note: Prerequisites (Python, Azure CLI, Git, etc.) will NOT be uninstalled.
You can manually remove them later if desired.

Uninstall log will be saved to: $LogFile
"@
    $lblInfo.ForeColor = [System.Drawing.Color]::Gray
    $lblInfo.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $lblInfo.Location = New-Object System.Drawing.Point(40, $yPos)
    $lblInfo.Size = New-Object System.Drawing.Size(520, 80)
    $form.Controls.Add($lblInfo)

    # Buttons
    $btnUninstall = New-Object System.Windows.Forms.Button
    $btnUninstall.Text = "Uninstall"
    $btnUninstall.Size = New-Object System.Drawing.Size(100, 30)
    $btnUninstall.Location = New-Object System.Drawing.Point(370, 360)
    $form.Controls.Add($btnUninstall)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"
    $btnCancel.Size = New-Object System.Drawing.Size(100, 30)
    $btnCancel.Location = New-Object System.Drawing.Point(480, 360)
    $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.Controls.Add($btnCancel)

    $btnUninstall.Add_Click({
        $Global:UninstallOptions.DeleteAzureResources = $chkAzureResources.Checked
        $Global:UninstallOptions.DeleteInstallDirectory = $chkInstallDir.Checked

        # Confirm if deleting Azure resources
        if ($Global:UninstallOptions.DeleteAzureResources) {
            $result = [System.Windows.Forms.MessageBox]::Show(
                "Are you sure you want to delete all Azure resources?`n`nThis action cannot be undone.",
                "Confirm Azure Resource Deletion",
                [System.Windows.Forms.MessageBoxButtons]::YesNo,
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )

            if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {
                return
            }
        }

        $form.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.Close()
    })

    $result = $form.ShowDialog()
    $form.Dispose()

    return ($result -eq [System.Windows.Forms.DialogResult]::OK)
}

function Show-ProgressScreen {
    param([scriptblock]$WorkScript)

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Uninstalling..."
    $form.Size = New-Object System.Drawing.Size(600, 400)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.ControlBox = $false

    # Title
    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text = "Uninstalling Azure AI Foundry Agents..."
    $lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $lblTitle.Location = New-Object System.Drawing.Point(20, 20)
    $lblTitle.Size = New-Object System.Drawing.Size(560, 30)
    $form.Controls.Add($lblTitle)

    # Progress bar
    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Location = New-Object System.Drawing.Point(20, 60)
    $progressBar.Size = New-Object System.Drawing.Size(560, 30)
    $progressBar.Style = "Marquee"
    $form.Controls.Add($progressBar)

    # Status label
    $lblStatus = New-Object System.Windows.Forms.Label
    $lblStatus.Text = "Initializing..."
    $lblStatus.Location = New-Object System.Drawing.Point(20, 100)
    $lblStatus.Size = New-Object System.Drawing.Size(560, 20)
    $form.Controls.Add($lblStatus)

    # Output text
    $txtOutput = New-Object System.Windows.Forms.TextBox
    $txtOutput.Multiline = $true
    $txtOutput.ScrollBars = "Vertical"
    $txtOutput.ReadOnly = $true
    $txtOutput.Location = New-Object System.Drawing.Point(20, 130)
    $txtOutput.Size = New-Object System.Drawing.Size(560, 190)
    $txtOutput.Font = New-Object System.Drawing.Font("Consolas", 9)
    $form.Controls.Add($txtOutput)

    # Close button (initially disabled)
    $btnClose = New-Object System.Windows.Forms.Button
    $btnClose.Text = "Close"
    $btnClose.Size = New-Object System.Drawing.Size(100, 30)
    $btnClose.Location = New-Object System.Drawing.Point(480, 330)
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
            & $Global:UpdateStatus "Uninstall complete!"
            & $Global:AppendOutput "`r`n[OK] Uninstall completed successfully!"
        }
        catch {
            & $Global:UpdateStatus "Uninstall failed"
            & $Global:AppendOutput "`r`n[X] Error: $_"
            Write-Log "Uninstall failed: $_" "ERROR"
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
    $form.Text = "Uninstall Complete"
    $form.Size = New-Object System.Drawing.Size(500, 300)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false

    # Title
    $lblTitle = New-Object System.Windows.Forms.Label
    if ($Success) {
        $lblTitle.Text = "[OK] Uninstall Completed"
        $lblTitle.ForeColor = [System.Drawing.Color]::Green
    }
    else {
        $lblTitle.Text = "[X] Uninstall Encountered Errors"
        $lblTitle.ForeColor = [System.Drawing.Color]::Red
    }
    $lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $lblTitle.Location = New-Object System.Drawing.Point(20, 20)
    $lblTitle.Size = New-Object System.Drawing.Size(460, 40)
    $lblTitle.TextAlign = "MiddleCenter"
    $form.Controls.Add($lblTitle)

    # Message
    $lblMessage = New-Object System.Windows.Forms.TextBox
    $lblMessage.Multiline = $true
    $lblMessage.ReadOnly = $true
    $lblMessage.ScrollBars = "Vertical"
    $lblMessage.BorderStyle = "None"
    $lblMessage.BackColor = $form.BackColor
    $lblMessage.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $lblMessage.Location = New-Object System.Drawing.Point(40, 80)
    $lblMessage.Size = New-Object System.Drawing.Size(420, 120)

    if ($Success) {
        $lblMessage.Text = @"
Azure AI Foundry Agents has been uninstalled.

Log file: $LogFile

Thank you for using Azure AI Foundry Agents!
"@
    }
    else {
        $lblMessage.Text = @"
Uninstall encountered errors. Some items may not have been removed.

Please check the log file for details:
$LogFile

You may need to manually remove remaining files or Azure resources.
"@
    }
    $form.Controls.Add($lblMessage)

    # Finish button
    $btnFinish = New-Object System.Windows.Forms.Button
    $btnFinish.Text = "Finish"
    $btnFinish.Size = New-Object System.Drawing.Size(100, 30)
    $btnFinish.Location = New-Object System.Drawing.Point(200, 220)
    $btnFinish.Add_Click({ $form.Close() })
    $form.Controls.Add($btnFinish)

    $form.ShowDialog()
    $form.Dispose()
}

#endregion

#region Uninstall Functions

function Remove-AzureResources {
    & $Global:UpdateStatus "Removing Azure resources..."
    & $Global:AppendOutput "Running 'azd down' to delete Azure resources..."

    Write-Log "Removing Azure resources"

    if (-not (Test-Prerequisite "azd")) {
        & $Global:AppendOutput "[WARNING] Azure Developer CLI (azd) not found. Cannot delete Azure resources."
        Write-Log "azd not found, skipping Azure resource deletion" "WARNING"
        return $false
    }

    try {
        # Navigate to installation directory if it exists
        $installDir = Find-InstallDirectory
        if ($installDir -and (Test-Path $installDir)) {
            Set-Location $installDir
            & $Global:AppendOutput "Working directory: $installDir"
        }

        azd down --force --purge --no-prompt 2>&1 | ForEach-Object {
            & $Global:AppendOutput $_
            Write-Log "azd down: $_"
        }

        if ($LASTEXITCODE -eq 0) {
            & $Global:AppendOutput "[OK] Azure resources deleted successfully"
            Write-Log "Azure resources deleted successfully" "SUCCESS"
            return $true
        }
        else {
            & $Global:AppendOutput "[WARNING] azd down completed with warnings"
            Write-Log "azd down completed with warnings" "WARNING"
            return $true
        }
    }
    catch {
        & $Global:AppendOutput "[X] Failed to delete Azure resources: $_"
        Write-Log "Failed to delete Azure resources: $_" "ERROR"
        return $false
    }
}

function Remove-InstallDirectory {
    & $Global:UpdateStatus "Removing installation directory..."

    $installDir = Find-InstallDirectory

    if (-not $installDir) {
        & $Global:AppendOutput "Installation directory not found. Nothing to remove."
        Write-Log "Installation directory not found"
        return $true
    }

    & $Global:AppendOutput "Removing directory: $installDir"
    Write-Log "Removing installation directory: $installDir"

    try {
        Remove-Item -Path $installDir -Recurse -Force
        & $Global:AppendOutput "[OK] Installation directory removed successfully"
        Write-Log "Installation directory removed successfully" "SUCCESS"
        return $true
    }
    catch {
        & $Global:AppendOutput "[X] Failed to remove installation directory: $_"
        & $Global:AppendOutput "You may need to manually delete: $installDir"
        Write-Log "Failed to remove installation directory: $_" "ERROR"
        return $false
    }
}

#endregion

#region Main Uninstall Flow

function Start-Uninstall {
    Write-Log "Starting uninstall workflow"

    # Show options screen
    if (-not (Show-UninstallOptionsScreen)) {
        Write-Log "Uninstall cancelled by user"
        return
    }

    Write-Log "Uninstall options: DeleteAzureResources=$($Global:UninstallOptions.DeleteAzureResources), DeleteInstallDirectory=$($Global:UninstallOptions.DeleteInstallDirectory)"

    # Nothing to do?
    if (-not $Global:UninstallOptions.DeleteAzureResources -and -not $Global:UninstallOptions.DeleteInstallDirectory) {
        Write-Log "No uninstall actions selected. Exiting."
        [System.Windows.Forms.MessageBox]::Show("No items selected for removal.", "Nothing to Uninstall", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        return
    }

    # Progress screen
    $Global:UninstallSuccess = $true

    Show-ProgressScreen -WorkScript {
        try {
            if ($Global:UninstallOptions.DeleteAzureResources) {
                if (-not (Remove-AzureResources)) {
                    $Global:UninstallSuccess = $false
                }
            }

            if ($Global:UninstallOptions.DeleteInstallDirectory) {
                if (-not (Remove-InstallDirectory)) {
                    $Global:UninstallSuccess = $false
                }
            }

            if ($Global:UninstallSuccess) {
                Write-Log "Uninstall completed successfully" "SUCCESS"
            }
            else {
                Write-Log "Uninstall completed with errors" "WARNING"
            }
        }
        catch {
            Write-Log "Uninstall failed: $_" "ERROR"
            $Global:UninstallSuccess = $false
        }
    }

    # Completion screen
    Show-CompletionScreen -Success $Global:UninstallSuccess

    Write-Log "Uninstall workflow completed"
}

#endregion

# Run uninstaller
try {
    Start-Uninstall
}
catch {
    Write-Log "Uninstaller crashed: $_" "ERROR"
    [System.Windows.Forms.MessageBox]::Show("Uninstaller encountered a fatal error. Check log file: $LogFile", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}
finally {
    Write-Log "=========================================="
    Write-Log "Uninstaller Finished"
    Write-Log "=========================================="
}
