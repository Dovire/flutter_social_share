/// Base platform interface for social sharing functionality.
/// 
/// This library defines the common interface that all social platform
/// implementations must follow. It ensures consistent behavior across
/// different social media platforms while allowing platform-specific
/// customizations.
/// 
/// ## Architecture
/// 
/// The platform interface follows Flutter's federated plugin pattern:
/// 
/// ```
/// Flutter App
///     ↓
/// Platform Interface (this file)
///     ↓
/// Platform Implementation (e.g., FacebookPlatformInterface)
///     ↓
/// Method Channel Implementation
///     ↓
/// Native Platform Code (Android/iOS)
/// ```
/// 
/// ## Implementation Requirements
/// 
/// All platform implementations must:
/// - Extend [SocialPlatformInterface]
/// - Implement all abstract methods
/// - Handle platform-specific errors consistently
/// - Support secure credential management
/// - Provide proper initialization and cleanup
/// 
/// ## Usage for Plugin Developers
/// 
/// ```dart
/// // Implement a new social platform
/// class TwitterPlatformInterface extends SocialPlatformInterface {
///   @override
///   String get platformName => 'Twitter';
///   
///   @override
///   Future<void> initialize(Map<String, String> credentials) async {
///     // Twitter-specific initialization
///   }
///   
///   @override
///   Future<ShareResult> shareImage(ShareImageRequest request) async {
///     // Twitter-specific sharing implementation
///   }
///   
///   @override
///   bool get isInitialized => _isInitialized;
/// }
/// ```
library;

import '../models/share_models.dart';

/// Base interface for all social platform implementations.
/// 
/// Defines the contract that all social media platform implementations
/// must follow. This ensures consistent behavior and API across different
/// platforms while allowing for platform-specific customizations.
/// 
/// ## Implementation Guidelines
/// 
/// When implementing this interface:
/// 
/// 1. **Initialization**: [initialize] should validate credentials and set up the SDK
/// 2. **State Management**: [isInitialized] should accurately reflect initialization state
/// 3. **Error Handling**: Use consistent [ShareErrorCode] values across platforms
/// 4. **Security**: Never log or persist credentials passed to [initialize]
/// 5. **Platform Naming**: [platformName] should return a user-friendly platform name
/// 
/// ## Example Implementation
/// 
/// ```dart
/// class TwitterPlatformInterface extends SocialPlatformInterface {
///   bool _isInitialized = false;
///   
///   @override
///   String get platformName => 'Twitter';
///   
///   @override
///   bool get isInitialized => _isInitialized;
///   
///   @override
///   Future<void> initialize(Map<String, String> credentials) async {
///     final apiKey = credentials['apiKey'];
///     final apiSecret = credentials['apiSecret'];
///     
///     if (apiKey == null || apiSecret == null) {
///       throw ArgumentError('Twitter requires apiKey and apiSecret');
///     }
///     
///     // Initialize Twitter SDK
///     await TwitterSDK.initialize(apiKey: apiKey, apiSecret: apiSecret);
///     _isInitialized = true;
///   }
///   
///   @override
///   Future<ShareResult> shareImage(ShareImageRequest request) async {
///     if (!_isInitialized) {
///       return ShareResult.error(
///         ShareErrorCode.initializationFailed,
///         'Twitter SDK not initialized',
///       );
///     }
///     
///     // Platform-specific sharing logic
///     try {
///       await TwitterSDK.shareImage(request.imagePath, request.caption);
///       return ShareResult.success();
///     } catch (e) {
///       return ShareResult.error(ShareErrorCode.unknown, e.toString());
///     }
///   }
/// }
/// ```
abstract class SocialPlatformInterface {
  /// Initialize the platform with the provided credentials.
  /// 
  /// Sets up the social media platform SDK with the necessary credentials
  /// and configuration. This must be called before any sharing operations.
  /// 
  /// ## Parameters
  /// 
  /// - [credentials]: A map containing platform-specific credential keys and values.
  ///   The exact keys depend on the platform (e.g., 'appId' and 'clientToken' for Facebook).
  /// 
  /// ## Security Considerations
  /// 
  /// - Credentials are passed securely via MethodChannel
  /// - Never log or persist the credentials map
  /// - Store credentials in memory only during the session
  /// - Validate all required credentials before initialization
  /// 
  /// ## Error Handling
  /// 
  /// Should throw [ArgumentError] for invalid or missing credentials.
  /// Platform-specific errors should be wrapped appropriately.
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// // Facebook credentials
  /// await platform.initialize({
  ///   'appId': '123456789',
  ///   'clientToken': 'abc123def456',
  /// });
  /// 
  /// // Twitter credentials (hypothetical)
  /// await platform.initialize({
  ///   'apiKey': 'your_api_key',
  ///   'apiSecret': 'your_api_secret',
  /// });
  /// ```
  Future<void> initialize(Map<String, String> credentials);
  
