@echo off
setlocal enabledelayedexpansion

:: Android Empty Activity Project Generator
:: Platform: Windows (Native CMD/PowerShell)

title Android Empty Activity Generator

color 0B
cls
echo ============================================================
echo    InitPrjkt-Apps-Kotlin
echo    Android Empty Activity Project Generator
echo    Platform: Windows
echo ============================================================
echo.

:: 1. Interactive Input
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

:: Validate and create directory if needed
if not exist "!PROJECT_LOCATION!" (
    echo [WARNING] Directory doesn't exist. Creating: !PROJECT_LOCATION!
    mkdir "!PROJECT_LOCATION!" 2>nul
    if errorlevel 1 (
        echo [ERROR] Failed to create directory!
        pause
        exit /b 1
    )
)

echo [OK] Project will be created in: !PROJECT_LOCATION!
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

if /i "!BUILD_LANG!"=="groovy" (
    set "BUILD_LANG=groovy"
) else (
    set "BUILD_LANG=kotlin"
)

:: SDK Versions
echo.
set "MIN_SDK=24"
set /p "MIN_SDK=Minimum SDK [24]: "

set "TARGET_SDK=34"
set /p "TARGET_SDK=Target SDK [34]: "

set "COMPILE_SDK=34"
set /p "COMPILE_SDK=Compile SDK [34]: "

set "AGP_VERSION=8.2.2"
set /p "AGP_VERSION=Android Gradle Plugin version [8.2.2]: "

set "KOTLIN_VERSION=1.9.22"
set /p "KOTLIN_VERSION=Kotlin version [1.9.22]: "

:: SDK Components
echo.
echo === SDK Components (optional) ===
set "INSTALL_SDK=n"
set /p "INSTALL_SDK=Install/Update SDK components? [y/N]: "

if /i "!INSTALL_SDK!"=="y" (
    set /p "INSTALL_NDK=Install NDK? [y/N]: "
    set /p "INSTALL_CMAKE=Install CMake? [y/N]: "
)

:: Summary
echo.
echo === Summary ===
echo Project Name    : !PROJECT_NAME!
echo Package         : !PACKAGE!
echo Build Language  : !BUILD_LANG!
echo Min SDK         : !MIN_SDK!
echo Target SDK      : !TARGET_SDK!
echo Compile SDK     : !COMPILE_SDK!
echo AGP Version     : !AGP_VERSION!
echo Kotlin Version  : !KOTLIN_VERSION!
echo.
set /p "CONFIRM=Continue? [Y/n]: "
if /i "!CONFIRM!"=="n" (
    echo Cancelled.
    exit /b 0
)

echo.
echo === Starting Project Creation ===
echo.

:: 2. Detect Android SDK Path
set "SDK_PATH="

if defined ANDROID_HOME (
    set "SDK_PATH=!ANDROID_HOME!"
) else if defined ANDROID_SDK_ROOT (
    set "SDK_PATH=!ANDROID_SDK_ROOT!"
) else (
    :: Check default location
    if exist "%LOCALAPPDATA%\Android\Sdk" (
        set "SDK_PATH=%LOCALAPPDATA%\Android\Sdk"
    ) else if exist "%USERPROFILE%\AppData\Local\Android\Sdk" (
        set "SDK_PATH=%USERPROFILE%\AppData\Local\Android\Sdk"
    )
)

if "!SDK_PATH!"=="" (
    echo [ERROR] Android SDK not found!
    echo Please set ANDROID_HOME or ANDROID_SDK_ROOT environment variable.
    echo Example: set ANDROID_HOME=C:\Users\YourName\AppData\Local\Android\Sdk
    pause
    exit /b 1
)

echo [OK] Android SDK found: !SDK_PATH!
echo.

:: 3. Check if project exists
set "FULL_PROJECT_PATH=!PROJECT_LOCATION!\!PROJECT_NAME!"
if exist "!FULL_PROJECT_PATH!" (
    echo [ERROR] Folder !FULL_PROJECT_PATH! already exists!
    pause
    exit /b 1
)

