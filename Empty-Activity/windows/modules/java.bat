@echo off
setlocal enabledelayedexpansion
:: Java Module
:: Handles Java detection and installation based on AGP requirements

:: Route to specific label if passed as argument
if not "%~1"=="" goto %~1

:detect_java
echo.
echo === Java Environment Check ===

set "JAVA_FOUND=0"
set "JAVA_VERSION="
:: Use JAVA_MIN from config if set, otherwise default to 21
if not defined JAVA_MIN set "JAVA_MIN=21"
set "REQUIRED_JAVA_VERSION=%JAVA_MIN%"

:: Check if JAVA_HOME is set and valid
if defined JAVA_HOME (
    if exist "%JAVA_HOME%\bin\java.exe" (
        for /f "tokens=3" %%v in ('"%JAVA_HOME%\bin\java.exe" -version 2^>^&1 ^| findstr /i "version"') do (
            set "JAVA_VERSION=%%~v"
        )
        call :parse_java_version "!JAVA_VERSION!"
        if !JAVA_MAJOR_VERSION! geq %REQUIRED_JAVA_VERSION% (
            echo [OK] Java !JAVA_MAJOR_VERSION! found at JAVA_HOME: %JAVA_HOME%
            set "JAVA_FOUND=1"
            goto :eof
        ) else (
            echo [WARNING] JAVA_HOME points to Java !JAVA_MAJOR_VERSION!, but Java %REQUIRED_JAVA_VERSION%+ is required.
        )
    )
)

:: Check java in PATH
where java >nul 2>&1
if %errorlevel%==0 (
    for /f "tokens=3" %%v in ('java -version 2^>^&1 ^| findstr /i "version"') do (
        set "JAVA_VERSION=%%~v"
    )
    call :parse_java_version "!JAVA_VERSION!"
    if !JAVA_MAJOR_VERSION! geq %REQUIRED_JAVA_VERSION% (
        echo [OK] Java !JAVA_MAJOR_VERSION! found in PATH
        set "JAVA_FOUND=1"
        goto :eof
    ) else (
        echo [INFO] Java !JAVA_MAJOR_VERSION! found in PATH, but Java %REQUIRED_JAVA_VERSION%+ is required.
    )
)

:: Check common installation paths for Java matching required version
set "JAVA_SEARCH_PATHS=%LOCALAPPDATA%\Programs\Java;%ProgramFiles%\Java;%ProgramFiles%\Eclipse Adoptium;%ProgramFiles%\Temurin"

for %%p in (%JAVA_SEARCH_PATHS%) do (
    if exist "%%p" (
        for /d %%d in ("%%p\jdk-%REQUIRED_JAVA_VERSION%*" "%%p\temurin-%REQUIRED_JAVA_VERSION%*") do (
            if exist "%%d\bin\java.exe" (
                echo [OK] Java %REQUIRED_JAVA_VERSION% found at: %%d
                set "JAVA_HOME=%%d"
                set "PATH=%%d\bin;%PATH%"
                set "JAVA_FOUND=1"
                goto :eof
            )
        )
    )
)

:: Java not found, need to install
echo [INFO] Java %REQUIRED_JAVA_VERSION%+ not found. Installation required.
call :install_java
goto :eof

:parse_java_version
:: Parse version string like "21.0.1" or "1.8.0_xxx"
set "ver_string=%~1"
set "ver_string=!ver_string:"=!"

:: Handle old format (1.x.x)
if "!ver_string:~0,2!"=="1." (
    set "JAVA_MAJOR_VERSION=!ver_string:~2,1!"
) else (
    :: Handle new format (xx.x.x)
    for /f "tokens=1 delims=." %%a in ("!ver_string!") do (
        set "JAVA_MAJOR_VERSION=%%a"
    )
)
goto :eof

:install_java
echo.
echo === Installing Java %REQUIRED_JAVA_VERSION% (Adoptium Temurin) ===
echo.

set "JAVA_INSTALL_DIR=%LOCALAPPDATA%\Programs\Java\jdk-%REQUIRED_JAVA_VERSION%"
set "JAVA_ZIP=%TEMP%\adoptium-jdk%REQUIRED_JAVA_VERSION%.zip"

