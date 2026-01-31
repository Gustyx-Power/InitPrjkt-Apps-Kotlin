#!/bin/bash
# Structure Module
# Handles project folder structure creation

check_project_exists() {
    FULL_PROJECT_PATH="$PROJECT_LOCATION/$PROJECT_NAME"
    if [ -d "$FULL_PROJECT_PATH" ]; then
        echo -e "${RED}ERROR: Folder $FULL_PROJECT_PATH already exists!${NC}"
        exit 1
    fi
}

create_folder_structure() {
    echo "Creating folder structure..."
    PACKAGE_PATH=${PACKAGE//./\/}
    mkdir -p "$FULL_PROJECT_PATH/app/src/main/java/$PACKAGE_PATH"
    mkdir -p "$FULL_PROJECT_PATH/app/src/main/java/$PACKAGE_PATH/ui/theme"
    mkdir -p "$FULL_PROJECT_PATH/app/src/main/res/layout"
    mkdir -p "$FULL_PROJECT_PATH/app/src/main/res/values"
    mkdir -p "$FULL_PROJECT_PATH/app/src/main/res/drawable"
    mkdir -p "$FULL_PROJECT_PATH/app/src/main/res/drawable-v24"
    mkdir -p "$FULL_PROJECT_PATH/app/src/main/res/mipmap-anydpi-v26"
    mkdir -p "$FULL_PROJECT_PATH/app/src/main/res/mipmap-hdpi"
    mkdir -p "$FULL_PROJECT_PATH/app/src/main/res/mipmap-mdpi"
    mkdir -p "$FULL_PROJECT_PATH/app/src/main/res/mipmap-xhdpi"
    mkdir -p "$FULL_PROJECT_PATH/app/src/main/res/mipmap-xxhdpi"
    mkdir -p "$FULL_PROJECT_PATH/app/src/main/res/mipmap-xxxhdpi"
    mkdir -p "$FULL_PROJECT_PATH/app/src/main/res/xml"
    mkdir -p "$FULL_PROJECT_PATH/app/src/test/java/$PACKAGE_PATH"
    mkdir -p "$FULL_PROJECT_PATH/app/src/androidTest/java/$PACKAGE_PATH"
    mkdir -p "$FULL_PROJECT_PATH/gradle/wrapper"
}