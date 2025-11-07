import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_social_platform_share/flutter_social_share.dart';
import 'package:flutter_social_platform_share/src/platform_interface/facebook_platform_interface.dart';

/// Mock implementation of FacebookPlatformInterface for testing
class MockFacebookPlatformInterface extends FacebookPlatformInterface {
  bool _isInitialized = false;
  String? _lastAppId;
  String? _lastClientToken;
  String? _lastImagePath;
  String? _lastCaption;
  
  // Control test behavior
  bool shouldFailInitialization = false;
  bool shouldFailSharing = false;
  ShareResult? mockShareResult;
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  Future<void> initializeFacebook(String appId, String clientToken) async {
    _lastAppId = appId;
    _lastClientToken = clientToken;
    
    if (shouldFailInitialization) {
      throw Exception('Mock initialization failure');
    }
    
    _isInitialized = true;
  }
  
  @override
  Future<ShareResult> shareImageToFacebook(String imagePath, String? caption) async {
    _lastImagePath = imagePath;
    _lastCaption = caption;
    
    if (!_isInitialized) {
      return ShareResult.error(
        ShareErrorCode.initializationFailed,
        'Facebook SDK not initialized',
      );
    }
    
    if (shouldFailSharing) {
      return ShareResult.error(
        ShareErrorCode.unknown,
        'Mock sharing failure',
      );
    }
    
    return mockShareResult ?? ShareResult.success();
  }
  
  // Test helper methods
  String? get lastAppId => _lastAppId;
  String? get lastClientToken => _lastClientToken;
  String? get lastImagePath => _lastImagePath;
  String? get lastCaption => _lastCaption;
  
  void reset() {
    _isInitialized = false;
    _lastAppId = null;
    _lastClientToken = null;
    _lastImagePath = null;
    _lastCaption = null;
    shouldFailInitialization = false;
    shouldFailSharing = false;
    mockShareResult = null;
  }
}