:: Detect architecture
set "ARCH=x64"
if "%PROCESSOR_ARCHITECTURE%"=="ARM64" set "ARCH=aarch64"

:: Download URL for Adoptium Temurin based on required version
if "%REQUIRED_JAVA_VERSION%"=="17" (
    set "JAVA_URL=https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.13%%2B11/OpenJDK17U-jdk_!ARCH!_windows_hotspot_17.0.13_11.zip"
) else (
    set "JAVA_URL=https://github.com/adoptium/temurin21-binaries/releases/download/jdk-21.0.5%%2B11/OpenJDK21U-jdk_!ARCH!_windows_hotspot_21.0.5_11.zip"
)

echo Downloading Java %REQUIRED_JAVA_VERSION% from Adoptium...
echo URL: !JAVA_URL!
echo This may take a few minutes (~190MB)...
echo.

:: Download using PowerShell with progress
powershell -Command ^
    "$ProgressPreference = 'Continue'; " ^
    "try { " ^
    "    Write-Host 'Downloading...' -ForegroundColor Cyan; " ^
    "    Invoke-WebRequest -Uri '!JAVA_URL!' -OutFile '!JAVA_ZIP!' -UseBasicParsing; " ^
    "    Write-Host '[OK] Download complete' -ForegroundColor Green; " ^
    "} catch { " ^
    "    Write-Host '[ERROR] Download failed: $_' -ForegroundColor Red; " ^
    "    exit 1; " ^
    "}"

if not exist "!JAVA_ZIP!" (
    echo [ERROR] Failed to download Java 21.
    echo Please install Java 21 manually from: https://adoptium.net/
    pause
    exit /b 1
)

:: Create installation directory
if not exist "%LOCALAPPDATA%\Programs\Java" (
    mkdir "%LOCALAPPDATA%\Programs\Java"
)

:: Extract using PowerShell
echo.
echo Extracting Java 21...
powershell -Command ^
    "try { " ^
    "    Expand-Archive -Path '!JAVA_ZIP!' -DestinationPath '%TEMP%\java_extract' -Force; " ^
    "    Write-Host '[OK] Extraction complete' -ForegroundColor Green; " ^
    "} catch { " ^
    "    Write-Host '[ERROR] Extraction failed: $_' -ForegroundColor Red; " ^
    "    exit 1; " ^
    "}"

:: Move extracted folder to final location
for /d %%d in ("%TEMP%\java_extract\jdk-%REQUIRED_JAVA_VERSION%*") do (
    if exist "!JAVA_INSTALL_DIR!" (
        echo Removing old installation...
        rmdir /s /q "!JAVA_INSTALL_DIR!" 2>nul
    )
    echo Moving to !JAVA_INSTALL_DIR!...
    move "%%d" "!JAVA_INSTALL_DIR!" >nul
)

:: Cleanup
del "!JAVA_ZIP!" 2>nul
rmdir /s /q "%TEMP%\java_extract" 2>nul

:: Verify installation
if exist "!JAVA_INSTALL_DIR!\bin\java.exe" (
    echo.
    echo [OK] Java %REQUIRED_JAVA_VERSION% installed successfully at: !JAVA_INSTALL_DIR!
    
    :: Set environment variables for current session
    set "JAVA_HOME=!JAVA_INSTALL_DIR!"
    set "PATH=!JAVA_INSTALL_DIR!\bin;%PATH%"
    set "JAVA_FOUND=1"
    
    :: Show version
    "!JAVA_INSTALL_DIR!\bin\java.exe" -version 2>&1 | findstr /i "version"
    
    echo.
    echo [TIP] To make this permanent, add JAVA_HOME to your system environment variables:
    echo       JAVA_HOME=!JAVA_INSTALL_DIR!
) else (
    echo [ERROR] Java installation failed.
    echo Please install Java %REQUIRED_JAVA_VERSION% manually from: https://adoptium.net/
    pause
    exit /b 1
)

goto :eof

:export_java_home
:: This label is called to export JAVA_HOME to parent process
:: Must be called with endlocal trick
endlocal & (
    set "JAVA_HOME=%JAVA_HOME%"
    set "PATH=%PATH%"
    set "JAVA_FOUND=%JAVA_FOUND%"
)
goto :eof
