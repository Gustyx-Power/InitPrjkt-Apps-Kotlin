#!/bin/bash

# Android Empty Activity Project Generator
# Platform: macOS, Linux, WSL

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear
echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║   InitPrjkt-Apps-Kotlin                                ║${NC}"
echo -e "${CYAN}║   Android Empty Activity Project Generator            ║${NC}"
echo -e "${CYAN}║   Platform: Linux                                      ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# 1. Interactive Input
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

# SDK Versions
echo ""
read -p "Minimum SDK [24]: " MIN_SDK
MIN_SDK=${MIN_SDK:-24}

read -p "Target SDK [34]: " TARGET_SDK
TARGET_SDK=${TARGET_SDK:-34}

read -p "Compile SDK [34]: " COMPILE_SDK
COMPILE_SDK=${COMPILE_SDK:-34}

# AGP and Kotlin versions
read -p "Android Gradle Plugin version [8.2.2]: " AGP_VERSION
AGP_VERSION=${AGP_VERSION:-8.2.2}

read -p "Kotlin version [1.9.22]: " KOTLIN_VERSION
KOTLIN_VERSION=${KOTLIN_VERSION:-1.9.22}

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

echo ""
echo -e "${GREEN}=== Summary ===${NC}"
echo "Project Name    : $PROJECT_NAME"
echo "Package         : $PACKAGE"
echo "Build Language  : $BUILD_LANG"
echo "Min SDK         : $MIN_SDK"
echo "Target SDK      : $TARGET_SDK"
echo "Compile SDK     : $COMPILE_SDK"
echo "AGP Version     : $AGP_VERSION"
echo "Kotlin Version  : $KOTLIN_VERSION"
echo ""
read -p "Continue? [Y/n]: " CONFIRM
CONFIRM=${CONFIRM:-y}
CONFIRM=$(echo "$CONFIRM" | tr '[:upper:]' '[:lower:]')

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "yes" ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""

# 2. Deteksi OS
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "Linux";;
        Darwin*)    echo "macOS";;
        CYGWIN*|MINGW*|MSYS*) echo "WSL";;
        *)          echo "Unknown";;
    esac
}

OS_TYPE=$(detect_os)
echo -e "${YELLOW}Detected OS: $OS_TYPE${NC}"

# 3. Deteksi Android SDK Path
detect_sdk_path() {
    # Cek ANDROID_HOME atau ANDROID_SDK_ROOT
    if [ -n "$ANDROID_HOME" ]; then
        echo "$ANDROID_HOME"
        return
    fi
    
    if [ -n "$ANDROID_SDK_ROOT" ]; then
        echo "$ANDROID_SDK_ROOT"
        return
    fi
    
    # Cek lokasi default berdasarkan OS
    case "$OS_TYPE" in
        "macOS")
            if [ -d "$HOME/Library/Android/sdk" ]; then
                echo "$HOME/Library/Android/sdk"
                return
            fi
            ;;
        "Linux")
            if [ -d "$HOME/Android/Sdk" ]; then
                echo "$HOME/Android/Sdk"
                return
            fi
            ;;
        "WSL")
            # WSL paths
            WSL_PATHS=(
                "/mnt/c/Users/$USER/AppData/Local/Android/Sdk"
                "$HOME/Android/Sdk"
            )
            for path in "${WSL_PATHS[@]}"; do
                if [ -d "$path" ]; then
                    echo "$path"
                    return
                fi
            done
            ;;
    esac
    
    echo ""
}

SDK_PATH=$(detect_sdk_path)

if [ -z "$SDK_PATH" ]; then
    echo -e "${RED}ERROR: Android SDK tidak ditemukan!${NC}"
    echo "Silakan set environment variable ANDROID_HOME atau ANDROID_SDK_ROOT"
    echo "Contoh:"
    echo "  export ANDROID_HOME=/path/to/android/sdk"
    exit 1
fi

