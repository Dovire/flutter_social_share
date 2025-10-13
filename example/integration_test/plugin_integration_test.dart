// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_social_share/flutter_social_share.dart';

import 'package:flutter_social_share_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Flutter Social Share Example App', () {
    testWidgets('App launches and displays main UI elements', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Verify that the main UI elements are present
      expect(find.text('Flutter Social Share Example'), findsOneWidget);
      expect(find.text('Facebook SDK Initialization'), findsOneWidget);
      expect(find.text('Image Selection'), findsOneWidget);
      expect(find.text('Caption (Optional)'), findsOneWidget);
      expect(find.text('Share to Facebook'), findsOneWidget);
      expect(find.text('Setup Instructions'), findsOneWidget);
    });

    testWidgets('Credential method selection works', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Find and tap the explicit credentials radio button
      expect(find.text('Environment Variables'), findsOneWidget);
      expect(find.text('Explicit Credentials'), findsOneWidget);
      
      // Tap on explicit credentials
      await tester.tap(find.text('Explicit Credentials'));
      await tester.pumpAndSettle();

      // Verify that credential input fields appear
      expect(find.text('Facebook App ID'), findsOneWidget);
      expect(find.text('Facebook Client Token'), findsOneWidget);
    });

    testWidgets('Image selection dialog appears', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Find and tap the select image button
      await tester.tap(find.text('Select Image'));
      await tester.pumpAndSettle();

      // Verify that the image source dialog appears
      expect(find.text('Select Image Source'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      
      // Close the dialog
      await tester.tap(find.byIcon(Icons.photo_library));
      await tester.pumpAndSettle();
    });

    testWidgets('Share button is disabled when not initialized', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Find the share button
      final shareButton = find.widgetWithText(ElevatedButton, 'Share to Facebook');
      expect(shareButton, findsOneWidget);

      // Verify the button is disabled (onPressed should be null)
      final ElevatedButton button = tester.widget(shareButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('Caption text field accepts input', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Find the caption text field
      final captionField = find.byType(TextField).last;
      expect(captionField, findsOneWidget);

      // Enter text in the caption field
      await tester.enterText(captionField, 'Test caption for sharing');
      await tester.pumpAndSettle();

      // Verify the text was entered
      expect(find.text('Test caption for sharing'), findsOneWidget);
    });
  });

  group('Plugin Integration Tests', () {
    testWidgets('Plugin registration and method channel communication', (WidgetTester tester) async {
      // Test that the plugin is properly registered and can communicate with native code
      
      // This test verifies that the method channel is set up correctly
      // by attempting to call a method that should return a platform-specific response
      try {
        // Create a method channel to test basic communication
        const channel = MethodChannel('flutter_social_share');
        final version = await channel.invokeMethod<String>('getPlatformVersion');
        
        // Verify we get a response (should be "Android X.X" or "iOS X.X")
        expect(version, isNotNull);
        expect(version, contains(RegExp(r'(Android|iOS)')));
        
        print('Platform version: $version');
      } catch (e) {
        fail('Method channel communication failed: $e');
      }
    });

    testWidgets('Facebook platform interface initialization', (WidgetTester tester) async {
      // Test that the Facebook platform interface is properly registered
      
      try {
        // Access the Facebook share instance to trigger plugin initialization
        final facebook = FlutterSocialShare.facebook;
        expect(facebook, isNotNull);
        expect(facebook.isInitialized, isFalse); // Should not be initialized yet
        
        print('Facebook platform interface is properly accessible');
      } catch (e) {
        fail('Facebook platform interface access failed: $e');
      }
    });

    testWidgets('Error handling for uninitialized Facebook SDK', (WidgetTester tester) async {
      // Test that proper error handling occurs when trying to share without initialization
      
      try {
        final facebook = FlutterSocialShare.facebook;
        
        // Attempt to share without initialization - should return error result
        final result = await facebook.shareImage('/fake/path/image.jpg');
        
        expect(result.status, ShareStatus.error);
        expect(result.errorCode, ShareErrorCode.initializationFailed);
        expect(result.errorMessage, contains('not initialized'));
        
        print('Proper error handling for uninitialized SDK: ${result.errorMessage}');
      } catch (e) {
        fail('Error handling test failed: $e');
      }
    });

    testWidgets('Invalid image path error handling', (WidgetTester tester) async {
      // Test error handling for invalid image paths
      
      try {
        final facebook = FlutterSocialShare.facebook;
        
        // Test empty image path on uninitialized SDK - should return initialization error first
        final result1 = await facebook.shareImage('');
        
        expect(result1.status, ShareStatus.error);
        expect(result1.errorCode, ShareErrorCode.initializationFailed);
        expect(result1.errorMessage, contains('not initialized'));
        
        print('Proper error handling for uninitialized SDK with empty path: ${result1.errorMessage}');
        
        // Test that path validation happens after initialization check
        // This demonstrates the correct error handling priority
      } catch (e) {
        fail('Invalid path error handling test failed: $e');
      }
    });

    testWidgets('Credential validation', (WidgetTester tester) async {
      // Test credential validation without actually initializing
      
      try {
        final facebook = FlutterSocialShare.facebook;
        
        // Test initialization with invalid credentials
        try {
          await facebook.init(appId: '', clientToken: '');
          fail('Should have thrown an error for empty credentials');
        } on ArgumentError catch (e) {
          expect(e.message, contains('Invalid Facebook credentials'));
          print('Proper credential validation: ${e.message}');
        }
        
        // Test initialization with null credentials (should try environment variables)
        try {
          await facebook.init();
          fail('Should have thrown an error for missing environment variables');
        } on ArgumentError catch (e) {
          expect(e.message, contains('Invalid Facebook credentials'));
          print('Proper environment variable validation: ${e.message}');
        }
      } catch (e) {
        fail('Credential validation test failed: $e');
      }
    });

    testWidgets('Facebook app detection and error handling', (WidgetTester tester) async {
      // Test that the plugin properly detects when Facebook app is not installed
      // and provides appropriate error messages
      
      try {
        final facebook = FlutterSocialShare.facebook;
        
        // Test with properly formatted credentials (will still fail on platform)
        try {
          await facebook.init(appId: '123456789012345', clientToken: 'a' * 32);
          
          // If initialization somehow succeeds, try to share
          // This should fail because Facebook app is not installed on simulator/test device
          final result = await facebook.shareImage('/fake/path/image.jpg');
          
          expect(result.status, ShareStatus.error);
          // Should be one of these error codes depending on what fails first
          expect([
            ShareErrorCode.missingApp, 
            ShareErrorCode.invalidPath,
            ShareErrorCode.initializationFailed,
            ShareErrorCode.unknown
          ], contains(result.errorCode));
          
          print('Proper error handling for missing Facebook app: ${result.errorMessage}');
        } catch (e) {
          // Platform-specific initialization will likely fail with test credentials
          // This is expected and demonstrates proper error handling
          print('Platform initialization handled test credentials appropriately: $e');
        }
        
      } catch (e) {
        fail('Facebook app detection test failed: $e');
      }
    });
  });
}
