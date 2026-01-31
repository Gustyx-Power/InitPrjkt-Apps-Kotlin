@echo off
setlocal enabledelayedexpansion
:: Source Module
:: Handles source code and resource files creation

:: Route to specific label if passed as argument
if not "%~1"=="" goto %~1

:create_source_files
echo Creating source files...
call :create_main_activity
call :create_compose_theme_files
call :create_test_files
call :create_resource_files
goto :eof

:create_main_activity
echo Creating MainActivity.kt...
if /i "!USE_COMPOSE!"=="y" (
    call :create_compose_main_activity
) else (
    call :create_view_main_activity
)
goto :eof

:create_compose_main_activity
(
    echo package !PACKAGE!
    echo.
    echo import android.os.Bundle
    echo import androidx.activity.ComponentActivity
    echo import androidx.activity.compose.setContent
    echo import androidx.activity.enableEdgeToEdge
    echo import androidx.compose.foundation.layout.fillMaxSize
    echo import androidx.compose.foundation.layout.padding
    echo import androidx.compose.material3.Scaffold
    echo import androidx.compose.material3.Text
    echo import androidx.compose.runtime.Composable
    echo import androidx.compose.ui.Modifier
    echo import androidx.compose.ui.tooling.preview.Preview
    echo import !PACKAGE!.ui.theme.!PROJECT_NAME!Theme
    echo.
    echo class MainActivity : ComponentActivity^(^) {
    echo     override fun onCreate^(savedInstanceState: Bundle?^) {
    echo         super.onCreate^(savedInstanceState^)
    echo         enableEdgeToEdge^(^)
    echo         setContent {
    echo             !PROJECT_NAME!Theme {
    echo                 Scaffold^(modifier = Modifier.fillMaxSize^(^)^) { innerPadding -^>
    echo                     Greeting^(
    echo                         name = "Android",
    echo                         modifier = Modifier.padding^(innerPadding^)
    echo                     ^)
    echo                 }
    echo             }
    echo         }
    echo     }
    echo }
    echo.
    echo @Composable
    echo fun Greeting^(name: String, modifier: Modifier = Modifier^) {
    echo     Text^(
    echo         text = "Hello $name!",
    echo         modifier = modifier
    echo     ^)
    echo }
    echo.
    echo @Preview^(showBackground = true^)
    echo @Composable
    echo fun GreetingPreview^(^) {
    echo     !PROJECT_NAME!Theme {
    echo         Greeting^("Android"^)
    echo     }
    echo }
) > "!FULL_PROJECT_PATH!\app\src\main\java\!PACKAGE_PATH!\MainActivity.kt"
goto :eof

:create_view_main_activity
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
goto :eof

:create_compose_theme_files
if /i "!USE_COMPOSE!"=="y" (
    echo Creating Compose theme files...
    call :create_color_kt
    call :create_type_kt
    call :create_theme_kt
)
goto :eof

:create_color_kt
(
    echo package !PACKAGE!.ui.theme
    echo.
    echo import androidx.compose.ui.graphics.Color
    echo.
    echo val Purple80 = Color^(0xFFD0BCFF^)
    echo val PurpleGrey80 = Color^(0xFFCCC2DC^)
    echo val Pink80 = Color^(0xFFEFB8C8^)
    echo.
    echo val Purple40 = Color^(0xFF6650a4^)
    echo val PurpleGrey40 = Color^(0xFF625b71^)
    echo val Pink40 = Color^(0xFF7D5260^)
) > "!FULL_PROJECT_PATH!\app\src\main\java\!PACKAGE_PATH!\ui\theme\Color.kt"
goto :eof

:create_type_kt
(
    echo package !PACKAGE!.ui.theme
    echo.
    echo import androidx.compose.material3.Typography
    echo import androidx.compose.ui.text.TextStyle
    echo import androidx.compose.ui.text.font.FontFamily
    echo import androidx.compose.ui.text.font.FontWeight
    echo import androidx.compose.ui.unit.sp
    echo.
    echo // Set of Material typography styles to start with
    echo val Typography = Typography^(
    echo     bodyLarge = TextStyle^(
    echo         fontFamily = FontFamily.Default,
    echo         fontWeight = FontWeight.Normal,
    echo         fontSize = 16.sp,
    echo         lineHeight = 24.sp,
    echo         letterSpacing = 0.5.sp
    echo     ^)
    echo ^)
) > "!FULL_PROJECT_PATH!\app\src\main\java\!PACKAGE_PATH!\ui\theme\Type.kt"
goto :eof

