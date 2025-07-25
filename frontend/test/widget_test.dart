import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

void main() {
  testWidgets('App has title and buttons', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Wait for initial frame
    await tester.pump();
    
    // AnimatedTextKit may be in progress, so check for partial text or widget type
    // We can check for the AppBar or other static elements instead
    expect(find.byType(MyHomePage), findsOneWidget);

    // Scroll down to find buttons (they might be below the fold)
    await tester.pump(const Duration(seconds: 1));
    
    // Check for main widgets existence
    expect(find.textContaining('Message Manager'), findsOneWidget);
    expect(find.textContaining('API Server'), findsOneWidget);
    expect(find.textContaining('Database'), findsOneWidget);
    
    // Verify that buttons exist by scrolling if necessary
    final getMessageButton = find.text('Get Message');
    final saveMessageButton = find.text('Save Message');
    
    // Scroll to find buttons
    await tester.ensureVisible(getMessageButton);
    await tester.ensureVisible(saveMessageButton);
    
    expect(getMessageButton, findsOneWidget);
    expect(saveMessageButton, findsOneWidget);
  });
}