:: 4. Create folder structure
echo Creating folder structure...
set "PACKAGE_PATH=!PACKAGE:.=\!"
mkdir "!FULL_PROJECT_PATH!\app\src\main\java\!PACKAGE_PATH!" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\main\res\layout" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\main\res\values" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\main\res\drawable" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\main\res\mipmap-hdpi" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\main\res\mipmap-mdpi" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\main\res\mipmap-xhdpi" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\main\res\mipmap-xxhdpi" 2>nul
mkdir "!FULL_PROJECT_PATH!\app\src\main\res\mipmap-xxxhdpi" 2>nul
mkdir "!FULL_PROJECT_PATH!\gradle\wrapper" 2>nul

:: 5. Install SDK Components (if requested)
if /i "!INSTALL_SDK!"=="y" (
    echo.
    echo === Installing SDK Components ===
    
    set "SDKMANAGER=!SDK_PATH!\cmdline-tools\latest\bin\sdkmanager.bat"
    
    if not exist "!SDKMANAGER!" (
        set "SDKMANAGER=!SDK_PATH!\tools\bin\sdkmanager.bat"
    )
    
    if exist "!SDKMANAGER!" (
        echo Updating platform-tools...
        echo y | "!SDKMANAGER!" "platform-tools" 2>nul
        
        echo Installing SDK platform !COMPILE_SDK!...
        echo y | "!SDKMANAGER!" "platforms;android-!COMPILE_SDK!" 2>nul
        
        echo Installing build-tools...
        echo y | "!SDKMANAGER!" "build-tools;34.0.0" 2>nul
        
        if /i "!INSTALL_NDK!"=="y" (
            echo Installing NDK...
            echo y | "!SDKMANAGER!" "ndk;26.1.10909125" 2>nul
        )
        
        if /i "!INSTALL_CMAKE!"=="y" (
            echo Installing CMake...
            echo y | "!SDKMANAGER!" "cmake;3.22.1" 2>nul
        )
        
        echo [OK] SDK components installed
    ) else (
        echo [WARNING] sdkmanager not found. Skipping SDK installation.
    )
)

:: 6. Create local.properties
echo.
echo Creating local.properties...
set "SDK_PATH_ESCAPED=!SDK_PATH:\=\\!"
echo sdk.dir=!SDK_PATH_ESCAPED! > "!FULL_PROJECT_PATH!\local.properties"

:: 7. Create settings.gradle
echo Creating settings.gradle...
if "!BUILD_LANG!"=="groovy" (
    (
        echo pluginManagement {
        echo     repositories {
        echo         google^(^)
        echo         mavenCentral^(^)
        echo         gradlePluginPortal^(^)
        echo     }
        echo }
        echo.
        echo dependencyResolutionManagement {
        echo     repositoriesMode.set^(RepositoriesMode.FAIL_ON_PROJECT_REPOS^)
        echo     repositories {
        echo         google^(^)
        echo         mavenCentral^(^)
        echo     }
        echo }
        echo.
        echo rootProject.name = "!PROJECT_NAME!"
        echo include ':app'
    ) > "!FULL_PROJECT_PATH!\settings.gradle"
) else (
    (
        echo pluginManagement {
        echo     repositories {
        echo         google^(^)
        echo         mavenCentral^(^)
        echo         gradlePluginPortal^(^)
        echo     }
        echo }
        echo.
        echo dependencyResolutionManagement {
        echo     repositoriesMode.set^(RepositoriesMode.FAIL_ON_PROJECT_REPOS^)
        echo     repositories {
        echo         google^(^)
        echo         mavenCentral^(^)
        echo     }
        echo }
        echo.
        echo rootProject.name = "!PROJECT_NAME!"
        echo include^(":app"^)
    ) > "!FULL_PROJECT_PATH!\settings.gradle.kts"
)

:: 8. Create build.gradle (Root)
echo Creating build.gradle ^(root^)...
if "!BUILD_LANG!"=="groovy" (
    (
        echo // Top-level build file
        echo plugins {
        echo     id 'com.android.application' version '!AGP_VERSION!' apply false
        echo     id 'org.jetbrains.kotlin.android' version '!KOTLIN_VERSION!' apply false
        echo }
    ) > "!FULL_PROJECT_PATH!\build.gradle"
) else (
    (
        echo // Top-level build file
        echo plugins {
        echo     id^("com.android.application"^) version "!AGP_VERSION!" apply false
        echo     id^("org.jetbrains.kotlin.android"^) version "!KOTLIN_VERSION!" apply false
        echo }
    ) > "!FULL_PROJECT_PATH!\build.gradle.kts"
)

