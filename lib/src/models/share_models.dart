library;

class ShareImageRequest {
  final String imagePath;

  final String? caption;

  final SocialPlatform platform;
  
  const ShareImageRequest({
    required this.imagePath,
    this.caption,
    required this.platform,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'caption': caption,
      'platform': platform.name,
    };
  }
  
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

class ShareResult {
  final ShareStatus status;
  
  /// Error message if the operation failed.
  final String? errorMessage;
  
  /// Error code if the operation failed.
  final ShareErrorCode? errorCode;
  
  const ShareResult({
    required this.status,
    this.errorMessage,
    this.errorCode,
  });
  
  factory ShareResult.success() {
    return const ShareResult(status: ShareStatus.success);
  }
  
  factory ShareResult.cancelled() {
    return const ShareResult(status: ShareStatus.cancelled);
  }
  
  factory ShareResult.error(ShareErrorCode code, String message) {
    return ShareResult(
      status: ShareStatus.error,
      errorCode: code,
      errorMessage: message,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'status': status.name,
      'errorMessage': errorMessage,
      'errorCode': errorCode?.name,
    };
  }
  
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
  
  bool get isSuccess => status == ShareStatus.success;
  
  bool get isCancelled => status == ShareStatus.cancelled;
  
  bool get isError => status == ShareStatus.error;
}


enum ShareStatus {
  success,
  cancelled,
  error,
}

enum ShareErrorCode {
  missingApp,
  invalidPath,
  initializationFailed,
  platformNotSupported,
  unknown,
}

/// Supported social platforms.
enum SocialPlatform {
  facebook,
}