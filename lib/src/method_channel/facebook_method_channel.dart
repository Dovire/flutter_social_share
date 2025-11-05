library;

import 'package:flutter/services.dart';
import '../models/share_models.dart';
import '../platform_interface/facebook_platform_interface.dart';

class FacebookMethodChannel extends FacebookPlatformInterface {
  static const MethodChannel _channel = MethodChannel('flutter_social_share');
  
  bool _isInitialized = false;
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  Future<void> initializeFacebook(String appId, String clientToken) async {
    try {
      await _channel.invokeMethod<void>('initializeFacebook', {
        'appId': appId,
        'clientToken': clientToken,
      });
      _isInitialized = true;
    } on PlatformException catch (e) {
      _isInitialized = false;
      throw PlatformException(
        code: e.code,
        message: 'Failed to initialize Facebook SDK: ${e.message}',
        details: e.details,
      );
    }
  }
  
  @override
  Future<ShareResult> shareImageToFacebook(String imagePath, String? caption) async {
    if (!_isInitialized) {
      return ShareResult.error(
        ShareErrorCode.initializationFailed,
        'Facebook SDK not initialized',
      );
    }
    
    try {
      final result = await _channel.invokeMethod<Map<String, dynamic>>(
        'shareImageToFacebook',
        {
          'imagePath': imagePath,
          'caption': caption,
        },
      );
      
      if (result == null) {
        return ShareResult.error(
          ShareErrorCode.unknown,
          'Received null result from platform',
        );
      }
      
      return ShareResult.fromMap(result);
    } on PlatformException catch (e) {
      ShareErrorCode errorCode;
      switch (e.code) {
        case 'MISSING_APP':
          errorCode = ShareErrorCode.missingApp;
          break;
        case 'INVALID_PATH':
          errorCode = ShareErrorCode.invalidPath;
          break;
        case 'INITIALIZATION_FAILED':
          errorCode = ShareErrorCode.initializationFailed;
          break;
        case 'PLATFORM_NOT_SUPPORTED':
          errorCode = ShareErrorCode.platformNotSupported;
          break;
        default:
          errorCode = ShareErrorCode.unknown;
      }
      
      return ShareResult.error(errorCode, e.message ?? 'Unknown error occurred');
    }
  }
}