:create_theme_kt
(
    echo package !PACKAGE!.ui.theme
    echo.
    echo import android.app.Activity
    echo import android.os.Build
    echo import androidx.compose.foundation.isSystemInDarkTheme
    echo import androidx.compose.material3.MaterialTheme
    echo import androidx.compose.material3.darkColorScheme
    echo import androidx.compose.material3.dynamicDarkColorScheme
    echo import androidx.compose.material3.dynamicLightColorScheme
    echo import androidx.compose.material3.lightColorScheme
    echo import androidx.compose.runtime.Composable
    echo import androidx.compose.ui.platform.LocalContext
    echo.
    echo private val DarkColorScheme = darkColorScheme^(
    echo     primary = Purple80,
    echo     secondary = PurpleGrey80,
    echo     tertiary = Pink80
    echo ^)
    echo.
    echo private val LightColorScheme = lightColorScheme^(
    echo     primary = Purple40,
    echo     secondary = PurpleGrey40,
    echo     tertiary = Pink40
    echo ^)
    echo.
    echo @Composable
    echo fun !PROJECT_NAME!Theme^(
    echo     darkTheme: Boolean = isSystemInDarkTheme^(^),
    echo     dynamicColor: Boolean = true,
    echo     content: @Composable ^(^) -^> Unit
    echo ^) {
    echo     val colorScheme = when {
    echo         dynamicColor ^&^& Build.VERSION.SDK_INT ^>= Build.VERSION_CODES.S -^> {
    echo             val context = LocalContext.current
    echo             if ^(darkTheme^) dynamicDarkColorScheme^(context^) else dynamicLightColorScheme^(context^)
    echo         }
    echo         darkTheme -^> DarkColorScheme
    echo         else -^> LightColorScheme
    echo     }
    echo.
    echo     MaterialTheme^(
    echo         colorScheme = colorScheme,
    echo         typography = Typography,
    echo         content = content
    echo     ^)
    echo }
) > "!FULL_PROJECT_PATH!\app\src\main\java\!PACKAGE_PATH!\ui\theme\Theme.kt"
goto :eof

:create_test_files
echo Creating test files...

:: ExampleUnitTest.kt
(
    echo package !PACKAGE!
    echo.
    echo import org.junit.Test
    echo import org.junit.Assert.*
    echo.
    echo class ExampleUnitTest {
    echo     @Test
    echo     fun addition_isCorrect^(^) {
    echo         assertEquals^(4, 2 + 2^)
    echo     }
    echo }
) > "!FULL_PROJECT_PATH!\app\src\test\java\!PACKAGE_PATH!\ExampleUnitTest.kt"

:: ExampleInstrumentedTest.kt
(
    echo package !PACKAGE!
    echo.
    echo import androidx.test.platform.app.InstrumentationRegistry
    echo import androidx.test.ext.junit.runners.AndroidJUnit4
    echo import org.junit.Test
    echo import org.junit.runner.RunWith
    echo import org.junit.Assert.*
    echo.
    echo @RunWith^(AndroidJUnit4::class^)
    echo class ExampleInstrumentedTest {
    echo     @Test
    echo     fun useAppContext^(^) {
    echo         val appContext = InstrumentationRegistry.getInstrumentation^(^).targetContext
    echo         assertEquals^("!PACKAGE!", appContext.packageName^)
    echo     }
    echo }
) > "!FULL_PROJECT_PATH!\app\src\androidTest\java\!PACKAGE_PATH!\ExampleInstrumentedTest.kt"
goto :eof

:create_resource_files
echo Creating resource files...
:: Call resource functions from resources.bat
if /i "!USE_COMPOSE!"=="n" (
    call :create_activity_main_xml_internal
)
call :create_strings_xml_internal
call :create_colors_xml_internal
call :create_themes_xml_internal
call :create_backup_rules_xml_internal
call :create_data_extraction_rules_xml_internal
call :create_drawable_resources
call :create_mipmap_resources
goto :eof

:create_activity_main_xml_internal
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
goto :eof

:create_strings_xml_internal
echo Creating strings.xml...
(
    echo ^<resources^>
    echo     ^<string name="app_name"^>!PROJECT_NAME!^</string^>
    echo ^</resources^>
) > "!FULL_PROJECT_PATH!\app\src\main\res\values\strings.xml"
goto :eof

:create_colors_xml_internal
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

:create_themes_xml_internal
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

:create_backup_rules_xml_internal
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

:create_data_extraction_rules_xml_internal
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

:create_drawable_resources
echo Creating drawable resources...
:: ic_launcher_background.xml
(
    echo ^<?xml version="1.0" encoding="utf-8"?^>
    echo ^<vector xmlns:android="http://schemas.android.com/apk/res/android"
    echo     android:width="108dp"
    echo     android:height="108dp"
    echo     android:viewportWidth="108"
    echo     android:viewportHeight="108"^>
    echo     ^<path
    echo         android:fillColor="#3DDC84"
    echo         android:pathData="M0,0h108v108h-108z" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M9,0L9,108"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M19,0L19,108"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M29,0L29,108"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M39,0L39,108"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M49,0L49,108"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M59,0L59,108"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M69,0L69,108"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M79,0L79,108"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M89,0L89,108"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M99,0L99,108"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M0,9L108,9"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M0,19L108,19"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M0,29L108,29"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M0,39L108,39"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M0,49L108,49"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M0,59L108,59"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M0,69L108,69"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M0,79L108,79"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M0,89L108,89"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M0,99L108,99"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M19,29L89,29"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M19,39L89,39"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M19,49L89,49"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M19,59L89,59"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M19,69L89,69"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M19,79L89,79"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M29,19L29,89"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M39,19L39,89"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M49,19L49,89"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M59,19L59,89"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M69,19L69,89"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo     ^<path
    echo         android:fillColor="#00000000"
    echo         android:pathData="M79,19L79,89"
    echo         android:strokeWidth="0.8"
    echo         android:strokeColor="#33FFFFFF" /^>
    echo ^</vector^>
) > "!FULL_PROJECT_PATH!\app\src\main\res\drawable\ic_launcher_background.xml"

