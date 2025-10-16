#!/bin/bash

# Script to verify CVE-2016-0752 fix in Action View
# This script checks if the Action View version is secure

set -e

echo "==================================="
echo "CVE-2016-0752 Security Fix Verification"
echo "==================================="
echo ""

# Check if Gemfile.lock exists
if [ ! -f "Gemfile.lock" ]; then
    echo "❌ ERROR: Gemfile.lock not found!"
    exit 1
fi

echo "Checking Action View version in Gemfile.lock..."
echo ""

# Extract actionview version
ACTIONVIEW_VERSION=$(grep -A 1 "^    actionview (" Gemfile.lock | head -1 | sed 's/.*(\(.*\))/\1/')

echo "Found Action View version: $ACTIONVIEW_VERSION"
echo ""

# Define minimum secure versions for different series
# CVE-2016-0752 requires:
# - 3.2.22.1+ for 3.x series
# - 4.1.14.1+ for 4.1.x series  
# - 4.2.5.1+ for 4.2.x series
# - 5.0.0.beta1.1+ for 5.x series

# Extract major, minor, and patch version
MAJOR_VERSION=$(echo "$ACTIONVIEW_VERSION" | cut -d. -f1)
MINOR_VERSION=$(echo "$ACTIONVIEW_VERSION" | cut -d. -f2)
PATCH_VERSION=$(echo "$ACTIONVIEW_VERSION" | cut -d. -f3)

echo "Analyzing version components:"
echo "  Major: $MAJOR_VERSION"
echo "  Minor: $MINOR_VERSION"
echo "  Patch: $PATCH_VERSION"
echo ""

# Check if version is secure
SECURE=false

if [ "$MAJOR_VERSION" -ge 5 ]; then
    echo "✅ SECURE: Version 5.x or higher is not affected by CVE-2016-0752"
    SECURE=true
elif [ "$MAJOR_VERSION" -eq 4 ]; then
    if [ "$MINOR_VERSION" -eq 2 ]; then
        # Check if 4.2.5.1 or higher
        if [ "$PATCH_VERSION" -ge 6 ] || ([ "$PATCH_VERSION" -eq 5 ] && echo "$ACTIONVIEW_VERSION" | grep -q '\.5\.1$'); then
            echo "✅ SECURE: Version 4.2.5.1 or higher"
            SECURE=true
        else
            echo "❌ VULNERABLE: Version must be 4.2.5.1 or higher"
        fi
    elif [ "$MINOR_VERSION" -eq 1 ]; then
        # Check if 4.1.14.1 or higher
        if [ "$PATCH_VERSION" -ge 15 ] || ([ "$PATCH_VERSION" -eq 14 ] && echo "$ACTIONVIEW_VERSION" | grep -q '\.14\.1$'); then
            echo "✅ SECURE: Version 4.1.14.1 or higher"
            SECURE=true
        else
            echo "❌ VULNERABLE: Version must be 4.1.14.1 or higher"
        fi
    else
        echo "❌ VULNERABLE: Action View 4.0.x is vulnerable"
    fi
elif [ "$MAJOR_VERSION" -eq 3 ]; then
    # Check if 3.2.22.1 or higher
    if ([ "$MINOR_VERSION" -eq 2 ] && [ "$PATCH_VERSION" -ge 23 ]) || ([ "$PATCH_VERSION" -eq 22 ] && echo "$ACTIONVIEW_VERSION" | grep -q '\.22\.1$'); then
        echo "✅ SECURE: Version 3.2.22.1 or higher"
        SECURE=true
    else
        echo "❌ VULNERABLE: Version must be 3.2.22.1 or higher"
    fi
else
    echo "❌ VULNERABLE: Unknown or very old version"
fi

echo ""
echo "==================================="
if [ "$SECURE" = true ]; then
    echo "✅ RESULT: CVE-2016-0752 is FIXED"
    echo "==================================="
    exit 0
else
    echo "❌ RESULT: CVE-2016-0752 is NOT FIXED"
    echo "==================================="
    exit 1
fi
