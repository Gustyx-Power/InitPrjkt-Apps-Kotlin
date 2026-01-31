#!/bin/bash
# Post-processing Module
# Handles indexing, gradle sync, and test build

gradle_sync() {
    echo ""
    echo -e "${BLUE}=== Gradle Sync ===${NC}"
    echo "Syncing Gradle project..."
    
    # Save current directory
    local original_dir=$(pwd)
    cd "$FULL_PROJECT_PATH"

    # Check if gradlew exists
    if [ ! -f "./gradlew" ]; then
        echo -e "${YELLOW}[WARNING] Gradle wrapper not found. Skipping sync.${NC}"
        cd "$original_dir"
        return
    fi

    # Try to sync gradle
    echo "Running gradle sync..."
    if ! ./gradlew --version &>/dev/null; then
        echo -e "${YELLOW}[WARNING] Gradle wrapper not working properly. This is normal for new projects.${NC}"
        echo -e "${CYAN}[INFO] Gradle will download dependencies on first build.${NC}"
    else
        echo "Gradle wrapper is working. Running initial sync..."
        if ./gradlew tasks --quiet &>/dev/null; then
            echo -e "${GREEN}[OK] Gradle sync completed successfully!${NC}"
        else
            echo -e "${YELLOW}[WARNING] Gradle sync failed. Project may need dependencies download.${NC}"
        fi
    fi

    cd "$original_dir"
}

project_indexing() {
    echo ""
    echo -e "${BLUE}=== Project Indexing ===${NC}"
    echo "Creating project index files..."

    # Create .idea directory structure for better IDE support
    mkdir -p "$FULL_PROJECT_PATH/.idea/codeStyles"
    mkdir -p "$FULL_PROJECT_PATH/.idea/inspectionProfiles"

    # Create basic IDE configuration
    cat <<EOF > "$FULL_PROJECT_PATH/.idea/gradle.xml"
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="GradleSettings">
    <option name="linkedExternalProjectsSettings">
      <GradleProjectSettings>
        <option name="distributionType" value="DEFAULT_WRAPPED" />
        <option name="externalProjectPath" value="\$PROJECT_DIR\$" />
        <option name="modules">
          <set>
            <option value="\$PROJECT_DIR\$" />
            <option value="\$PROJECT_DIR\$/app" />
          </set>
        </option>
        <option name="resolveModulePerSourceSet" value="false" />
      </GradleProjectSettings>
    </option>
  </component>
</project>
EOF

    # Create compiler configuration
    cat <<EOF > "$FULL_PROJECT_PATH/.idea/compiler.xml"
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="CompilerConfiguration">
    <bytecodeTargetLevel target="11" />
  </component>
</project>
EOF

    # Create misc.xml
    cat <<EOF > "$FULL_PROJECT_PATH/.idea/misc.xml"
<?xml version="1.0" encoding="UTF-8"?>
<project version="4">
  <component name="ProjectRootManager" version="2" languageLevel="JDK_11" default="true" project-jdk-name="11" project-jdk-type="JavaSDK">
    <output url="file://\$PROJECT_DIR\$/build/classes" />
  </component>
</project>
EOF

    # Create .vscode settings for VS Code users
    mkdir -p "$FULL_PROJECT_PATH/.vscode"
    cat <<EOF > "$FULL_PROJECT_PATH/.vscode/settings.json"
{
    "java.configuration.updateBuildConfiguration": "automatic",
    "java.compile.nullAnalysis.mode": "automatic",
    "files.exclude": {
        "**/.gradle": true,
        "**/build": true,
        "**/.idea": true
    }
}
EOF

    echo -e "${GREEN}[OK] Project indexing completed!${NC}"
}

test_build() {
    echo ""
    echo -e "${BLUE}=== Building Project ===${NC}"
    echo ""
    
    # Save current directory
    local original_dir=$(pwd)
    cd "$FULL_PROJECT_PATH"

    echo "Running initial build (this may take a few minutes on first run)..."
    echo ""

    # Use --no-daemon to avoid cache conflicts
    if ./gradlew build --no-daemon; then
        echo ""
        echo -e "${GREEN}[SUCCESS] Build completed successfully!${NC}"
        echo ""
        
        # Ask for debug APK generation
        read -p "Generate debug APK? [Y/n]: " BUILD_DEBUG
        BUILD_DEBUG=${BUILD_DEBUG:-y}
        BUILD_DEBUG=$(echo "$BUILD_DEBUG" | tr '[:upper:]' '[:lower:]')

        if [[ "$BUILD_DEBUG" != "n" && "$BUILD_DEBUG" != "no" ]]; then
            echo ""
            echo "Generating debug APK..."
            if ./gradlew assembleDebug --no-daemon --quiet; then
                echo -e "${GREEN}[OK] Debug APK generated successfully!${NC}"
                echo "Location: app/build/outputs/apk/debug/app-debug.apk"
            else
                echo -e "${YELLOW}[WARNING] Debug APK generation failed.${NC}"
            fi
        else
            echo "Skipping debug APK generation."
        fi
    else
        echo ""
        echo -e "${YELLOW}[WARNING] First build attempt failed. Cleaning Gradle cache and retrying...${NC}"
        
        # Clean local Gradle cache
        rm -rf .gradle build app/build 2>/dev/null
        
        echo "Retrying build..."
        if ./gradlew build --no-daemon --refresh-dependencies; then
            echo ""
            echo -e "${GREEN}[SUCCESS] Build completed successfully!${NC}"
        else
            echo ""
            echo -e "${RED}[ERROR] Build failed! There might be configuration issues.${NC}"
            echo "Please check the following:"
            echo "  1. Android SDK is properly installed"
            echo "  2. Java 17+ is installed and configured"
            echo "  3. Internet connection for downloading dependencies"
            echo "  4. Try clearing global Gradle cache: rm -rf ~/.gradle/caches"
            echo ""
            echo "You can try building manually later with:"
            echo "  cd \"$FULL_PROJECT_PATH\""
            echo "  ./gradlew build"
        fi
    fi

    cd "$original_dir"
}

open_project_suggestion() {
    echo ""
    echo -e "${CYAN}=== Next Steps ===${NC}"
    echo ""
    echo -e "${GREEN}Your Android project has been created successfully!${NC}"
    echo ""
    echo -e "${CYAN}To open the project:${NC}"
    echo "  1. Android Studio: File > Open > Select \"$FULL_PROJECT_PATH\""
    echo "  2. VS Code: Open folder \"$FULL_PROJECT_PATH\""
    echo "  3. IntelliJ IDEA: Import Project > Select \"$FULL_PROJECT_PATH\""
    echo ""
    echo -e "${CYAN}To build from command line:${NC}"
    echo "  cd \"$FULL_PROJECT_PATH\""
    echo "  ./gradlew build                # Build project"
    echo "  ./gradlew assembleDebug        # Generate debug APK"
    echo "  ./gradlew installDebug         # Install to connected device"
    echo ""

    read -p "Open project folder in Finder? [Y/n]: " OPEN_FOLDER
    OPEN_FOLDER=${OPEN_FOLDER:-y}
    OPEN_FOLDER=$(echo "$OPEN_FOLDER" | tr '[:upper:]' '[:lower:]')

    if [[ "$OPEN_FOLDER" != "n" && "$OPEN_FOLDER" != "no" ]]; then
        echo "Opening project folder..."
        open "$FULL_PROJECT_PATH"
    fi
}