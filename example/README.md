# Flutter Social Share Example

This example app demonstrates how to use the `flutter_social_share` plugin to share images to Facebook with optional captions.

## Features

- **Facebook SDK Initialization**: Initialize the Facebook SDK using either environment variables or explicit credentials
- **Image Selection**: Pick images from gallery or camera using the device's native image picker
- **Caption Support**: Add optional captions to your shared images
- **Comprehensive Error Handling**: Clear feedback for all sharing scenarios (success, cancellation, errors)
- **Multiple Credential Methods**: Support for both `--dart-define` environment variables and explicit credential input

## Setup Instructions

### Prerequisites

1. **Facebook App Configuration**:
   - Create a Facebook app at [Facebook Developers](https://developers.facebook.com/)
   - Get your App ID and Client Token from the app dashboard
   - Configure your app for mobile sharing

2. **Facebook App Installation**:
   - Install the Facebook app on your test device
   - Make sure you're logged into Facebook on the device

### Running the Example

#### Method 1: Environment Variables (Recommended)

Run the app with your Facebook credentials as environment variables:

```bash
flutter run --dart-define=FB_APP_ID=your_facebook_app_id --dart-define=FB_CLIENT_TOKEN=your_facebook_client_token
```

#### Method 2: Explicit Credentials

1. Run the app normally:
   ```bash
   flutter run
   ```

2. In the app, select "Explicit Credentials" and enter your Facebook App ID and Client Token manually.

### Platform-Specific Setup

#### Android

No additional setup required - the plugin handles Facebook SDK configuration automatically.

#### iOS

No additional setup required - the plugin handles Facebook SDK configuration automatically.

## Usage Flow

1. **Initialize Facebook SDK**:
   - Choose your credential method (environment variables or explicit input)
   - Tap "Initialize Facebook SDK"
   - Wait for successful initialization

2. **Select an Image**:
   - Tap "Select Image"
   - Choose between Gallery or Camera
   - Select or take a photo

3. **Add Caption (Optional)**:
   - Enter a caption in the text field
   - Leave empty if you don't want a caption

4. **Share to Facebook**:
   - Tap "Share to Facebook"
   - The Facebook sharing dialog will appear
   - Complete the sharing process or cancel

## Testing Scenarios

The example app allows you to test various scenarios:

- **Successful sharing**: Complete the Facebook sharing flow
- **User cancellation**: Cancel the Facebook sharing dialog
- **Missing Facebook app**: Test behavior when Facebook app is not installed
- **Invalid credentials**: Test with incorrect App ID or Client Token
- **Network issues**: Test sharing with poor network connectivity
- **Different image formats**: Test with various image types and sizes

## Troubleshooting

### Common Issues

1. **"Facebook app not installed"**:
   - Install the Facebook app from your device's app store
   - Make sure you're logged into Facebook

2. **"Initialization failed"**:
   - Check that your App ID and Client Token are correct
   - Verify your Facebook app is properly configured
   - Make sure your app is not in development mode restrictions

3. **"Invalid image path"**:
   - Make sure you've selected an image before sharing
   - Try selecting a different image

4. **Sharing dialog doesn't appear**:
   - Ensure Facebook SDK is initialized successfully
   - Check that Facebook app is installed and updated

### Getting Help

If you encounter issues:

1. Check the error messages displayed in the app
2. Review the setup instructions above
3. Verify your Facebook app configuration
4. Check the main plugin documentation

## Development Notes

This example app demonstrates:

- Proper plugin initialization patterns
- Error handling best practices
- User-friendly UI for testing
- Both environment variable and explicit credential usage
- Image picker integration
- Comprehensive status feedback

The code is structured to be educational and can serve as a reference for integrating the plugin into your own applications.
