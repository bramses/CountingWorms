# Counting Worms - Setup Guide

## Overview
Counting Worms is a calorie tracking app that uses AI to analyze food photos and estimate calories. It includes home screen and lock screen widgets for quick access.

## Setup Steps

### 1. Configure Info.plist for Camera Access
Add the following to your Info.plist:
```xml
<key>NSCameraUsageDescription</key>
<string>We need camera access to take photos of your food for calorie estimation</string>
```

### 2. Configure URL Scheme for Deep Linking
In Xcode:
1. Select your project in the navigator
2. Select the "CountingWorms" target
3. Go to the "Info" tab
4. Expand "URL Types"
5. Click "+" to add a new URL Type
6. Set:
   - Identifier: `com.bramadams.countingworms`
   - URL Schemes: `countingworms`

### 3. Set Up App Groups (Required for Widgets)
The app uses App Groups to share data between the main app and widgets.

1. Select your project in the navigator
2. Select the "CountingWorms" target
3. Go to "Signing & Capabilities"
4. Click "+ Capability" and add "App Groups"
5. Click "+" under App Groups and create: `group.com.bramadams.countingworms`
6. Make sure the checkbox is checked

**Important:** Update the App Group ID in `SharedDataManager.swift` (line 18) to match your App Group.

### 4. Create Widget Extension
To enable widgets:

1. In Xcode, go to File → New → Target
2. Select "Widget Extension"
3. Name it "CountingWormsWidget"
4. Uncheck "Include Configuration Intent"
5. Click Finish

6. **Move these files from the main app to the Widget Extension target:**
   - `CountingWorms/Widget/CountingWormsWidget.swift`
   - `CountingWorms/Widget/LockScreenWidget.swift`

7. **Share these files with both targets** (main app AND widget):
   - `CountingWorms/Models/SharedDataManager.swift`
   - Select the file in Xcode
   - In the File Inspector (right panel), check both "CountingWorms" and "CountingWormsWidget" under Target Membership

8. **In `LockScreenWidget.swift`**, uncomment the `@main` attribute (line 126):
   ```swift
   @main
   struct CountingWormsWidgetBundle: WidgetBundle {
   ```

9. **Configure Widget Extension Capabilities:**
   - Select the "CountingWormsWidget" target
   - Go to "Signing & Capabilities"
   - Add "App Groups" capability
   - Select the same App Group: `group.com.bramadams.countingworms`

### 5. Get an API Key
Choose one of these AI providers and get an API key:

**Option 1: OpenAI**
- Go to https://platform.openai.com/
- Sign up and create an API key
- You'll need GPT-4 Vision access (gpt-4o model)

**Option 2: Anthropic Claude**
- Go to https://console.anthropic.com/
- Sign up and create an API key
- You'll need Claude 3.5 Sonnet access

### 6. Configure the App
When you first run the app:
1. Tap the gear icon (⚙️) in the top right
2. Enter your daily calorie target (e.g., 2000)
3. Set your day reset time (when your calorie count resets)
4. Select your AI provider (OpenAI or Claude)
5. Enter your API key
6. Tap "Save"

## Features

### Main App
- **Home Screen**: Shows remaining calories with color-coded display (green/orange/red)
- **Camera**: Tap "Log Food" to take a photo of your food
- **AI Analysis**: The app sends the photo to your chosen AI provider to estimate calories
- **Food Log**: View all your meals for the day with images and descriptions

### Home Screen Widgets
Three sizes available:
- **Small**: Shows remaining calories
- **Medium**: Shows remaining calories plus consumed/target
- **Large**: Full dashboard with all stats

### Lock Screen Widgets
Three styles available:
- **Circular**: Compact circular widget
- **Rectangular**: More detailed horizontal widget
- **Inline**: Shows in the lock screen date area

### Widget Features
- All widgets are tappable and open the camera automatically
- Widgets update every 15 minutes
- Widgets show real-time calorie data from your daily intake

## Usage Tips

1. **Daily Reset**: The app automatically resets your calorie count at your configured time each day
2. **Widget Updates**: After logging food, widgets update automatically
3. **Privacy**: All photos are stored locally on your device
4. **API Costs**: Be aware that API calls to OpenAI or Claude have costs associated
5. **Accuracy**: AI calorie estimates are approximate - for precise tracking, verify with nutrition labels

## Troubleshooting

### Widgets Not Showing Data
- Make sure App Groups are configured correctly in both targets
- Check that the App Group ID matches in `SharedDataManager.swift`
- Log at least one food item to populate widget data

### Camera Not Opening
- Check that camera permissions are granted in Settings → CountingWorms
- Verify the URL scheme is configured correctly

### AI Analysis Failing
- Verify your API key is correct
- Check that you have credits/quota remaining with your AI provider
- Ensure you have internet connectivity

## Project Structure

```
CountingWorms/
├── CountingWorms/
│   ├── Models/
│   │   ├── FoodEntry.swift          # SwiftData model for food entries
│   │   ├── UserSettings.swift       # SwiftData model for user preferences
│   │   ├── CalorieManager.swift     # Core calorie tracking logic
│   │   └── SharedDataManager.swift  # Shared data for widgets
│   ├── Views/
│   │   ├── HomeView.swift           # Main screen
│   │   ├── CameraView.swift         # Camera interface
│   │   ├── SettingsView.swift       # Settings screen
│   │   └── FoodLogView.swift        # Daily food log
│   ├── Services/
│   │   └── AIService.swift          # OpenAI & Claude integration
│   └── Widget/
│       ├── CountingWormsWidget.swift    # Home screen widgets
│       └── LockScreenWidget.swift       # Lock screen widgets
```

## Privacy & Security

- API keys are stored locally using UserDefaults (within App Group)
- Photos are stored locally in SwiftData
- No data is sent anywhere except to your chosen AI provider for analysis
- Consider the privacy policies of OpenAI or Anthropic when using their APIs

## Future Enhancements

Potential features to add:
- Export food log to CSV
- Add manual calorie entry (without photo)
- Weekly/monthly statistics
- HealthKit integration for exercise tracking
- Multiple meal categories (breakfast, lunch, dinner, snacks)
- Favorite foods quick-add
- Barcode scanning for packaged foods
