/// Credential management classes for social platforms.
/// 
/// This library provides secure credential management for social media platform
/// SDKs. Credentials can be provided via environment variables (recommended) or
/// explicitly in code.
/// 
/// ## Security Best Practices
/// 
/// - **Use `--dart-define`**: Pass credentials via build-time environment variables
/// - **Never hardcode**: Don't include credentials directly in source code
/// - **Memory-only storage**: Credentials are stored in memory only, never persisted
/// - **Secure transmission**: Credentials are passed securely via MethodChannel
/// 
/// ## Supported Platforms
/// 
/// - [FacebookCredentials]: Facebook App ID and Client Token
/// - Future: TwitterCredentials, InstagramCredentials, etc.
/// 
/// ## Usage Examples
/// 
/// ### Environment Variables (Recommended)
/// ```bash
/// # Build with credentials
/// flutter run --dart-define=FB_APP_ID=123456789 --dart-define=FB_CLIENT_TOKEN=abc123def456
/// ```
/// 
/// ```dart
/// // Use environment variables
/// final credentials = FacebookCredentials.fromEnvironment();
/// if (credentials.isValid()) {
///   await initializeFacebook(credentials);
/// }
/// ```
/// 
/// ### Explicit Credentials (Not Recommended for Production)
/// ```dart
/// // Only for testing or development
/// final credentials = FacebookCredentials(
///   appId: 'your_app_id',
///   clientToken: 'your_client_token',
/// );
/// ```
library;

/// Base class for social platform credentials.
/// 
/// Defines the common interface that all social platform credential classes
/// must implement. This ensures consistent credential handling across all
/// supported platforms.
/// 
/// ## Implementation Requirements
/// 
/// All credential classes must:
/// - Implement [toMap] for secure MethodChannel transmission
/// - Implement [isValid] for credential validation
/// - Support environment variable initialization
/// - Never persist credentials to disk
/// 
/// ## Security Considerations
/// 
/// - Credentials are stored in memory only
/// - [toMap] is used for secure MethodChannel communication
/// - [toString] should redact sensitive information
/// - Validation should check for empty/null values
abstract class SocialCredentials {
  /// Convert credentials to map for secure transmission.
  /// 
  /// Converts the credential object to a Map<String, String> format
  /// suitable for secure transmission via MethodChannel to native
  /// platform implementations.
  /// 
  /// ## Security Note
  /// 
  /// The returned map contains sensitive information and should only
  /// be used for immediate transmission to native code. Do not store
  /// or log the returned map.
  /// 
  /// ## Example
  /// ```dart
  /// final credentials = FacebookCredentials.fromEnvironment();
  /// final credentialMap = credentials.toMap();
  /// // credentialMap is now ready for MethodChannel transmission
  /// await methodChannel.invokeMethod('initialize', credentialMap);
  /// ```
  Map<String, String> toMap();
  
  /// Validate that all required credentials are present.
  /// 
  /// Checks that all required credential fields are non-empty and valid.
  /// This should be called before attempting to initialize any SDK to
  /// provide early validation and clear error messages.
  /// 
  /// ## Returns
  /// 
  /// - `true` if all required credentials are present and valid
  /// - `false` if any required credential is missing or empty
  /// 
  /// ## Example
  /// ```dart
  /// final credentials = FacebookCredentials.fromEnvironment();
  /// if (!credentials.isValid()) {
  ///   throw ArgumentError(
  ///     'Invalid Facebook credentials. Please set FB_APP_ID and FB_CLIENT_TOKEN '
  ///     'via --dart-define or provide them explicitly.'
  ///   );
  /// }
  /// ```
  bool isValid();
}

/// Facebook app credentials for SDK initialization.
/// 
/// Contains the Facebook App ID and Client Token required to initialize
/// the Facebook SDK for sharing functionality. These credentials can be
/// obtained from the Facebook Developers Console.
/// 
/// ## Getting Facebook Credentials
/// 
/// 1. Go to [Facebook Developers Console](https://developers.facebook.com/)
/// 2. Create or select your app
/// 3. Go to Settings > Basic
/// 4. Copy the App ID and Client Token
/// 
/// ## Security Best Practices
/// 
/// - **Use environment variables**: Pass credentials via `--dart-define`
/// - **Never commit credentials**: Don't include them in source control
/// - **Rotate regularly**: Update credentials periodically for security
/// - **Restrict permissions**: Configure minimal required permissions in Facebook Console
/// 
/// ## Usage Examples
/// 
/// ### Environment Variables (Recommended)
/// ```bash
/// # Set credentials at build time
/// flutter run \
///   --dart-define=FB_APP_ID=123456789012345 \
///   --dart-define=FB_CLIENT_TOKEN=abcdef123456789abcdef123456789ab
/// ```
/// 
/// ```dart
/// // Load from environment
/// final credentials = FacebookCredentials.fromEnvironment();
/// 
/// // Validate before use
/// if (!credentials.isValid()) {
///   throw ArgumentError('Facebook credentials not configured properly');
/// }
/// 
/// // Initialize Facebook SDK
/// await FlutterSocialShare.facebook.init();
/// ```
/// 
/// ### Explicit Credentials (Development Only)
/// ```dart
/// // Only for development/testing - never in production
/// final credentials = FacebookCredentials(
///   appId: '123456789012345',
///   clientToken: 'abcdef123456789abcdef123456789ab',
/// );
/// 
/// await FlutterSocialShare.facebook.init(
///   appId: credentials.appId,
///   clientToken: credentials.clientToken,
/// );
/// ```
/// 
/// ## Validation
/// 
/// ```dart
/// final credentials = FacebookCredentials.fromEnvironment();
/// 
/// if (credentials.isValid()) {
///   print('✅ Facebook credentials are valid');
/// } else {
///   print('❌ Missing or invalid Facebook credentials');
///   print('Please set FB_APP_ID and FB_CLIENT_TOKEN via --dart-define');
/// }
/// ```
class FacebookCredentials implements SocialCredentials {
  /// Facebook App ID.
  /// 
  /// A unique identifier for your Facebook app, obtained from the
  /// Facebook Developers Console. This is typically a 15-16 digit number.
  /// 
  /// **Example**: `123456789012345`
  /// 
  /// **Where to find**: Facebook Developers Console > Your App > Settings > Basic > App ID
  final String appId;
  
