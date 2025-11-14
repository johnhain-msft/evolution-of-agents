#!/bin/bash
set -e

echo "=============================================="
echo "Populating .env file from deployment outputs"
echo "=============================================="

# Check if azd is installed
if ! command -v azd &> /dev/null; then
    echo "Error: Azure Developer CLI (azd) not found"
    echo "Please install azd: https://learn.microsoft.com/azure/developer/azure-developer-cli/install-azd"
    exit 1
fi

# Extract deployment outputs from Azure Developer CLI
echo "Retrieving deployment outputs from azd..."
azd env get-values > .env

# Verify .env file was created successfully
if [ ! -f .env ]; then
    echo "Error: Failed to create .env file"
    exit 1
fi

# Add semantic kernel diagnostic flags if not present
if ! grep -q "SEMANTICKERNEL_EXPERIMENTAL_GENAI_ENABLE_OTEL_DIAGNOSTICS" .env; then
    echo "" >> .env
    echo "# Semantic Kernel diagnostics" >> .env
    echo "SEMANTICKERNEL_EXPERIMENTAL_GENAI_ENABLE_OTEL_DIAGNOSTICS=true" >> .env
    echo "SEMANTICKERNEL_EXPERIMENTAL_GENAI_ENABLE_OTEL_DIAGNOSTICS_SENSITIVE=true" >> .env
fi

echo ""
echo "✓ .env file created successfully!"
echo ""
echo "Next steps:"
echo "  1. Run 'uv sync' to install Python dependencies"
echo "  2. Select the Python interpreter in VS Code (.venv/bin/python)"
echo "  3. Open and run notebooks 1-7 in sequence"
echo ""
