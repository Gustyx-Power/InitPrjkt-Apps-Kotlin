@echo off
:: Configuration Module
:: Handles user input and project configuration

:: If called with a label, jump to it
if not "%1"=="" goto %1

:: If called without label, show error
echo [ERROR] config.bat must be called with a label
echo Usage: call config.bat :get_project_config
exit /b 1

:get_project_config
echo === Project Configuration ===
echo.

:: Project Location
echo Where to create the project?
echo Examples:
echo   C:\Users\YourName\Documents\AndroidProjects
echo   D:\Projects\Android
echo   %USERPROFILE%\Desktop\MyApps
echo.
set "PROJECT_LOCATION=%CD%"
set /p "PROJECT_LOCATION=Project location [current directory]: "

:: Remove trailing backslash if present
if "%PROJECT_LOCATION:~-1%"=="\" set "PROJECT_LOCATION=%PROJECT_LOCATION:~0,-1%"

:: Validate and create directory if needed
if not exist "%PROJECT_LOCATION%" (
    echo [WARNING] Directory doesn't exist. Creating: %PROJECT_LOCATION%
    mkdir "%PROJECT_LOCATION%" 2>nul
    if errorlevel 1 (
        echo [ERROR] Failed to create directory!
        pause
        exit /b 1
    )
)

:: Convert to absolute path if relative
pushd "%PROJECT_LOCATION%" 2>nul
if errorlevel 1 (
    echo [ERROR] Invalid directory path!
    pause
    exit /b 1
)
set "PROJECT_LOCATION=%CD%"
popd

echo [OK] Project will be created in: %PROJECT_LOCATION%
echo.

set "PROJECT_NAME=InitPrjkt-Apps-Kotlin"
set /p "PROJECT_NAME=Application name [InitPrjkt-Apps-Kotlin]: "

set "PACKAGE=com.example.myapp"
set /p "PACKAGE=Package name [com.example.myapp]: "

:: Build Configuration
echo.
echo === Build Configuration ===
set "BUILD_LANG=kotlin"
set /p "BUILD_LANG=Groovy DSL or Kotlin DSL? [groovy/kotlin, default: kotlin]: "

if /i "%BUILD_LANG%"=="groovy" (
    set "BUILD_LANG=groovy"
) else (
    set "BUILD_LANG=kotlin"
)

:: UI Framework
echo.
set "USE_COMPOSE=y"
set /p "USE_COMPOSE=Use Jetpack Compose? [Y/n]: "
if /i "%USE_COMPOSE%"=="n" (
    set "USE_COMPOSE=n"
) else (
    set "USE_COMPOSE=y"
)

:: SDK Versions
echo.
echo Available Min SDK versions:
echo   21 - Android 5.0 Lollipop
echo   22 - Android 5.1 Lollipop
echo   23 - Android 6.0 Marshmallow
echo   24 - Android 7.0 Nougat
echo   25 - Android 7.1 Nougat
echo   26 - Android 8.0 Oreo
echo   27 - Android 8.1 Oreo
echo   28 - Android 9.0 Pie
echo   29 - Android 10
echo   30 - Android 11
echo   31 - Android 12
echo   32 - Android 12L
echo   33 - Android 13
echo   34 - Android 14
echo   35 - Android 15
echo   36 - Android 16
echo.
set "MIN_SDK=21"
set /p "MIN_SDK=Minimum SDK [21]: "

set "TARGET_SDK=36"
set /p "TARGET_SDK=Target SDK [36]: "

set "COMPILE_SDK=36"
set /p "COMPILE_SDK=Compile SDK [36]: "