echo -e "${GREEN}Android SDK ditemukan: $SDK_PATH${NC}"
echo ""

# 4. Cek apakah project sudah ada
FULL_PROJECT_PATH="$PROJECT_LOCATION/$PROJECT_NAME"
if [ -d "$FULL_PROJECT_PATH" ]; then
    echo -e "${RED}ERROR: Folder $FULL_PROJECT_PATH sudah ada!${NC}"
    exit 1
fi

# 5. Buat Struktur Folder
echo "Membuat struktur folder..."
PACKAGE_PATH=${PACKAGE//./\/}
mkdir -p "$FULL_PROJECT_PATH/app/src/main/java/$PACKAGE_PATH"
mkdir -p "$FULL_PROJECT_PATH/app/src/main/res/layout"
mkdir -p "$FULL_PROJECT_PATH/app/src/main/res/values"
mkdir -p "$FULL_PROJECT_PATH/app/src/main/res/drawable"
mkdir -p "$FULL_PROJECT_PATH/app/src/main/res/mipmap-hdpi"
mkdir -p "$FULL_PROJECT_PATH/app/src/main/res/mipmap-mdpi"
mkdir -p "$FULL_PROJECT_PATH/app/src/main/res/mipmap-xhdpi"
mkdir -p "$FULL_PROJECT_PATH/app/src/main/res/mipmap-xxhdpi"
mkdir -p "$FULL_PROJECT_PATH/app/src/main/res/mipmap-xxxhdpi"
mkdir -p "$FULL_PROJECT_PATH/gradle/wrapper"

# 6. Install/Update SDK Components (jika diminta)
if [[ "$INSTALL_SDK" == "y" || "$INSTALL_SDK" == "yes" ]]; then
    echo ""
    echo -e "${BLUE}=== Installing SDK Components ===${NC}"
    
    SDKMANAGER="$SDK_PATH/cmdline-tools/latest/bin/sdkmanager"
    
    # Cek apakah sdkmanager ada
    if [ ! -f "$SDKMANAGER" ]; then
        # Coba lokasi alternatif
        SDKMANAGER="$SDK_PATH/tools/bin/sdkmanager"
        if [ ! -f "$SDKMANAGER" ]; then
            echo -e "${YELLOW}Warning: sdkmanager tidak ditemukan. Skip instalasi SDK components.${NC}"
            INSTALL_SDK="n"
        fi
    fi
    
    if [[ "$INSTALL_SDK" == "y" || "$INSTALL_SDK" == "yes" ]]; then
        echo "Updating SDK platform-tools..."
        yes | "$SDKMANAGER" "platform-tools" 2>/dev/null || true
        
        echo "Installing SDK platform $COMPILE_SDK..."
        yes | "$SDKMANAGER" "platforms;android-$COMPILE_SDK" 2>/dev/null || true
        
        echo "Installing build-tools..."
        yes | "$SDKMANAGER" "build-tools;34.0.0" 2>/dev/null || true
        
        if [[ "$INSTALL_NDK" == "y" || "$INSTALL_NDK" == "yes" ]]; then
            echo "Installing NDK..."
            yes | "$SDKMANAGER" "ndk;26.1.10909125" 2>/dev/null || true
        fi
        
        if [[ "$INSTALL_CMAKE" == "y" || "$INSTALL_CMAKE" == "yes" ]]; then
            echo "Installing CMake..."
            yes | "$SDKMANAGER" "cmake;3.22.1" 2>/dev/null || true
        fi
        
        echo -e "${GREEN}✓ SDK components installed${NC}"
    fi
fi

# 7. Buat file local.properties
echo ""
echo "Membuat local.properties..."
SDK_PATH_ESCAPED="$SDK_PATH"
echo "sdk.dir=$SDK_PATH_ESCAPED" > "$FULL_PROJECT_PATH/local.properties"

# 8. Buat settings.gradle (Groovy atau Kotlin DSL)
echo "Membuat settings.gradle..."
if [ "$BUILD_LANG" = "groovy" ]; then
    cat <<EOF > "$FULL_PROJECT_PATH/settings.gradle"
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "$PROJECT_NAME"
include ':app'
EOF
else
    cat <<EOF > "$FULL_PROJECT_PATH/settings.gradle.kts"
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "$PROJECT_NAME"
include(":app")
EOF
fi

# 9. Buat build.gradle (Root)
echo "Membuat build.gradle (root)..."
if [ "$BUILD_LANG" = "groovy" ]; then
    cat <<EOF > "$FULL_PROJECT_PATH/build.gradle"
// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    id 'com.android.application' version '$AGP_VERSION' apply false
    id 'org.jetbrains.kotlin.android' version '$KOTLIN_VERSION' apply false
}
EOF
else
    cat <<EOF > "$FULL_PROJECT_PATH/build.gradle.kts"
