# Counting Worms

A heavy metal-themed iOS calorie tracking app with AI-powered food recognition. Named after the Knocked Loose song "Counting Worms."

[*"The results have a reasonable level of accuracy, with energy values having the highest level of conformity: 97% of the artificial intelligence values fall within a 40% difference from United States Department of Agriculture data."*](https://www.sciencedirect.com/science/article/abs/pii/S0899900723003532)

![Platform](https://img.shields.io/badge/platform-iOS%2017.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/license-MIT-green)

<p>
  <img src="https://github.com/user-attachments/assets/1f28d37d-e527-4ea4-beed-2e5622f6d62c" width="180" />
  <img src="https://github.com/user-attachments/assets/1404140c-9969-4113-b9ad-c30a5b519286" width="180" />
  <img src="https://github.com/user-attachments/assets/5402f96e-c8c6-4c1e-a1be-7a126e8d8a13" width="180" />
  <img src="https://github.com/user-attachments/assets/eb0cdf52-32b7-45c7-a374-d57058baa5ad" width="180" />
</p>



## Features

### Core Functionality
- **AI Food Recognition**: Take photos of your meals and get instant calorie estimates using OpenAI GPT-4o or Claude 3.5 Sonnet
- **Smart Calorie Tracking**: Automatic deduction from your daily calorie target
- **Custom Day Reset**: Configure when your calorie day resets (not just midnight)
- **Serving Adjustment**: One-serving default with +/- buttons to multiply servings
- **Manual Editing**: Edit calorie values manually for accuracy
- **Food Log**: Visual history of all meals with images, descriptions, and calorie counts

### Widgets
- **Home Screen Widgets**: Small, medium, and large widgets showing remaining calories
- **Lock Screen Widgets**: Circular, rectangular, and inline formats for quick glances
- **Deep Linking**: Tap any widget to instantly open the camera and log food

### Design
Heavy metal aesthetic inspired by Knocked Loose's "Counting Worms":
- Dark red/black gradient backgrounds
- Bold, uppercase, tracked typography
- Intense color-coded gradients (red for danger, orange for warning, green for safe)
- Glowing shadow effects on numbers

## Screenshots

[Add screenshots here]

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- OpenAI API key OR Anthropic Claude API key

## Installation

1. Clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/CountingWorms.git
cd CountingWorms
```

2. Open the project in Xcode:
```bash
open CountingWorms.xcodeproj
```

3. Configure App Groups:
   - Select the `CountingWorms` target
   - Go to Signing & Capabilities
   - Ensure App Groups is enabled with `group.bram.CountingWorms`
   - Repeat for the `CountingWormsWidgetExtension` target

4. Update the App Group ID (if needed):
   - If you change the App Group ID, update it in:
     - `CountingWorms/Models/SharedDataManager.swift`
     - `CountingWormsWidget​Extension/SharedDataManager.swift`
   - Change `group.bram.CountingWorms` to your own identifier

5. Build and run the project

## Setup

1. Launch the app and go to Settings
2. Enter your API key (OpenAI or Claude)
3. Select your AI provider
4. Set your daily calorie target
5. Configure your day reset time (default: midnight)
6. Test your API connection using the "Test API Connection" button

## Usage

### Logging Food
1. Tap the camera button on the home screen (or tap any widget)
2. Take a photo of your food
3. The AI analyzes the image and estimates calories
4. Adjust servings with +/- buttons if needed
5. Edit manually if you want to correct the calorie count

### Managing Entries
- **View Log**: Tap "Food Log" to see all entries for the day
- **Adjust Servings**: Use +/- buttons on any entry
- **Edit Calories**: Tap "Edit" to manually adjust the calorie value
- **Delete**: Tap "Delete" to remove an entry

### Widgets
1. Long-press on your home screen or lock screen
2. Tap the + button to add a widget
3. Search for "Counting Worms"
4. Choose your preferred widget size
5. Tap the widget anytime to open the camera

## Architecture

### Tech Stack
- **Framework**: SwiftUI
- **Persistence**: SwiftData
- **Widgets**: WidgetKit
- **Camera**: UIImagePickerController
- **AI Integration**: URLSession with OpenAI and Anthropic APIs
- **Data Sharing**: App Groups with UserDefaults

### Project Structure
```
CountingWorms/
├── Models/
│   ├── FoodEntry.swift           # SwiftData model for food entries
│   ├── UserSettings.swift        # SwiftData model for user preferences
│   ├── CalorieManager.swift      # Core business logic
│   └── SharedDataManager.swift   # App Group data sharing
├── Views/
│   ├── HomeView.swift            # Main calorie display
│   ├── FoodLogView.swift         # Daily food history
│   ├── CameraView.swift          # Photo capture
│   └── SettingsView.swift        # User configuration
├── Services/
│   └── AIService.swift           # OpenAI and Claude API integration
└── CountingWormsWidgetExtension/
    ├── CountingWormsWidget_Extension.swift  # Home screen widgets
    └── LockScreenWidget.swift               # Lock screen widgets
```

## AI Providers

### OpenAI
- Model: GPT-4o
- Endpoint: `https://api.openai.com/v1/chat/completions`
- Get API key: https://platform.openai.com/api-keys

### Anthropic Claude
- Model: Claude 3.5 Sonnet
- Endpoint: `https://api.anthropic.com/v1/messages`
- Get API key: https://console.anthropic.com/

## Privacy

- All data is stored locally on your device using SwiftData
- API keys are stored securely in local storage, never transmitted anywhere except to the chosen AI provider
- Photos are sent to your selected AI provider for analysis but are not stored on their servers
- No analytics or tracking
- No third-party services except your chosen AI provider

## Customization

### Changing the Theme
Edit the color values in:
- `HomeView.swift`: Main app colors
- `CountingWormsWidget_Extension.swift`: Home screen widget colors
- `LockScreenWidget.swift`: Lock screen widget colors

### Adjusting Calorie Thresholds
Warning thresholds (when colors change from green → orange → red) can be adjusted in the `remainingColor` computed properties throughout the views.

### Modifying AI Prompts
The AI prompt is in `AIService.swift`. Customize the analysis behavior by editing the prompt text in the `analyzeWithOpenAI` and `analyzeWithClaude` methods.

## Troubleshooting

### Widgets Not Updating
- Ensure App Groups are properly configured in both targets
- Check that the App Group ID matches in code and capabilities
- Try removing and re-adding the widget

### API Connection Failed
- Verify your API key is correct
- Use the "Test API Connection" button in Settings
- Check your internet connection
- Ensure you have API credits with your provider

### Camera Not Working
- Grant camera permissions in Settings → CountingWorms → Camera
- Restart the app after granting permissions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- App name and aesthetic inspired by "Counting Worms" by Knocked Loose
- Heavy metal design philosophy
- OpenAI GPT-4o for food recognition
- Anthropic Claude 3.5 Sonnet for food recognition

## Support

For issues, questions, or suggestions, please open an issue on GitHub.

---

Built with SwiftUI, SwiftData, and a love for heavy music. 🤘