  /// Share an image with optional caption.
  /// 
  /// Initiates the sharing flow for the specified image and caption to
  /// the social media platform. The exact sharing UI and behavior depend
  /// on the platform implementation.
  /// 
  /// ## Parameters
  /// 
  /// - [request]: A [ShareImageRequest] containing the image path, caption,
  ///   and target platform information.
  /// 
  /// ## Returns
  /// 
  /// A [ShareResult] indicating the outcome of the sharing operation:
  /// - [ShareStatus.success]: Share completed successfully
  /// - [ShareStatus.cancelled]: User cancelled the share dialog
  /// - [ShareStatus.error]: An error occurred (see [ShareErrorCode] for details)
  /// 
  /// ## Common Error Conditions
  /// 
  /// - [ShareErrorCode.initializationFailed]: Platform not initialized
  /// - [ShareErrorCode.invalidPath]: Image file not found or inaccessible
  /// - [ShareErrorCode.missingApp]: Social media app not installed
  /// - [ShareErrorCode.platformNotSupported]: Platform mismatch
  /// 
  /// ## Example
  /// 
  /// ```dart
  /// final request = ShareImageRequest(
  ///   imagePath: '/path/to/image.jpg',
  ///   caption: 'Check out this photo!',
  ///   platform: SocialPlatform.facebook,
  /// );
  /// 
  /// final result = await platform.shareImage(request);
  /// 
  /// switch (result.status) {
  ///   case ShareStatus.success:
  ///     print('Successfully shared!');
  ///     break;
  ///   case ShareStatus.cancelled:
  ///     print('User cancelled');
  ///     break;
  ///   case ShareStatus.error:
  ///     print('Error: ${result.errorMessage}');
  ///     break;
  /// }
  /// ```
  Future<ShareResult> shareImage(ShareImageRequest request);
  
  /// Check if the platform is properly initialized.
  /// 
  /// Returns `true` if [initialize] has been called successfully and the
  /// platform SDK is ready for sharing operations. Returns `false` if
  /// initialization hasn't been called or failed.
  /// 
  /// ## Usage
  /// 
  /// ```dart
  /// if (!platform.isInitialized) {
  ///   await platform.initialize(credentials);
  /// }
  /// 
  /// // Now safe to share
  /// final result = await platform.shareImage(request);
  /// ```
  /// 
  /// ## Implementation Notes
  /// 
  /// - Should be updated immediately when initialization state changes
  /// - Should return `false` if initialization failed or was never attempted
  /// - Should persist across multiple sharing operations until app restart
  bool get isInitialized;
  
  /// Get the platform name.
  /// 
  /// Returns a human-readable name for the social media platform.
  /// This is used for logging, error messages, and user-facing text.
  /// 
  /// ## Examples
  /// 
  /// - Facebook: `"Facebook"`
  /// - Twitter: `"Twitter"`
  /// - Instagram: `"Instagram"`
  /// 
  /// ## Usage
  /// 
  /// ```dart
  /// print('Initializing ${platform.platformName}...');
  /// 
  /// // In error messages
  /// throw Exception('Failed to initialize ${platform.platformName} SDK');
  /// 
  /// // In analytics
  /// analytics.track('share_attempt', {'platform': platform.platformName});
  /// ```
  String get platformName;
}