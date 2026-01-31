#!/bin/bash
# SDK Module
# Handles Android SDK detection and component installation

detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "Linux";;
        Darwin*)    echo "macOS";;
        CYGWIN*|MINGW*|MSYS*) echo "WSL";;
        *)          echo "Unknown";;
    esac
}

install_java_21() {
    echo ""
    echo -e "${BLUE}=== Java Environment Check ===${NC}"
    
    REQUIRED_JAVA_VERSION=21
    JAVA_FOUND=0
    
    # Check current Java version
    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | cut -d'.' -f1)
        if [[ "$JAVA_VERSION" =~ ^[0-9]+$ ]] && [ "$JAVA_VERSION" -ge "$REQUIRED_JAVA_VERSION" ]; then
            echo -e "${GREEN}[OK] Java $JAVA_VERSION found${NC}"
            JAVA_FOUND=1
            return 0
        else
            echo -e "${YELLOW}[INFO] Java $JAVA_VERSION found, but Java $REQUIRED_JAVA_VERSION+ is required${NC}"
        fi
    fi
    
    # Install Java 21 via Homebrew on macOS
    if [[ "$(detect_os)" == "macOS" ]]; then
        if command -v brew &> /dev/null; then
            echo "Installing Java 21 via Homebrew..."
            brew install openjdk@21
            
            # Set JAVA_HOME
            if [ -d "/opt/homebrew/opt/openjdk@21" ]; then
                export JAVA_HOME="/opt/homebrew/opt/openjdk@21"
            elif [ -d "/usr/local/opt/openjdk@21" ]; then
                export JAVA_HOME="/usr/local/opt/openjdk@21"
            fi
            
            if [ -n "$JAVA_HOME" ]; then
                export PATH="$JAVA_HOME/bin:$PATH"
                echo -e "${GREEN}[OK] Java 21 installed successfully${NC}"
                echo -e "${YELLOW}[TIP] Add to your ~/.zshrc or ~/.bash_profile:${NC}"
                echo "  export JAVA_HOME=$JAVA_HOME"
                echo "  export PATH=\$JAVA_HOME/bin:\$PATH"
                JAVA_FOUND=1
                return 0
            fi
        else
            echo -e "${RED}[ERROR] Homebrew not found. Please install Homebrew first:${NC}"
            echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            echo ""
            echo "Or install Java 21 manually from: https://adoptium.net/"
            return 1
        fi
    fi
    
    if [ "$JAVA_FOUND" -eq 0 ]; then
        echo -e "${RED}[ERROR] Java 21 installation failed${NC}"
        echo "Please install Java 21 manually from: https://adoptium.net/"
        return 1
    fi
}

detect_sdk_path() {
    # Check ANDROID_HOME or ANDROID_SDK_ROOT
    if [ -n "$ANDROID_HOME" ]; then
        echo "$ANDROID_HOME"
        return
    fi
    
    if [ -n "$ANDROID_SDK_ROOT" ]; then
        echo "$ANDROID_SDK_ROOT"
        return
    fi
    
    # Check default locations based on OS
    case "$OS_TYPE" in
        "macOS")
            if [ -d "$HOME/Library/Android/sdk" ]; then
                echo "$HOME/Library/Android/sdk"
                return
            fi
            ;;
        "Linux")
            if [ -d "$HOME/Android/Sdk" ]; then
                echo "$HOME/Android/Sdk"
                return
            fi
            ;;
        "WSL")
            # WSL paths
            WSL_PATHS=(
                "/mnt/c/Users/$USER/AppData/Local/Android/Sdk"
                "$HOME/Android/Sdk"
            )
            for path in "${WSL_PATHS[@]}"; do
                if [ -d "$path" ]; then
                    echo "$path"
                    return
                fi
            done
            ;;
    esac
    
    echo ""
}

detect_sdk() {
    OS_TYPE=$(detect_os)
    echo -e "${YELLOW}Detected OS: $OS_TYPE${NC}"

    # Check and install Java 21
    install_java_21

    SDK_PATH=$(detect_sdk_path)

    if [ -z "$SDK_PATH" ]; then
        echo -e "${RED}ERROR: Android SDK not found!${NC}"
        echo "Please set ANDROID_HOME or ANDROID_SDK_ROOT environment variable"
        echo "Example:"
        echo "  export ANDROID_HOME=/path/to/android/sdk"
        exit 1
    fi

    echo -e "${GREEN}Android SDK found: $SDK_PATH${NC}"
    echo ""
}

