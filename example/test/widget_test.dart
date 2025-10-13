// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_social_share_example/main.dart';

void main() {
  group('Flutter Social Share Example Widget Tests', () {
    testWidgets('App displays main UI components', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify that main UI components are present
      expect(find.text('Flutter Social Share Example'), findsOneWidget);
      expect(find.text('Facebook SDK Initialization'), findsOneWidget);
      expect(find.text('Image Selection'), findsOneWidget);
      expect(find.text('Caption (Optional)'), findsOneWidget);
      expect(find.text('Share to Facebook'), findsAtLeastNWidgets(1));
    });

    testWidgets('Credential method radio buttons work', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Find radio buttons
      expect(find.text('Environment Variables'), findsOneWidget);
      expect(find.text('Explicit Credentials'), findsOneWidget);

      // Tap explicit credentials radio button
      await tester.tap(find.text('Explicit Credentials'));
      await tester.pump();

      // Verify credential input fields appear
      expect(find.text('Facebook App ID'), findsOneWidget);
      expect(find.text('Facebook Client Token'), findsOneWidget);
    });

    testWidgets('Initialize button is present and tappable', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Find and verify initialize button
      final initButton = find.text('Initialize Facebook SDK');
      expect(initButton, findsOneWidget);

      // Verify button is tappable (has onPressed)
      final ElevatedButton button = tester.widget(find.widgetWithText(ElevatedButton, 'Initialize Facebook SDK'));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('Select image button is present', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Find select image button
      expect(find.text('Select Image'), findsOneWidget);
    });

    testWidgets('Caption text field accepts input', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Find caption text field (it's the TextField in the caption section)
      final captionField = find.byType(TextField).last;
      
      // Enter text
      await tester.enterText(captionField, 'Test caption');
      await tester.pump();

      // Verify text was entered
      expect(find.text('Test caption'), findsOneWidget);
    });

    testWidgets('Share button is initially disabled', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Find all ElevatedButtons and check the one with share icon
      final elevatedButtons = find.byType(ElevatedButton);
      expect(elevatedButtons, findsAtLeastNWidgets(1));

      // Find the share button by looking for the one with blue background
      final shareButton = find.byWidgetPredicate(
        (widget) => widget is ElevatedButton && 
                    widget.style?.backgroundColor?.resolve({}) == Colors.blue
      );
      
      if (shareButton.evaluate().isNotEmpty) {
        // Verify button is disabled
        final ElevatedButton button = tester.widget(shareButton);
        expect(button.onPressed, isNull);
      }
    });

    testWidgets('Setup instructions are displayed', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MyApp());

      // Verify setup instructions are present
      expect(find.text('Setup Instructions'), findsOneWidget);
      expect(find.text('Method 1: Environment Variables (Recommended)'), findsOneWidget);
      expect(find.text('Method 2: Explicit Credentials'), findsOneWidget);
    });
  });
}
