import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/main.dart';

void main() {
  testWidgets('App has title and buttons', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Wait for initial frame and animations
    await tester.pumpAndSettle();
    
    // AnimatedTextKit may be in progress, so check for the AppBar widget
    expect(find.byType(MyHomePage), findsOneWidget);
    
    // Find the CustomScrollView
    final scrollViewFinder = find.byType(CustomScrollView);
    expect(scrollViewFinder, findsOneWidget);
    
    // Scroll down to find the Message Manager section
    await tester.dragUntilVisible(
      find.text('Message Manager'),
      scrollViewFinder,
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    
    // Now check for Message Manager
    expect(find.text('Message Manager'), findsOneWidget);
    
    // Continue scrolling to find buttons
    await tester.dragUntilVisible(
      find.text('Get Message'),
      scrollViewFinder,
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    
    // Verify that buttons exist
    expect(find.text('Get Message'), findsOneWidget);
    expect(find.text('Save Message'), findsOneWidget);
    
    // Check for other key elements
    expect(find.text('API Server'), findsOneWidget);
    expect(find.text('Database'), findsOneWidget);
  });
}