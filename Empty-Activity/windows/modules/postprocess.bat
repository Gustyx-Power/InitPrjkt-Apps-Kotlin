@echo off
setlocal enabledelayedexpansion
:: Post-processing Module
:: Handles indexing, gradle sync, and test build

:: Route to specific label if passed as argument
if not "%~1"=="" goto %~1

:gradle_sync
echo.
echo === Gradle Sync ===
echo Syncing Gradle project...

:: Save current directory
set "ORIGINAL_DIR=%CD%"

:: Change to project directory
cd /d "!FULL_PROJECT_PATH!"

:: Check if gradlew.bat exists
if not exist "gradlew.bat" (
    echo [WARNING] Gradle wrapper not found. Skipping sync.
    cd /d "!ORIGINAL_DIR!"
    goto :eof
)

:: Try to run gradle version to test wrapper
echo Running gradle sync...
call gradlew.bat --version >nul 2>&1
if errorlevel 1 (
    echo [WARNING] Gradle wrapper not working properly. This is normal for new projects.
    echo [INFO] Gradle will download dependencies on first build.
) else (
    echo Gradle wrapper is working. Running initial sync...
    call gradlew.bat tasks --quiet >nul 2>&1
    if errorlevel 1 (
        echo [WARNING] Gradle sync failed. Project may need dependencies download.
    ) else (
        echo [OK] Gradle sync completed successfully!
    )
)

:: Return to original directory
cd /d "!ORIGINAL_DIR!"
goto :eof

:project_indexing
echo.
echo === Project Indexing ===
echo Creating project index files...

:: Create .idea directory structure for better IDE support
mkdir "!FULL_PROJECT_PATH!\.idea" 2>nul
mkdir "!FULL_PROJECT_PATH!\.idea\codeStyles" 2>nul
mkdir "!FULL_PROJECT_PATH!\.idea\inspectionProfiles" 2>nul

:: Create basic IDE configuration
(
    echo ^<?xml version="1.0" encoding="UTF-8"?^>
    echo ^<project version="4"^>
    echo   ^<component name="GradleSettings"^>
    echo     ^<option name="linkedExternalProjectsSettings"^>
    echo       ^<GradleProjectSettings^>
    echo         ^<option name="distributionType" value="DEFAULT_WRAPPED" /^>
    echo         ^<option name="externalProjectPath" value="$PROJECT_DIR$" /^>
    echo         ^<option name="modules"^>
    echo           ^<set^>
    echo             ^<option value="$PROJECT_DIR$" /^>
    echo             ^<option value="$PROJECT_DIR$/app" /^>
    echo           ^</set^>
    echo         ^</option^>
    echo         ^<option name="resolveModulePerSourceSet" value="false" /^>
    echo       ^</GradleProjectSettings^>
    echo     ^</option^>
    echo   ^</component^>
    echo ^</project^>
) > "!FULL_PROJECT_PATH!\.idea\gradle.xml"

:: Create compiler configuration
(
    echo ^<?xml version="1.0" encoding="UTF-8"?^>
    echo ^<project version="4"^>
    echo   ^<component name="CompilerConfiguration"^>
    echo     ^<bytecodeTargetLevel target="11" /^>
    echo   ^</component^>
    echo ^</project^>
) > "!FULL_PROJECT_PATH!\.idea\compiler.xml"

:: Create misc.xml
(
    echo ^<?xml version="1.0" encoding="UTF-8"?^>
    echo ^<project version="4"^>
    echo   ^<component name="ProjectRootManager" version="2" languageLevel="JDK_11" default="true" project-jdk-name="11" project-jdk-type="JavaSDK"^>
    echo     ^<output url="file://$PROJECT_DIR$/build/classes" /^>
    echo   ^</component^>
    echo ^</project^>
) > "!FULL_PROJECT_PATH!\.idea\misc.xml"

:: Create .vscode settings for VS Code users
mkdir "!FULL_PROJECT_PATH!\.vscode" 2>nul
(
    echo {
    echo     "java.configuration.updateBuildConfiguration": "automatic",
    echo     "java.compile.nullAnalysis.mode": "automatic",
    echo     "files.exclude": {
    echo         "**/.gradle": true,
    echo         "**/build": true,
    echo         "**/.idea": true
    echo     }
    echo }
) > "!FULL_PROJECT_PATH!\.vscode\settings.json"

echo [OK] Project indexing completed!
goto :eof

:test_build
echo.
echo === Building Project ===
echo.

:: Save current directory
set "ORIGINAL_DIR=%CD%"

:: Change to project directory
cd /d "!FULL_PROJECT_PATH!"

echo Running initial build (this may take a few minutes on first run)...
echo.

:: Use --no-daemon to avoid cache conflicts
call gradlew.bat build --no-daemon
if errorlevel 1 (
    echo.
    echo [WARNING] First build attempt failed. Cleaning Gradle cache and retrying...
    
    :: Clean local Gradle cache
    if exist ".gradle" rmdir /s /q ".gradle" 2>nul
    if exist "build" rmdir /s /q "build" 2>nul
    if exist "app\build" rmdir /s /q "app\build" 2>nul
    
    echo Retrying build...
    call gradlew.bat build --no-daemon --refresh-dependencies
    if errorlevel 1 (
        echo.
        echo [ERROR] Build failed! There might be configuration issues.
        echo Please check the following:
        echo   1. Android SDK is properly installed
        echo   2. Java 17+ is installed and configured
        echo   3. Internet connection for downloading dependencies
        echo   4. Try clearing global Gradle cache: rmdir /s /q "%USERPROFILE%\.gradle\caches"
        echo.
        echo You can try building manually later with:
        echo   cd "!FULL_PROJECT_PATH!"
        echo   gradlew.bat build
        cd /d "!ORIGINAL_DIR!"
        goto :eof
    )
)

echo.
echo [SUCCESS] Build completed successfully!
echo.

:: Ask for debug APK generation
set /p "BUILD_DEBUG=Generate debug APK? [Y/n]: "
if /i "!BUILD_DEBUG!"=="n" (
    echo Skipping debug APK generation.
) else (
    echo.
    echo Generating debug APK...
    call gradlew.bat assembleDebug --no-daemon --quiet
    if errorlevel 1 (
        echo [WARNING] Debug APK generation failed.
    ) else (
        echo [OK] Debug APK generated successfully!
        echo Location: app\build\outputs\apk\debug\app-debug.apk
    )
)

:: Return to original directory
cd /d "!ORIGINAL_DIR!"
goto :eof

:open_project_suggestion
echo.
echo === Next Steps ===
echo.
echo Your Android project has been created successfully!
echo.
echo To open the project:
echo   1. Android Studio: File ^> Open ^> Select "!FULL_PROJECT_PATH!"
echo   2. VS Code: Open folder "!FULL_PROJECT_PATH!"
echo   3. IntelliJ IDEA: Import Project ^> Select "!FULL_PROJECT_PATH!"
echo.
echo To build from command line:
echo   cd "!FULL_PROJECT_PATH!"
echo   gradlew.bat build                # Build project
echo   gradlew.bat assembleDebug        # Generate debug APK
echo   gradlew.bat installDebug         # Install to connected device
echo.

set /p "OPEN_EXPLORER=Open project folder in Explorer? [Y/n]: "
if /i "!OPEN_EXPLORER!"=="n" (
    goto :eof
)

echo Opening project folder...
start "" "!FULL_PROJECT_PATH!"
goto :eof