import 'src/facebook_share.dart';
import 'src/flutter_social_share_plugin.dart';

export 'src/models/share_models.dart';
export 'src/models/credentials.dart';
export 'src/facebook_share.dart';

/// Flutter Social Share plugin for sharing images to social media platforms.
class FlutterSocialShare {
  static bool _initialized = false;

  static void _ensureInitialized() {
    if (!_initialized) {
      FlutterSocialSharePlugin.registerWith();
      _initialized = true;
    }
  }

  /// Access to Facebook sharing functionality.
  static FacebookShare get facebook {
    _ensureInitialized();
    return FacebookShare.instance;
  }
}
