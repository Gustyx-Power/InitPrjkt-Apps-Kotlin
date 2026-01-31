#!/bin/bash
# Configuration Module
# Handles user input and project configuration

get_project_config() {
    echo -e "${BLUE}=== Project Configuration ===${NC}"
    echo ""

    # Project Location
    echo -e "${YELLOW}Where to create the project?${NC}"
    echo "Examples:"
    echo "  ~/Documents/AndroidProjects"
    echo "  ~/Desktop/MyApps"
    echo "  /Users/yourname/Projects"
    echo ""
    read -p "Project location [current directory]: " PROJECT_LOCATION
    PROJECT_LOCATION=${PROJECT_LOCATION:-$(pwd)}

    # Expand ~ to home directory
    PROJECT_LOCATION="${PROJECT_LOCATION/#\~/$HOME}"

    # Validate path
    if [ ! -d "$PROJECT_LOCATION" ]; then
        echo -e "${YELLOW}Directory doesn't exist. Creating: $PROJECT_LOCATION${NC}"
        mkdir -p "$PROJECT_LOCATION" || {
            echo -e "${RED}Failed to create directory!${NC}"
            exit 1
        }
    fi

    echo -e "${GREEN}✓ Project will be created in: $PROJECT_LOCATION${NC}"
    echo ""

    # Project Name
    read -p "Application name [InitPrjkt-Apps-Kotlin]: " PROJECT_NAME
    PROJECT_NAME=${PROJECT_NAME:-InitPrjkt-Apps-Kotlin}

    # Package Name
    read -p "Package name [com.example.myapp]: " PACKAGE
    PACKAGE=${PACKAGE:-com.example.myapp}

    # Build Configuration
    echo ""
    echo -e "${BLUE}=== Build Configuration ===${NC}"
    read -p "Groovy DSL or Kotlin DSL? [groovy/kotlin, default: kotlin]: " BUILD_LANG
    BUILD_LANG=${BUILD_LANG:-kotlin}
    BUILD_LANG=$(echo "$BUILD_LANG" | tr '[:upper:]' '[:lower:]')

    if [[ "$BUILD_LANG" != "groovy" && "$BUILD_LANG" != "kotlin" ]]; then
        echo -e "${YELLOW}Invalid input. Using Kotlin DSL.${NC}"
        BUILD_LANG="kotlin"
    fi

    # UI Framework
    echo ""
    read -p "Use Jetpack Compose? [Y/n]: " USE_COMPOSE
    USE_COMPOSE=${USE_COMPOSE:-y}
    USE_COMPOSE=$(echo "$USE_COMPOSE" | tr '[:upper:]' '[:lower:]')

    if [[ "$USE_COMPOSE" != "n" && "$USE_COMPOSE" != "no" ]]; then
        USE_COMPOSE="y"
    else
        USE_COMPOSE="n"
    fi

    # SDK Versions
    echo ""
    echo -e "${YELLOW}Available Min SDK versions:${NC}"
    echo "  21 - Android 5.0 Lollipop"
    echo "  22 - Android 5.1 Lollipop"
    echo "  23 - Android 6.0 Marshmallow"
    echo "  24 - Android 7.0 Nougat"
    echo "  25 - Android 7.1 Nougat"
    echo "  26 - Android 8.0 Oreo"
    echo "  27 - Android 8.1 Oreo"
    echo "  28 - Android 9.0 Pie"
    echo "  29 - Android 10"
    echo "  30 - Android 11"
    echo "  31 - Android 12"
    echo "  32 - Android 12L"
    echo "  33 - Android 13"
    echo "  34 - Android 14"
    echo "  35 - Android 15"
    echo "  36 - Android 16"
    echo ""
    read -p "Minimum SDK [21]: " MIN_SDK
    MIN_SDK=${MIN_SDK:-21}

    read -p "Target SDK [36]: " TARGET_SDK
    TARGET_SDK=${TARGET_SDK:-36}

    read -p "Compile SDK [36]: " COMPILE_SDK
    COMPILE_SDK=${COMPILE_SDK:-36}

    # AGP Version Selection with Gradle Mapping
    echo ""
    echo -e "${YELLOW}Available Android Gradle Plugin versions:${NC}"
    echo "  1 - AGP 8.7.3  (Gradle 8.9,   Java 17+) - Stable"
    echo "  2 - AGP 8.8.2  (Gradle 8.10,  Java 17+) - Stable"
    echo "  3 - AGP 8.9.0  (Gradle 8.11,  Java 17+) - Stable"
    echo "  4 - AGP 8.10.0 (Gradle 8.11,  Java 21+) - Stable"
    echo "  5 - AGP 8.11.0 (Gradle 8.11,  Java 21+) - Stable"
    echo "  6 - AGP 8.12.0 (Gradle 8.12,  Java 21+) - Stable"
    echo "  7 - AGP 8.13.2 (Gradle 8.13,  Java 21+) - Latest Stable [default]"
    echo "  8 - AGP 9.0.0  (Gradle 8.14,  Java 21+) - Beta/Canary"
    echo ""
    read -p "Select AGP version [1-8, default: 7]: " AGP_CHOICE
    AGP_CHOICE=${AGP_CHOICE:-7}

    # Map AGP choice to versions
    case "$AGP_CHOICE" in
        1)
            AGP_VERSION="8.7.3"
            GRADLE_VERSION="8.9"
            JAVA_MIN="17"
            ;;
        2)
            AGP_VERSION="8.8.2"
            GRADLE_VERSION="8.10.2"
            JAVA_MIN="17"
            ;;
        3)
            AGP_VERSION="8.9.0"
            GRADLE_VERSION="8.11.1"
            JAVA_MIN="17"
            ;;
        4)
            AGP_VERSION="8.10.0"
            GRADLE_VERSION="8.11.1"
            JAVA_MIN="21"
            ;;
        5)
            AGP_VERSION="8.11.0"
            GRADLE_VERSION="8.11.1"
            JAVA_MIN="21"
            ;;
        6)
            AGP_VERSION="8.12.0"
            GRADLE_VERSION="8.12"
            JAVA_MIN="21"
            ;;
        7)
            AGP_VERSION="8.13.2"
            GRADLE_VERSION="8.13"
            JAVA_MIN="21"
            ;;
        8)
            AGP_VERSION="9.0.0"
            GRADLE_VERSION="8.14"
            JAVA_MIN="21"
            ;;
        *)
            echo -e "${YELLOW}[INFO] Invalid choice, using default AGP 8.13.2${NC}"
            AGP_VERSION="8.13.2"
            GRADLE_VERSION="8.13"
            JAVA_MIN="21"
            ;;
    esac

    echo -e "${GREEN}[OK] Selected: AGP $AGP_VERSION with Gradle $GRADLE_VERSION (requires Java $JAVA_MIN+)${NC}"

    read -p "Kotlin version [2.0.21]: " KOTLIN_VERSION
    KOTLIN_VERSION=${KOTLIN_VERSION:-2.0.21}

    # SDK Components
    echo ""
    echo -e "${BLUE}=== SDK Components (optional) ===${NC}"
    read -p "Install/Update SDK components? [y/N]: " INSTALL_SDK
    INSTALL_SDK=${INSTALL_SDK:-n}
    INSTALL_SDK=$(echo "$INSTALL_SDK" | tr '[:upper:]' '[:lower:]')

    if [[ "$INSTALL_SDK" == "y" || "$INSTALL_SDK" == "yes" ]]; then
        read -p "Install NDK? [y/N]: " INSTALL_NDK
        INSTALL_NDK=${INSTALL_NDK:-n}
        INSTALL_NDK=$(echo "$INSTALL_NDK" | tr '[:upper:]' '[:lower:]')
        
        read -p "Install CMake? [y/N]: " INSTALL_CMAKE
        INSTALL_CMAKE=${INSTALL_CMAKE:-n}
        INSTALL_CMAKE=$(echo "$INSTALL_CMAKE" | tr '[:upper:]' '[:lower:]')
    fi
}

show_summary() {
    echo ""
    echo -e "${GREEN}=== Summary ===${NC}"
    echo "Project Name    : $PROJECT_NAME"
    echo "Package         : $PACKAGE"
    echo "Build Language  : $BUILD_LANG"
    echo "Use Compose     : $USE_COMPOSE"
    echo "Min SDK         : $MIN_SDK"
    echo "Target SDK      : $TARGET_SDK"
    echo "Compile SDK     : $COMPILE_SDK"
    echo "AGP Version     : $AGP_VERSION"
    echo "Gradle Version  : $GRADLE_VERSION"
    echo "Java Required   : $JAVA_MIN+"
    echo "Kotlin Version  : $KOTLIN_VERSION"
    echo ""
    read -p "Continue? [Y/n]: " CONFIRM
    CONFIRM=${CONFIRM:-y}
    CONFIRM=$(echo "$CONFIRM" | tr '[:upper:]' '[:lower:]')

    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "yes" ]]; then
        echo "Cancelled."
        exit 0
    fi
}