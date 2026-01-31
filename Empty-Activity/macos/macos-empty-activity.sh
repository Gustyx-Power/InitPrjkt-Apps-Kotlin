#!/bin/bash

# Android Empty Activity Project Generator (Modular Version)
# Platform: macOS

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   InitPrjkt-Apps-Kotlin                               ║${NC}"
echo -e "${CYAN}║   Android Empty Activity Project Generator            ║${NC}"
echo -e "${CYAN}║   Platform: macOS                                      ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR="$SCRIPT_DIR/modules"

# Load modules
source "$MODULE_DIR/config.sh"
source "$MODULE_DIR/sdk.sh"
source "$MODULE_DIR/structure.sh"
source "$MODULE_DIR/android.sh"
source "$MODULE_DIR/source.sh"
source "$MODULE_DIR/postprocess.sh"

# 1. Get project configuration
get_project_config

# 2. Show summary and confirm
show_summary

echo ""
echo -e "${BLUE}=== Starting Project Creation ===${NC}"
echo ""

# 3. Detect Android SDK
detect_sdk

# 4. Check if project exists
check_project_exists

# 5. Create folder structure
create_folder_structure

# 6. Install SDK components (if requested)
install_sdk_components

# 7. Create Gradle files
echo ""
echo "Creating Gradle configuration files..."
create_gradle_files

# 8. Create Android files
echo ""
create_app_build_gradle
create_android_files

# 9. Create source files
echo ""
create_source_files

# 10. Post-processing
project_indexing
gradle_sync
test_build

# 11. Done
open_project_suggestion