:: 9. Create build.gradle (App)
echo Creating build.gradle ^(app^)...
if "!BUILD_LANG!"=="groovy" (
    (
        echo plugins {
        echo     id 'com.android.application'
        echo     id 'org.jetbrains.kotlin.android'
        echo }
        echo.
        echo android {
        echo     namespace '!PACKAGE!'
        echo     compileSdk !COMPILE_SDK!
        echo.
        echo     defaultConfig {
        echo         applicationId "!PACKAGE!"
        echo         minSdk !MIN_SDK!
        echo         targetSdk !TARGET_SDK!
        echo         versionCode 1
        echo         versionName "1.0"
        echo         testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
        echo     }
        echo.
        echo     buildTypes {
        echo         release {
        echo             minifyEnabled false
        echo             proguardFiles getDefaultProguardFile^('proguard-android-optimize.txt'^), 'proguard-rules.pro'
        echo         }
        echo     }
        echo.
        echo     compileOptions {
        echo         sourceCompatibility JavaVersion.VERSION_17
        echo         targetCompatibility JavaVersion.VERSION_17
        echo     }
        echo.
        echo     kotlinOptions {
        echo         jvmTarget = .17.
        echo     }
        echo }
        echo.
        echo dependencies {
        echo     implementation 'androidx.core:core-ktx:1.12.0'
        echo     implementation 'androidx.appcompat:appcompat:1.6.1'
        echo     implementation 'com.google.android.material:material:1.11.0'
        echo     implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
        echo     testImplementation 'junit:junit:4.13.2'
        echo     androidTestImplementation 'androidx.test.ext:junit:1.1.5'
        echo     androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
        echo }
    ) > "!FULL_PROJECT_PATH!\app\build.gradle"
) else (
    (
        echo plugins {
        echo     id^("com.android.application"^)
        echo     id^("org.jetbrains.kotlin.android"^)
        echo }
        echo.
        echo android {
        echo     namespace = "!PACKAGE!"
        echo     compileSdk = !COMPILE_SDK!
        echo.
        echo     defaultConfig {
        echo         applicationId = "!PACKAGE!"
        echo         minSdk = !MIN_SDK!
        echo         targetSdk = !TARGET_SDK!
        echo         versionCode = 1
        echo         versionName = "1.0"
        echo         testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        echo     }
        echo.
        echo     buildTypes {
        echo         release {
        echo             isMinifyEnabled = false
        echo             proguardFiles^(
        echo                 getDefaultProguardFile^("proguard-android-optimize.txt"^),
        echo                 "proguard-rules.pro"
        echo             ^)
        echo         }
        echo     }
        echo.
        echo     compileOptions {
        echo         sourceCompatibility = JavaVersion.VERSION_17
        echo         targetCompatibility = JavaVersion.VERSION_17
        echo     }
        echo.
        echo     kotlinOptions {
        echo         jvmTarget = .17.
        echo     }
        echo }
        echo.
        echo dependencies {
        echo     implementation^("androidx.core:core-ktx:1.12.0"^)
        echo     implementation^("androidx.appcompat:appcompat:1.6.1"^)
        echo     implementation^("com.google.android.material:material:1.11.0"^)
        echo     implementation^("androidx.constraintlayout:constraintlayout:2.1.4"^)
        echo     testImplementation^("junit:junit:4.13.2"^)
        echo     androidTestImplementation^("androidx.test.ext:junit:1.1.5"^)
        echo     androidTestImplementation^("androidx.test.espresso:espresso-core:3.5.1"^)
        echo }
    ) > "!FULL_PROJECT_PATH!\app\build.gradle.kts"
)

