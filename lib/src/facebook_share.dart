library;

import 'models/credentials.dart';
import 'models/share_models.dart';
import 'platform_interface/facebook_platform_interface.dart';

/// Facebook sharing functionality.
class FacebookShare {
  static final FacebookShare _instance = FacebookShare._();
  FacebookShare._();
  
  static FacebookShare get instance => _instance;
  
  bool get isInitialized => FacebookPlatformInterface.instance.isInitialized;
  
  /// Initialize Facebook SDK with credentials.
  Future<void> init({
    String? appId,
    String? clientToken,
  }) async {
    FacebookCredentials credentials;
    
    if (appId != null && clientToken != null) {
      credentials = FacebookCredentials(
        appId: appId,
        clientToken: clientToken,
      );
    } else {
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