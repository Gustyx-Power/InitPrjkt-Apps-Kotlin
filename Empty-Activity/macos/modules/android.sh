#!/bin/bash
# Android Module
# Handles Android-specific files creation

create_gradle_files() {
    # Create libs.versions.toml
    cat <<EOF > "$FULL_PROJECT_PATH/gradle/libs.versions.toml"
[versions]
agp = "$AGP_VERSION"
kotlin = "$KOTLIN_VERSION"
coreKtx = "1.10.1"
junit = "4.13.2"
junitVersion = "1.1.5"
espressoCore = "3.5.1"
lifecycleRuntimeKtx = "2.6.1"
activityCompose = "1.8.0"
composeBom = "2024.09.00"
appcompat = "1.6.1"
material = "1.11.0"
constraintlayout = "2.1.4"

[libraries]
androidx-core-ktx = { group = "androidx.core", name = "core-ktx", version.ref = "coreKtx" }
junit = { group = "junit", name = "junit", version.ref = "junit" }
androidx-junit = { group = "androidx.test.ext", name = "junit", version.ref = "junitVersion" }
androidx-espresso-core = { group = "androidx.test.espresso", name = "espresso-core", version.ref = "espressoCore" }
EOF

    if [[ "$USE_COMPOSE" == "y" ]]; then
        cat <<EOF >> "$FULL_PROJECT_PATH/gradle/libs.versions.toml"
androidx-lifecycle-runtime-ktx = { group = "androidx.lifecycle", name = "lifecycle-runtime-ktx", version.ref = "lifecycleRuntimeKtx" }
androidx-activity-compose = { group = "androidx.activity", name = "activity-compose", version.ref = "activityCompose" }
androidx-compose-bom = { group = "androidx.compose", name = "compose-bom", version.ref = "composeBom" }
androidx-compose-ui = { group = "androidx.compose.ui", name = "ui" }
androidx-compose-ui-graphics = { group = "androidx.compose.ui", name = "ui-graphics" }
androidx-compose-ui-tooling = { group = "androidx.compose.ui", name = "ui-tooling" }
androidx-compose-ui-tooling-preview = { group = "androidx.compose.ui", name = "ui-tooling-preview" }
androidx-compose-ui-test-manifest = { group = "androidx.compose.ui", name = "ui-test-manifest" }
androidx-compose-ui-test-junit4 = { group = "androidx.compose.ui", name = "ui-test-junit4" }
androidx-compose-material3 = { group = "androidx.compose.material3", name = "material3" }
EOF
    else
        cat <<EOF >> "$FULL_PROJECT_PATH/gradle/libs.versions.toml"
androidx-appcompat = { group = "androidx.appcompat", name = "appcompat", version.ref = "appcompat" }
material = { group = "com.google.android.material", name = "material", version.ref = "material" }
androidx-constraintlayout = { group = "androidx.constraintlayout", name = "constraintlayout", version.ref = "constraintlayout" }
EOF
    fi

    cat <<EOF >> "$FULL_PROJECT_PATH/gradle/libs.versions.toml"

[plugins]
android-application = { id = "com.android.application", version.ref = "agp" }
kotlin-android = { id = "org.jetbrains.kotlin.android", version.ref = "kotlin" }
EOF

    if [[ "$USE_COMPOSE" == "y" ]]; then
        cat <<EOF >> "$FULL_PROJECT_PATH/gradle/libs.versions.toml"
kotlin-compose = { id = "org.jetbrains.kotlin.plugin.compose", version.ref = "kotlin" }
EOF
    fi

    # Create local.properties
    echo "Creating local.properties..."
    echo "sdk.dir=$SDK_PATH" > "$FULL_PROJECT_PATH/local.properties"

    # Create settings.gradle
    echo "Creating settings.gradle..."
    if [ "$BUILD_LANG" = "groovy" ]; then
        cat <<EOF > "$FULL_PROJECT_PATH/settings.gradle"
pluginManagement {
    repositories {
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
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
        google {
            content {
                includeGroupByRegex("com\\.android.*")
                includeGroupByRegex("com\\.google.*")
                includeGroupByRegex("androidx.*")
            }
        }
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
}

create_app_build_gradle() {
    echo "Creating app/build.gradle..."
    if [ "$BUILD_LANG" = "groovy" ]; then
        cat <<EOF > "$FULL_PROJECT_PATH/app/build.gradle"
plugins {
    alias libs.plugins.android.application
    alias libs.plugins.kotlin.android
EOF
        if [[ "$USE_COMPOSE" == "y" ]]; then
            cat <<EOF >> "$FULL_PROJECT_PATH/app/build.gradle"
    alias libs.plugins.kotlin.compose
EOF
        fi
        cat <<EOF >> "$FULL_PROJECT_PATH/app/build.gradle"
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
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = '11'
    }
EOF
        if [[ "$USE_COMPOSE" == "y" ]]; then
            cat <<EOF >> "$FULL_PROJECT_PATH/app/build.gradle"

    buildFeatures {
        compose = true
    }
EOF
        fi
        cat <<EOF >> "$FULL_PROJECT_PATH/app/build.gradle"
}

dependencies {
    implementation libs.androidx.core.ktx
EOF
        if [[ "$USE_COMPOSE" == "y" ]]; then
            cat <<EOF >> "$FULL_PROJECT_PATH/app/build.gradle"
    implementation libs.androidx.lifecycle.runtime.ktx
    implementation libs.androidx.activity.compose
    implementation platform(libs.androidx.compose.bom)
    implementation libs.androidx.compose.ui
    implementation libs.androidx.compose.ui.graphics
    implementation libs.androidx.compose.ui.tooling.preview
    implementation libs.androidx.compose.material3
    androidTestImplementation platform(libs.androidx.compose.bom)
    androidTestImplementation libs.androidx.compose.ui.test.junit4
    debugImplementation libs.androidx.compose.ui.tooling
    debugImplementation libs.androidx.compose.ui.test.manifest
EOF
        else
            cat <<EOF >> "$FULL_PROJECT_PATH/app/build.gradle"
    implementation libs.androidx.appcompat
    implementation libs.material
    implementation libs.androidx.constraintlayout
EOF
        fi
        cat <<EOF >> "$FULL_PROJECT_PATH/app/build.gradle"
    testImplementation libs.junit
    androidTestImplementation libs.androidx.junit
    androidTestImplementation libs.androidx.espresso.core
}
EOF
    else
        cat <<EOF > "$FULL_PROJECT_PATH/app/build.gradle.kts"
plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
EOF
        if [[ "$USE_COMPOSE" == "y" ]]; then
            cat <<EOF >> "$FULL_PROJECT_PATH/app/build.gradle.kts"
    alias(libs.plugins.kotlin.compose)
EOF
        fi
        cat <<EOF >> "$FULL_PROJECT_PATH/app/build.gradle.kts"
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
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }
EOF
        if [[ "$USE_COMPOSE" == "y" ]]; then
            cat <<EOF >> "$FULL_PROJECT_PATH/app/build.gradle.kts"

    buildFeatures {
        compose = true
    }
EOF
        fi
        cat <<EOF >> "$FULL_PROJECT_PATH/app/build.gradle.kts"
}

