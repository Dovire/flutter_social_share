/// Data models for social sharing functionality.
/// 
/// This library contains all the data models used for sharing content to social
/// platforms, including request models, result models, and enums for status
/// and error codes.
/// 
/// ## Core Classes
/// 
/// - [ShareImageRequest]: Request model for sharing images
/// - [ShareResult]: Result model containing share operation outcome
/// - [ShareStatus]: Enum representing the status of a share operation
/// - [ShareErrorCode]: Enum representing specific error conditions
/// - [SocialPlatform]: Enum representing supported social platforms
/// 
/// ## Usage Example
/// 
/// ```dart
/// // Create a share request
/// final request = ShareImageRequest(
///   imagePath: '/path/to/image.jpg',
///   caption: 'Check out this photo!',
///   platform: SocialPlatform.facebook,
/// );
/// 
/// // Handle share result
/// final result = await shareImage(request);
/// switch (result.status) {
///   case ShareStatus.success:
///     print('Share successful!');
///     break;
///   case ShareStatus.cancelled:
///     print('User cancelled share');
///     break;
///   case ShareStatus.error:
///     print('Share failed: ${result.errorMessage}');
///     print('Error code: ${result.errorCode}');
///     break;
/// }
/// ```
library;

/// Represents a request to share an image to a social platform.
/// 
/// This class encapsulates all the information needed to share an image,
/// including the image path, optional caption, and target platform.
/// 
/// Example:
/// ```dart
/// final request = ShareImageRequest(
///   imagePath: '/path/to/image.jpg',
///   caption: 'Check out this photo!',
///   platform: SocialPlatform.facebook,
/// );
/// ```
class ShareImageRequest {
  /// Path to the image file to share.
  /// 
  /// Must be a valid, accessible file path. The file should exist and be
  /// readable by the application. Supported formats depend on the target
  /// platform but typically include JPEG, PNG, and GIF.
  final String imagePath;
  
  /// Optional caption to include with the shared image.
  /// 
  /// This text will be pre-filled in the sharing dialog, but users can
  /// modify it before sharing. If null, no caption will be included.
  final String? caption;
  
  /// The social platform to share to.
  /// 
  /// Determines which platform-specific sharing implementation to use.
  /// Currently supports [SocialPlatform.facebook] with more platforms
  /// planned for future releases.
  final SocialPlatform platform;
  
  const ShareImageRequest({
    required this.imagePath,
    this.caption,
    required this.platform,
  });
  
  /// Convert to map for MethodChannel communication
  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'caption': caption,
      'platform': platform.name,
    };
  }
  
  /// Create from map for MethodChannel communication
  factory ShareImageRequest.fromMap(Map<String, dynamic> map) {
    return ShareImageRequest(
      imagePath: map['imagePath'] as String,
      caption: map['caption'] as String?,
      platform: SocialPlatform.values.firstWhere(
        (p) => p.name == map['platform'],
      ),
    );
  }
}

