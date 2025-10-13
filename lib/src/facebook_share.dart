/// Facebook sharing implementation
library;

import 'models/credentials.dart';
import 'models/share_models.dart';
import 'platform_interface/facebook_platform_interface.dart';

/// Facebook sharing functionality.
/// 
/// This class provides methods to initialize the Facebook SDK and share images
/// to Facebook with optional captions. The Facebook app must be installed on
/// the device for sharing to work.
/// 
/// ## Usage
/// 
/// ### Basic Usage with Environment Variables
/// 
/// ```dart
/// // Initialize with credentials from --dart-define
/// await FlutterSocialShare.facebook.init();
/// 
/// // Share an image
/// final result = await FlutterSocialShare.facebook.shareImage(
///   '/path/to/image.jpg',
///   caption: 'Check out this photo!',
/// );
/// 
/// // Handle the result
/// if (result.isSuccess) {
///   print('Successfully shared!');
/// } else if (result.isCancelled) {
///   print('User cancelled');
/// } else {
///   print('Error: ${result.errorMessage}');
/// }
/// ```
/// 
/// ### Explicit Credential Initialization
/// 
/// ```dart
/// await FlutterSocialShare.facebook.init(
///   appId: 'your_facebook_app_id',
///   clientToken: 'your_facebook_client_token',
/// );
/// ```
/// 
/// ## Error Handling
/// 
/// The [shareImage] method returns a [ShareResult] that indicates:
/// - [ShareStatus.success]: Share completed successfully
/// - [ShareStatus.cancelled]: User cancelled the share dialog
/// - [ShareStatus.error]: An error occurred (see [ShareErrorCode] for details)
/// 
/// Common error codes:
/// - [ShareErrorCode.missingApp]: Facebook app not installed
/// - [ShareErrorCode.invalidPath]: Invalid image path
/// - [ShareErrorCode.initializationFailed]: SDK not initialized
/// 
/// ## Requirements
/// 
/// - Facebook app must be installed on the device
/// - Valid Facebook App ID and Client Token
/// - Image file must exist and be accessible
/// - Must call [init] before sharing
class FacebookShare {
  static final FacebookShare _instance = FacebookShare._();
  FacebookShare._();
  
  /// Get the singleton instance
  static FacebookShare get instance => _instance;
  
  /// Whether Facebook SDK is initialized.
  /// 
  /// Returns `true` if [init] has been called successfully, `false` otherwise.
  /// You must initialize the SDK before calling [shareImage].
  bool get isInitialized => FacebookPlatformInterface.instance.isInitialized;
  
  /// Initialize Facebook SDK with credentials.
  /// 
  /// If [appId] and [clientToken] are not provided, they will be read from
  /// environment variables set via `--dart-define`:
  /// - `FB_APP_ID`: Your Facebook App ID
  /// - `FB_CLIENT_TOKEN`: Your Facebook Client Token
  /// 
  /// Get these credentials from [Facebook Developers Console](https://developers.facebook.com/):
  /// 1. Go to your app's Settings > Basic
  /// 2. Copy the App ID and Client Token
  /// 
  /// ## Environment Variable Usage (Recommended)
  /// 
  /// ```bash
  /// flutter run --dart-define=FB_APP_ID=123456789 --dart-define=FB_CLIENT_TOKEN=abc123def456
  /// ```
  /// 
  /// ```dart
  /// await FlutterSocialShare.facebook.init(); // Uses environment variables
  /// ```
  /// 
  /// ## Explicit Credential Usage
  /// 
  /// ```dart
  /// await FlutterSocialShare.facebook.init(
  ///   appId: '123456789',
  ///   clientToken: 'abc123def456',
  /// );
  /// ```
  /// 
  /// ## Security Note
  /// 
  /// Credentials are stored in memory only and never persisted to disk.
  /// Using `--dart-define` is the recommended approach as it keeps credentials
  /// out of your source code.
  /// 
  /// Throws [ArgumentError] if credentials are invalid or missing.
  Future<void> init({
    String? appId,
    String? clientToken,
  }) async {
    FacebookCredentials credentials;
    
    if (appId != null && clientToken != null) {
      // Use explicitly provided credentials
      credentials = FacebookCredentials(
        appId: appId,
        clientToken: clientToken,
      );
    } else {
      // Use environment variables
      credentials = FacebookCredentials.fromEnvironment();
    }
    
    if (!credentials.isValid()) {
      throw ArgumentError(
        'Invalid Facebook credentials. Ensure FB_APP_ID and FB_CLIENT_TOKEN '
        'are set via --dart-define or provided explicitly. '
        'Get credentials from https://developers.facebook.com/',
      );
    }
    
    await FacebookPlatformInterface.instance.initialize(credentials.toMap());
  }
  
  /// Share an image to Facebook with optional caption.
  /// 
  /// Opens the Facebook sharing dialog with the specified image and caption.
  /// The user can modify the caption and choose their audience before sharing.
  /// 
  /// ## Parameters
  /// 
  /// - [imagePath]: Path to the image file to share. Must be a valid, accessible file path.
  ///   Supported formats: JPEG, PNG, GIF
  /// - [caption]: Optional text to include with the shared image. Can be modified by the user.
  /// 
  /// ## Returns
  /// 
  /// A [ShareResult] indicating the outcome:
  /// - [ShareStatus.success]: Image was shared successfully
  /// - [ShareStatus.cancelled]: User cancelled the sharing dialog
  /// - [ShareStatus.error]: An error occurred (see [ShareResult.errorCode] for details)
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// // Basic sharing
  /// final result = await FlutterSocialShare.facebook.shareImage('/path/to/image.jpg');
  /// 
  /// // Sharing with caption
  /// final result = await FlutterSocialShare.facebook.shareImage(
  ///   '/path/to/image.jpg',
  ///   caption: 'Check out this amazing sunset!',
  /// );
  /// 
  /// // Handle different outcomes
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
  /// ## Error Conditions
  /// 
  /// Returns [ShareResult] with [ShareStatus.error] in these cases:
  /// - [ShareErrorCode.initializationFailed]: [init] was not called or failed
  /// - [ShareErrorCode.invalidPath]: Image path is empty, invalid, or inaccessible
  /// - [ShareErrorCode.missingApp]: Facebook app is not installed
  /// - [ShareErrorCode.unknown]: Other platform-specific errors
  /// 
  /// ## Requirements
  /// 
  /// - Must call [init] successfully before sharing
  /// - Facebook app must be installed on the device
  /// - Image file must exist and be readable by the app
  /// - Device must have network connectivity (handled by Facebook SDK)
  /// 
  /// ## Platform Notes
  /// 
  /// - **Android**: Uses Facebook Android SDK SharePhotoContent and ShareDialog
  /// - **iOS**: Uses Facebook iOS SDK FBSDKSharePhotoContent and ShareDialog
  /// - Both platforms handle the sharing UI automatically
  /// - Large images are automatically optimized by the Facebook SDK
  Future<ShareResult> shareImage(
    String imagePath, {
    String? caption,
  }) async {
    if (!isInitialized) {
      return ShareResult.error(
        ShareErrorCode.initializationFailed,
        'Facebook SDK not initialized. Call init() first.',
      );
    }
    
    if (imagePath.isEmpty) {
      return ShareResult.error(
        ShareErrorCode.invalidPath,
        'Image path cannot be empty',
      );
    }
    
    final request = ShareImageRequest(
      imagePath: imagePath,
      caption: caption,
      platform: SocialPlatform.facebook,
    );
    
    return FacebookPlatformInterface.instance.shareImage(request);
  }
}