dependencies {
    implementation(libs.androidx.core.ktx)
EOF
        if [[ "$USE_COMPOSE" == "y" ]]; then
            cat <<EOF >> "$FULL_PROJECT_PATH/app/build.gradle.kts"
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.activity.compose)
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.compose.ui)
    implementation(libs.androidx.compose.ui.graphics)
    implementation(libs.androidx.compose.ui.tooling.preview)
    implementation(libs.androidx.compose.material3)
    androidTestImplementation(platform(libs.androidx.compose.bom))
    androidTestImplementation(libs.androidx.compose.ui.test.junit4)
    debugImplementation(libs.androidx.compose.ui.tooling)
    debugImplementation(libs.androidx.compose.ui.test.manifest)
EOF
        else
            cat <<EOF >> "$FULL_PROJECT_PATH/app/build.gradle.kts"
    implementation(libs.androidx.appcompat)
    implementation(libs.material)
    implementation(libs.androidx.constraintlayout)
EOF
        fi
        cat <<EOF >> "$FULL_PROJECT_PATH/app/build.gradle.kts"
    testImplementation(libs.junit)
    androidTestImplementation(libs.androidx.junit)
    androidTestImplementation(libs.androidx.espresso.core)
}
EOF
    fi
}

create_android_files() {
    echo "Creating Android files..."
    
    # Create proguard-rules.pro
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

    # Create AndroidManifest.xml
    cat <<EOF > "$FULL_PROJECT_PATH/app/src/main/AndroidManifest.xml"
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <application
        android:allowBackup="true"
        android:dataExtractionRules="@xml/data_extraction_rules"
        android:fullBackupContent="@xml/backup_rules"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:supportsRtl="true"
EOF
    if [[ "$USE_COMPOSE" == "y" ]]; then
        cat <<EOF >> "$FULL_PROJECT_PATH/app/src/main/AndroidManifest.xml"
        android:theme="@style/Theme.$PROJECT_NAME">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:label="@string/app_name"
            android:theme="@style/Theme.$PROJECT_NAME">
EOF
    else
        cat <<EOF >> "$FULL_PROJECT_PATH/app/src/main/AndroidManifest.xml"
        android:theme="@style/Theme.AppCompat.Light.DarkActionBar">
        <activity
            android:name=".MainActivity"
            android:exported="true">
EOF
    fi
    cat <<EOF >> "$FULL_PROJECT_PATH/app/src/main/AndroidManifest.xml"
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>

</manifest>
EOF

    # Create .gitignore
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

    # Create gradle.properties with dynamic JVM memory allocation
    create_gradle_properties

    # Create gradle-wrapper.properties
    cat <<EOF > "$FULL_PROJECT_PATH/gradle/wrapper/gradle-wrapper.properties"
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-$GRADLE_VERSION-bin.zip
networkTimeout=10000
validateDistributionUrl=true
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
EOF

    # Create gradlew scripts
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

    # Download gradle-wrapper.jar
    echo "Downloading gradle-wrapper.jar..."
    WRAPPER_JAR="$FULL_PROJECT_PATH/gradle/wrapper/gradle-wrapper.jar"
    WRAPPER_URL="https://raw.githubusercontent.com/gradle/gradle/master/gradle/wrapper/gradle-wrapper.jar"

    if command -v curl &> /dev/null; then
        curl -L -o "$WRAPPER_JAR" "$WRAPPER_URL" 2>/dev/null || echo -e "${YELLOW}Warning: Failed to download gradle-wrapper.jar. Run './gradlew' later for auto-download.${NC}"
    elif command -v wget &> /dev/null; then
        wget -O "$WRAPPER_JAR" "$WRAPPER_URL" 2>/dev/null || echo -e "${YELLOW}Warning: Failed to download gradle-wrapper.jar. Run './gradlew' later for auto-download.${NC}"
    else
        echo -e "${YELLOW}Warning: curl/wget not found. Gradle wrapper will auto-download on first run.${NC}"
    fi
}