/// Represents the result of a share operation.
/// 
/// Contains the outcome of a social media sharing operation, including
/// success/failure status, error details, and convenience methods for
/// handling different result types.
/// 
/// ## Properties
/// 
/// - [status]: The overall status of the operation ([ShareStatus])
/// - [errorMessage]: Human-readable error description (if failed)
/// - [errorCode]: Specific error code for programmatic handling (if failed)
/// 
/// ## Convenience Methods
/// 
/// - [isSuccess]: Returns `true` if the share was successful
/// - [isCancelled]: Returns `true` if the user cancelled the share
/// - [isError]: Returns `true` if an error occurred
/// 
/// ## Usage Examples
/// 
/// ### Basic Result Handling
/// ```dart
/// final result = await FlutterSocialShare.facebook.shareImage('/path/to/image.jpg');
/// 
/// if (result.isSuccess) {
///   showSnackBar('Successfully shared to Facebook!');
/// } else if (result.isCancelled) {
///   showSnackBar('Share cancelled');
/// } else {
///   showSnackBar('Share failed: ${result.errorMessage}');
/// }
/// ```
/// 
/// ### Detailed Error Handling
/// ```dart
/// final result = await FlutterSocialShare.facebook.shareImage('/path/to/image.jpg');
/// 
/// switch (result.status) {
///   case ShareStatus.success:
///     analytics.trackEvent('share_success', {'platform': 'facebook'});
///     showSuccessDialog();
///     break;
///   case ShareStatus.cancelled:
///     analytics.trackEvent('share_cancelled', {'platform': 'facebook'});
///     // No action needed - user choice
///     break;
///   case ShareStatus.error:
///     analytics.trackEvent('share_error', {
///       'platform': 'facebook',
///       'error_code': result.errorCode?.name,
///       'error_message': result.errorMessage,
///     });
///     handleShareError(result);
///     break;
/// }
/// ```
/// 
/// ### Error-Specific Handling
/// ```dart
/// void handleShareError(ShareResult result) {
///   switch (result.errorCode) {
///     case ShareErrorCode.missingApp:
///       showDialog(
///         title: 'Facebook Not Installed',
///         message: 'Please install Facebook to share content.',
///         actions: [
///           TextButton(
///             onPressed: () => launchUrl('https://apps.apple.com/app/facebook/id284882215'),
///             child: Text('Install'),
///           ),
///         ],
///       );
///       break;
///     case ShareErrorCode.invalidPath:
///       showSnackBar('Please select a valid image file');
///       break;
///     case ShareErrorCode.initializationFailed:
///       showSnackBar('Please check your Facebook app configuration');
///       break;
///     default:
///       showSnackBar('Share failed: ${result.errorMessage}');
///   }
/// }
/// ```
class ShareResult {
  /// The status of the share operation.
  /// 
  /// Indicates whether the operation was successful, cancelled by the user,
  /// or failed with an error. Use the convenience methods [isSuccess],
  /// [isCancelled], and [isError] for easier checking.
  final ShareStatus status;
  
  /// Error message if the operation failed.
  /// 
  /// Contains a human-readable description of what went wrong when
  /// [status] is [ShareStatus.error]. This message is suitable for
  /// displaying to users or logging for debugging purposes.
  /// 
  /// Will be `null` when [status] is [ShareStatus.success] or
  /// [ShareStatus.cancelled].
  final String? errorMessage;
  
  /// Error code if the operation failed.
  /// 
  /// Provides a specific error code that can be used for programmatic
  /// error handling when [status] is [ShareStatus.error]. Use this to
  /// implement different recovery strategies for different error types.
  /// 
  /// Will be `null` when [status] is [ShareStatus.success] or
  /// [ShareStatus.cancelled].
  final ShareErrorCode? errorCode;
  
  const ShareResult({
    required this.status,
    this.errorMessage,
    this.errorCode,
  });
  
  /// Create a successful result
  factory ShareResult.success() {
    return const ShareResult(status: ShareStatus.success);
  }
  
  /// Create a cancelled result
  factory ShareResult.cancelled() {
    return const ShareResult(status: ShareStatus.cancelled);
  }
  
  /// Create an error result
  factory ShareResult.error(ShareErrorCode code, String message) {
    return ShareResult(
      status: ShareStatus.error,
      errorCode: code,
      errorMessage: message,
    );
  }
  
