library;

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../models/share_models.dart';
import 'social_platform_interface.dart';

abstract class FacebookPlatformInterface extends PlatformInterface implements SocialPlatformInterface {
  FacebookPlatformInterface() : super(token: _token);

  static final Object _token = Object();

  static FacebookPlatformInterface? _instance;

  static FacebookPlatformInterface get instance {
    if (_instance == null) {
      throw StateError(
        'FacebookPlatformInterface has not been initialized. '
        'Make sure to set the instance before using it.',
      );
    }
    return _instance!;
  }

  static set instance(FacebookPlatformInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  @override
  String get platformName => 'Facebook';

  Future<void> initializeFacebook(String appId, String clientToken);

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