install_sdk_components() {
    if [[ "$INSTALL_SDK" == "y" || "$INSTALL_SDK" == "yes" ]]; then
        echo ""
        echo -e "${BLUE}=== Installing SDK Components ===${NC}"
        
        SDKMANAGER="$SDK_PATH/cmdline-tools/latest/bin/sdkmanager"
        
        # Check if sdkmanager exists
        if [ ! -f "$SDKMANAGER" ]; then
            # Try alternative location
            SDKMANAGER="$SDK_PATH/tools/bin/sdkmanager"
        fi
        
        # If sdkmanager still not found, download command-line tools
        if [ ! -f "$SDKMANAGER" ]; then
            echo -e "${YELLOW}[INFO] sdkmanager not found. Downloading command-line tools...${NC}"
            
            CMDTOOLS_URL="https://github.com/Gustyx-Power/InitPrjkt-Apps-Kotlin/releases/download/cmd-tools/commandlinetools-mac-14742923.zip"
            CMDTOOLS_ZIP="/tmp/commandlinetools-mac.zip"
            CMDTOOLS_DIR="$SDK_PATH/cmdline-tools"
            
            # Download using curl or wget
            echo "Downloading command-line tools..."
            if command -v curl &> /dev/null; then
                curl -L -o "$CMDTOOLS_ZIP" "$CMDTOOLS_URL" 2>/dev/null
            elif command -v wget &> /dev/null; then
                wget -O "$CMDTOOLS_ZIP" "$CMDTOOLS_URL" 2>/dev/null
            else
                echo -e "${RED}[ERROR] curl or wget not found. Cannot download command-line tools.${NC}"
                return
            fi
            
            if [ -f "$CMDTOOLS_ZIP" ]; then
                # Create cmdline-tools directory
                mkdir -p "$CMDTOOLS_DIR"
                
                # Extract
                echo "Extracting command-line tools..."
                unzip -q -o "$CMDTOOLS_ZIP" -d "$CMDTOOLS_DIR"
                
                # Rename to 'latest' for standard path
                if [ -d "$CMDTOOLS_DIR/cmdline-tools" ]; then
                    rm -rf "$CMDTOOLS_DIR/latest" 2>/dev/null
                    mv "$CMDTOOLS_DIR/cmdline-tools" "$CMDTOOLS_DIR/latest"
                    chmod +x "$CMDTOOLS_DIR/latest/bin/"*
                    echo -e "${GREEN}[OK] Command-line tools installed${NC}"
                    SDKMANAGER="$CMDTOOLS_DIR/latest/bin/sdkmanager"
                fi
                
                # Cleanup
                rm -f "$CMDTOOLS_ZIP"
            else
                echo -e "${YELLOW}[WARNING] Failed to download command-line tools. Skipping SDK installation.${NC}"
                return
            fi
        fi
        
        if [ -f "$SDKMANAGER" ]; then
            # Accept licenses first
            echo "Accepting SDK licenses..."
            yes | "$SDKMANAGER" --licenses > /dev/null 2>&1 || true
            
            echo "Updating SDK platform-tools..."
            yes | "$SDKMANAGER" "platform-tools" 2>/dev/null || true
            
            echo "Installing SDK platform $COMPILE_SDK..."
            yes | "$SDKMANAGER" "platforms;android-$COMPILE_SDK" 2>/dev/null || true
            
            echo "Installing build-tools..."
            yes | "$SDKMANAGER" "build-tools;34.0.0" 2>/dev/null || true
            
            if [[ "$INSTALL_NDK" == "y" || "$INSTALL_NDK" == "yes" ]]; then
                echo "Installing NDK..."
                yes | "$SDKMANAGER" "ndk;26.1.10909125" 2>/dev/null || true
            fi
            
            if [[ "$INSTALL_CMAKE" == "y" || "$INSTALL_CMAKE" == "yes" ]]; then
                echo "Installing CMake..."
                yes | "$SDKMANAGER" "cmake;3.22.1" 2>/dev/null || true
            fi
            
            echo -e "${GREEN}✓ SDK components installed${NC}"
        else
            echo -e "${YELLOW}[WARNING] sdkmanager not found. Skipping SDK installation.${NC}"
        fi
    fi
}