create_gradle_properties() {
    echo "Detecting system RAM for optimal Gradle configuration..."
    
    # Detect total RAM
    local total_ram_mb
    local total_ram_gb
    local half_ram_mb
    local jvm_memory
    
    # macOS - get RAM in bytes then convert
    total_ram_mb=$(sysctl -n hw.memsize | awk '{print int($1/1024/1024)}')
    total_ram_gb=$((total_ram_mb / 1024))
    
    # Calculate half of RAM in MB
    half_ram_mb=$((total_ram_mb / 2))
    
    # Apply minimum (1024MB) and maximum (8192MB) caps
    if [ $half_ram_mb -lt 1024 ]; then
        half_ram_mb=1024
    elif [ $half_ram_mb -gt 8192 ]; then
        half_ram_mb=8192
    fi
    
    local half_ram_gb=$((half_ram_mb / 1024))
    jvm_memory="${half_ram_mb}m"
    
    echo -e "${GREEN}Detected ${total_ram_gb}GB RAM. Setting Gradle JVM memory to ${half_ram_mb}MB (${half_ram_gb}GB) - 50% of available RAM.${NC}"
    
    cat <<EOF > "$FULL_PROJECT_PATH/gradle.properties"
# Project-wide Gradle settings.
# IDE (e.g. Android Studio) users:
# Gradle settings configured through the IDE *will override*
# any settings specified in this file.
# For more details on how to configure your build environment visit
# http://www.gradle.org/docs/current/userguide/build_environment.html
# Specifies the JVM arguments used for the daemon process.
# The setting is particularly useful for tweaking memory settings.
# Memory allocation optimized for ${total_ram_gb}GB RAM system
org.gradle.jvmargs=-Xmx${jvm_memory} -Dfile.encoding=UTF-8
# When configured, Gradle will run in incubating parallel mode.
# This option should only be used with decoupled projects. For more details, visit
# https://developer.android.com/r/tools/gradle-multi-project-decoupled-projects
# org.gradle.parallel=true
# AndroidX package structure to make it clearer which packages are bundled with the
# Android operating system, and which are packaged with your app's APK
# https://developer.android.com/topic/libraries/support-library/androidx-rn
android.useAndroidX=true
# Kotlin code style for this project: "official" or "obsolete":
kotlin.code.style=official
# Enables namespacing of each library's R class so that its R class includes only the
# resources declared in the library itself and none from the library's dependencies,
# thereby reducing the size of the R class for that library
android.nonTransitiveRClass=true
EOF
}