// Top-level build file where you can add configuration options common to all sub-projects/modules.
plugins {
    id("com.android.application") version "$AGP_VERSION" apply false
    id("org.jetbrains.kotlin.android") version "$KOTLIN_VERSION" apply false
}
EOF
fi

# 10. Buat build.gradle (App Module)
echo "Membuat build.gradle (app)..."
if [ "$BUILD_LANG" = "groovy" ]; then
    cat <<EOF > "$FULL_PROJECT_PATH/app/build.gradle"
plugins {
    id 'com.android.application'
    id 'org.jetbrains.kotlin.android'
}

android {
    namespace '$PACKAGE'
    compileSdk $COMPILE_SDK

    defaultConfig {
        applicationId "$PACKAGE"
        minSdk $MIN_SDK
        targetSdk $TARGET_SDK
        versionCode 1
        versionName "1.0"

        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_17
        targetCompatibility JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = '17'
    }
}

dependencies {
    implementation 'androidx.core:core-ktx:1.12.0'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.11.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    
    testImplementation 'junit:junit:4.13.2'
    androidTestImplementation 'androidx.test.ext:junit:1.1.5'
    androidTestImplementation 'androidx.test.espresso:espresso-core:3.5.1'
}
EOF
else
    cat <<EOF > "$FULL_PROJECT_PATH/app/build.gradle.kts"
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "$PACKAGE"
    compileSdk = $COMPILE_SDK

    defaultConfig {
        applicationId = "$PACKAGE"
        minSdk = $MIN_SDK
        targetSdk = $TARGET_SDK
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
    
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    
    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("com.google.android.material:material:1.11.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.4")
    
    testImplementation("junit:junit:4.13.2")
    androidTestImplementation("androidx.test.ext:junit:1.1.5")
    androidTestImplementation("androidx.test.espresso:espresso-core:3.5.1")
}
EOF
fi

# 11. Buat proguard-rules.pro
echo "Membuat proguard-rules.pro..."
cat <<EOF > "$FULL_PROJECT_PATH/app/proguard-rules.pro"
# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.kts.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile
EOF

# 12. Buat AndroidManifest.xml
echo "Membuat AndroidManifest.xml..."
cat <<EOF > "$FULL_PROJECT_PATH/app/src/main/AndroidManifest.xml"
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
        android:theme="@style/Theme.AppCompat.Light.DarkActionBar">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>

</manifest>
EOF

# 13. Buat MainActivity.kt
echo "Membuat MainActivity.kt..."
cat <<EOF > "$FULL_PROJECT_PATH/app/src/main/java/$PACKAGE_PATH/MainActivity.kt"
package $PACKAGE

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
    }
}
EOF

# 14. Buat activity_main.xml
echo "Membuat activity_main.xml..."
cat <<EOF > "$FULL_PROJECT_PATH/app/src/main/res/layout/activity_main.xml"
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout 
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".MainActivity">

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Hello World!"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

</androidx.constraintlayout.widget.ConstraintLayout>
EOF

