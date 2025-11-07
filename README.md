# Flutter Social Share

A Flutter plugin for sharing images to social platforms like Facebook through their native SDKs.

## Features

- Share images to Facebook using the official Facebook SDK
- Native Android implementation
- Simple and easy-to-use API
- Proper error handling and callbacks

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  flutter_social_share: ^1.0.0
```

## Usage

### Initialize and Share

```dart
import 'package:flutter_social_share/flutter_social_share.dart';

// Initialize Facebook SDK (reads from --dart-define)
await FlutterSocialShare.facebook.init();

// Or pass credentials explicitly
await FlutterSocialShare.facebook.init(
  appId: 'YOUR_FACEBOOK_APP_ID',
  clientToken: 'YOUR_FACEBOOK_CLIENT_TOKEN',
);

// Share an image to Facebook
final result = await FlutterSocialShare.facebook.shareImage(
  '/path/to/your/image.jpg',
  caption: 'Check out this image!',
);

if (result.isSuccess) {
  print('Successfully shared to Facebook!');
} else if (result.isCancelled) {
  print('User cancelled the share');
} else {
  print('Error: ${result.errorMessage}');
}
```

### Running with Credentials

Use `--dart-define` to pass your Facebook credentials:

```bash
flutter run --dart-define=FB_APP_ID=your_app_id --dart-define=FB_CLIENT_TOKEN=your_client_token
```

For building:

```bash
flutter build apk --dart-define=FB_APP_ID=your_app_id --dart-define=FB_CLIENT_TOKEN=your_client_token
```

## Requirements

- Flutter ≥ 3.3.0
- Dart ≥ 3.6.0
- Android SDK ≥ 24
- Facebook App with valid App ID and Client Token

## Getting Facebook Credentials

1. Go to [Facebook Developers](https://developers.facebook.com/)
2. Create a new app or use an existing one
3. Get your App ID from the app dashboard
4. Generate a Client Token in App Settings > Advanced

## Limitations

- Currently only supports Android platform
- Caption parameter is not supported in the current Facebook SDK version
- Requires Facebook app to be installed on the device

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

