# Quick Start Guide

## Choose Your Platform

### Windows Users
```cmd
cd windows
empty-activity.bat
```

### macOS Users
```bash
cd macos
chmod +x empty-activity.sh
./empty-activity.sh
```

### Linux Users
```bash
cd linux
chmod +x empty-activity.sh
./empty-activity.sh
```

## First Time Setup

### 1. Install Java 17 (if not installed)

**Windows:**
```cmd
winget install EclipseAdoptium.Temurin.17.JDK
```

**macOS:**
```bash
brew install openjdk@17
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt install openjdk-17-jdk

# Fedora
sudo dnf install java-17-openjdk-devel

# Arch
sudo pacman -S jdk17-openjdk
```

### 2. Set ANDROID_HOME (if not set)

**Windows:**
```cmd
setx ANDROID_HOME "C:\Users\%USERNAME%\AppData\Local\Android\Sdk"
```

**macOS:**
```bash
echo 'export ANDROID_HOME=$HOME/Library/Android/sdk' >> ~/.zshrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.zshrc
source ~/.zshrc
```

**Linux:**
```bash
echo 'export ANDROID_HOME=$HOME/Android/Sdk' >> ~/.bashrc
echo 'export PATH=$PATH:$ANDROID_HOME/platform-tools' >> ~/.bashrc
source ~/.bashrc
```

## Example: Create Your First Project

### Step 1: Run the script
```bash
./empty-activity.sh
```

### Step 2: Follow the prompts

```
Where to create the project?
Examples:
  ~/Documents/AndroidProjects

Project location [current directory]: ~/Documents/AndroidProjects
```
**Tip for beginners:** Just type `~/Documents/AndroidProjects` and press Enter

```
Application name [InitPrjkt-Apps-Kotlin]: MyFirstApp
```
**Tip:** Use PascalCase (no spaces), e.g., `MyFirstApp`, `TodoApp`, `WeatherApp`

```
Package name [com.example.myapp]: com.myname.myfirstapp
```
**Tip:** Use reverse domain format: `com.yourname.appname` (all lowercase, no spaces)

```
Groovy DSL or Kotlin DSL? [groovy/kotlin, default: kotlin]: 
```
**Tip for beginners:** Just press Enter (use Kotlin DSL, it's recommended)

```
Minimum SDK [24]: 
Target SDK [34]: 
Compile SDK [34]: 
```
**Tip for beginners:** Just press Enter for all (use defaults)

```
Android Gradle Plugin version [8.2.2]: 
Kotlin version [1.9.22]: 
```
**Tip for beginners:** Just press Enter (use defaults)

```
Install/Update SDK components? [y/N]: y
```
**Tip for first time:** Type `y` and press Enter (install required SDK components)

```
Install NDK? [y/N]: n
Install CMake? [y/N]: n
```
**Tip for beginners:** Type `n` (you don't need these for basic apps)

### Step 3: Wait for completion

The script will:
1. Create project structure
2. Generate all necessary files
3. Download Gradle wrapper
4. Install SDK components (if selected)

### Step 4: Build your project

```bash
cd ~/Documents/AndroidProjects/MyFirstApp
./gradlew build
```

### Step 5: Open in Android Studio (optional)

1. Open Android Studio
2. File → Open
3. Navigate to `~/Documents/AndroidProjects/MyFirstApp`
4. Click "Open"
5. Wait for Gradle sync
6. Click Run ▶️

## Common Beginner Mistakes

### ❌ Wrong: Using spaces in names
```
Application name: My First App
Package name: com.my name.app
```

### ✅ Correct: No spaces
```
Application name: MyFirstApp
Package name: com.myname.app
```

### ❌ Wrong: Package name with uppercase
```
Package name: com.MyName.MyApp
```

### ✅ Correct: All lowercase
```
Package name: com.myname.myapp
```

### ❌ Wrong: Invalid path
```
Project location: C:\My Projects\Android
```
(Space in path can cause issues)

### ✅ Correct: No spaces in path
```
Project location: C:\Projects\Android
```

## Tips for Beginners

1. **Project Location**: Create a dedicated folder for all Android projects
   - Windows: `C:\AndroidProjects`
   - macOS/Linux: `~/Documents/AndroidProjects`

2. **Package Name**: Use your domain reversed
   - If you own `example.com`, use `com.example.appname`
   - If no domain, use `com.yourname.appname`

3. **App Name**: Keep it simple and descriptive
   - Good: `TodoApp`, `WeatherApp`, `MyNotes`
   - Avoid: `App1`, `Test`, `MyApp`

4. **SDK Versions**: Use defaults unless you have specific requirements
   - Min SDK 24 = Android 7.0 (covers 95%+ devices)
   - Target SDK 34 = Android 14 (latest)

5. **Build Language**: Use Kotlin DSL (default)
   - Better IDE support
   - Type-safe
   - Recommended by Google

## Next Steps

After creating your project:

1. **Learn the structure**
   - `app/src/main/java/` - Your Kotlin code
   - `app/src/main/res/layout/` - UI layouts
   - `app/src/main/AndroidManifest.xml` - App configuration

2. **Edit MainActivity.kt**
   - This is your app's entry point
   - Start coding here!

3. **Edit activity_main.xml**
   - Design your UI here
   - Drag and drop in Android Studio

4. **Build and run**
   ```bash
   ./gradlew installDebug
   ```

5. **Learn more**
   - [Android Developer Guide](https://developer.android.com/guide)
   - [Kotlin Documentation](https://kotlinlang.org/docs/home.html)

## Need Help?

- Check `README.md` for detailed documentation
- Visit [Android Developer](https://developer.android.com/)
- Join [r/androiddev](https://reddit.com/r/androiddev)