# 15. Buat strings.xml
echo "Membuat strings.xml..."
cat <<EOF > "$FULL_PROJECT_PATH/app/src/main/res/values/strings.xml"
<resources>
    <string name="app_name">$PROJECT_NAME</string>
</resources>
EOF

# 16. Buat colors.xml
echo "Membuat colors.xml..."
cat <<EOF > "$FULL_PROJECT_PATH/app/src/main/res/values/colors.xml"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="black">#FF000000</color>
    <color name="white">#FFFFFFFF</color>
</resources>
EOF

# 17. Buat gradle.properties
echo "Membuat gradle.properties..."
cat <<EOF > "$FULL_PROJECT_PATH/gradle.properties"
# Project-wide Gradle settings.
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
kotlin.code.style=official
android.nonTransitiveRClass=true
EOF

# 18. Buat gradle-wrapper.properties
echo "Membuat gradle-wrapper.properties..."
cat <<EOF > "$FULL_PROJECT_PATH/gradle/wrapper/gradle-wrapper.properties"
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.2-bin.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

# 19. Buat .gitignore
echo "Membuat .gitignore..."
cat <<EOF > "$FULL_PROJECT_PATH/.gitignore"
*.iml
.gradle
/local.properties
/.idea/caches
/.idea/libraries
/.idea/modules.xml
/.idea/workspace.xml
/.idea/navEditor.xml
/.idea/assetWizardSettings.xml
.DS_Store
/build
/captures
.externalNativeBuild
.cxx
local.properties
EOF

# 20. Buat gradlew dan gradlew.bat
echo "Membuat gradlew scripts..."

# gradlew (Unix/Linux/macOS)
cat <<'EOF' > "$FULL_PROJECT_PATH/gradlew"
#!/bin/sh

##############################################################################
# Gradle start up script for POSIX generated by Gradle.
##############################################################################

# Attempt to set APP_HOME
APP_HOME=$( cd "${APP_HOME:-./}" && pwd -P ) || exit

# Use the maximum available, or set MAX_FD != -1 to use that value.
MAX_FD=maximum

warn () {
    echo "$*"
} >&2

die () {
    echo
    echo "$*"
    echo
    exit 1
} >&2

# OS specific support (must be 'true' or 'false').
cygwin=false
msys=false
darwin=false
nonstop=false
case "$( uname )" in
  CYGWIN* )         cygwin=true  ;;
  Darwin* )         darwin=true  ;;
  MSYS* | MINGW* )  msys=true    ;;
  NONSTOP* )        nonstop=true ;;
esac

CLASSPATH=$APP_HOME/gradle/wrapper/gradle-wrapper.jar

# Determine the Java command to use to start the JVM.
if [ -n "$JAVA_HOME" ] ; then
    if [ -x "$JAVA_HOME/jre/sh/java" ] ; then
        JAVACMD=$JAVA_HOME/jre/sh/java
    else
        JAVACMD=$JAVA_HOME/bin/java
    fi
    if [ ! -x "$JAVACMD" ] ; then
        die "ERROR: JAVA_HOME is set to an invalid directory: $JAVA_HOME"
    fi
else
    JAVACMD=java
    if ! command -v java >/dev/null 2>&1
    then
        die "ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH."
    fi
fi

# Escape application args
save () {
    for i do printf %s\\n "$i" | sed "s/'/'\\\\''/g;1s/^/'/;\$s/\$/' \\\\/" ; done
    echo " "
}
APP_ARGS=$(save "$@")

eval "set -- $APP_ARGS"

exec "$JAVACMD" "$@" -Dorg.gradle.appname="$APP_BASE_NAME" -classpath "$CLASSPATH" org.gradle.wrapper.GradleWrapperMain "$@"
EOF

chmod +x "$FULL_PROJECT_PATH/gradlew"

