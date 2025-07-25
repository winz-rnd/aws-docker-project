import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

void main() {
  testWidgets('App has title and buttons', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Wait for animations
    await tester.pumpAndSettle();

    // Verify that our app has the expected elements
    expect(find.text('AWS Full Stack Demo'), findsOneWidget);

    // Verify that buttons exist
    expect(find.text('Get Message'), findsOneWidget);
    expect(find.text('Save Message'), findsOneWidget);
  });
}