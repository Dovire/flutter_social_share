# Troubleshooting Guide

This guide helps you resolve common issues when using the Flutter Social Share plugin.

## Common Issues

### 1. Facebook App Not Installed

**Error:** `ShareErrorCode.missingApp` or "Facebook app not installed"

**Cause:** The Facebook mobile app is not installed on the device.

**Solutions:**
- Guide users to install the Facebook app from their device's app store
- Implement a fallback sharing method (web-based sharing)
- Show a user-friendly dialog explaining the requirement

```dart
if (result.errorCode == ShareErrorCode.missingApp) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Facebook App Required'),
      content: Text(
        'To share content to Facebook, please install the Facebook app from your device\'s app store.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Open app store
            Navigator.pop(context);
            // Implement app store opening logic
          },
          child: Text('Install'),
        ),
      ],
    ),
  );
}
```

### 2. Initialization Failed

**Error:** `ShareErrorCode.initializationFailed` or "Failed to initialize Facebook SDK"

**Possible Causes:**
- Invalid Facebook App ID or Client Token
- Credentials not properly passed via `--dart-define`
- Network connectivity issues
- Facebook app configuration issues

**Solutions:**

#### Check Credentials
1. Verify your Facebook App ID and Client Token in [Facebook Developers Console](https://developers.facebook.com/)
2. Ensure credentials are correctly passed:
   ```bash
   flutter run --dart-define=FB_APP_ID=your_actual_app_id --dart-define=FB_CLIENT_TOKEN=your_actual_client_token
   ```

#### Debug Credential Loading
```dart
void debugCredentials() {
  const appId = String.fromEnvironment('FB_APP_ID');
  const clientToken = String.fromEnvironment('FB_CLIENT_TOKEN');
  
  print('FB_APP_ID: ${appId.isEmpty ? 'NOT SET' : 'SET (${appId.length} chars)'}');
  print('FB_CLIENT_TOKEN: ${clientToken.isEmpty ? 'NOT SET' : 'SET (${clientToken.length} chars)'}');
}
```

#### Facebook App Configuration
1. Go to [Facebook Developers Console](https://developers.facebook.com/)
2. Select your app
3. Go to **Settings** > **Basic**
4. Ensure your app is not in "Development Mode" if testing on production
5. Add your app's package name to **Android** settings
6. Add your app's bundle ID to **iOS** settings

### 3. Invalid Image Path

**Error:** `ShareErrorCode.invalidPath` or "Invalid or inaccessible image path"

**Possible Causes:**
- Image file doesn't exist at the specified path
- App doesn't have permission to access the file
- Path format is incorrect
- File is corrupted or not a valid image

**Solutions:**

#### Validate File Existence
```dart
Future<bool> validateImagePath(String imagePath) async {
  final file = File(imagePath);
  
  // Check if file exists
  if (!await file.exists()) {
    print('File does not exist: $imagePath');
    return false;
  }
  
  // Check file size
  final size = await file.length();
  if (size == 0) {
    print('File is empty: $imagePath');
    return false;
  }
  
  // Check if it's a valid image (basic check)
  final extension = path.extension(imagePath).toLowerCase();
  if (!['.jpg', '.jpeg', '.png', '.gif'].contains(extension)) {
    print('Unsupported image format: $extension');
    return false;
  }
  
  return true;
}
```

#### Handle File Picker Results
```dart
// When using image_picker
final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
if (pickedFile != null) {
  final isValid = await validateImagePath(pickedFile.path);
  if (isValid) {
    // Proceed with sharing
    final result = await FlutterSocialShare.facebook.shareImage(pickedFile.path);
  } else {
    // Handle invalid file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selected image is not valid')),
    );
  }
}
```

### 4. Sharing Dialog Doesn't Appear

**Possible Causes:**
- Facebook SDK not properly initialized
- Facebook app not installed
- Invalid image or content
- Platform-specific issues

**Solutions:**

#### Ensure Proper Initialization Order
```dart
class SocialShareManager {
  static bool _isInitialized = false;
  
  static Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    
    try {
      await FlutterSocialShare.facebook.init();
      _isInitialized = true;
      print('Facebook SDK initialized successfully');
    } catch (e) {
      print('Facebook SDK initialization failed: $e');
      rethrow;
    }
  }
  
  static Future<ShareResult> shareImage(String imagePath, {String? caption}) async {
    await ensureInitialized();
    return await FlutterSocialShare.facebook.shareImage(imagePath, caption: caption);
  }
}
```

### 5. Build Issues

#### Android Build Errors

**Error:** "Duplicate class" or "Conflicting dependencies"

**Solution:** Check for conflicting Facebook SDK versions in your `android/app/build.gradle`:

```gradle
android {
    configurations.all {
        resolutionStrategy {
            force 'com.facebook.android:facebook-android-sdk:latest.release'
        }
    }
}
```

**Error:** "Manifest merger failed"

**Solution:** The plugin handles manifest configuration automatically. If you have manual Facebook SDK configuration, remove it:

```xml
<!-- Remove these from AndroidManifest.xml if present -->
<meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/facebook_app_id"/>
<meta-data android:name="com.facebook.sdk.ClientToken" android:value="@string/facebook_client_token"/>
```

#### iOS Build Errors

**Error:** "Framework not found FBSDKCoreKit"

**Solution:** Clean and rebuild:
```bash
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter build ios
```

**Error:** "Info.plist configuration missing"

**Solution:** The plugin handles Info.plist configuration automatically. If you have manual configuration, remove it:

```xml
<!-- Remove these from Info.plist if present -->
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>facebook</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fb{your-app-id}</string>
    </array>
  </dict>
</array>
```

## Platform-Specific Debugging

### Android Debugging

#### Enable Debug Logging
Add to your `android/app/src/main/kotlin/.../MainActivity.kt`:

```kotlin
import android.util.Log
import com.facebook.LoggingBehavior
import com.facebook.FacebookSdk

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable Facebook SDK debug logging
        if (BuildConfig.DEBUG) {
            FacebookSdk.setIsDebugEnabled(true)
            FacebookSdk.addLoggingBehavior(LoggingBehavior.INCLUDE_ACCESS_TOKENS)
        }
    }
}
```

#### Check Logcat Output
```bash
adb logcat | grep -E "(Facebook|FlutterSocialShare)"
```

### iOS Debugging

#### Enable Debug Logging
Add to your `ios/Runner/AppDelegate.swift`:

```swift
import FBSDKCoreKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    #if DEBUG
    Settings.shared.isLoggingBehaviorEnabled = true
    #endif
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

#### Check Console Output
In Xcode, check the console output for Facebook SDK logs.

## Performance Issues

### Large Image Files

**Issue:** Sharing large images causes memory issues or crashes.

**Solution:** Resize images before sharing:

```dart
import 'package:image/image.dart' as img;

Future<String> resizeImageForSharing(String originalPath) async {
  final originalFile = File(originalPath);
  final bytes = await originalFile.readAsBytes();
  
  // Decode image
  final image = img.decodeImage(bytes);
  if (image == null) throw Exception('Failed to decode image');
  
  // Resize if too large (max 1080px width)
  final resized = image.width > 1080 
    ? img.copyResize(image, width: 1080)
    : image;
  
  // Save resized image
  final tempDir = await getTemporaryDirectory();
  final resizedPath = '${tempDir.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg';
  final resizedFile = File(resizedPath);
  await resizedFile.writeAsBytes(img.encodeJpg(resized, quality: 85));
  
  return resizedPath;
}
```

### Memory Leaks

**Issue:** Memory usage increases over time with repeated sharing.

**Solution:** Ensure proper cleanup:

```dart
class ImageShareService {
  final List<String> _tempFiles = [];
  
  Future<ShareResult> shareImage(String imagePath, {String? caption}) async {
    String pathToShare = imagePath;
    
    // Resize if needed
    if (await _needsResize(imagePath)) {
      pathToShare = await resizeImageForSharing(imagePath);
      _tempFiles.add(pathToShare); // Track temp file
    }
    
    try {
      return await FlutterSocialShare.facebook.shareImage(pathToShare, caption: caption);
    } finally {
      // Clean up temp files
      await _cleanupTempFiles();
    }
  }
  
  Future<void> _cleanupTempFiles() async {
    for (final path in _tempFiles) {
      try {
        await File(path).delete();
      } catch (e) {
        print('Failed to delete temp file: $path');
      }
    }
    _tempFiles.clear();
  }
}
```

## FAQ

### Q: Can I share without the Facebook app installed?
A: No, the Facebook app must be installed for native sharing to work. This is a Facebook SDK requirement.

### Q: Can I share to Facebook Stories?
A: Currently, only feed sharing is supported. Stories sharing may be added in future versions.

### Q: Can I share videos?
A: Currently, only image sharing is supported. Video sharing may be added in future versions.

### Q: How do I handle different screen sizes and orientations?
A: The plugin handles platform-specific UI automatically. The Facebook sharing dialog adapts to the device.

### Q: Can I customize the sharing dialog appearance?
A: The sharing dialog appearance is controlled by the Facebook app and cannot be customized.

### Q: How do I test without real Facebook credentials?
A: You can use test credentials from Facebook's test app, but you'll need valid credentials for the Facebook SDK to initialize.

### Q: Can I share to Facebook Pages?
A: The current implementation shares to the user's personal timeline. Page sharing requires additional Facebook permissions and may be added in future versions.

### Q: How do I handle network connectivity issues?
A: The Facebook SDK handles network issues internally. Your app will receive appropriate error callbacks if sharing fails due to network problems.

## Getting Help

If you're still experiencing issues:

1. **Check the Example App**: Run the example app to see if the issue is with your implementation
2. **Enable Debug Logging**: Use the debug logging techniques above to get more information
3. **Check Facebook Developer Console**: Ensure your app configuration is correct
4. **Create an Issue**: If you've found a bug, create an issue on the [GitHub repository](https://github.com/your-repo/flutter_social_share/issues)

When reporting issues, please include:
- Flutter version (`flutter --version`)
- Plugin version
- Platform (Android/iOS) and version
- Complete error messages and stack traces
- Minimal code example that reproduces the issue
- Facebook App ID (you can mask most digits for privacy)

## Debug Checklist

Before reporting an issue, please verify:

- [ ] Facebook app is installed on the test device
- [ ] Facebook App ID and Client Token are correct
- [ ] Credentials are properly passed via `--dart-define`
- [ ] Image file exists and is accessible
- [ ] `init()` is called before sharing
- [ ] You're testing on a physical device (not simulator for sharing)
- [ ] Your Facebook app is properly configured in Facebook Developer Console
- [ ] You've tried the example app with your credentials