  /// Convert to map for MethodChannel communication
  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'errorMessage': errorMessage,
      'errorCode': errorCode?.name,
    };
  }
  
  /// Create from map for MethodChannel communication
  factory ShareResult.fromMap(Map<String, dynamic> map) {
    return ShareResult(
      status: ShareStatus.values.firstWhere(
        (s) => s.name == map['status'],
      ),
      errorMessage: map['errorMessage'] as String?,
      errorCode: map['errorCode'] != null
          ? ShareErrorCode.values.firstWhere(
              (e) => e.name == map['errorCode'],
            )
          : null,
    );
  }
  
  /// Whether the share operation was successful
  bool get isSuccess => status == ShareStatus.success;
  
  /// Whether the share operation was cancelled by the user
  bool get isCancelled => status == ShareStatus.cancelled;
  
  /// Whether the share operation failed with an error
  bool get isError => status == ShareStatus.error;
}

/// Status of a share operation.
/// 
/// Represents the three possible outcomes of a social media sharing operation:
/// successful completion, user cancellation, or error condition.
/// 
/// ## Usage
/// 
/// ```dart
/// final result = await FlutterSocialShare.facebook.shareImage('/path/to/image.jpg');
/// 
/// switch (result.status) {
///   case ShareStatus.success:
///     // Share completed successfully
///     showSuccessMessage('Posted to Facebook!');
///     break;
///   case ShareStatus.cancelled:
///     // User cancelled the share dialog
///     showInfoMessage('Share cancelled');
///     break;
///   case ShareStatus.error:
///     // An error occurred during sharing
///     showErrorMessage('Share failed: ${result.errorMessage}');
///     handleShareError(result.errorCode);
///     break;
/// }
/// ```
enum ShareStatus {
  /// The share operation completed successfully.
  /// 
  /// This indicates that the user successfully shared the content to the
  /// social platform. The content is now posted and visible according to
  /// the user's privacy settings.
  success,
  
  /// The share operation was cancelled by the user.
  /// 
  /// This occurs when the user opens the sharing dialog but then cancels
  /// it without posting. This is a normal user action and not an error
  /// condition.
  cancelled,
  
  /// The share operation failed with an error.
  /// 
  /// This indicates that an error occurred during the sharing process.
  /// Check [ShareResult.errorCode] and [ShareResult.errorMessage] for
  /// specific details about what went wrong.
  error,
}

/// Error codes for share operations.
/// 
/// Provides specific error codes that help identify and handle different
/// failure scenarios when sharing content to social platforms.
/// 
/// ## Error Handling Examples
/// 
/// ```dart
/// final result = await FlutterSocialShare.facebook.shareImage('/path/to/image.jpg');
/// 
/// if (result.isError) {
///   switch (result.errorCode) {
///     case ShareErrorCode.missingApp:
///       // Show dialog to install Facebook app
///       showInstallAppDialog('Facebook');
///       break;
///     case ShareErrorCode.invalidPath:
///       // Show file picker to select valid image
///       showImagePicker();
///       break;
///     case ShareErrorCode.initializationFailed:
///       // Retry initialization or show setup instructions
///       await retryInitialization();
///       break;
///     case ShareErrorCode.platformNotSupported:
///       // Show alternative sharing options
///       showAlternativeShareOptions();
///       break;
///     case ShareErrorCode.unknown:
///       // Log error and show generic message
///       logError(result.errorMessage);
///       showGenericErrorMessage();
///       break;
///     default:
///       showGenericErrorMessage();
///   }
/// }
/// ```
enum ShareErrorCode {
  /// The target social app is not installed on the device.
  /// 
  /// **Cause**: The required social media app (e.g., Facebook) is not
  /// installed on the user's device.
  /// 
  /// **Resolution**: Prompt the user to install the app from the App Store
  /// or Google Play Store, or provide alternative sharing methods.
  /// 
  /// **Example**: User tries to share to Facebook but doesn't have the
  /// Facebook app installed.
  missingApp,
  
  /// The provided image path is invalid or inaccessible.
  /// 
  /// **Cause**: The image file path is empty, points to a non-existent file,
  /// or the app doesn't have permission to access the file.
  /// 
  /// **Resolution**: Verify the file exists, check file permissions, or
  /// prompt the user to select a different image.
  /// 
  /// **Example**: Passing an empty string or a path to a deleted file.
  invalidPath,
  
