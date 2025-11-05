library;

import '../models/share_models.dart';

abstract class SocialPlatformInterface {
  Future<void> initialize(Map<String, String> credentials);
  
  Future<ShareResult> shareImage(ShareImageRequest request);
  
  bool get isInitialized;
  
  String get platformName;
}