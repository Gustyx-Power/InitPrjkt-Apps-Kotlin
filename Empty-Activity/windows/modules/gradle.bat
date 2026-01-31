@echo off
setlocal enabledelayedexpansion
:: Gradle Module
:: Handles Gradle configuration files

:: Route to specific label if passed as argument
if not "%~1"=="" goto %~1

:create_libs_versions_toml
echo Creating gradle/libs.versions.toml...
(
    echo [versions]
    echo agp = "!AGP_VERSION!"
    echo kotlin = "!KOTLIN_VERSION!"
    echo coreKtx = "1.10.1"
    echo junit = "4.13.2"
    echo junitVersion = "1.1.5"
    echo espressoCore = "3.5.1"
    echo lifecycleRuntimeKtx = "2.6.1"
    echo activityCompose = "1.8.0"
    echo composeBom = "2024.09.00"
    echo appcompat = "1.6.1"
    echo material = "1.11.0"
    echo constraintlayout = "2.1.4"
    echo.
    echo [libraries]
    echo androidx-core-ktx = { group = "androidx.core", name = "core-ktx", version.ref = "coreKtx" }
    echo junit = { group = "junit", name = "junit", version.ref = "junit" }
    echo androidx-junit = { group = "androidx.test.ext", name = "junit", version.ref = "junitVersion" }
    echo androidx-espresso-core = { group = "androidx.test.espresso", name = "espresso-core", version.ref = "espressoCore" }
    if /i "!USE_COMPOSE!"=="y" (
        echo androidx-lifecycle-runtime-ktx = { group = "androidx.lifecycle", name = "lifecycle-runtime-ktx", version.ref = "lifecycleRuntimeKtx" }
        echo androidx-activity-compose = { group = "androidx.activity", name = "activity-compose", version.ref = "activityCompose" }
        echo androidx-compose-bom = { group = "androidx.compose", name = "compose-bom", version.ref = "composeBom" }
        echo androidx-compose-ui = { group = "androidx.compose.ui", name = "ui" }
        echo androidx-compose-ui-graphics = { group = "androidx.compose.ui", name = "ui-graphics" }
        echo androidx-compose-ui-tooling = { group = "androidx.compose.ui", name = "ui-tooling" }
        echo androidx-compose-ui-tooling-preview = { group = "androidx.compose.ui", name = "ui-tooling-preview" }
        echo androidx-compose-ui-test-manifest = { group = "androidx.compose.ui", name = "ui-test-manifest" }
        echo androidx-compose-ui-test-junit4 = { group = "androidx.compose.ui", name = "ui-test-junit4" }
        echo androidx-compose-material3 = { group = "androidx.compose.material3", name = "material3" }
    ) else (
        echo androidx-appcompat = { group = "androidx.appcompat", name = "appcompat", version.ref = "appcompat" }
        echo material = { group = "com.google.android.material", name = "material", version.ref = "material" }
        echo androidx-constraintlayout = { group = "androidx.constraintlayout", name = "constraintlayout", version.ref = "constraintlayout" }
    )
    echo.
    echo [plugins]
    echo android-application = { id = "com.android.application", version.ref = "agp" }
    echo kotlin-android = { id = "org.jetbrains.kotlin.android", version.ref = "kotlin" }
    if /i "!USE_COMPOSE!"=="y" (
        echo kotlin-compose = { id = "org.jetbrains.kotlin.plugin.compose", version.ref = "kotlin" }
    )
) > "!FULL_PROJECT_PATH!\gradle\libs.versions.toml"
goto :eof

:create_local_properties
echo Creating local.properties...
set "SDK_PATH_ESCAPED=!SDK_PATH:\=\\!"
echo sdk.dir=!SDK_PATH_ESCAPED! > "!FULL_PROJECT_PATH!\local.properties"
goto :eof

