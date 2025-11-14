#!/usr/bin/env pwsh
# Stop on errors
$ErrorActionPreference = "Stop"

Write-Host "=============================================="
Write-Host "Populating .env file from deployment outputs"
Write-Host "=============================================="

# Check if azd is installed
if (!(Get-Command azd -ErrorAction SilentlyContinue)) {
    Write-Error "Azure Developer CLI (azd) not found"
    Write-Host "Please install azd: https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd"
    exit 1
}

# Extract deployment outputs from Azure Developer CLI
Write-Host "Retrieving deployment outputs from azd..."
azd env get-values | Out-File -FilePath .env -Encoding utf8

# Verify .env file was created successfully
if (!(Test-Path .env)) {
    Write-Error "Failed to create .env file"
    exit 1
}

# Add semantic kernel diagnostic flags if not present
$envContent = Get-Content .env -Raw
if ($envContent -notmatch "SEMANTICKERNEL_EXPERIMENTAL_GENAI_ENABLE_OTEL_DIAGNOSTICS") {
    Add-Content -Path .env -Value ""
    Add-Content -Path .env -Value "# Semantic Kernel diagnostics"
    Add-Content -Path .env -Value "SEMANTICKERNEL_EXPERIMENTAL_GENAI_ENABLE_OTEL_DIAGNOSTICS=true"
    Add-Content -Path .env -Value "SEMANTICKERNEL_EXPERIMENTAL_GENAI_ENABLE_OTEL_DIAGNOSTICS_SENSITIVE=true"
}

Write-Host ""
Write-Host "[OK] .env file created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:"
Write-Host "  1. Run 'uv sync' to install Python dependencies"
Write-Host "  2. Select the Python interpreter in VS Code (.venv\Scripts\python.exe)"
Write-Host "  3. Open and run notebooks 1-7 in sequence"
Write-Host ""