:: AGP Version Selection with Gradle Mapping
echo.
echo Available Android Gradle Plugin versions:
echo   1 - AGP 8.7.3  ^(Gradle 8.9,   Java 17+^) - Stable
echo   2 - AGP 8.8.2  ^(Gradle 8.10,  Java 17+^) - Stable
echo   3 - AGP 8.9.0  ^(Gradle 8.11,  Java 17+^) - Stable
echo   4 - AGP 8.10.0 ^(Gradle 8.11,  Java 21+^) - Stable
echo   5 - AGP 8.11.0 ^(Gradle 8.11,  Java 21+^) - Stable
echo   6 - AGP 8.12.0 ^(Gradle 8.12,  Java 21+^) - Stable
echo   7 - AGP 8.13.2 ^(Gradle 8.13,  Java 21+^) - Latest Stable [default]
echo   8 - AGP 9.0.0  ^(Gradle 8.14,  Java 21+^) - Beta/Canary
echo.
set "AGP_CHOICE=7"
set /p "AGP_CHOICE=Select AGP version [1-8, default: 7]: "

:: Map AGP choice to versions
if "%AGP_CHOICE%"=="1" (
    set "AGP_VERSION=8.7.3"
    set "GRADLE_VERSION=8.9"
    set "JAVA_MIN=17"
) else if "%AGP_CHOICE%"=="2" (
    set "AGP_VERSION=8.8.2"
    set "GRADLE_VERSION=8.10.2"
    set "JAVA_MIN=17"
) else if "%AGP_CHOICE%"=="3" (
    set "AGP_VERSION=8.9.0"
    set "GRADLE_VERSION=8.11.1"
    set "JAVA_MIN=17"
) else if "%AGP_CHOICE%"=="4" (
    set "AGP_VERSION=8.10.0"
    set "GRADLE_VERSION=8.11.1"
    set "JAVA_MIN=21"
) else if "%AGP_CHOICE%"=="5" (
    set "AGP_VERSION=8.11.0"
    set "GRADLE_VERSION=8.11.1"
    set "JAVA_MIN=21"
) else if "%AGP_CHOICE%"=="6" (
    set "AGP_VERSION=8.12.0"
    set "GRADLE_VERSION=8.12"
    set "JAVA_MIN=21"
) else if "%AGP_CHOICE%"=="7" (
    set "AGP_VERSION=8.13.2"
    set "GRADLE_VERSION=8.13"
    set "JAVA_MIN=21"
) else if "%AGP_CHOICE%"=="8" (
    set "AGP_VERSION=9.0.0"
    set "GRADLE_VERSION=8.14"
    set "JAVA_MIN=21"
) else (
    echo [INFO] Invalid choice, using default AGP 8.13.2
    set "AGP_VERSION=8.13.2"
    set "GRADLE_VERSION=8.13"
    set "JAVA_MIN=21"
)

echo [OK] Selected: AGP %AGP_VERSION% with Gradle %GRADLE_VERSION% ^(requires Java %JAVA_MIN%+^)

set "KOTLIN_VERSION=2.0.21"
set /p "KOTLIN_VERSION=Kotlin version [2.0.21]: "

:: SDK Components
echo.
echo === SDK Components (optional) ===
set "INSTALL_SDK=n"
set /p "INSTALL_SDK=Install/Update SDK components? [y/N]: "

set "INSTALL_NDK=n"
set "INSTALL_CMAKE=n"
if /i "%INSTALL_SDK%"=="y" (
    set /p "INSTALL_NDK=Install NDK? [y/N]: "
    set /p "INSTALL_CMAKE=Install CMake? [y/N]: "
)

:: Set derived variables
set "FULL_PROJECT_PATH=%PROJECT_LOCATION%\%PROJECT_NAME%"
set "PACKAGE_PATH=%PACKAGE:.=\%"

exit /b 0

:show_summary
echo.
echo === Summary ===
echo Project Name    : %PROJECT_NAME%
echo Package         : %PACKAGE%
echo Build Language  : %BUILD_LANG%
echo Use Compose     : %USE_COMPOSE%
echo Min SDK         : %MIN_SDK%
echo Target SDK      : %TARGET_SDK%
echo Compile SDK     : %COMPILE_SDK%
echo AGP Version     : %AGP_VERSION%
echo Gradle Version  : %GRADLE_VERSION%
echo Java Required   : %JAVA_MIN%+
echo Kotlin Version  : %KOTLIN_VERSION%
echo.
set /p "CONFIRM=Continue? [Y/n]: "
if /i "%CONFIRM%"=="n" (
    exit /b 1
)
exit /b 0