:create_settings_gradle
echo Creating settings.gradle...
if "!BUILD_LANG!"=="groovy" (
    (
        echo pluginManagement {
        echo     repositories {
        echo         google {
        echo             content {
        echo                 includeGroupByRegex^("com\\.android.*"^)
        echo                 includeGroupByRegex^("com\\.google.*"^)
        echo                 includeGroupByRegex^("androidx.*"^)
        echo             }
        echo         }
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
        echo         google {
        echo             content {
        echo                 includeGroupByRegex^("com\\.android.*"^)
        echo                 includeGroupByRegex^("com\\.google.*"^)
        echo                 includeGroupByRegex^("androidx.*"^)
        echo             }
        echo         }
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
goto :eof

:create_root_build_gradle
echo Creating build.gradle ^(root^)...
if "!BUILD_LANG!"=="groovy" (
    (
        echo // Top-level build file where you can add configuration options common to all sub-projects/modules.
        echo plugins {
        echo     alias^(libs.plugins.android.application^) apply false
        echo     alias^(libs.plugins.kotlin.android^) apply false
        if /i "!USE_COMPOSE!"=="y" (
            echo     alias^(libs.plugins.kotlin.compose^) apply false
        )
        echo }
    ) > "!FULL_PROJECT_PATH!\build.gradle"
) else (
    (
        echo // Top-level build file where you can add configuration options common to all sub-projects/modules.
        echo plugins {
        echo     alias^(libs.plugins.android.application^) apply false
        echo     alias^(libs.plugins.kotlin.android^) apply false
        if /i "!USE_COMPOSE!"=="y" (
            echo     alias^(libs.plugins.kotlin.compose^) apply false
        )
        echo }
    ) > "!FULL_PROJECT_PATH!\build.gradle.kts"
)
goto :eof

:create_gradle_properties
echo Detecting system RAM for optimal Gradle configuration...

:: Get total RAM in bytes using PowerShell (more reliable than wmic)
for /f %%i in ('powershell -Command "(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory"') do set total_ram_bytes=%%i

:: Calculate half of RAM in MB using PowerShell (batch can't handle large numbers)
for /f %%i in ('powershell -Command "[math]::Floor(%total_ram_bytes% / 1024 / 1024 / 2)"') do set half_ram_mb=%%i

:: Get total RAM in GB for display
for /f %%i in ('powershell -Command "[math]::Floor(%total_ram_bytes% / 1024 / 1024 / 1024)"') do set total_ram_gb=%%i

:: Apply minimum (1024MB) and maximum (8192MB) caps
if !half_ram_mb! lss 1024 set half_ram_mb=1024
if !half_ram_mb! gtr 8192 set half_ram_mb=8192

:: Convert to display format
set /a half_ram_gb=!half_ram_mb! / 1024

set jvm_memory=!half_ram_mb!m
echo [OK] Detected !total_ram_gb!GB RAM. Setting Gradle JVM memory to !half_ram_mb!MB ^(!half_ram_gb!GB^) - 50%% of available RAM.

echo Creating gradle.properties...
(
    echo # Project-wide Gradle settings.
    echo # IDE ^(e.g. Android Studio^) users:
    echo # Gradle settings configured through the IDE *will override*
    echo # any settings specified in this file.
    echo # For more details on how to configure your build environment visit
    echo # http://www.gradle.org/docs/current/userguide/build_environment.html
    echo # Specifies the JVM arguments used for the daemon process.
    echo # The setting is particularly useful for tweaking memory settings.
    echo # Memory allocation optimized for !total_ram_gb!GB RAM system
    echo org.gradle.jvmargs=-Xmx!jvm_memory! -Dfile.encoding=UTF-8
    echo # When configured, Gradle will run in incubating parallel mode.
    echo # This option should only be used with decoupled projects. For more details, visit
    echo # https://developer.android.com/r/tools/gradle-multi-project-decoupled-projects
    echo # org.gradle.parallel=true
    echo # AndroidX package structure to make it clearer which packages are bundled with the
    echo # Android operating system, and which are packaged with your app's APK
    echo # https://developer.android.com/topic/libraries/support-library/androidx-rn
    echo android.useAndroidX=true
    echo # Kotlin code style for this project: "official" or "obsolete":
    echo kotlin.code.style=official
    echo # Enables namespacing of each library's R class so that its R class includes only the
    echo # resources declared in the library itself and none from the library's dependencies,
    echo # thereby reducing the size of the R class for that library
    echo android.nonTransitiveRClass=true
) > "!FULL_PROJECT_PATH!\gradle.properties"
goto :eof

:create_gradle_wrapper_properties
echo Creating gradle-wrapper.properties with Gradle !GRADLE_VERSION!...
(
    echo distributionBase=GRADLE_USER_HOME
    echo distributionPath=wrapper/dists
    echo distributionUrl=https\://services.gradle.org/distributions/gradle-!GRADLE_VERSION!-bin.zip
    echo networkTimeout=10000
    echo validateDistributionUrl=true
    echo zipStoreBase=GRADLE_USER_HOME
    echo zipStorePath=wrapper/dists
) > "!FULL_PROJECT_PATH!\gradle\wrapper\gradle-wrapper.properties"
goto :eof

:create_gradlew_bat
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
goto :eof

:download_gradle_wrapper
echo Downloading gradle-wrapper.jar...
powershell -Command "try { Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/gradle/gradle/master/gradle/wrapper/gradle-wrapper.jar' -OutFile '!FULL_PROJECT_PATH!\gradle\wrapper\gradle-wrapper.jar' -UseBasicParsing } catch { Write-Host 'Warning: Failed to download gradle-wrapper.jar' }" 2>nul
goto :eof