  /// The SDK initialization failed.
  /// 
  /// **Cause**: The social platform SDK could not be initialized, usually
  /// due to invalid credentials, network issues, or missing configuration.
  /// 
  /// **Resolution**: Verify credentials are correct, check network
  /// connectivity, and ensure proper SDK setup.
  /// 
  /// **Example**: Invalid Facebook App ID or Client Token provided during
  /// initialization.
  initializationFailed,
  
  /// The requested social platform is not supported.
  /// 
  /// **Cause**: Attempting to share to a platform that is not yet
  /// implemented or supported by the plugin.
  /// 
  /// **Resolution**: Use a supported platform or wait for future plugin
  /// updates that add support for the requested platform.
  /// 
  /// **Example**: Trying to share to Instagram when only Facebook is
  /// currently supported.
  platformNotSupported,
  
  /// An unknown error occurred.
  /// 
  /// **Cause**: An unexpected error that doesn't fit into other categories,
  /// such as platform-specific issues or network problems.
  /// 
  /// **Resolution**: Check the error message for more details, retry the
  /// operation, or report the issue if it persists.
  /// 
  /// **Example**: Platform-specific SDK errors or unexpected API responses.
  unknown,
}

/// Supported social platforms.
/// 
/// Represents the social media platforms that are supported by this plugin
/// for sharing content. Each platform has its own specific implementation
/// and requirements.
/// 
/// ## Current Support
/// 
/// | Platform | Status | Requirements |
/// |----------|--------|--------------|
/// | Facebook | ✅ Supported | Facebook app installed, valid App ID & Client Token |
/// | Twitter  | 🚧 Planned | Coming in future release |
/// | Instagram| 🚧 Planned | Coming in future release |
/// 
/// ## Usage
/// 
/// ```dart
/// // Specify platform in share request
/// final request = ShareImageRequest(
///   imagePath: '/path/to/image.jpg',
///   caption: 'Check this out!',
///   platform: SocialPlatform.facebook, // Currently the only supported option
/// );
/// 
/// // Platform-specific sharing
/// switch (targetPlatform) {
///   case SocialPlatform.facebook:
///     await FlutterSocialShare.facebook.shareImage(imagePath, caption: caption);
///     break;
///   // Future platforms:
///   // case SocialPlatform.twitter:
///   //   await FlutterSocialShare.twitter.shareImage(imagePath, caption: caption);
///   //   break;
/// }
/// ```
enum SocialPlatform {
  /// Facebook platform.
  /// 
  /// **Requirements**:
  /// - Facebook app must be installed on the device
  /// - Valid Facebook App ID and Client Token
  /// - Network connectivity for authentication
  /// 
  /// **Features**:
  /// - Share images with optional captions
  /// - User can edit caption before posting
  /// - Respects user's privacy settings
  /// - Automatic image optimization by Facebook SDK
  /// 
  /// **Setup**: Get credentials from [Facebook Developers Console](https://developers.facebook.com/)
  facebook,
  
  // Future platforms will be added here:
  // 
  // /// Twitter platform.
  // /// 
  // /// **Requirements**:
  // /// - Twitter app must be installed on the device
  // /// - Valid Twitter API Key and API Secret
  // /// - Network connectivity for authentication
  // /// 
  // /// **Features**:
  // /// - Share images with optional text
  // /// - Character limit enforcement
  // /// - Hashtag and mention support
  // twitter,
  // 
  // /// Instagram platform.
  // /// 
  // /// **Requirements**:
  // /// - Instagram app must be installed on the device
  // /// - Valid Instagram App ID and App Secret
  // /// - Network connectivity for authentication
  // /// 
  // /// **Features**:
  // /// - Share images to Instagram Stories
  // /// - Share images to Instagram Feed
  // /// - Support for Instagram's aspect ratio requirements
  // instagram,
}