@echo off
setlocal enabledelayedexpansion
:: SDK Module
:: Handles Android SDK detection and component installation

:: Import environment variables if not set
if not defined PROJECT_NAME set "PROJECT_NAME=%PROJECT_NAME%"
if not defined PACKAGE set "PACKAGE=%PACKAGE%"
if not defined FULL_PROJECT_PATH set "FULL_PROJECT_PATH=%FULL_PROJECT_PATH%"
if not defined INSTALL_SDK set "INSTALL_SDK=%INSTALL_SDK%"
if not defined INSTALL_NDK set "INSTALL_NDK=%INSTALL_NDK%"
if not defined INSTALL_CMAKE set "INSTALL_CMAKE=%INSTALL_CMAKE%"
if not defined COMPILE_SDK set "COMPILE_SDK=%COMPILE_SDK%"

:: Route to specific label if passed as argument
if not "%~1"=="" goto %~1

:detect_sdk
set "SDK_PATH="

if defined ANDROID_HOME (
    set "SDK_PATH=%ANDROID_HOME%"
) else if defined ANDROID_SDK_ROOT (
    set "SDK_PATH=%ANDROID_SDK_ROOT%"
) else (
    :: Check default location
    if exist "%LOCALAPPDATA%\Android\Sdk" (
        set "SDK_PATH=%LOCALAPPDATA%\Android\Sdk"
    ) else if exist "%USERPROFILE%\AppData\Local\Android\Sdk" (
        set "SDK_PATH=%USERPROFILE%\AppData\Local\Android\Sdk"
    )
)

if "%SDK_PATH%"=="" (
    echo [ERROR] Android SDK not found!
    echo Please set ANDROID_HOME or ANDROID_SDK_ROOT environment variable.
    echo Example: set ANDROID_HOME=C:\Users\YourName\AppData\Local\Android\Sdk
    pause
    exit /b 1
)

echo [OK] Android SDK found: %SDK_PATH%
:: Export SDK_PATH as environment variable
set "SDK_PATH=%SDK_PATH%"
exit /b 0

:install_sdk_components
if /i "%INSTALL_SDK%"=="y" (
    echo.
    echo === Installing SDK Components ===
    
    set "SDKMANAGER=%SDK_PATH%\cmdline-tools\latest\bin\sdkmanager.bat"
    
    if not exist "!SDKMANAGER!" (
        set "SDKMANAGER=%SDK_PATH%\tools\bin\sdkmanager.bat"
    )
    
    :: If sdkmanager still not found, download command-line tools
    if not exist "!SDKMANAGER!" (
        echo [INFO] sdkmanager not found. Downloading command-line tools...
        
        set "CMDTOOLS_URL=https://github.com/Gustyx-Power/InitPrjkt-Apps-Kotlin/releases/download/cmd-tools/commandlinetools-win-14742923.zip"
        set "CMDTOOLS_ZIP=%TEMP%\commandlinetools-win.zip"
        set "CMDTOOLS_DIR=%SDK_PATH%\cmdline-tools"
        
        :: Download using PowerShell
        echo Downloading command-line tools...
        powershell -Command "try { Invoke-WebRequest -Uri '!CMDTOOLS_URL!' -OutFile '!CMDTOOLS_ZIP!' -UseBasicParsing; Write-Host '[OK] Downloaded command-line tools' } catch { Write-Host '[ERROR] Failed to download command-line tools'; exit 1 }"
        
        if exist "!CMDTOOLS_ZIP!" (
            :: Create cmdline-tools directory
            if not exist "!CMDTOOLS_DIR!" mkdir "!CMDTOOLS_DIR!"
            
            :: Extract using PowerShell
            echo Extracting command-line tools...
            powershell -Command "Expand-Archive -Path '!CMDTOOLS_ZIP!' -DestinationPath '!CMDTOOLS_DIR!' -Force"
            
            :: Rename to 'latest' for standard path
            if exist "!CMDTOOLS_DIR!\cmdline-tools" (
                if exist "!CMDTOOLS_DIR!\latest" rmdir /s /q "!CMDTOOLS_DIR!\latest" 2>nul
                move "!CMDTOOLS_DIR!\cmdline-tools" "!CMDTOOLS_DIR!\latest" >nul
                echo [OK] Command-line tools installed
                set "SDKMANAGER=!CMDTOOLS_DIR!\latest\bin\sdkmanager.bat"
            )
            
            :: Cleanup
            del "!CMDTOOLS_ZIP!" 2>nul
        ) else (
            echo [WARNING] Failed to download command-line tools. Skipping SDK installation.
            goto :eof
        )
    )
    
    if exist "!SDKMANAGER!" (
        :: Create file with 'y' responses for license acceptance
        set "YES_FILE=%TEMP%\sdk_yes.txt"
        (for /L %%i in (1,1,50) do @echo y) > "!YES_FILE!"
        
        echo Accepting SDK licenses...
        cmd /c "type "!YES_FILE!" | "!SDKMANAGER!" --licenses"
        echo [OK] Licenses processed
        
        :: Install components (no stdin redirect needed - they don't prompt)
        echo.
        echo Installing platform-tools...
        "!SDKMANAGER!" --install "platform-tools"
        
        echo.
        echo Installing SDK platform %COMPILE_SDK%...
        "!SDKMANAGER!" --install "platforms;android-%COMPILE_SDK%"
        
        echo.
        echo Installing build-tools...
        "!SDKMANAGER!" --install "build-tools;34.0.0"
        
        if /i "!INSTALL_NDK!"=="y" (
            echo.
            echo Installing NDK...
            "!SDKMANAGER!" --install "ndk;26.1.10909125"
        )
        
        if /i "!INSTALL_CMAKE!"=="y" (
            echo.
            echo Installing CMake...
            "!SDKMANAGER!" --install "cmake;3.22.1"
        )
        
        :: Cleanup
        del "!YES_FILE!" 2>nul
        
        echo.
        echo [OK] SDK components installed
    ) else (
        echo [WARNING] sdkmanager not found. Skipping SDK installation.
    )
)
goto :eof