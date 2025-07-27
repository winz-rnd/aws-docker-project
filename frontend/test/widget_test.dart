import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/main.dart';

void main() {
  testWidgets('App has title and buttons', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Wait for a few frames instead of pumpAndSettle (which times out due to animations)
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    
    // Check that the app loaded
    expect(find.byType(MyHomePage), findsOneWidget);
    
    // Find the scrollable widget
    final scrollableFinder = find.byType(Scrollable).first;
    
    // Scroll down to find Message Manager
    await tester.scrollUntilVisible(
      find.text('Message Manager'),
      300,
      scrollable: scrollableFinder,
    );
    await tester.pump();
    
    // Verify Message Manager is visible
    expect(find.text('Message Manager'), findsOneWidget);
    
    // Continue scrolling to find buttons
    await tester.scrollUntilVisible(
      find.text('Get Message'),
      300,
      scrollable: scrollableFinder,
    );
    await tester.pump();
    
    // Verify buttons are visible
    expect(find.text('Get Message'), findsOneWidget);
    expect(find.text('Save Message'), findsOneWidget);
  });
}