:: 10. Create proguard-rules.pro
echo Creating proguard-rules.pro...
(
    echo # Add project specific ProGuard rules here.
    echo # For more details, see
    echo #   http://developer.android.com/guide/developing/tools/proguard.html
) > "!FULL_PROJECT_PATH!\app\proguard-rules.pro"

:: 11. Create AndroidManifest.xml
echo Creating AndroidManifest.xml...
(
    echo ^<?xml version="1.0" encoding="utf-8"?^>
    echo ^<manifest xmlns:android="http://schemas.android.com/apk/res/android"^>
    echo.
    echo     ^<application
    echo         android:allowBackup="true"
    echo         android:icon="@mipmap/ic_launcher"
    echo         android:label="@string/app_name"
    echo         android:roundIcon="@mipmap/ic_launcher_round"
    echo         android:supportsRtl="true"
    echo         android:theme="@style/Theme.AppCompat.Light.DarkActionBar"^>
    echo         ^<activity
    echo             android:name=".MainActivity"
    echo             android:exported="true"^>
    echo             ^<intent-filter^>
    echo                 ^<action android:name="android.intent.action.MAIN" /^>
    echo                 ^<category android:name="android.intent.category.LAUNCHER" /^>
    echo             ^</intent-filter^>
    echo         ^</activity^>
    echo     ^</application^>
    echo.
    echo ^</manifest^>
) > "!FULL_PROJECT_PATH!\app\src\main\AndroidManifest.xml"

:: 12. Create MainActivity.kt
echo Creating MainActivity.kt...
(
    echo package !PACKAGE!
    echo.
    echo import android.os.Bundle
    echo import androidx.appcompat.app.AppCompatActivity
    echo.
    echo class MainActivity : AppCompatActivity^(^) {
    echo     override fun onCreate^(savedInstanceState: Bundle?^) {
    echo         super.onCreate^(savedInstanceState^)
    echo         setContentView^(R.layout.activity_main^)
    echo     }
    echo }
) > "!FULL_PROJECT_PATH!\app\src\main\java\!PACKAGE_PATH!\MainActivity.kt"

:: 13. Create activity_main.xml
echo Creating activity_main.xml...
(
    echo ^<?xml version="1.0" encoding="utf-8"?^>
    echo ^<androidx.constraintlayout.widget.ConstraintLayout
    echo     xmlns:android="http://schemas.android.com/apk/res/android"
    echo     xmlns:app="http://schemas.android.com/apk/res-auto"
    echo     xmlns:tools="http://schemas.android.com/tools"
    echo     android:layout_width="match_parent"
    echo     android:layout_height="match_parent"
    echo     tools:context=".MainActivity"^>
    echo.
    echo     ^<TextView
    echo         android:layout_width="wrap_content"
    echo         android:layout_height="wrap_content"
    echo         android:text="Hello World!"
    echo         app:layout_constraintBottom_toBottomOf="parent"
    echo         app:layout_constraintEnd_toEndOf="parent"
    echo         app:layout_constraintStart_toStartOf="parent"
    echo         app:layout_constraintTop_toTopOf="parent" /^>
    echo.
    echo ^</androidx.constraintlayout.widget.ConstraintLayout^>
) > "!FULL_PROJECT_PATH!\app\src\main\res\layout\activity_main.xml"

:: 14. Create strings.xml
echo Creating strings.xml...
(
    echo ^<resources^>
    echo     ^<string name="app_name"^>!PROJECT_NAME!^</string^>
    echo ^</resources^>
) > "!FULL_PROJECT_PATH!\app\src\main\res\values\strings.xml"

:: 15. Create colors.xml
echo Creating colors.xml...
(
    echo ^<?xml version="1.0" encoding="utf-8"?^>
    echo ^<resources^>
    echo     ^<color name="black"^>#FF000000^</color^>
    echo     ^<color name="white"^>#FFFFFFFF^</color^>
    echo ^</resources^>
) > "!FULL_PROJECT_PATH!\app\src\main\res\values\colors.xml"

:: 16. Create gradle.properties
echo Creating gradle.properties...
(
    echo # Project-wide Gradle settings.
    echo org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
    echo android.useAndroidX=true
    echo kotlin.code.style=official
    echo android.nonTransitiveRClass=true
) > "!FULL_PROJECT_PATH!\gradle.properties"

