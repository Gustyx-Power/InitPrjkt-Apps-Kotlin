# PowerShell Bridge for Batch Modules
# This script acts as a bridge to share environment variables between batch modules

param(
    [string]$ModulePath
)

# Execute all batch modules in sequence with shared environment
$exitCode = 0

# 3. Detect Android SDK
& cmd /c "`"$ModulePath\sdk.bat`" :detect_sdk"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# 4. Check if project exists
& cmd /c "`"$ModulePath\structure.bat`" :check_project_exists"
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

# 5. Create folder structure
& cmd /c "`"$ModulePath\structure.bat`" :create_folder_structure"

# 6. Install SDK components
& cmd /c "`"$ModulePath\sdk.bat`" :install_sdk_components"

# 7. Create Gradle files
Write-Host ""
Write-Host "Creating Gradle configuration files..."
& cmd /c "`"$ModulePath\gradle.bat`" :create_libs_versions_toml"
& cmd /c "`"$ModulePath\gradle.bat`" :create_local_properties"
& cmd /c "`"$ModulePath\gradle.bat`" :create_settings_gradle"
& cmd /c "`"$ModulePath\gradle.bat`" :create_root_build_gradle"
& cmd /c "`"$ModulePath\gradle.bat`" :create_gradle_properties"
& cmd /c "`"$ModulePath\gradle.bat`" :create_gradle_wrapper_properties"
& cmd /c "`"$ModulePath\gradle.bat`" :create_gradlew_bat"
& cmd /c "`"$ModulePath\gradle.bat`" :download_gradle_wrapper"

# 8. Create Android files
Write-Host ""
& cmd /c "`"$ModulePath\android.bat`" :create_app_build_gradle"
& cmd /c "`"$ModulePath\android.bat`" :create_android_files"

# 9. Create source files
Write-Host ""
& cmd /c "`"$ModulePath\source.bat`" :create_source_files"

# 10. Post-processing
& cmd /c "`"$ModulePath\postprocess.bat`" :project_indexing"
& cmd /c "`"$ModulePath\postprocess.bat`" :gradle_sync"
& cmd /c "`"$ModulePath\postprocess.bat`" :test_build"

# 11. Done
& cmd /c "`"$ModulePath\postprocess.bat`" :open_project_suggestion"

exit 0
