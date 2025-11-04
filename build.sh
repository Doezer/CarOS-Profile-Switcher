#!/bin/bash
# CarOS Profile Switcher - Build Script (Bash)
# Creates a release ZIP for Magisk installation

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Functions
show_help() {
    cat << EOF
CarOS Profile Switcher Build Script
====================================

Usage: ./build.sh [version]

Arguments:
  version    Optional version number (e.g., "0.2.4")
             If not provided, will extract from module.prop

Examples:
  ./build.sh              # Auto-detect version from module.prop
  ./build.sh 0.2.4        # Build with specific version

The script will:
1. Read or use the provided version number
2. Create the rel/ directory if needed
3. Package all necessary files into a ZIP
4. Save to rel/CarOS_Profile_Switcher-v{VERSION}.zip

EOF
    exit 0
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_help
fi

echo -e "${CYAN}🚗 CarOS Profile Switcher - Build Script${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""

# Get version
VERSION="$1"
if [ -z "$VERSION" ]; then
    if [ -f "module.prop" ]; then
        VERSION=$(grep "^version=" module.prop | cut -d'=' -f2)
        echo -e "${GREEN}📋 Version detected from module.prop: $VERSION${NC}"
    else
        echo -e "${RED}❌ Error: module.prop not found!${NC}"
        exit 1
    fi
fi

# Validate required files
REQUIRED_FILES=(
    "caros_config.sh"
    "module.prop"
    "post-fs-data.sh"
    "service.sh"
    "system.prop"
    "grant_permissions.sh"
    "META-INF/com/google/android/update-binary"
    "META-INF/com/google/android/updater-script"
)

MISSING_FILES=()
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        MISSING_FILES+=("$file")
    fi
done

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    echo -e "${RED}❌ Error: Missing required files:${NC}"
    for file in "${MISSING_FILES[@]}"; do
        echo -e "${RED}  - $file${NC}"
    done
    exit 1
fi

echo -e "${GREEN}✅ All required files found${NC}"

# Create rel directory if needed
if [ ! -d "rel" ]; then
    mkdir -p rel
    echo -e "${YELLOW}📁 Created rel/ directory${NC}"
fi

# Define output file
OUTPUT_FILE="rel/CarOS_Profile_Switcher-v${VERSION}.zip"

# Remove existing file if present
if [ -f "$OUTPUT_FILE" ]; then
    rm -f "$OUTPUT_FILE"
    echo -e "${YELLOW}🗑️  Removed existing release file${NC}"
fi

# Create the ZIP archive
echo -e "${CYAN}📦 Creating release package...${NC}"

if zip -r "$OUTPUT_FILE" \
    caros_config.sh \
    module.prop \
    post-fs-data.sh \
    service.sh \
    system.prop \
    grant_permissions.sh \
    META-INF \
    -q; then
    
    echo ""
    echo -e "${GREEN}✅ SUCCESS! Release created:${NC}"
    echo -e "   📄 $OUTPUT_FILE"
    
    # Get file size
    FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)
    echo -e "   📊 Size: $FILE_SIZE"
    echo ""
    echo -e "${GREEN}📤 Ready to install via Magisk Manager!${NC}"
else
    echo ""
    echo -e "${RED}❌ Error creating ZIP archive${NC}"
    exit 1
fi
