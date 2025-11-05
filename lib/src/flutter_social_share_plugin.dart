library;

import 'method_channel/facebook_method_channel.dart';
import 'platform_interface/facebook_platform_interface.dart';

class FlutterSocialSharePlugin {
  static bool _registered = false;
  
  static void registerWith() {
    if (_registered) return;
    
    final facebookChannel = FacebookMethodChannel();
    FacebookPlatformInterface.instance = facebookChannel;
    
    _registered = true;
  }
}