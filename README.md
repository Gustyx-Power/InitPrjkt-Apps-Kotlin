# InitPrjkt-Apps-Kotlin

Android project generator with interactive CLI. Create Android projects similar to Android Studio wizard, but from command line. Cross-platform support for Windows, macOS, and Linux.

## Project Structure

```
InitPrjkt-Apps-Kotlin/
├── windows/
│   └── empty-activity.bat          # Windows batch script
├── macos/
│   └── empty-activity.sh           # macOS bash script
├── linux/
│   └── empty-activity.sh           # Linux bash script
└── README.md
```

## Features

- 🎯 Interactive CLI with user-friendly prompts
- 📁 Custom project location (choose where to save)
- 🖥️ Cross-platform: Windows, macOS, Linux
- 🔧 Groovy or Kotlin DSL build scripts
- 🤖 Auto-detect Android SDK
- 📦 Optional SDK components installation
- ☕ Java 17 (Temurin) default
- ✅ Complete project structure ready to build

## Requirements

- **Android SDK** installed
- **Java JDK 17+** (Temurin recommended)
- **Windows**: CMD or PowerShell
- **macOS/Linux**: Bash shell

## Usage

### Windows
```cmd
cd windows
empty-activity.bat
```

### macOS
```bash
cd macos
chmod +x empty-activity.sh
./empty-activity.sh
```

### Linux
```bash
cd linux
chmod +x empty-activity.sh
./empty-activity.sh
```

## Interactive Prompts

The script will guide you through:

### 1. Project Location
Where to save your project with examples:

**Windows:**
```
C:\Users\YourName\Documents\AndroidProjects
D:\Projects\Android
%USERPROFILE%\Desktop\MyApps
```

**macOS:**
```
~/Documents/AndroidProjects
~/Desktop/MyApps
/Users/yourname/Projects
```

**Linux:**
```
~/Documents/AndroidProjects
~/Projects/Android
/home/yourname/workspace
```

### 2. Project Configuration
- Application name (default: InitPrjkt-Apps-Kotlin)
- Package name (default: com.example.myapp)
- Build language: Groovy or Kotlin DSL (default: kotlin)
- Minimum SDK (default: 24)
- Target SDK (default: 34)
- Compile SDK (default: 34)
- Android Gradle Plugin version (default: 8.2.2)
- Kotlin version (default: 1.9.22)

### 3. SDK Components (Optional)
- Install/update platform-tools
- Install SDK platform
- Install build-tools
- Install NDK (optional)
- Install CMake (optional)

## Example Session

```
╔════════════════════════════════════════════════════════╗
║   InitPrjkt-Apps-Kotlin                                ║
║   Android Empty Activity Project Generator            ║
╚════════════════════════════════════════════════════════╝

=== Project Configuration ===

Where to create the project?
Examples:
  ~/Documents/AndroidProjects
  ~/Desktop/MyApps
  /Users/yourname/Projects

Project location [current directory]: ~/Documents/AndroidProjects
✓ Project will be created in: /Users/yourname/Documents/AndroidProjects

Application name [InitPrjkt-Apps-Kotlin]: MyAwesomeApp
Package name [com.example.myapp]: com.mycompany.awesome
Groovy DSL or Kotlin DSL? [groovy/kotlin, default: kotlin]: kotlin
Minimum SDK [24]: 24
Target SDK [34]: 34
Compile SDK [34]: 34
Android Gradle Plugin version [8.2.2]: 
Kotlin version [1.9.22]: 
Install/Update SDK components? [y/N]: n

=== Summary ===
Project Name    : MyAwesomeApp
Package         : com.mycompany.awesome
Build Language  : kotlin
Min SDK         : 24
Target SDK      : 34
Compile SDK     : 34

Continue? [Y/n]: y

[OK] Project created successfully!
```

## Build Commands

After project generation:

```bash
# Navigate to project
cd ~/Documents/AndroidProjects/MyAwesomeApp

# Build project
./gradlew build                # Unix/macOS/Linux
gradlew.bat build              # Windows

# Build debug APK
./gradlew assembleDebug

# Install to device/emulator
./gradlew installDebug

# Clean build
./gradlew clean
```

## Generated Project Structure

```
MyAwesomeApp/
├── app/
│   ├── src/main/
│   │   ├── java/com/mycompany/awesome/
│   │   │   └── MainActivity.kt
│   │   ├── res/
│   │   │   ├── layout/activity_main.xml
│   │   │   ├── values/strings.xml
│   │   │   └── values/colors.xml
│   │   └── AndroidManifest.xml
│   ├── build.gradle.kts
│   └── proguard-rules.pro
├── gradle/wrapper/
├── build.gradle.kts
├── settings.gradle.kts
├── gradle.properties
├── local.properties
├── gradlew
├── gradlew.bat
└── .gitignore
```

## Troubleshooting

### Android SDK not found

Set environment variable:

**Windows:**
```cmd
setx ANDROID_HOME "C:\Users\YourName\AppData\Local\Android\Sdk"
```

**macOS:**
```bash
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
source ~/.zshrc
```

**Linux:**
```bash
echo 'export ANDROID_HOME=$HOME/Android/Sdk' >> ~/.bashrc
source ~/.bashrc
```

### Java 17 not found

Install Java 17 (Temurin):

**Windows:**
- Download from [Adoptium](https://adoptium.net/)
- Or use: `winget install EclipseAdoptium.Temurin.17.JDK`

**macOS:**
```bash
brew install openjdk@17
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install openjdk-17-jdk
```

**Linux (Fedora):**
```bash
sudo dnf install java-17-openjdk-devel
```

### Permission denied (macOS/Linux)

```bash
chmod +x empty-activity.sh
chmod +x gradlew
```

## Supported Activity Types

Currently available:
- ✅ Empty Activity

Coming soon:
- 🔜 Basic Activity
- 🔜 Bottom Navigation Activity
- 🔜 Fragment + ViewModel
- 🔜 Compose Activity

## License

Free to use and modify.

## Contributing

Feel free to submit issues or pull requests!
