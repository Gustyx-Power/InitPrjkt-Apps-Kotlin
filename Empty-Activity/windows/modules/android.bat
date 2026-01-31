@echo off
setlocal enabledelayedexpansion
:: Android Module
:: Handles Android-specific files creation

:: Route to specific label if passed as argument
if not "%~1"=="" goto %~1

:create_app_build_gradle
echo Creating build.gradle ^(app^)...
if "!BUILD_LANG!"=="groovy" (
    (
        echo plugins {
        echo     alias libs.plugins.android.application
        echo     alias libs.plugins.kotlin.android
        if /i "!USE_COMPOSE!"=="y" (
            echo     alias libs.plugins.kotlin.compose
        )
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
        echo         sourceCompatibility JavaVersion.VERSION_11
        echo         targetCompatibility JavaVersion.VERSION_11
        echo     }
        echo.
        echo     kotlinOptions {
        echo         jvmTarget = '11'
        echo     }
        if /i "!USE_COMPOSE!"=="y" (
            echo.
            echo     buildFeatures {
            echo         compose = true
            echo     }
        )
        echo }
        echo.
        echo dependencies {
        echo     implementation libs.androidx.core.ktx
        if /i "!USE_COMPOSE!"=="y" (
            echo     implementation libs.androidx.lifecycle.runtime.ktx
            echo     implementation libs.androidx.activity.compose
            echo     implementation platform^(libs.androidx.compose.bom^)
            echo     implementation libs.androidx.compose.ui
            echo     implementation libs.androidx.compose.ui.graphics
            echo     implementation libs.androidx.compose.ui.tooling.preview
            echo     implementation libs.androidx.compose.material3
            echo     androidTestImplementation platform^(libs.androidx.compose.bom^)
            echo     androidTestImplementation libs.androidx.compose.ui.test.junit4
            echo     debugImplementation libs.androidx.compose.ui.tooling
            echo     debugImplementation libs.androidx.compose.ui.test.manifest
        ) else (
            echo     implementation libs.androidx.appcompat
            echo     implementation libs.material
            echo     implementation libs.androidx.constraintlayout
        )
        echo     testImplementation libs.junit
        echo     androidTestImplementation libs.androidx.junit
        echo     androidTestImplementation libs.androidx.espresso.core
        echo }
    ) > "!FULL_PROJECT_PATH!\app\build.gradle"
) else (
    (
        echo plugins {
        echo     alias^(libs.plugins.android.application^)
        echo     alias^(libs.plugins.kotlin.android^)
        if /i "!USE_COMPOSE!"=="y" (
            echo     alias^(libs.plugins.kotlin.compose^)
        )
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
        echo         sourceCompatibility = JavaVersion.VERSION_11
        echo         targetCompatibility = JavaVersion.VERSION_11
        echo     }
        echo.
        echo     kotlinOptions {
        echo         jvmTarget = "11"
        echo     }
        if /i "!USE_COMPOSE!"=="y" (
            echo.
            echo     buildFeatures {
            echo         compose = true
            echo     }
        )
        echo }
        echo.
        echo dependencies {
        echo     implementation^(libs.androidx.core.ktx^)
        if /i "!USE_COMPOSE!"=="y" (
            echo     implementation^(libs.androidx.lifecycle.runtime.ktx^)
            echo     implementation^(libs.androidx.activity.compose^)
            echo     implementation^(platform^(libs.androidx.compose.bom^)^)
            echo     implementation^(libs.androidx.compose.ui^)
            echo     implementation^(libs.androidx.compose.ui.graphics^)
            echo     implementation^(libs.androidx.compose.ui.tooling.preview^)
            echo     implementation^(libs.androidx.compose.material3^)
            echo     androidTestImplementation^(platform^(libs.androidx.compose.bom^)^)
            echo     androidTestImplementation^(libs.androidx.compose.ui.test.junit4^)
            echo     debugImplementation^(libs.androidx.compose.ui.tooling^)
            echo     debugImplementation^(libs.androidx.compose.ui.test.manifest^)
        ) else (
            echo     implementation^(libs.androidx.appcompat^)
            echo     implementation^(libs.material^)
            echo     implementation^(libs.androidx.constraintlayout^)
        )
        echo     testImplementation^(libs.junit^)
        echo     androidTestImplementation^(libs.androidx.junit^)
        echo     androidTestImplementation^(libs.androidx.espresso.core^)
        echo }
    ) > "!FULL_PROJECT_PATH!\app\build.gradle.kts"
)
goto :eof

