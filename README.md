# Flutter Social Share

A Flutter plugin for sharing images to social platforms like Facebook with secure credential management and plug-and-play setup.

## Features

- 🔐 **Secure Credential Management**: Uses `--dart-define` for secure credential handling
- 📱 **Plug-and-Play Setup**: No manual platform-specific configuration required
- 🎯 **Facebook Sharing**: Share images with optional captions to Facebook
- 🛡️ **Comprehensive Error Handling**: Detailed error reporting and user feedback
- 🏗️ **Extensible Architecture**: Designed for easy addition of new social platforms

## Quick Start

### 1. Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_social_share: ^0.0.1
```

Run:
```bash
flutter pub get
```

### 2. Get Facebook Credentials

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create a new app or use an existing one
3. Navigate to **Settings** > **Basic**
4. Copy your **App ID** and **Client Token**

### 3. Basic Usage

```dart
import 'package:flutter_social_share/flutter_social_share.dart';

// Initialize Facebook SDK with environment variables
await FlutterSocialShare.facebook.init();

// Share an image
final result = await FlutterSocialShare.facebook.shareImage(
  '/path/to/your/image.jpg',
  caption: 'Check out this amazing photo!',
);

// Handle the result
switch (result.status) {
  case ShareStatus.success:
    print('Successfully shared to Facebook!');
    break;
  case ShareStatus.cancelled:
    print('User cancelled the share');
    break;
  case ShareStatus.error:
    print('Share failed: ${result.errorMessage}');
    break;
}
```

### 4. Run with Credentials

Use `--dart-define` to securely pass your Facebook credentials:

```bash
flutter run --dart-define=FB_APP_ID=your_app_id --dart-define=FB_CLIENT_TOKEN=your_client_token
```

For development, you can also create a launch configuration in your IDE:

**VS Code (.vscode/launch.json):**
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Flutter (Development)",
      "request": "launch",
      "type": "dart",
      "toolArgs": [
        "--dart-define=FB_APP_ID=your_app_id",
        "--dart-define=FB_CLIENT_TOKEN=your_client_token"
      ]
    }
  ]
}
```

**Android Studio:**
1. Go to **Run** > **Edit Configurations**
2. Add to **Additional run args**: `--dart-define=FB_APP_ID=your_app_id --dart-define=FB_CLIENT_TOKEN=your_client_token`

## Platform Setup

### Android Setup

**No manual configuration required!** The plugin automatically configures the Facebook SDK.

**Requirements:**
- Android API level 24+ (Android 7.0+)
- Facebook app installed on device (for sharing)

**What the plugin handles automatically:**
- Facebook SDK initialization
- Required permissions
- ProGuard rules
- Manifest configuration

### iOS Setup

**No manual configuration required!** The plugin automatically configures the Facebook SDK.

**Requirements:**
- iOS 13.0+
- Facebook app installed on device (for sharing)

**What the plugin handles automatically:**
- Facebook SDK initialization
- Info.plist configuration
- URL scheme handling
- App Transport Security settings

### Platform Support

| Platform | Status | Min Version |
|----------|--------|-------------|
| Android  | ✅ Supported | API 24+ (Android 7.0+) |
| iOS      | ✅ Supported | iOS 13.0+ |

## Advanced Usage

### Explicit Credential Initialization

Instead of using environment variables, you can pass credentials directly:

```dart
await FlutterSocialShare.facebook.init(
  appId: 'your_app_id',
  clientToken: 'your_client_token',
);
```

### Complete Example with Error Handling

```dart
import 'package:flutter_social_share/flutter_social_share.dart';
import 'dart:io';

class SocialShareService {
  static bool _isInitialized = false;

  static Future<void> initializeFacebook() async {
    if (_isInitialized) return;
    
    try {
      await FlutterSocialShare.facebook.init();
      _isInitialized = true;
      print('Facebook SDK initialized successfully');
    } catch (e) {
      print('Failed to initialize Facebook SDK: $e');
      rethrow;
    }
  }

  static Future<bool> shareImageToFacebook(
    String imagePath, {
    String? caption,
  }) async {
    // Ensure Facebook is initialized
    await initializeFacebook();
    
    // Validate image exists
    if (!await File(imagePath).exists()) {
      throw Exception('Image file not found: $imagePath');
    }
    
    try {
      final result = await FlutterSocialShare.facebook.shareImage(
        imagePath,
        caption: caption,
      );
      
      switch (result.status) {
        case ShareStatus.success:
          print('Successfully shared to Facebook');
          return true;
        case ShareStatus.cancelled:
          print('User cancelled Facebook share');
          return false;
        case ShareStatus.error:
          print('Facebook share error: ${result.errorMessage}');
          return false;
      }
    } catch (e) {
      print('Exception during Facebook share: $e');
      return false;
    }
  }
}
```

### Credential Configuration Options

#### Option 1: Environment Variables (Recommended)
```bash
# Development
flutter run --dart-define=FB_APP_ID=123456789 --dart-define=FB_CLIENT_TOKEN=abc123

# Production build
flutter build apk --dart-define=FB_APP_ID=123456789 --dart-define=FB_CLIENT_TOKEN=abc123
```

#### Option 2: IDE Configuration
Set up your IDE to automatically pass credentials during development.