# gradlew.bat (Windows)
cat <<'EOF' > "$FULL_PROJECT_PATH/gradlew.bat"
@rem Gradle startup script for Windows

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

set DIRNAME=%~dp0
if "%DIRNAME%"=="" set DIRNAME=.
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%

@rem Add default JVM options here. You can also use JAVA_OPTS and GRADLE_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS="-Xmx64m" "-Xms64m"

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if %ERRORLEVEL% equ 0 goto execute

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto execute

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
goto fail

:execute
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %GRADLE_OPTS% "-Dorg.gradle.appname=%APP_BASE_NAME%" -classpath "%CLASSPATH%" org.gradle.wrapper.GradleWrapperMain %*

:end
@rem End local scope for the variables with windows NT shell
if %ERRORLEVEL% equ 0 goto mainEnd

:fail
rem Set variable GRADLE_EXIT_CONSOLE if you need the _script_ return code instead of
rem the _cmd.exe /c_ return code!
set EXIT_CODE=%ERRORLEVEL%
if %EXIT_CODE% equ 0 set EXIT_CODE=1
if not ""=="%GRADLE_EXIT_CONSOLE%" exit %EXIT_CODE%
exit /b %EXIT_CODE%

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
EOF

# 21. Download gradle-wrapper.jar
echo "Downloading gradle-wrapper.jar..."
WRAPPER_JAR="$FULL_PROJECT_PATH/gradle/wrapper/gradle-wrapper.jar"
WRAPPER_URL="https://raw.githubusercontent.com/gradle/gradle/master/gradle/wrapper/gradle-wrapper.jar"

if command -v curl &> /dev/null; then
    curl -L -o "$WRAPPER_JAR" "$WRAPPER_URL" 2>/dev/null || echo -e "${YELLOW}Warning: Gagal download gradle-wrapper.jar. Jalankan './gradlew' nanti untuk auto-download.${NC}"
elif command -v wget &> /dev/null; then
    wget -O "$WRAPPER_JAR" "$WRAPPER_URL" 2>/dev/null || echo -e "${YELLOW}Warning: Gagal download gradle-wrapper.jar. Jalankan './gradlew' nanti untuk auto-download.${NC}"
else
    echo -e "${YELLOW}Warning: curl/wget tidak ditemukan. Gradle wrapper akan auto-download saat pertama kali dijalankan.${NC}"
fi

# 22. Selesai
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          ✓ Project berhasil dibuat!                    ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Project Details:${NC}"
echo "  Name          : $PROJECT_NAME"
echo "  Package       : $PACKAGE"
echo "  Build Language: $BUILD_LANG"
echo "  Min SDK       : $MIN_SDK"
echo "  Target SDK    : $TARGET_SDK"
echo ""
echo -e "${CYAN}Struktur Project:${NC}"
echo "  $PROJECT_NAME/"
echo "  ├── app/"
echo "  │   ├── src/main/"
echo "  │   │   ├── java/$PACKAGE_PATH/"
echo "  │   │   │   └── MainActivity.kt"
echo "  │   │   ├── res/"
echo "  │   │   │   ├── layout/activity_main.xml"
echo "  │   │   │   └── values/"
echo "  │   │   └── AndroidManifest.xml"
if [ "$BUILD_LANG" = "groovy" ]; then
echo "  │   └── build.gradle"
echo "  ├── build.gradle"
echo "  └── settings.gradle"
else
echo "  │   └── build.gradle.kts"
echo "  ├── build.gradle.kts"
echo "  └── settings.gradle.kts"
fi
echo ""
echo -e "${CYAN}Langkah Selanjutnya:${NC}"
echo "  1. cd $PROJECT_NAME"
echo "  2. ./gradlew build              # Build project"
echo "  3. ./gradlew assembleDebug      # Build APK"
echo "  4. ./gradlew installDebug       # Install ke device"
echo ""
echo -e "${YELLOW}Atau buka di Android Studio / VS Code${NC}"
echo ""