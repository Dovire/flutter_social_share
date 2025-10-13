/// Plugin initialization and registration
library;

import 'method_channel/facebook_method_channel.dart';
import 'platform_interface/facebook_platform_interface.dart';

/// Initialize the plugin and register platform implementations
class FlutterSocialSharePlugin {
  static bool _registered = false;
  
  /// Register platform implementations
  static void registerWith() {
    if (_registered) return;
    
    final facebookChannel = FacebookMethodChannel();
    
    // Register Facebook platform implementation
    FacebookPlatformInterface.instance = facebookChannel;
    
    _registered = true;
  }
}