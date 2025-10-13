/// Facebook-specific platform interface.
/// 
/// This library defines the Facebook-specific implementation of the social
/// platform interface. It handles Facebook SDK initialization, sharing
/// operations, and error handling specific to Facebook's requirements.
/// 
/// ## Facebook SDK Integration
/// 
/// This interface wraps the Facebook SDK for both Android and iOS:
/// - **Android**: Uses Facebook Android SDK with SharePhotoContent and ShareDialog
/// - **iOS**: Uses Facebook iOS SDK with FBSDKSharePhotoContent and ShareDialog
/// 
/// ## Requirements
/// 
/// - Facebook app must be installed on the device
/// - Valid Facebook App ID and Client Token from [Facebook Developers Console](https://developers.facebook.com/)
/// - Network connectivity for authentication and sharing
/// 
/// ## Credential Setup
/// 
/// 1. Go to [Facebook Developers Console](https://developers.facebook.com/)
/// 2. Create or select your app
/// 3. Go to Settings > Basic
/// 4. Copy the App ID and Client Token
/// 5. Configure in your app using `--dart-define`:
/// 
/// ```bash
/// flutter run \
///   --dart-define=FB_APP_ID=your_app_id \
///   --dart-define=FB_CLIENT_TOKEN=your_client_token
/// ```
/// 
/// ## Usage Example
/// 
/// ```dart
/// // Get the Facebook platform instance
/// final facebook = FacebookPlatformInterface.instance;
/// 
/// // Initialize with credentials
/// await facebook.initialize({
///   'appId': 'your_facebook_app_id',
///   'clientToken': 'your_facebook_client_token',
/// });
/// 
/// // Share an image
/// final request = ShareImageRequest(
///   imagePath: '/path/to/image.jpg',
///   caption: 'Check out this photo!',
///   platform: SocialPlatform.facebook,
/// );
/// 
/// final result = await facebook.shareImage(request);
/// ```
/// 
/// ## Error Handling
/// 
/// Facebook-specific errors are mapped to standard [ShareErrorCode] values:
/// - Facebook app not installed → [ShareErrorCode.missingApp]
/// - Invalid credentials → [ShareErrorCode.initializationFailed]
/// - File access issues → [ShareErrorCode.invalidPath]
/// - Network/SDK errors → [ShareErrorCode.unknown]
library;

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../models/share_models.dart';
import 'social_platform_interface.dart';

/// Platform interface for Facebook sharing functionality.
/// 
/// Extends [SocialPlatformInterface] to provide Facebook-specific sharing
/// capabilities. This interface is implemented by platform-specific classes
/// that handle the actual Facebook SDK integration.
/// 
/// ## Implementation Pattern
/// 
/// This interface follows Flutter's federated plugin pattern:
/// 
/// ```
/// FacebookPlatformInterface (this class)
///         ↓
/// FacebookMethodChannel (method channel implementation)
///         ↓
/// Native Facebook SDK (Android/iOS)
/// ```
/// 
/// ## Facebook-Specific Features
/// 
/// - **Programmatic SDK initialization**: No manual manifest/plist configuration required
/// - **Secure credential handling**: Credentials passed via MethodChannel
/// - **Image sharing**: Share images with optional captions to Facebook
/// - **Error mapping**: Platform-specific errors mapped to standard codes
/// - **App detection**: Automatic detection of Facebook app installation
/// 
/// ## Usage by Plugin Developers
/// 
/// ```dart
/// // Register a Facebook platform implementation
/// FacebookPlatformInterface.instance = MyFacebookImplementation();
/// 
/// // Use the registered implementation
/// final facebook = FacebookPlatformInterface.instance;
/// await facebook.initializeFacebook('app_id', 'client_token');
/// final result = await facebook.shareImageToFacebook('/path/to/image.jpg', 'caption');
/// ```
/// 
/// ## Thread Safety
/// 
/// All methods in this interface should be safe to call from the main thread.
/// Platform implementations should handle any necessary thread management
/// internally.
abstract class FacebookPlatformInterface extends PlatformInterface implements SocialPlatformInterface {
  
  /// Constructs a FacebookPlatformInterface.
  FacebookPlatformInterface() : super(token: _token);

  static final Object _token = Object();

  static FacebookPlatformInterface? _instance;

