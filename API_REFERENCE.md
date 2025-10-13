# Flutter Social Share - API Reference

This document provides comprehensive API documentation for the Flutter Social Share plugin, including detailed error code explanations and usage examples.

## Table of Contents

- [Quick Start](#quick-start)
- [Core Classes](#core-classes)
- [Error Codes Reference](#error-codes-reference)
- [Platform Support](#platform-support)
- [Security Best Practices](#security-best-practices)
- [Troubleshooting](#troubleshooting)

## Quick Start

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_social_share: ^1.0.0
```

### Basic Usage

```dart
import 'package:flutter_social_share/flutter_social_share.dart';

// Initialize Facebook SDK
await FlutterSocialShare.facebook.init();

// Share an image
final result = await FlutterSocialShare.facebook.shareImage(
  '/path/to/your/image.jpg',
  caption: 'Check out this amazing photo!',
);

// Handle the result
if (result.isSuccess) {
  print('Successfully shared to Facebook!');
} else if (result.isCancelled) {
  print('User cancelled the share');
} else {
  print('Share failed: ${result.errorMessage}');
}
```

### Credential Configuration

Use `--dart-define` to securely pass your Facebook credentials:

```bash
flutter run \
  --dart-define=FB_APP_ID=your_app_id \
  --dart-define=FB_CLIENT_TOKEN=your_client_token
```

## Core Classes

### FlutterSocialShare

Main entry point for the plugin. Provides access to platform-specific sharing functionality.

**Properties:**
- `facebook` - Access to Facebook sharing functionality

**Example:**
```dart
// Access Facebook sharing
final facebookShare = FlutterSocialShare.facebook;
```

### FacebookShare

Handles Facebook-specific sharing operations.

**Methods:**

#### `init({String? appId, String? clientToken})`

Initialize Facebook SDK with credentials.

**Parameters:**
- `appId` (optional) - Facebook App ID. If not provided, reads from `FB_APP_ID` environment variable
- `clientToken` (optional) - Facebook Client Token. If not provided, reads from `FB_CLIENT_TOKEN` environment variable

**Throws:**
- `ArgumentError` if credentials are invalid or missing

**Example:**
```dart
// Using environment variables (recommended)
await FlutterSocialShare.facebook.init();

// Using explicit credentials
await FlutterSocialShare.facebook.init(
  appId: 'your_app_id',
  clientToken: 'your_client_token',
);
```

#### `shareImage(String imagePath, {String? caption})`

Share an image to Facebook with optional caption.

**Parameters:**
- `imagePath` - Path to the image file to share
- `caption` (optional) - Text to include with the shared image

**Returns:**
- `Future<ShareResult>` - Result of the share operation

**Example:**
```dart
final result = await FlutterSocialShare.facebook.shareImage(
  '/path/to/image.jpg',
  caption: 'Check out this photo!',
);
```

**Properties:**
- `isInitialized` - Returns `true` if Facebook SDK is initialized

### ShareResult

Represents the result of a share operation.

**Properties:**
- `status` - The status of the share operation ([ShareStatus])
- `errorMessage` - Human-readable error description (if failed)
- `errorCode` - Specific error code for programmatic handling (if failed)

**Convenience Methods:**
- `isSuccess` - Returns `true` if the share was successful
- `isCancelled` - Returns `true` if the user cancelled the share
- `isError` - Returns `true` if an error occurred

**Factory Constructors:**
- `ShareResult.success()` - Create a successful result
- `ShareResult.cancelled()` - Create a cancelled result
- `ShareResult.error(ShareErrorCode code, String message)` - Create an error result

### ShareImageRequest

Represents a request to share an image to a social platform.

**Properties:**
- `imagePath` - Path to the image file to share
- `caption` - Optional caption to include with the shared image
- `platform` - The social platform to share to

### FacebookCredentials

Contains Facebook app credentials for SDK initialization.

**Properties:**
- `appId` - Facebook App ID
- `clientToken` - Facebook Client Token

**Factory Constructors:**
- `FacebookCredentials.fromEnvironment()` - Create from environment variables

**Methods:**
- `isValid()` - Validate that all required credentials are present
- `toMap()` - Convert to map for secure transmission

## Error Codes Reference

### ShareStatus

Represents the three possible outcomes of a sharing operation:

| Status | Description | Action Required |
|--------|-------------|-----------------|
| `success` | Share completed successfully | None - operation succeeded |
| `cancelled` | User cancelled the share dialog | None - normal user action |
| `error` | An error occurred during sharing | Check `errorCode` and `errorMessage` |

### ShareErrorCode

Specific error codes that help identify and handle different failure scenarios:

#### `missingApp`

**Cause:** The target social app (e.g., Facebook) is not installed on the device.

**Resolution:** 
- Prompt user to install the app from App Store/Google Play
- Provide alternative sharing methods (web sharing, copy link, etc.)
- Show installation instructions

**Example Handling:**
```dart
if (result.errorCode == ShareErrorCode.missingApp) {
  showDialog(
    title: 'Facebook Not Installed',
    message: 'Please install Facebook to share content.',
    actions: [
      TextButton(
        onPressed: () => launchUrl('https://apps.apple.com/app/facebook/id284882215'),
        child: Text('Install Facebook'),
      ),
    ],
  );
}
```

#### `invalidPath`

**Cause:** The image file path is empty, points to a non-existent file, or the app doesn't have permission to access the file.

**Resolution:**
- Verify the file exists before sharing
- Check file permissions
- Use a file picker to let user select a valid image
- Ensure the path is absolute and accessible

**Example Handling:**
```dart
if (result.errorCode == ShareErrorCode.invalidPath) {
  showSnackBar('Please select a valid image file');
  // Show file picker
  final file = await FilePicker.pickFiles(type: FileType.image);
  if (file != null) {
    // Retry with valid file
    await shareImage(file.files.first.path!);
  }
}
```

#### `initializationFailed`

**Cause:** The social platform SDK could not be initialized, usually due to:
- Invalid or missing credentials
- Network connectivity issues
- Incorrect SDK configuration

**Resolution:**
- Verify credentials are correct and properly configured
- Check network connectivity
- Ensure proper SDK setup
- Retry initialization

**Example Handling:**
```dart
if (result.errorCode == ShareErrorCode.initializationFailed) {
  showDialog(
    title: 'Setup Required',
    message: 'Please check your Facebook app configuration and try again.',
    actions: [
      TextButton(
        onPressed: () async {
          // Retry initialization
          try {
            await FlutterSocialShare.facebook.init();
            showSnackBar('Facebook initialized successfully');
          } catch (e) {
            showSnackBar('Initialization failed: $e');
          }
        },
        child: Text('Retry'),
      ),
    ],
  );
}
```

#### `platformNotSupported`

**Cause:** Attempting to share to a platform that is not yet implemented or supported.

**Resolution:**
- Use a supported platform (currently only Facebook)
- Wait for future plugin updates
- Implement custom sharing for unsupported platforms

**Example Handling:**
```dart
if (result.errorCode == ShareErrorCode.platformNotSupported) {
  showDialog(
    title: 'Platform Not Supported',
    message: 'This platform is not yet supported. Please try Facebook sharing.',
    actions: [
      TextButton(
        onPressed: () => shareToFacebook(),
        child: Text('Share to Facebook'),
      ),
    ],
  );
}
```

#### `unknown`

**Cause:** An unexpected error that doesn't fit into other categories, such as:
- Platform-specific SDK errors
- Network connectivity issues
- Unexpected API responses
- Device-specific problems

**Resolution:**
- Check the error message for more details
- Retry the operation
- Log the error for debugging
- Report persistent issues

**Example Handling:**
```dart
if (result.errorCode == ShareErrorCode.unknown) {
  // Log for debugging
  print('Unknown share error: ${result.errorMessage}');
  
  showDialog(
    title: 'Share Failed',
    message: 'An unexpected error occurred. Please try again.',
    actions: [
      TextButton(
        onPressed: () => retryShare(),
        child: Text('Retry'),
      ),
      TextButton(
        onPressed: () => reportIssue(result.errorMessage),
        child: Text('Report Issue'),
      ),
    ],
  );
}
```

## Platform Support

| Platform | Status | Min Version | Requirements |
|----------|--------|-------------|--------------|
| Android  | ✅ Supported | API 24+ (Android 7.0+) | Facebook app installed |
| iOS      | ✅ Supported | iOS 13.0+ | Facebook app installed |

### Facebook Requirements

- **Facebook App**: Must be installed on the device
- **Credentials**: Valid Facebook App ID and Client Token from [Facebook Developers Console](https://developers.facebook.com/)
- **Network**: Internet connectivity for authentication
- **Permissions**: File access permissions for image sharing

## Security Best Practices

### Credential Management

1. **Use Environment Variables**: Always use `--dart-define` for credentials
   ```bash
   flutter run --dart-define=FB_APP_ID=123456789 --dart-define=FB_CLIENT_TOKEN=abc123def456
   ```

2. **Never Hardcode**: Don't include credentials in source code
   ```dart
   // ❌ DON'T DO THIS
   await FlutterSocialShare.facebook.init(
     appId: '123456789', // Hardcoded - bad!
     clientToken: 'abc123def456', // Hardcoded - bad!
   );
   
   // ✅ DO THIS INSTEAD
   await FlutterSocialShare.facebook.init(); // Uses environment variables
   ```

3. **Secure Storage**: Credentials are stored in memory only, never persisted

4. **Rotate Regularly**: Update credentials periodically for security

### File Access

1. **Validate Paths**: Always check that image files exist before sharing
2. **Use Absolute Paths**: Ensure file paths are absolute and accessible
3. **Handle Permissions**: Request necessary file access permissions

## Troubleshooting

### Common Issues

#### "Facebook SDK not initialized"

**Cause:** Trying to share before calling `init()`

**Solution:**
```dart
// Always initialize first
await FlutterSocialShare.facebook.init();
// Then share
final result = await FlutterSocialShare.facebook.shareImage('/path/to/image.jpg');
```

#### "Invalid Facebook credentials"

**Cause:** Missing or incorrect App ID/Client Token

**Solution:**
1. Verify credentials in Facebook Developers Console
2. Check `--dart-define` parameters are correct
3. Ensure environment variables are set properly

#### "Facebook app not installed"

**Cause:** Facebook app is not installed on the device

**Solution:**
- Prompt user to install Facebook app
- Provide alternative sharing methods
- Handle gracefully in your app

#### "Image file not found"

**Cause:** Invalid or inaccessible image path

**Solution:**
```dart
// Verify file exists before sharing
final file = File(imagePath);
if (await file.exists()) {
  final result = await FlutterSocialShare.facebook.shareImage(imagePath);
} else {
  print('Image file not found: $imagePath');
}
```

### Debug Mode

Enable debug logging to troubleshoot issues:

```dart
// Add this for debugging
import 'dart:developer' as developer;

try {
  final result = await FlutterSocialShare.facebook.shareImage('/path/to/image.jpg');
  developer.log('Share result: ${result.status}');
} catch (e) {
  developer.log('Share error: $e');
}
```

### Getting Help

1. **Check Documentation**: Review this API reference and README
2. **Search Issues**: Look for similar issues on GitHub
3. **Create Issue**: Report bugs with detailed reproduction steps
4. **Provide Context**: Include platform, versions, and error messages

## Complete Example

Here's a complete example showing proper error handling:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_social_share/flutter_social_share.dart';

class ShareExample extends StatefulWidget {
  @override
  _ShareExampleState createState() => _ShareExampleState();
}

class _ShareExampleState extends State<ShareExample> {
  bool _isInitialized = false;
  String _status = 'Not initialized';

  @override
  void initState() {
    super.initState();
    _initializeFacebook();
  }

  Future<void> _initializeFacebook() async {
    try {
      await FlutterSocialShare.facebook.init();
      setState(() {
        _isInitialized = true;
        _status = 'Facebook initialized successfully';
      });
    } catch (e) {
      setState(() {
        _isInitialized = false;
        _status = 'Initialization failed: $e';
      });
    }
  }

  Future<void> _shareImage(String imagePath) async {
    if (!_isInitialized) {
      _showSnackBar('Please initialize Facebook first');
      return;
    }

    final result = await FlutterSocialShare.facebook.shareImage(
      imagePath,
      caption: 'Shared from my Flutter app!',
    );

    switch (result.status) {
      case ShareStatus.success:
        _showSnackBar('Successfully shared to Facebook!');
        break;
      case ShareStatus.cancelled:
        _showSnackBar('Share cancelled');
        break;
      case ShareStatus.error:
        _handleShareError(result);
        break;
    }
  }

  void _handleShareError(ShareResult result) {
    switch (result.errorCode) {
      case ShareErrorCode.missingApp:
        _showInstallFacebookDialog();
        break;
      case ShareErrorCode.invalidPath:
        _showSnackBar('Please select a valid image file');
        break;
      case ShareErrorCode.initializationFailed:
        _showSnackBar('Please check your Facebook app configuration');
        break;
      default:
        _showSnackBar('Share failed: ${result.errorMessage}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showInstallFacebookDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Facebook Not Installed'),
        content: Text('Please install Facebook to share content.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Launch app store
            },
            child: Text('Install'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Share Example')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Status: $_status'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isInitialized ? () => _shareImage('/path/to/image.jpg') : null,
              child: Text('Share Image'),
            ),
            if (!_isInitialized)
              ElevatedButton(
                onPressed: _initializeFacebook,
                child: Text('Retry Initialization'),
              ),
          ],
        ),
      ),
    );
  }
}
```

This example demonstrates:
- Proper initialization handling
- Comprehensive error handling for all error codes
- User-friendly error messages and recovery options
- State management for initialization status
- Best practices for UI feedback