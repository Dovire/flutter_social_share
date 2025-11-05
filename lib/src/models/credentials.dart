library;

abstract class SocialCredentials {
  Map<String, String> toMap();
  bool isValid();
}

// =====================================================================================================================

class FacebookCredentials implements SocialCredentials {
  /// Facebook App ID.
  ///
  /// **Where to find**: Facebook Developers Console > Your App > Settings > Basic > App ID
  final String appId;

  /// Facebook Client Token.
  ///
  /// **Where to find**: Facebook Developers Console > Your App > Settings > Basic > Client Token
  final String clientToken;

  const FacebookCredentials({required this.appId, required this.clientToken});

  factory FacebookCredentials.fromEnvironment() {
    return FacebookCredentials(
      appId: const String.fromEnvironment('FB_APP_ID'),
      clientToken: const String.fromEnvironment('FB_CLIENT_TOKEN'),
    );
  }

  @override
  Map<String, String> toMap() {
    return {'appId': appId, 'clientToken': clientToken};
  }

  @override
  bool isValid() {
    return appId.isNotEmpty && clientToken.isNotEmpty;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FacebookCredentials && other.appId == appId && other.clientToken == clientToken;
  }

  @override
  int get hashCode => appId.hashCode ^ clientToken.hashCode;

  @override
  String toString() {
    return 'FacebookCredentials(appId: ${appId.isNotEmpty ? '[REDACTED]' : '[EMPTY]'}, '
        'clientToken: ${clientToken.isNotEmpty ? '[REDACTED]' : '[EMPTY]'})';
  }
}

// =====================================================================================================================
