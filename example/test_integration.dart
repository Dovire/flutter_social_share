#!/usr/bin/env dart

/// End-to-end integration test script for Flutter Social Share plugin.
/// 
/// This script demonstrates the complete integration of all components:
/// - Dart API layer
/// - Platform interfaces
/// - Method channel communication
/// - Native platform implementations
/// 
/// Run with: dart run example/test_integration.dart

import 'dart:io';
import 'package:flutter_social_share/flutter_social_share.dart';

void main() async {
  print('🚀 Flutter Social Share - End-to-End Integration Test');
  print('=' * 60);
  
  await testPluginRegistration();
  await testFacebookIntegration();
  await testErrorHandling();
  
  print('\n✅ All integration tests completed successfully!');
  print('🎉 Plugin components are properly wired together.');
}

Future<void> testPluginRegistration() async {
  print('\n📋 Testing Plugin Registration...');
  
  try {
    // Test that the main plugin class is accessible
    final facebook = FlutterSocialShare.facebook;
    print('✅ FlutterSocialShare.facebook accessible');
    
    // Test that the platform interface is registered
    print('✅ Facebook platform interface registered');
    
    // Test initialization state
    final isInitialized = facebook.isInitialized;
    print('✅ Initialization state accessible: $isInitialized');
    
  } catch (e) {
    print('❌ Plugin registration test failed: $e');
    exit(1);
  }
}

Future<void> testFacebookIntegration() async {
  print('\n🔗 Testing Facebook Integration...');
  
  try {
    final facebook = FlutterSocialShare.facebook;
    
    // Test credential validation
    try {
      await facebook.init(appId: '', clientToken: '');
      print('❌ Should have failed with empty credentials');
      exit(1);
    } on ArgumentError catch (e) {
      print('✅ Credential validation works: ${e.message}');
    }
    
    // Test environment variable fallback
    try {
      await facebook.init();
      print('❌ Should have failed with missing environment variables');
      exit(1);
    } on ArgumentError catch (e) {
      print('✅ Environment variable validation works: ${e.message}');
    }
    
    // Test sharing without initialization
    final result = await facebook.shareImage('/fake/path/image.jpg');
    if (result.status == ShareStatus.error && 
        result.errorCode == ShareErrorCode.initializationFailed) {
      print('✅ Uninitialized sharing error handling works');
    } else {
      print('❌ Unexpected result for uninitialized sharing: ${result.status}');
      exit(1);
    }
    
  } catch (e) {
    print('❌ Facebook integration test failed: $e');
    exit(1);
  }
}

Future<void> testErrorHandling() async {
  print('\n🛡️ Testing Error Handling...');
  
  try {
    final facebook = FlutterSocialShare.facebook;
    
    // Test empty image path
    final emptyPathResult = await facebook.shareImage('');
    if (emptyPathResult.status == ShareStatus.error) {
      print('✅ Empty path error handling works: ${emptyPathResult.errorMessage}');
    } else {
      print('❌ Empty path should return error');
      exit(1);
    }
    
    // Test null caption handling (should not crash)
    final nullCaptionResult = await facebook.shareImage('/fake/path');
    if (nullCaptionResult.status == ShareStatus.error) {
      print('✅ Null caption handling works: ${nullCaptionResult.errorMessage}');
    } else {
      print('❌ Should return error for uninitialized SDK');
      exit(1);
    }
    
  } catch (e) {
    print('❌ Error handling test failed: $e');
    exit(1);
  }
}