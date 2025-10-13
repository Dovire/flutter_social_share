import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_social_share/src/facebook_share.dart';
import 'package:flutter_social_share/src/models/share_models.dart';
import 'package:flutter_social_share/src/platform_interface/facebook_platform_interface.dart';

/// Mock implementation of FacebookPlatformInterface for testing FacebookShare
class MockFacebookPlatformInterface extends FacebookPlatformInterface {
  bool _isInitialized = false;
  Map<String, String>? _lastCredentials;
  ShareImageRequest? _lastShareRequest;
  
  // Control test behavior
  bool shouldFailInitialization = false;
  bool shouldFailSharing = false;
  ShareResult? mockShareResult;
  Exception? initializationException;
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  Future<void> initialize(Map<String, String> credentials) async {
    _lastCredentials = Map.from(credentials);
    
    if (shouldFailInitialization) {
      _isInitialized = false;
      throw initializationException ?? Exception('Mock initialization failure');
    }
    
    _isInitialized = true;
  }
  
  @override
  Future<void> initializeFacebook(String appId, String clientToken) async {
    await initialize({'appId': appId, 'clientToken': clientToken});
  }
  
  @override
  Future<ShareResult> shareImage(ShareImageRequest request) async {
    _lastShareRequest = request;
    
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
  
  @override
  Future<ShareResult> shareImageToFacebook(String imagePath, String? caption) async {
    final request = ShareImageRequest(
      imagePath: imagePath,
      caption: caption,
      platform: SocialPlatform.facebook,
    );
    return shareImage(request);
  }
  
  // Test helper methods
  Map<String, String>? get lastCredentials => _lastCredentials;
  ShareImageRequest? get lastShareRequest => _lastShareRequest;
  
  void reset() {
    _isInitialized = false;
    _lastCredentials = null;
    _lastShareRequest = null;
    shouldFailInitialization = false;
    shouldFailSharing = false;
    mockShareResult = null;
    initializationException = null;
  }
}

void main() {
  group('FacebookShare', () {
    late MockFacebookPlatformInterface mockPlatform;
    late FacebookShare facebookShare;
    
    setUp(() {
      mockPlatform = MockFacebookPlatformInterface();
      FacebookPlatformInterface.instance = mockPlatform;
      facebookShare = FacebookShare.instance;
    });
    
    tearDown(() {
      mockPlatform.reset();
    });
    
    group('Initialization', () {
      test('initializes with explicit credentials', () async {
        await facebookShare.init(
          appId: 'test_app_id',
          clientToken: 'test_client_token',
        );
        
        expect(facebookShare.isInitialized, isTrue);
        expect(mockPlatform.lastCredentials, equals({
          'appId': 'test_app_id',
          'clientToken': 'test_client_token',
        }));
      });
      
      test('throws ArgumentError for invalid explicit credentials', () async {
        expect(
          () => facebookShare.init(appId: '', clientToken: 'test_token'),
          throwsA(isA<ArgumentError>()),
        );
        
        expect(
          () => facebookShare.init(appId: 'test_app', clientToken: ''),
          throwsA(isA<ArgumentError>()),
        );
        
        expect(
          () => facebookShare.init(appId: '', clientToken: ''),
          throwsA(isA<ArgumentError>()),
        );
      });
      
      test('throws ArgumentError for missing environment credentials', () async {
        // When no explicit credentials are provided and environment variables are empty
        expect(
          () => facebookShare.init(),
          throwsA(isA<ArgumentError>()),
        );
      });
      
      test('handles platform initialization failure', () async {
        mockPlatform.shouldFailInitialization = true;
        mockPlatform.initializationException = Exception('Platform init failed');
        
        expect(
          () => facebookShare.init(
            appId: 'test_app_id',
            clientToken: 'test_client_token',
          ),
          throwsA(isA<Exception>()),
        );
        
        expect(facebookShare.isInitialized, isFalse);
      });
      
      test('sets initialization state correctly on success', () async {
        expect(facebookShare.isInitialized, isFalse);
        
        await facebookShare.init(
          appId: 'test_app_id',
          clientToken: 'test_client_token',
        );
        
        expect(facebookShare.isInitialized, isTrue);
      });
      
      test('sets initialization state correctly on failure', () async {
        mockPlatform.shouldFailInitialization = true;
        
        try {
          await facebookShare.init(
            appId: 'test_app_id',
            clientToken: 'test_client_token',
          );
        } catch (e) {
          // Expected to fail
        }
        
        expect(facebookShare.isInitialized, isFalse);
      });
    });
    
    group('Image Sharing', () {
      setUp(() async {
        // Initialize for sharing tests
        await facebookShare.init(
          appId: 'test_app_id',
          clientToken: 'test_client_token',
        );
      });
      
      test('shares image successfully with caption', () async {
        mockPlatform.mockShareResult = ShareResult.success();
        
        final result = await facebookShare.shareImage(
          '/path/to/image.jpg',
          caption: 'Test caption',
        );
        
        expect(result.isSuccess, isTrue);
        expect(mockPlatform.lastShareRequest?.imagePath, equals('/path/to/image.jpg'));
        expect(mockPlatform.lastShareRequest?.caption, equals('Test caption'));
        expect(mockPlatform.lastShareRequest?.platform, equals(SocialPlatform.facebook));
      });
      
      test('shares image successfully without caption', () async {
        mockPlatform.mockShareResult = ShareResult.success();
        
        final result = await facebookShare.shareImage('/path/to/image.jpg');
        
        expect(result.isSuccess, isTrue);
        expect(mockPlatform.lastShareRequest?.imagePath, equals('/path/to/image.jpg'));
        expect(mockPlatform.lastShareRequest?.caption, isNull);
        expect(mockPlatform.lastShareRequest?.platform, equals(SocialPlatform.facebook));
      });
      
      test('returns error when not initialized', () async {
        // Create a new instance that's not initialized
        mockPlatform.reset();
        
        final result = await facebookShare.shareImage('/path/to/image.jpg');
        
        expect(result.isError, isTrue);
        expect(result.errorCode, equals(ShareErrorCode.initializationFailed));
        expect(result.errorMessage, contains('not initialized'));
      });
      
      test('returns error for empty image path', () async {
        final result = await facebookShare.shareImage('');
        
        expect(result.isError, isTrue);
        expect(result.errorCode, equals(ShareErrorCode.invalidPath));
        expect(result.errorMessage, contains('cannot be empty'));
      });
      
      test('handles platform sharing failure', () async {
        mockPlatform.shouldFailSharing = true;
        
        final result = await facebookShare.shareImage('/path/to/image.jpg');
        
        expect(result.isError, isTrue);
        expect(result.errorCode, equals(ShareErrorCode.unknown));
        expect(result.errorMessage, equals('Mock sharing failure'));
      });
      
      test('handles user cancellation', () async {
        mockPlatform.mockShareResult = ShareResult.cancelled();
        
        final result = await facebookShare.shareImage('/path/to/image.jpg');
        
        expect(result.isCancelled, isTrue);
        expect(result.errorCode, isNull);
        expect(result.errorMessage, isNull);
      });
      
      test('handles missing app error', () async {
        mockPlatform.mockShareResult = ShareResult.error(
          ShareErrorCode.missingApp,
          'Facebook app not installed',
        );
        
        final result = await facebookShare.shareImage('/path/to/image.jpg');
        
        expect(result.isError, isTrue);
        expect(result.errorCode, equals(ShareErrorCode.missingApp));
        expect(result.errorMessage, equals('Facebook app not installed'));
      });
      
      test('handles invalid path error', () async {
        mockPlatform.mockShareResult = ShareResult.error(
          ShareErrorCode.invalidPath,
          'Image file not found',
        );
        
        final result = await facebookShare.shareImage('/invalid/path.jpg');
        
        expect(result.isError, isTrue);
        expect(result.errorCode, equals(ShareErrorCode.invalidPath));
        expect(result.errorMessage, equals('Image file not found'));
      });
    });
    
    group('Singleton Behavior', () {
      test('returns same instance', () {
        final instance1 = FacebookShare.instance;
        final instance2 = FacebookShare.instance;
        
        expect(instance1, same(instance2));
      });
      
      test('maintains state across instance calls', () async {
        final instance1 = FacebookShare.instance;
        await instance1.init(
          appId: 'test_app_id',
          clientToken: 'test_client_token',
        );
        
        final instance2 = FacebookShare.instance;
        expect(instance2.isInitialized, isTrue);
      });
    });
    
    group('Error Scenarios', () {
      test('handles various error codes correctly', () async {
        await facebookShare.init(
          appId: 'test_app_id',
          clientToken: 'test_client_token',
        );
        
        // Test each error code
        final errorCodes = [
          ShareErrorCode.missingApp,
          ShareErrorCode.invalidPath,
          ShareErrorCode.initializationFailed,
          ShareErrorCode.platformNotSupported,
          ShareErrorCode.unknown,
        ];
        
        for (final errorCode in errorCodes) {
          mockPlatform.mockShareResult = ShareResult.error(
            errorCode,
            'Test error for $errorCode',
          );
          
          final result = await facebookShare.shareImage('/path/to/image.jpg');
          
          expect(result.isError, isTrue);
          expect(result.errorCode, equals(errorCode));
          expect(result.errorMessage, equals('Test error for $errorCode'));
        }
      });
      
      test('validates input parameters thoroughly', () async {
        await facebookShare.init(
          appId: 'test_app_id',
          clientToken: 'test_client_token',
        );
        
        // Test various invalid inputs
        final invalidPaths = ['', '   ', '\n', '\t'];
        
        for (final invalidPath in invalidPaths) {
          final result = await facebookShare.shareImage(invalidPath.trim());
          
          expect(result.isError, isTrue);
          expect(result.errorCode, equals(ShareErrorCode.invalidPath));
        }
      });
    });
  });
}