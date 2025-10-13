/// Method channel implementation for Facebook platform interface.
/// 
/// This library provides the concrete implementation of [FacebookPlatformInterface]
/// using Flutter's MethodChannel for communication with native platform code.
/// It handles the serialization/deserialization of data and error mapping
/// between Dart and native implementations.
/// 
/// ## Architecture
/// 
/// ```
/// FacebookShare (Dart API)
///         ↓
/// FacebookMethodChannel (this class)
///         ↓
/// MethodChannel ('flutter_social_share')
///         ↓
/// Native Platform Implementation (Android/iOS)
///         ↓
/// Facebook SDK (Native)
/// ```
/// 
/// ## Method Channel Protocol
/// 
/// This implementation uses the `flutter_social_share` method channel with
/// these methods:
/// 
/// - `initializeFacebook`: Initialize Facebook SDK with credentials
/// - `shareImageToFacebook`: Share an image with optional caption
/// 
/// ## Error Handling
/// 
/// Platform exceptions are mapped to [ShareResult] errors:
/// - `MISSING_APP` → [ShareErrorCode.missingApp]
/// - `INVALID_PATH` → [ShareErrorCode.invalidPath]
/// - `INITIALIZATION_FAILED` → [ShareErrorCode.initializationFailed]
/// - `PLATFORM_NOT_SUPPORTED` → [ShareErrorCode.platformNotSupported]
/// - Other errors → [ShareErrorCode.unknown]
/// 
/// ## Thread Safety
/// 
/// All MethodChannel calls are made on the main thread and are safe to call
/// from any isolate. The native implementations handle any necessary
/// background processing.
library;

import 'package:flutter/services.dart';
import '../models/share_models.dart';
import '../platform_interface/facebook_platform_interface.dart';

/// Method channel implementation of [FacebookPlatformInterface].
/// 
/// Provides the concrete implementation for Facebook sharing functionality
/// using Flutter's MethodChannel to communicate with native platform code.
/// This class handles data serialization, error mapping, and state management.
/// 
/// ## Usage
/// 
/// This class is typically registered automatically by the plugin:
/// 
/// ```dart
/// // Automatic registration (done by plugin)
/// FacebookPlatformInterface.instance = FacebookMethodChannel();
/// 
/// // Use via the high-level API
/// await FlutterSocialShare.facebook.init();
/// final result = await FlutterSocialShare.facebook.shareImage('/path/to/image.jpg');
/// ```
/// 
/// ## Method Channel Communication
/// 
/// All communication with native code happens through the `flutter_social_share`
/// method channel. Data is serialized to/from Maps for transmission.
/// 
/// ## State Management
/// 
/// This class tracks initialization state to provide early validation and
/// better error messages when methods are called before initialization.
class FacebookMethodChannel extends FacebookPlatformInterface {
  /// The method channel used to interact with the native platform.
  /// 
  /// Uses the channel name `flutter_social_share` to communicate with
  /// both Android and iOS native implementations. All method calls
  /// are made through this channel with appropriate data serialization.
  static const MethodChannel _channel = MethodChannel('flutter_social_share');
  
  /// Internal initialization state tracking.
  /// 
  /// Set to `true` when [initializeFacebook] completes successfully,
  /// `false` when initialization fails or hasn't been attempted.
  /// Used by [isInitialized] getter and for early validation.
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
      // Map platform exceptions to ShareResult errors
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