:: ic_launcher_foreground.xml
(
    echo ^<vector xmlns:android="http://schemas.android.com/apk/res/android"
    echo     xmlns:aapt="http://schemas.android.com/aapt"
    echo     android:width="108dp"
    echo     android:height="108dp"
    echo     android:viewportWidth="108"
    echo     android:viewportHeight="108"^>
    echo     ^<path android:pathData="M31,63.928c0,0 6.4,-11 12.1,-13.1c7.2,-2.6 26,-1.4 26,-1.4l38.1,38.1L107,108.928l-32,-1L31,63.928z"^>
    echo         ^<aapt:attr name="android:fillColor"^>
    echo             ^<gradient
    echo                 android:endX="85.84757"
    echo                 android:endY="92.4963"
    echo                 android:startX="42.9492"
    echo                 android:startY="49.59793"
    echo                 android:type="linear"^>
    echo                 ^<item
    echo                     android:color="#44000000"
    echo                     android:offset="0.0" /^>
    echo                 ^<item
    echo                     android:color="#00000000"
    echo                     android:offset="1.0" /^>
    echo             ^</gradient^>
    echo         ^</aapt:attr^>
    echo     ^</path^>
    echo     ^<path
    echo         android:fillColor="#FFFFFF"
    echo         android:fillType="nonZero"
    echo         android:pathData="M65.3,45.828l3.8,-6.6c0.2,-0.4 0.1,-0.9 -0.3,-1.1c-0.4,-0.2 -0.9,-0.1 -1.1,0.3l-3.9,6.7c-6.3,-2.8 -13.4,-2.8 -19.7,0l-3.9,-6.7c-0.2,-0.4 -0.7,-0.5 -1.1,-0.3C38.8,38.328 38.7,38.828 38.9,39.228l3.8,6.6C36.2,49.428 31.7,56.028 31,63.928h46C76.3,56.028 71.8,49.428 65.3,45.828zM43.4,57.328c-0.8,0 -1.5,-0.5 -1.8,-1.2c-0.3,-0.7 -0.1,-1.5 0.4,-2.1c0.5,-0.5 1.4,-0.7 2.1,-0.4c0.7,0.3 1.2,1 1.2,1.8C45.3,56.528 44.5,57.328 43.4,57.328L43.4,57.328zM64.6,57.328c-0.8,0 -1.5,-0.5 -1.8,-1.2s-0.1,-1.5 0.4,-2.1c0.5,-0.5 1.4,-0.7 2.1,-0.4c0.7,0.3 1.2,1 1.2,1.8C66.5,56.528 65.6,57.328 64.6,57.328L64.6,57.328z"
    echo         android:strokeWidth="1"
    echo         android:strokeColor="#00000000" /^>
    echo ^</vector^>
) > "!FULL_PROJECT_PATH!\app\src\main\res\drawable-v24\ic_launcher_foreground.xml"
goto :eof

:create_mipmap_resources
echo Creating mipmap resources...
:: ic_launcher.xml
(
    echo ^<?xml version="1.0" encoding="utf-8"?^>
    echo ^<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android"^>
    echo     ^<background android:drawable="@drawable/ic_launcher_background" /^>
    echo     ^<foreground android:drawable="@drawable/ic_launcher_foreground" /^>
    echo     ^<monochrome android:drawable="@drawable/ic_launcher_foreground" /^>
    echo ^</adaptive-icon^>
) > "!FULL_PROJECT_PATH!\app\src\main\res\mipmap-anydpi-v26\ic_launcher.xml"

:: ic_launcher_round.xml
(
    echo ^<?xml version="1.0" encoding="utf-8"?^>
    echo ^<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android"^>
    echo     ^<background android:drawable="@drawable/ic_launcher_background" /^>
    echo     ^<foreground android:drawable="@drawable/ic_launcher_foreground" /^>
    echo     ^<monochrome android:drawable="@drawable/ic_launcher_foreground" /^>
    echo ^</adaptive-icon^>
) > "!FULL_PROJECT_PATH!\app\src\main\res\mipmap-anydpi-v26\ic_launcher_round.xml"

:: Create placeholder webp files
echo Creating placeholder launcher icons...
for %%d in (hdpi mdpi xhdpi xxhdpi xxxhdpi) do (
    echo. > "!FULL_PROJECT_PATH!\app\src\main\res\mipmap-%%d\ic_launcher.webp"
    echo. > "!FULL_PROJECT_PATH!\app\src\main\res\mipmap-%%d\ic_launcher_round.webp"
)
echo [WARNING] Placeholder launcher icons created. Replace with actual icons for production.
goto :eof