void main() {
  group('FlutterSocialShare', () {
    late MockFacebookPlatformInterface mockPlatform;
    
    setUp(() {
      mockPlatform = MockFacebookPlatformInterface();
      FacebookPlatformInterface.instance = mockPlatform;
    });
    
    tearDown(() {
      mockPlatform.reset();
    });
    
    test('provides access to Facebook sharing functionality', () {
      final facebook = FlutterSocialShare.facebook;
      expect(facebook, isA<FacebookShare>());
      expect(FlutterSocialShare.facebook, same(facebook)); // Should be singleton
    });
  });
  
  group('FacebookCredentials', () {
    test('creates credentials with valid app ID and client token', () {
      const credentials = FacebookCredentials(
        appId: 'test_app_id',
        clientToken: 'test_client_token',
      );
      
      expect(credentials.appId, equals('test_app_id'));
      expect(credentials.clientToken, equals('test_client_token'));
      expect(credentials.isValid(), isTrue);
    });
    
    test('validates credentials correctly', () {
      const validCredentials = FacebookCredentials(
        appId: 'test_app_id',
        clientToken: 'test_client_token',
      );
      expect(validCredentials.isValid(), isTrue);
      
      const emptyAppId = FacebookCredentials(
        appId: '',
        clientToken: 'test_client_token',
      );
      expect(emptyAppId.isValid(), isFalse);
      
      const emptyClientToken = FacebookCredentials(
        appId: 'test_app_id',
        clientToken: '',
      );
      expect(emptyClientToken.isValid(), isFalse);
      
      const bothEmpty = FacebookCredentials(
        appId: '',
        clientToken: '',
      );
      expect(bothEmpty.isValid(), isFalse);
    });
    
    test('converts to map correctly', () {
      const credentials = FacebookCredentials(
        appId: 'test_app_id',
        clientToken: 'test_client_token',
      );
      
      final map = credentials.toMap();
      expect(map, equals({
        'appId': 'test_app_id',
        'clientToken': 'test_client_token',
      }));
    });
    
    test('equality and hashCode work correctly', () {
      const credentials1 = FacebookCredentials(
        appId: 'test_app_id',
        clientToken: 'test_client_token',
      );
      
      const credentials2 = FacebookCredentials(
        appId: 'test_app_id',
        clientToken: 'test_client_token',
      );
      
      const credentials3 = FacebookCredentials(
        appId: 'different_app_id',
        clientToken: 'test_client_token',
      );
      
      expect(credentials1, equals(credentials2));
      expect(credentials1.hashCode, equals(credentials2.hashCode));
      expect(credentials1, isNot(equals(credentials3)));
    });
    
    test('toString redacts sensitive information', () {
      const credentials = FacebookCredentials(
        appId: 'test_app_id',
        clientToken: 'test_client_token',
      );
      
      final string = credentials.toString();
      expect(string, contains('[REDACTED]'));
      expect(string, isNot(contains('test_app_id')));
      expect(string, isNot(contains('test_client_token')));
      
      const emptyCredentials = FacebookCredentials(
        appId: '',
        clientToken: '',
      );
      
      final emptyString = emptyCredentials.toString();
      expect(emptyString, contains('[EMPTY]'));
    });
  });
  
  group('ShareResult', () {
    test('creates success result correctly', () {
      final result = ShareResult.success();
      expect(result.status, equals(ShareStatus.success));
      expect(result.isSuccess, isTrue);
      expect(result.isCancelled, isFalse);
      expect(result.isError, isFalse);
      expect(result.errorMessage, isNull);
      expect(result.errorCode, isNull);
    });
    
    test('creates cancelled result correctly', () {
      final result = ShareResult.cancelled();
      expect(result.status, equals(ShareStatus.cancelled));
      expect(result.isSuccess, isFalse);
      expect(result.isCancelled, isTrue);
      expect(result.isError, isFalse);
      expect(result.errorMessage, isNull);
      expect(result.errorCode, isNull);
    });
    
    test('creates error result correctly', () {
      final result = ShareResult.error(
        ShareErrorCode.missingApp,
        'Facebook app not installed',
      );
      
      expect(result.status, equals(ShareStatus.error));
      expect(result.isSuccess, isFalse);
      expect(result.isCancelled, isFalse);
      expect(result.isError, isTrue);
      expect(result.errorCode, equals(ShareErrorCode.missingApp));
      expect(result.errorMessage, equals('Facebook app not installed'));
    });
    
    test('converts to and from map correctly', () {
      final originalResult = ShareResult.error(
        ShareErrorCode.invalidPath,
        'Invalid image path',
      );
      
      final map = originalResult.toMap();
      final reconstructedResult = ShareResult.fromMap(map);
      
      expect(reconstructedResult.status, equals(originalResult.status));
      expect(reconstructedResult.errorCode, equals(originalResult.errorCode));
      expect(reconstructedResult.errorMessage, equals(originalResult.errorMessage));
    });
  });
  
  group('ShareImageRequest', () {
    test('creates request with required parameters', () {
      const request = ShareImageRequest(
        imagePath: '/path/to/image.jpg',
        platform: SocialPlatform.facebook,
      );
      
      expect(request.imagePath, equals('/path/to/image.jpg'));
      expect(request.caption, isNull);
      expect(request.platform, equals(SocialPlatform.facebook));
    });
    
    test('creates request with optional caption', () {
      const request = ShareImageRequest(
        imagePath: '/path/to/image.jpg',
        caption: 'Test caption',
        platform: SocialPlatform.facebook,
      );
      
      expect(request.imagePath, equals('/path/to/image.jpg'));
      expect(request.caption, equals('Test caption'));
      expect(request.platform, equals(SocialPlatform.facebook));
    });
    
    test('converts to and from map correctly', () {
      const originalRequest = ShareImageRequest(
        imagePath: '/path/to/image.jpg',
        caption: 'Test caption',
        platform: SocialPlatform.facebook,
      );
      
      final map = originalRequest.toMap();
      final reconstructedRequest = ShareImageRequest.fromMap(map);
      
      expect(reconstructedRequest.imagePath, equals(originalRequest.imagePath));
      expect(reconstructedRequest.caption, equals(originalRequest.caption));
      expect(reconstructedRequest.platform, equals(originalRequest.platform));
    });
  });
}