:: 17. Create gradle-wrapper.properties
echo Creating gradle-wrapper.properties...
(
    echo distributionBase=GRADLE_USER_HOME
    echo distributionPath=wrapper/dists
    echo distributionUrl=https\://services.gradle.org/distributions/gradle-8.2-bin.zip
    echo networkTimeout=10000
    echo validateDistributionUrl=true
    echo zipStoreBase=GRADLE_USER_HOME
    echo zipStorePath=wrapper/dists
) > "!FULL_PROJECT_PATH!\gradle\wrapper\gradle-wrapper.properties"

:: 18. Create .gitignore
echo Creating .gitignore...
(
    echo *.iml
    echo .gradle
    echo /local.properties
    echo /.idea/
    echo .DS_Store
    echo /build
    echo /captures
    echo .externalNativeBuild
    echo .cxx
    echo local.properties
) > "!FULL_PROJECT_PATH!\.gitignore"

:: 19. Create gradlew.bat
echo Creating gradlew.bat...
(
    echo @rem Gradle startup script for Windows
    echo @rem Set local scope for the variables with windows NT shell
    echo if "%%OS%%"=="Windows_NT" setlocal
    echo.
    echo set DIRNAME=%%~dp0
    echo if "%%DIRNAME%%"=="" set DIRNAME=.
    echo set APP_BASE_NAME=%%~n0
    echo set APP_HOME=%%DIRNAME%%
    echo.
    echo @rem Find java.exe
    echo if defined JAVA_HOME goto findJavaFromJavaHome
    echo.
    echo set JAVA_EXE=java.exe
    echo %%JAVA_EXE%% -version ^>NUL 2^>^&1
    echo if %%ERRORLEVEL%% equ 0 goto execute
    echo.
    echo echo ERROR: JAVA_HOME is not set and no 'java' command could be found
    echo goto fail
    echo.
    echo :findJavaFromJavaHome
    echo set JAVA_HOME=%%JAVA_HOME:"=%%
    echo set JAVA_EXE=%%JAVA_HOME%%/bin/java.exe
    echo.
    echo if exist "%%JAVA_EXE%%" goto execute
    echo.
    echo echo ERROR: JAVA_HOME is set to an invalid directory
    echo goto fail
    echo.
    echo :execute
    echo "%%JAVA_EXE%%" -classpath "%%APP_HOME%%\gradle\wrapper\gradle-wrapper.jar" org.gradle.wrapper.GradleWrapperMain %%*
    echo.
    echo :fail
    echo exit /b 1
) > "!FULL_PROJECT_PATH!\gradlew.bat"

:: 20. Download gradle-wrapper.jar
echo Downloading gradle-wrapper.jar...
powershell -Command "try { Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/gradle/gradle/master/gradle/wrapper/gradle-wrapper.jar' -OutFile '!PROJECT_NAME!\gradle\wrapper\gradle-wrapper.jar' -UseBasicParsing } catch { Write-Host 'Warning: Failed to download gradle-wrapper.jar' }" 2>nul

:: 21. Done
echo.
echo ============================================================
echo          [OK] Project created successfully!
echo ============================================================
echo.
echo Project Details:
echo   Name          : !PROJECT_NAME!
echo   Package       : !PACKAGE!
echo   Build Language: !BUILD_LANG!
echo   Min SDK       : !MIN_SDK!
echo   Target SDK    : !TARGET_SDK!
echo.
echo Project Structure:
echo   !PROJECT_NAME!\
echo   +-- app\
echo   +-- gradle\
if "!BUILD_LANG!"=="groovy" (
    echo   +-- build.gradle
    echo   +-- settings.gradle
) else (
    echo   +-- build.gradle.kts
    echo   +-- settings.gradle.kts
)
echo   +-- gradlew.bat
echo.
echo Next Steps:
echo   1. cd !PROJECT_NAME!
echo   2. gradlew.bat build              # Build project
echo   3. gradlew.bat assembleDebug      # Build APK
echo   4. gradlew.bat installDebug       # Install to device
echo.
echo Or open in Android Studio / VS Code
echo.
pause
