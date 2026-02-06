# Final Setup Steps for Counting Worms

## ✅ Completed
- Main app implementation with SwiftData
- Camera integration
- AI service (OpenAI and Claude support)
- Home screen widgets (Small, Medium, Large)
- Lock screen widgets (Circular, Rectangular, Inline)
- Widget Extension created and configured
- Deep linking from widgets to camera
- Shared data manager for app-widget communication

## 🔧 Remaining Configuration Steps

### 1. Add Camera Permission to Info.plist

The app needs camera access permissions. Add this to your project:

1. In Xcode, select your **CountingWorms** project in the navigator
2. Select the **CountingWorms** target (not the widget extension)
3. Go to the **Info** tab
4. Click the **+** button to add a new key
5. Add:
   - **Key**: `Privacy - Camera Usage Description` (NSCameraUsageDescription)
   - **Value**: `We need camera access to take photos of your food for calorie estimation`

### 2. Configure URL Scheme (for Widget Deep Linking)

This allows widgets to open the camera when tapped:

1. Select your project in the navigator
2. Select the **CountingWorms** target
3. Go to the **Info** tab
4. Expand **URL Types** section (or add it if not present)
5. Click **+** to add a new URL Type
6. Set:
   - **Identifier**: `com.bramadams.countingworms`
   - **URL Schemes**: `countingworms`
   - **Role**: Editor

### 3. Set Up App Groups (CRITICAL for Widgets)

App Groups allow the main app and widgets to share data:

**For Main App:**
1. Select your project in the navigator
2. Select the **CountingWorms** target
3. Go to **Signing & Capabilities** tab
4. Click **+ Capability**
5. Add **App Groups**
6. Click **+** under App Groups
7. Create: `group.com.bramadams.countingworms`
8. Ensure the checkbox is checked

**For Widget Extension:**
1. Select the **CountingWormsWidgetExtension** target
2. Go to **Signing & Capabilities** tab
3. Click **+ Capability**
4. Add **App Groups**
5. Select the **same** App Group: `group.com.bramadams.countingworms`
6. Ensure the checkbox is checked

**Important:** If you use a different App Group ID, update it in:
- `CountingWorms/CountingWorms/Models/SharedDataManager.swift` (line 23)
- `CountingWormsWidget​Extension/SharedDataManager.swift` (line 23)

### 4. Get an API Key

Choose one provider:

**Option A: OpenAI**
- Go to: https://platform.openai.com/api-keys
- Sign up and create an API key
- You'll need GPT-4o (Vision) access
- Note: Costs approximately $0.01-0.03 per image analysis

**Option B: Anthropic Claude**
- Go to: https://console.anthropic.com/
- Sign up and create an API key
- You'll need Claude 3.5 Sonnet access
- Note: Costs approximately $0.01-0.02 per image analysis

### 5. Configure the App on First Launch

1. Run the app on your device or simulator
2. Tap the **gear icon (⚙️)** in the top right corner
3. Enter your settings:
   - **Daily Calorie Target**: Your target (e.g., 2000)
   - **Reset Hour**: When your day starts (e.g., 12:00 AM or 4:00 AM)
   - **AI Provider**: Select OpenAI or Claude
   - **API Key**: Paste your API key
4. Tap **Save**

### 6. Add Widgets to Home Screen

1. Long-press on your home screen
2. Tap the **+** button (top left)
3. Search for **"Counting Worms"**
4. Choose widget size:
   - **Small**: Just remaining calories
   - **Medium**: Calories + consumed/target stats
   - **Large**: Full dashboard
5. Add to home screen
6. Tap the widget to open camera

### 7. Add Widgets to Lock Screen (iOS 16+)

1. Lock your device
2. Long-press on the lock screen
3. Tap **Customize**
4. Tap on the widget areas
5. Search for **"Counting Worms"**
6. Choose widget style:
   - **Circular**: Compact round widget
   - **Rectangular**: Horizontal detailed view
   - **Inline**: In the date area
7. Tap **Done**

## 📱 Using the App

### Logging Food
1. Open the app OR tap any widget
2. Tap **"Log Food"** button
3. Take a photo of your food
4. Wait for AI analysis (5-10 seconds)
5. Food is automatically logged with calories

### Viewing History
1. Tap **"View Today's Log"** on home screen
2. Scroll through all meals for the day
3. See photos, descriptions, and calories

### Adjusting Settings
1. Tap the gear icon (⚙️)
2. Change daily target, reset time, or API key
3. Tap **Save**

## 🔍 Troubleshooting

### Camera Doesn't Open
- Check camera permissions: Settings → CountingWorms → Camera
- Verify the URL scheme is configured correctly

### Widgets Show No Data
- Log at least one meal to populate widget data
- Check App Groups are configured in both targets
- Verify App Group ID matches in SharedDataManager.swift files
- Try removing and re-adding the widget

### AI Analysis Fails
- Verify your API key is correct
- Check internet connection
- Verify you have API credits remaining
- Check API provider status page

### Widgets Don't Update
- Widgets update every 15 minutes automatically
- Force refresh by logging new food
- Try removing and re-adding widget

## 🎨 Features Overview

### Main App
- **Large calorie display** with color coding (green/orange/red)
- **Camera integration** for food photos
- **AI-powered calorie estimation**
- **Daily food log** with images
- **Configurable settings**
- **Custom day reset times**

### Home Screen Widgets
- **Real-time calorie tracking**
- **3 sizes** to choose from
- **Tap to open camera**
- **Auto-refresh every 15 minutes**

### Lock Screen Widgets
- **Quick glance** at remaining calories
- **3 styles** (circular, rectangular, inline)
- **Tap to open camera**
- **Always accessible**

## 🔐 Privacy & Data

- All photos stored **locally** on device
- API keys stored **locally** in UserDefaults
- No data sent anywhere except to your chosen AI provider
- Photos only sent to AI for analysis
- No user tracking or analytics

## 💡 Tips

1. **Take clear photos** - Better lighting = better estimates
2. **Include full plate** - AI needs to see all food
3. **Daily reset time** - Set to when you wake up
4. **Check estimates** - AI is approximate, verify with nutrition labels
5. **Monitor API costs** - Each photo analysis costs a few cents

## 🚀 Next Steps (Optional Enhancements)

Future features you could add:
- Manual calorie entry (without photo)
- Weekly/monthly statistics
- HealthKit integration
- Meal categories (breakfast/lunch/dinner)
- Favorite foods quick-add
- Barcode scanner
- Export data to CSV
- Multiple users/profiles

---

**Project Successfully Built! ✅**

The app is ready to use once you complete the configuration steps above.