:create_proguard_rules
echo Creating proguard-rules.pro...
(
    echo # Add project specific ProGuard rules here.
    echo # You can control the set of applied configuration files using the
    echo # proguardFiles setting in build.gradle.kts.
    echo #
    echo # For more details, see
    echo #   http://developer.android.com/guide/developing/tools/proguard.html
    echo.
    echo # If your project uses WebView with JS, uncomment the following
    echo # and specify the fully qualified class name to the JavaScript interface
    echo # class:
    echo #-keepclassmembers class fqcn.of.javascript.interface.for.webview {
    echo #   public *;
    echo #}
    echo.
    echo # Uncomment this to preserve the line number information for
    echo # debugging stack traces.
    echo #-keepattributes SourceFile,LineNumberTable
    echo.
    echo # If you keep the line number information, uncomment this to
    echo # hide the original source file name.
    echo #-renamesourcefileattribute SourceFile
) > "!FULL_PROJECT_PATH!\app\proguard-rules.pro"
goto :eof

:create_android_manifest
echo Creating AndroidManifest.xml...
(
    echo ^<?xml version="1.0" encoding="utf-8"?^>
    echo ^<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    echo     xmlns:tools="http://schemas.android.com/tools"^>
    echo.
    echo     ^<application
    echo         android:allowBackup="true"
    echo         android:dataExtractionRules="@xml/data_extraction_rules"
    echo         android:fullBackupContent="@xml/backup_rules"
    echo         android:icon="@mipmap/ic_launcher"
    echo         android:label="@string/app_name"
    echo         android:roundIcon="@mipmap/ic_launcher_round"
    echo         android:supportsRtl="true"
    if /i "!USE_COMPOSE!"=="y" (
        echo         android:theme="@style/Theme.!PROJECT_NAME!"^>
    ) else (
        echo         android:theme="@style/Theme.AppCompat.Light.DarkActionBar"^>
    )
    echo         ^<activity
    echo             android:name=".MainActivity"
    echo             android:exported="true"
    if /i "!USE_COMPOSE!"=="y" (
        echo             android:label="@string/app_name"
        echo             android:theme="@style/Theme.!PROJECT_NAME!"^>
    ) else (
        echo ^>
    )
    echo             ^<intent-filter^>
    echo                 ^<action android:name="android.intent.action.MAIN" /^>
    echo                 ^<category android:name="android.intent.category.LAUNCHER" /^>
    echo             ^</intent-filter^>
    echo         ^</activity^>
    echo     ^</application^>
    echo.
    echo ^</manifest^>
) > "!FULL_PROJECT_PATH!\app\src\main\AndroidManifest.xml"
goto :eof

:create_gitignore
echo Creating .gitignore...
(
    echo *.iml
    echo .gradle
    echo /local.properties
    echo /.idea/caches
    echo /.idea/libraries
    echo /.idea/modules.xml
    echo /.idea/workspace.xml
    echo /.idea/navEditor.xml
    echo /.idea/assetWizardSettings.xml
    echo .DS_Store
    echo /build
    echo /captures
    echo .externalNativeBuild
    echo .cxx
    echo local.properties
) > "!FULL_PROJECT_PATH!\.gitignore"
goto :eof

:create_android_files
echo Creating Android files...
call :create_proguard_rules
call :create_android_manifest
call :create_gitignore
goto :eof