  /// Facebook Client Token.
  /// 
  /// A secret token used to authenticate your app with Facebook's servers.
  /// This is a 32-character hexadecimal string that should be kept secure.
  /// 
  /// **Example**: `abcdef123456789abcdef123456789ab`
  /// 
  /// **Where to find**: Facebook Developers Console > Your App > Settings > Basic > Client Token
  /// 
  /// **Security Note**: This token should never be exposed in client-side code
  /// or committed to version control. Use `--dart-define` to pass it securely.
  final String clientToken;
  
  const FacebookCredentials({
    required this.appId,
    required this.clientToken,
  });
  
  /// Create credentials from environment variables set via --dart-define.
  /// 
  /// Reads Facebook credentials from environment variables that were set
  /// at build time using `--dart-define`. This is the recommended approach
  /// for securely providing credentials without hardcoding them.
  /// 
  /// ## Environment Variables
  /// 
  /// - `FB_APP_ID`: Your Facebook App ID (15-16 digit number)
  /// - `FB_CLIENT_TOKEN`: Your Facebook Client Token (32-character hex string)
  /// 
  /// ## Build Command Example
  /// 
  /// ```bash
  /// flutter run \
  ///   --dart-define=FB_APP_ID=123456789012345 \
  ///   --dart-define=FB_CLIENT_TOKEN=abcdef123456789abcdef123456789ab
  /// ```
  /// 
  /// ## Usage
  /// 
  /// ```dart
  /// // Load credentials from environment
  /// final credentials = FacebookCredentials.fromEnvironment();
  /// 
  /// // Always validate before using
  /// if (!credentials.isValid()) {
  ///   throw ArgumentError(
  ///     'Facebook credentials not found. Please set FB_APP_ID and FB_CLIENT_TOKEN '
  ///     'via --dart-define when building your app.'
  ///   );
  /// }
  /// 
  /// // Use for initialization
  /// await FlutterSocialShare.facebook.init();
  /// ```
  /// 
  /// ## Troubleshooting
  /// 
  /// If credentials are not found:
  /// 1. Verify you're using `--dart-define` with correct variable names
  /// 2. Check that the values are not empty or contain only whitespace
  /// 3. Ensure you're building/running with the same command that sets the variables
  /// 4. For release builds, make sure to include the defines in your build command
  /// 
  /// ## Returns
  /// 
  /// A [FacebookCredentials] instance with values from environment variables.
  /// If the environment variables are not set, the fields will be empty strings.
  /// Use [isValid] to check if the credentials are properly configured.
  factory FacebookCredentials.fromEnvironment() {
    return FacebookCredentials(
      appId: const String.fromEnvironment('FB_APP_ID'),
      clientToken: const String.fromEnvironment('FB_CLIENT_TOKEN'),
    );
  }
  
  @override
  Map<String, String> toMap() {
    return {
      'appId': appId,
      'clientToken': clientToken,
    };
  }
  
  @override
  bool isValid() {
    return appId.isNotEmpty && clientToken.isNotEmpty;
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FacebookCredentials &&
        other.appId == appId &&
        other.clientToken == clientToken;
  }
  
  @override
  int get hashCode => appId.hashCode ^ clientToken.hashCode;
  
  @override
  String toString() {
    return 'FacebookCredentials(appId: ${appId.isNotEmpty ? '[REDACTED]' : '[EMPTY]'}, '
           'clientToken: ${clientToken.isNotEmpty ? '[REDACTED]' : '[EMPTY]'})';
  }
}

// Future credential classes for other platforms
/*
class TwitterCredentials implements SocialCredentials {
  final String apiKey;
  final String apiSecret;
  
  const TwitterCredentials({
    required this.apiKey,
    required this.apiSecret,
  });
  
  factory TwitterCredentials.fromEnvironment() {
    return TwitterCredentials(
      apiKey: const String.fromEnvironment('TWITTER_API_KEY'),
      apiSecret: const String.fromEnvironment('TWITTER_API_SECRET'),
    );
  }
  
  @override
  Map<String, String> toMap() {
    return {
      'apiKey': apiKey,
      'apiSecret': apiSecret,
    };
  }
  
  @override
  bool isValid() {
    return apiKey.isNotEmpty && apiSecret.isNotEmpty;
  }
}
*/