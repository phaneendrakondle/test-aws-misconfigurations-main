#!/bin/bash
# Validation script to verify Apache Tomcat version meets security requirements
# This script checks that all Tomcat configurations use a secure version

set -e

echo "🔍 Validating Apache Tomcat version in configurations..."
echo ""

# Define secure versions for CVE-2025-24813
SECURE_VERSION_9="9.0.99"
SECURE_VERSION_10="10.1.35"
SECURE_VERSION_11="11.0.3"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Function to check version
check_version() {
    local file=$1
    local version=$2
    
    echo "Checking $file..."
    
    # Check if version is in the file
    if grep -q "$version" "$file"; then
        # Determine if it's a secure version
        if [[ "$version" == "$SECURE_VERSION_9" ]] || [[ "$version" == "$SECURE_VERSION_10" ]] || [[ "$version" == "$SECURE_VERSION_11" ]]; then
            echo -e "${GREEN}✓ PASS${NC}: $file uses secure version $version"
        else
            echo -e "${RED}✗ FAIL${NC}: $file uses vulnerable version $version"
            ERRORS=$((ERRORS + 1))
        fi
    fi
    echo ""
}

# Check Terraform EC2 configuration
if [ -f "terraform-ec2-misconfigured.tf" ]; then
    echo "📄 Checking Terraform EC2 configuration..."
    if grep -q "TOMCAT_VERSION=\"9.0.99\"" terraform-ec2-misconfigured.tf; then
        echo -e "${GREEN}✓ PASS${NC}: terraform-ec2-misconfigured.tf uses secure Tomcat version 9.0.99"
    else
        echo -e "${RED}✗ FAIL${NC}: terraform-ec2-misconfigured.tf does not use secure Tomcat version"
        ERRORS=$((ERRORS + 1))
    fi
    
    # Check for CVE-2025-24813 mitigation comments
    if grep -q "CVE-2025-24813" terraform-ec2-misconfigured.tf; then
        echo -e "${GREEN}✓ PASS${NC}: CVE-2025-24813 is documented in terraform-ec2-misconfigured.tf"
    else
        echo -e "${YELLOW}⚠ WARNING${NC}: CVE-2025-24813 not documented in terraform-ec2-misconfigured.tf"
        WARNINGS=$((WARNINGS + 1))
    fi
    echo ""
fi

# Check src/tomcat-config.yaml
if [ -f "src/tomcat-config.yaml" ]; then
    echo "📄 Checking src/tomcat-config.yaml..."
    if grep -q "version: \"9.0.99\"" src/tomcat-config.yaml; then
        echo -e "${GREEN}✓ PASS${NC}: src/tomcat-config.yaml uses secure Tomcat version 9.0.99"
    else
        echo -e "${RED}✗ FAIL${NC}: src/tomcat-config.yaml does not use secure Tomcat version"
        ERRORS=$((ERRORS + 1))
    fi
    
    if grep -q "status: \"PATCHED\"" src/tomcat-config.yaml; then
        echo -e "${GREEN}✓ PASS${NC}: CVE-2025-24813 status is marked as PATCHED"
    else
        echo -e "${RED}✗ FAIL${NC}: CVE-2025-24813 status not marked as PATCHED"
        ERRORS=$((ERRORS + 1))
    fi
    echo ""
fi

# Check src/cloudformation-tomcat-secure.yaml
if [ -f "src/cloudformation-tomcat-secure.yaml" ]; then
    echo "📄 Checking src/cloudformation-tomcat-secure.yaml..."
    if grep -q "TOMCAT_VERSION=\"9.0.99\"" src/cloudformation-tomcat-secure.yaml; then
        echo -e "${GREEN}✓ PASS${NC}: src/cloudformation-tomcat-secure.yaml uses secure Tomcat version 9.0.99"
    else
        echo -e "${RED}✗ FAIL${NC}: src/cloudformation-tomcat-secure.yaml does not use secure Tomcat version"
        ERRORS=$((ERRORS + 1))
    fi
    
    if grep -q "CVE-2025-24813" src/cloudformation-tomcat-secure.yaml; then
        echo -e "${GREEN}✓ PASS${NC}: CVE-2025-24813 is documented in CloudFormation template"
    else
        echo -e "${YELLOW}⚠ WARNING${NC}: CVE-2025-24813 not documented in CloudFormation template"
        WARNINGS=$((WARNINGS + 1))
    fi
    echo ""
fi

# Check security hardening measures
echo "🔒 Checking security hardening measures..."

# Check for readonly parameter
if grep -q "readonly" terraform-ec2-misconfigured.tf && grep -q "readonly" src/cloudformation-tomcat-secure.yaml; then
    echo -e "${GREEN}✓ PASS${NC}: Readonly mode configured in Tomcat deployments"
else
    echo -e "${RED}✗ FAIL${NC}: Readonly mode not properly configured"
    ERRORS=$((ERRORS + 1))
fi

# Summary
echo ""
echo "========================================"
echo "Validation Summary"
echo "========================================"
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All validations passed!${NC}"
    echo ""
    echo "✅ Apache Tomcat is configured with secure version 9.0.99"
    echo "✅ CVE-2025-24813 mitigation measures are in place"
    exit 0
else
    echo -e "${RED}✗ Validation failed with $ERRORS error(s)${NC}"
    exit 1
fi
