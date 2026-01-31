@echo off

:: Android Empty Activity Project Generator
:: Platform: Windows

title Android Empty Activity Generator

color 0B
cls
echo ============================================================
echo    InitPrjkt-Apps-Kotlin
echo    Android Empty Activity Project Generator
echo    Platform: Windows
echo ============================================================
echo.

:: Set module path
set "MODULE_PATH=%~dp0modules"

:: 1. Get project configuration
call "%MODULE_PATH%\config.bat" :get_project_config
if errorlevel 1 exit /b 1

:: 2. Detect and install Java 21 if needed
call "%MODULE_PATH%\java.bat" :detect_java
if errorlevel 1 exit /b 1

:: 3. Show summary and confirm
call "%MODULE_PATH%\config.bat" :show_summary
if errorlevel 1 (
    echo Cancelled.
    pause
    exit /b 0
)

echo.
echo === Starting Project Creation ===
echo.

:: Debug - show variables
echo [DEBUG] PROJECT_NAME = %PROJECT_NAME%
echo [DEBUG] PACKAGE = %PACKAGE%
echo [DEBUG] FULL_PROJECT_PATH = %FULL_PROJECT_PATH%
echo.

:: Use PowerShell as bridge to share environment variables between batch modules
powershell -ExecutionPolicy Bypass -Command "$env:PROJECT_LOCATION='%PROJECT_LOCATION%'; $env:PROJECT_NAME='%PROJECT_NAME%'; $env:PACKAGE='%PACKAGE%'; $env:BUILD_LANG='%BUILD_LANG%'; $env:USE_COMPOSE='%USE_COMPOSE%'; $env:MIN_SDK='%MIN_SDK%'; $env:TARGET_SDK='%TARGET_SDK%'; $env:COMPILE_SDK='%COMPILE_SDK%'; $env:AGP_VERSION='%AGP_VERSION%'; $env:GRADLE_VERSION='%GRADLE_VERSION%'; $env:JAVA_MIN='%JAVA_MIN%'; $env:KOTLIN_VERSION='%KOTLIN_VERSION%'; $env:INSTALL_SDK='%INSTALL_SDK%'; $env:INSTALL_NDK='%INSTALL_NDK%'; $env:INSTALL_CMAKE='%INSTALL_CMAKE%'; $env:FULL_PROJECT_PATH='%FULL_PROJECT_PATH%'; $env:PACKAGE_PATH='%PACKAGE_PATH%'; & '%MODULE_PATH%\bridge.ps1' -ModulePath '%MODULE_PATH%'"

if errorlevel 1 (
    echo.
    echo [ERROR] Project creation failed!
    pause
    exit /b 1
)

echo.
echo ============================================================
echo          [OK] Project created successfully!
echo ============================================================

pause