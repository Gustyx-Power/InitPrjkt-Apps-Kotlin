@echo off
setlocal enabledelayedexpansion
:: Structure Module
:: Handles project folder structure creation

:: Route to specific label if passed as argument
if not "%~1"=="" goto %~1

:create_folder_structure
echo Creating folder structure...
set "PACKAGE_PATH=!PACKAGE:.=\!"
mkdir "!FULL_PROJECT_PATH!\app\src\main\java\!PACKAGE_PATH!" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\main\java\!PACKAGE_PATH!\ui\theme" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\main\res\layout" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\main\res\values" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\main\res\drawable" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\main\res\drawable-v24" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\main\res\mipmap-anydpi-v26" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\main\res\mipmap-hdpi" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\main\res\mipmap-mdpi" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\main\res\mipmap-xhdpi" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\main\res\mipmap-xxhdpi" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\main\res\mipmap-xxxhdpi" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\main\res\xml" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\test\java\!PACKAGE_PATH!" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\androidTest\java\!PACKAGE_PATH!" 2>nul
mkdir "!FULL_PROJECT_PATH!\gradle\wrapper" 2>nul
goto :eof

:check_project_exists
set "FULL_PROJECT_PATH=!PROJECT_LOCATION!\!PROJECT_NAME!"
if exist "!FULL_PROJECT_PATH!" (
    echo [ERROR] Folder !FULL_PROJECT_PATH! already exists!
    pause
    exit /b 1
)
goto :eof