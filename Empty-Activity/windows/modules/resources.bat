@echo off
setlocal enabledelayedexpansion
:: Resources Module
:: Handles Android resource files creation

:: Route to specific label if passed as argument
if not "%~1"=="" goto %~1

:create_activity_main_xml
if /i "!USE_COMPOSE!"=="n" (
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
)
goto :eof

:create_strings_xml
echo Creating strings.xml...
(
    echo ^<resources^>
    echo     ^<string name="app_name"^>!PROJECT_NAME!^</string^>
    echo ^</resources^>
) > "!FULL_PROJECT_PATH!\app\src\main\res\values\strings.xml"
goto :eof

:create_colors_xml
echo Creating colors.xml...
(
    echo ^<?xml version="1.0" encoding="utf-8"?^>
    echo ^<resources^>
    echo     ^<color name="purple_200"^>#FFBB86FC^</color^>
    echo     ^<color name="purple_500"^>#FF6200EE^</color^>
    echo     ^<color name="purple_700"^>#FF3700B3^</color^>
    echo     ^<color name="teal_200"^>#FF03DAC5^</color^>
    echo     ^<color name="teal_700"^>#FF018786^</color^>
    echo     ^<color name="black"^>#FF000000^</color^>
    echo     ^<color name="white"^>#FFFFFFFF^</color^>
    echo ^</resources^>
) > "!FULL_PROJECT_PATH!\app\src\main\res\values\colors.xml"
goto :eof

:create_themes_xml
echo Creating themes.xml...
if /i "!USE_COMPOSE!"=="y" (
    (
        echo ^<?xml version="1.0" encoding="utf-8"?^>
        echo ^<resources^>
        echo     ^<style name="Theme.!PROJECT_NAME!" parent="android:Theme.Material.Light.NoActionBar" /^>
        echo ^</resources^>
    ) > "!FULL_PROJECT_PATH!\app\src\main\res\values\themes.xml"
) else (
    (
        echo ^<?xml version="1.0" encoding="utf-8"?^>
        echo ^<resources^>
        echo     ^<style name="Theme.!PROJECT_NAME!" parent="Theme.AppCompat.Light.DarkActionBar"^>
        echo         ^<item name="colorPrimary"^>@color/purple_500^</item^>
        echo         ^<item name="colorPrimaryVariant"^>@color/purple_700^</item^>
        echo         ^<item name="colorOnPrimary"^>@color/white^</item^>
        echo         ^<item name="colorSecondary"^>@color/teal_200^</item^>
        echo         ^<item name="colorSecondaryVariant"^>@color/teal_700^</item^>
        echo         ^<item name="colorOnSecondary"^>@color/black^</item^>
        echo     ^</style^>
        echo ^</resources^>
    ) > "!FULL_PROJECT_PATH!\app\src\main\res\values\themes.xml"
)
goto :eof

:create_backup_rules_xml
echo Creating backup_rules.xml...
(
    echo ^<?xml version="1.0" encoding="utf-8"?^>
    echo ^<!--
    echo    Sample backup rules file; uncomment and customize as necessary.
    echo    See https://developer.android.com/guide/topics/data/autobackup
    echo    for details.
    echo    Note: This file is ignored for devices older than API 31
    echo    See https://developer.android.com/about/versions/12/backup-restore
    echo --^>
    echo ^<full-backup-content^>
    echo     ^<!--
    echo    ^<include domain="sharedpref" path="."/^>
    echo    ^<exclude domain="sharedpref" path="device.xml"/^>
    echo --^>
    echo ^</full-backup-content^>
) > "!FULL_PROJECT_PATH!\app\src\main\res\xml\backup_rules.xml"
goto :eof

:create_data_extraction_rules_xml
echo Creating data_extraction_rules.xml...
(
    echo ^<?xml version="1.0" encoding="utf-8"?^>
    echo ^<!--
    echo    Sample data extraction rules file; uncomment and customize as necessary.
    echo    See https://developer.android.com/about/versions/12/backup-restore#xml-changes
    echo    for details.
    echo --^>
    echo ^<data-extraction-rules^>
    echo     ^<cloud-backup^>
    echo         ^<!-- TODO: Use ^<include^> and ^<exclude^> to control what is backed up.
    echo         ^<include .../^>
    echo         ^<exclude .../^>
    echo         --^>
    echo     ^</cloud-backup^>
    echo     ^<!--
    echo     ^<device-transfer^>
    echo         ^<include .../^>
    echo         ^<exclude .../^>
    echo     ^</device-transfer^>
    echo     --^>
    echo ^</data-extraction-rules^>
) > "!FULL_PROJECT_PATH!\app\src\main\res\xml\data_extraction_rules.xml"
goto :eof