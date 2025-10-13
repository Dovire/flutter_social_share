import 'src/facebook_share.dart';
import 'src/flutter_social_share_plugin.dart';

// Export public API
export 'src/models/share_models.dart';
export 'src/models/credentials.dart';
export 'src/facebook_share.dart';

/// Main entry point for Flutter Social Share plugin.
/// 
/// This plugin enables sharing images to social platforms with secure credential
/// management and plug-and-play setup. Currently supports Facebook sharing with
/// plans to expand to other platforms.
/// 
/// ## Features
/// 
/// - 🔐 **Secure Credential Management**: Uses `--dart-define` for secure credential handling
/// - 📱 **Plug-and-Play Setup**: No manual platform-specific configuration required
/// - 🎯 **Facebook Sharing**: Share images with optional captions to Facebook
/// - 🛡️ **Comprehensive Error Handling**: Detailed error reporting and user feedback
/// - 🏗️ **Extensible Architecture**: Designed for easy addition of new social platforms
/// 
/// ## Quick Start
/// 
/// ```dart
/// import 'package:flutter_social_share/flutter_social_share.dart';
/// 
/// // Initialize Facebook SDK
/// await FlutterSocialShare.facebook.init();
/// 
/// // Share an image
/// final result = await FlutterSocialShare.facebook.shareImage(
///   '/path/to/your/image.jpg',
///   caption: 'Check out this amazing photo!',
/// );
/// 
/// if (result.isSuccess) {
///   print('Successfully shared to Facebook!');
/// } else if (result.isCancelled) {
///   print('User cancelled the share');
/// } else {
///   print('Share failed: ${result.errorMessage}');
/// }
/// ```
/// 
/// ## Credential Configuration
/// 
/// Use `--dart-define` to securely pass your Facebook credentials:
/// 
/// ```bash
/// flutter run --dart-define=FB_APP_ID=your_app_id --dart-define=FB_CLIENT_TOKEN=your_client_token
/// ```
/// 
/// ## Platform Support
/// 
/// | Platform | Status | Min Version |
/// |----------|--------|-------------|
/// | Android  | ✅ Supported | API 24+ (Android 7.0+) |
/// | iOS      | ✅ Supported | iOS 13.0+ |
/// 
/// ## Requirements
/// 
/// - Facebook app must be installed on the device for sharing
/// - Valid Facebook App ID and Client Token from [Facebook Developers](https://developers.facebook.com/)
/// 
/// See the [example app](https://github.com/your-repo/flutter_social_share/tree/main/example) 
/// for a complete implementation.
class FlutterSocialShare {
  static bool _initialized = false;

  /// Initialize the plugin (called automatically on first access)
  static void _ensureInitialized() {
    if (!_initialized) {
      FlutterSocialSharePlugin.registerWith();
      _initialized = true;
    }
  }

  /// Access to Facebook sharing functionality.
  /// 
  /// Provides methods to initialize the Facebook SDK and share images to Facebook.
  /// The Facebook app must be installed on the device for sharing to work.
  /// 
  /// Example:
  /// ```dart
  /// // Initialize with environment variables
  /// await FlutterSocialShare.facebook.init();
  /// 
  /// // Or initialize with explicit credentials
  /// await FlutterSocialShare.facebook.init(
  ///   appId: 'your_app_id',
  ///   clientToken: 'your_client_token',
  /// );
  /// 
  /// // Share an image
  /// final result = await FlutterSocialShare.facebook.shareImage(
  ///   imagePath,
  ///   caption: 'Optional caption',
  /// );
  /// ```
  static FacebookShare get facebook {
    _ensureInitialized();
    return FacebookShare.instance;
  }

  // Future platform access points can be added here:
  // 
  // /// Access to Twitter sharing functionality.
  // /// 
  // /// Provides methods to initialize the Twitter SDK and share content to Twitter.
  // /// The Twitter app must be installed on the device for sharing to work.
  // static TwitterShare get twitter {
  //   _ensureInitialized();
  //   return TwitterShare.instance;
  // }
  // 
  // /// Access to Instagram sharing functionality.
  // /// 
  // /// Provides methods to initialize the Instagram SDK and share content to Instagram.
  // /// The Instagram app must be installed on the device for sharing to work.
  // static InstagramShare get instagram {
  //   _ensureInitialized();
  //   return InstagramShare.instance;
  // }
}
