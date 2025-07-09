#!/bin/bash
# build_lambda_cloudtrail.sh

# Set up colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Exit on any error
set -euxo pipefail

# Function for error handling
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    deactivate 2>/dev/null || true
    rm -rf venv 2>/dev/null || true
    exit 1
}

# Function for cleanup
cleanup() {
    echo "Cleaning up..."
    deactivate 2>/dev/null || true
    rm -rf venv 2>/dev/null || true
}

# Set trap for cleanup on script exit
trap cleanup EXIT

# Check required tools
command -v python3 >/dev/null 2>&1 || error_exit "Python3 is required but not installed"
command -v pip3 >/dev/null 2>&1 || error_exit "pip3 is required but not installed"
command -v zip >/dev/null 2>&1 || error_exit "zip is required but not installed"

# Verify source files exist
[ -f "requirements.txt" ] || error_exit "requirements.txt not found"
[ -f "src/opensearch_handler.py" ] || error_exit "src/opensearch_handler.py not found"

echo -e "${GREEN}Starting Lambda build process...${NC}"

# Create necessary directories
echo "Creating build directories..."
mkdir -p build/lambda || error_exit "Failed to create lambda directory"
mkdir -p build/layer/python || error_exit "Failed to create layer directory"

# Clean up any previous builds
echo "Cleaning previous builds..."
rm -rf build/lambda/* build/layer/python/*

# Create virtual environment with specific Python version
echo "Creating virtual environment..."
python3 -m venv venv || error_exit "Failed to create virtual environment"
source venv/bin/activate || error_exit "Failed to activate virtual environment"

# Verify Python version
PYTHON_VERSION=$(python3 --version 2>&1 | cut -d" " -f2)
echo -e "${YELLOW}Using Python version: $PYTHON_VERSION${NC}"

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip || error_exit "Failed to upgrade pip"

# Install dependencies
echo "Installing dependencies..."
pip install -r requirements.txt --target build/layer/python || error_exit "Failed to install dependencies"

# Create Lambda function package
echo "Creating Lambda function package..."
cp src/opensearch_handler.py build/lambda/ || error_exit "Failed to copy handler"

cd build/lambda || error_exit "Failed to change to lambda directory"
zip -r cloudtrail_processor.zip opensearch_handler.py || error_exit "Failed to create function zip"
cd ../..

# Create layer package
echo "Creating Lambda layer package..."
cd build/layer || error_exit "Failed to change to layer directory"
zip -r ../lambda_layer_cloudtrail.zip python/ || error_exit "Failed to create layer zip"
cd ../..

echo -e "${GREEN}Build complete!${NC}"

# Verify the build
echo "Verifying build artifacts..."
if [ -f "build/lambda/cloudtrail_processor.zip" ] && [ -f "build/lambda_layer_cloudtrail.zip" ]; then
    echo -e "${GREEN}Build verification successful!${NC}"
    echo "Package sizes:"
    ls -lh build/lambda/cloudtrail_processor.zip
    ls -lh build/lambda_layer_cloudtrail.zip

    # Print package contents for verification
    echo -e "\nLambda function contents:"
    unzip -l build/lambda/cloudtrail_processor.zip

    echo -e "\nLambda layer contents (first 10 items):"
    unzip -l build/lambda_layer_cloudtrail.zip | head -n 13

    echo -e "\n${GREEN}Build completed successfully!${NC}"

    # Optional: Print MD5 hashes for verification
    echo -e "\nMD5 Hashes:"
    md5sum build/lambda/cloudtrail_processor.zip
    md5sum build/lambda_layer_cloudtrail.zip
else
    error_exit "Build verification failed! Some packages are missing."
fi