  /// The default instance of [FacebookPlatformInterface] to use.
  static FacebookPlatformInterface get instance {
    if (_instance == null) {
      throw StateError(
        'FacebookPlatformInterface has not been initialized. '
        'Make sure to set the instance before using it.',
      );
    }
    return _instance!;
  }

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FacebookPlatformInterface] when
  /// they register themselves.
  static set instance(FacebookPlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  @override
  String get platformName => 'Facebook';

  /// Initialize Facebook SDK with app credentials.
  /// 
  /// Sets up the Facebook SDK with the provided App ID and Client Token.
  /// This method handles the platform-specific SDK initialization without
  /// requiring manual configuration in Android manifests or iOS plists.
  /// 
  /// ## Parameters
  /// 
  /// - [appId]: Facebook App ID (15-16 digit number from Facebook Developers Console)
  /// - [clientToken]: Facebook Client Token (32-character hex string from Facebook Developers Console)
  /// 
  /// ## Platform Behavior
  /// 
  /// - **Android**: Calls `FacebookSdk.setApplicationId()` and `FacebookSdk.setClientToken()`
  /// - **iOS**: Calls `Settings.setAppID()` and `Settings.setClientToken()`
  /// 
  /// ## Error Conditions
  /// 
  /// Throws [PlatformException] if:
  /// - App ID or Client Token is invalid
  /// - Facebook SDK initialization fails
  /// - Network connectivity issues prevent SDK setup
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// try {
  ///   await FacebookPlatformInterface.instance.initializeFacebook(
  ///     '123456789012345',
  ///     'abcdef123456789abcdef123456789ab',
  ///   );
  ///   print('Facebook SDK initialized successfully');
  /// } on PlatformException catch (e) {
  ///   print('Facebook initialization failed: ${e.message}');
  /// }
  /// ```
  /// 
  /// ## Security Notes
  /// 
  /// - Credentials are transmitted securely via MethodChannel
  /// - Credentials are stored in memory only, never persisted
  /// - Use `--dart-define` to avoid hardcoding credentials
  Future<void> initializeFacebook(String appId, String clientToken);
  
  /// Share an image to Facebook with optional caption.
  /// 
  /// Opens the Facebook sharing dialog with the specified image and caption.
  /// The user can modify the caption and choose their audience before sharing.
  /// 
  /// ## Parameters
  /// 
  /// - [imagePath]: Absolute path to the image file to share
  /// - [caption]: Optional text to pre-fill in the sharing dialog
  /// 
  /// ## Supported Image Formats
  /// 
  /// - JPEG (.jpg, .jpeg)
  /// - PNG (.png)
  /// - GIF (.gif) - static images only
  /// 
  /// ## Platform Behavior
  /// 
  /// - **Android**: Uses `SharePhotoContent` and `ShareDialog` from Facebook Android SDK
  /// - **iOS**: Uses `FBSDKSharePhotoContent` and `FBSDKShareDialog` from Facebook iOS SDK
  /// 
  /// ## Returns
  /// 
  /// A [ShareResult] with one of these outcomes:
  /// - [ShareStatus.success]: User successfully shared the image
  /// - [ShareStatus.cancelled]: User cancelled the sharing dialog
  /// - [ShareStatus.error]: An error occurred (see [ShareErrorCode] for details)
  /// 
  /// ## Error Conditions
  /// 
  /// Returns [ShareResult] with [ShareStatus.error] for:
  /// - [ShareErrorCode.missingApp]: Facebook app not installed
  /// - [ShareErrorCode.invalidPath]: Image file not found or inaccessible
  /// - [ShareErrorCode.initializationFailed]: SDK not initialized
  /// - [ShareErrorCode.unknown]: Other platform-specific errors
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final result = await FacebookPlatformInterface.instance.shareImageToFacebook(
  ///   '/path/to/image.jpg',
  ///   'Check out this amazing sunset!',
  /// );
  /// 
  /// switch (result.status) {
  ///   case ShareStatus.success:
  ///     showSnackBar('Successfully shared to Facebook!');
  ///     break;
  ///   case ShareStatus.cancelled:
  ///     showSnackBar('Share cancelled');
  ///     break;
  ///   case ShareStatus.error:
  ///     if (result.errorCode == ShareErrorCode.missingApp) {
  ///       showInstallFacebookDialog();
  ///     } else {
  ///       showSnackBar('Share failed: ${result.errorMessage}');
  ///     }
  ///     break;
  /// }
  /// ```
  /// 
  /// ## Requirements
  /// 
  /// - Must call [initializeFacebook] successfully first
  /// - Facebook app must be installed on the device
  /// - Image file must exist and be readable
  /// - Device must have network connectivity
  Future<ShareResult> shareImageToFacebook(String imagePath, String? caption);
  
  @override
  Future<void> initialize(Map<String, String> credentials) async {
    final appId = credentials['appId'];
    final clientToken = credentials['clientToken'];
    
    if (appId == null || clientToken == null) {
      throw ArgumentError('Facebook credentials must include appId and clientToken');
    }
    
    await initializeFacebook(appId, clientToken);
  }
  
  @override
  Future<ShareResult> shareImage(ShareImageRequest request) async {
    if (request.platform != SocialPlatform.facebook) {
      return ShareResult.error(
        ShareErrorCode.platformNotSupported,
        'This interface only supports Facebook sharing',
      );
    }
    
    return shareImageToFacebook(request.imagePath, request.caption);
  }
}