#### Option 3: Explicit Initialization
```dart
await FlutterSocialShare.facebook.init(
  appId: 'your_app_id',
  clientToken: 'your_client_token',
);
```

## Error Handling

The plugin provides comprehensive error handling with detailed error codes:

```dart
enum ShareStatus {
  success,   // Share completed successfully
  cancelled, // User cancelled the share dialog
  error,     // An error occurred during sharing
}

enum ShareErrorCode {
  missingApp,           // App not installed
  invalidPath,          // Invalid or inaccessible image path
  initializationFailed, // Facebook SDK initialization failed
  platformNotSupported, // Platform not supported
  unknown,              // Unknown error occurred
}

class ShareResult {
  final ShareStatus status;
  final String? errorMessage;
  final ShareErrorCode? errorCode;
  
  bool get isSuccess => status == ShareStatus.success;
  bool get isCancelled => status == ShareStatus.cancelled;
  bool get isError => status == ShareStatus.error;
}
```

### Handling Different Error Scenarios

```dart
final result = await FlutterSocialShare.facebook.shareImage(imagePath);

if (result.isError) {
  switch (result.errorCode) {
    case ShareErrorCode.missingApp:
      // Show dialog to install Facebook app
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Facebook App Required'),
          content: Text('Please install the Facebook app to share content.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      break;
    case ShareErrorCode.invalidPath:
      // Handle invalid image path
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected image is not accessible')),
      );
      break;
    case ShareErrorCode.initializationFailed:
      // Handle SDK initialization failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize Facebook SDK')),
      );
      break;
    default:
      // Handle other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Share failed: ${result.errorMessage}')),
      );
  }
}

## Security Best Practices

### Credential Management
- ✅ **Use `--dart-define`**: Never hardcode credentials in your source code
- ✅ **Environment Variables**: Store credentials in environment variables for CI/CD
- ✅ **Memory Only**: Credentials are stored in memory only, never persisted to disk
- ❌ **Avoid**: Don't commit credentials to version control

### Image Handling
- ✅ **Validate Paths**: Always validate image paths before sharing
- ✅ **File Permissions**: Ensure your app has proper file access permissions
- ✅ **Temporary Files**: Clean up temporary files after sharing

## Architecture

This plugin follows a modular, extensible architecture designed for future expansion:

```
FlutterSocialShare (Main API)
├── FacebookShare (Platform-specific)
├── TwitterShare (Future)
└── InstagramShare (Future)

Platform Interface Layer
├── FacebookPlatformInterface
├── TwitterPlatformInterface (Future)
└── InstagramPlatformInterface (Future)

Native Implementation Layer
├── Android (Kotlin)
│   ├── FacebookShareHandler
│   └── FlutterSocialSharePlugin
└── iOS (Swift)
    ├── FacebookShareHandler
    └── FlutterSocialSharePlugin
```

**Key Design Principles:**
- **Separation of Concerns**: Each platform has its own implementation
- **Extensibility**: Easy to add new social platforms
- **Security**: Secure credential management throughout
- **Consistency**: Unified API across all platforms

## Example App

The [example app](example/) demonstrates:

- ✅ Facebook SDK initialization with environment variables
- ✅ Image picker integration for selecting images
- ✅ Sharing images with custom captions
- ✅ Comprehensive error handling and user feedback
- ✅ Proper credential management patterns
- ✅ UI for testing different sharing scenarios

To run the example:

```bash
cd example
flutter run --dart-define=FB_APP_ID=your_app_id --dart-define=FB_CLIENT_TOKEN=your_client_token
```

## API Reference

### FlutterSocialShare

Main entry point for accessing social platform implementations.

```dart
class FlutterSocialShare {
  static FacebookShare get facebook;
  // Future: static TwitterShare get twitter;
  // Future: static InstagramShare get instagram;
}
```

### FacebookShare

Facebook-specific sharing functionality.

```dart
class FacebookShare {
  /// Initialize Facebook SDK with credentials
  Future<void> init({String? appId, String? clientToken});
  
  /// Share an image to Facebook with optional caption
  Future<ShareResult> shareImage(String imagePath, {String? caption});
}
```

### ShareResult

Result object returned from sharing operations.

```dart
class ShareResult {
  final ShareStatus status;
  final String? errorMessage;
  final ShareErrorCode? errorCode;
  
  bool get isSuccess;
  bool get isCancelled;
  bool get isError;
}
```

## Troubleshooting

### Common Issues

**Q: "Facebook app not installed" error**
A: The Facebook app must be installed on the device for sharing to work. Guide users to install it from the app store.

**Q: "Initialization failed" error**
A: Check that your Facebook App ID and Client Token are correct and properly passed via `--dart-define`.

**Q: "Invalid path" error**
A: Ensure the image file exists and your app has permission to access it. Use `File(path).exists()` to verify.

**Q: Sharing dialog doesn't appear**
A: Make sure you've called `init()` before attempting to share, and that the Facebook app is installed.

For more troubleshooting information, see [TROUBLESHOOTING.md](TROUBLESHOOTING.md).

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/flutter_social_share.git`
3. Install dependencies: `flutter pub get`
4. Run tests: `flutter test`
5. Run the example app: `cd example && flutter run --dart-define=FB_APP_ID=test --dart-define=FB_CLIENT_TOKEN=test`

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed history of changes.

