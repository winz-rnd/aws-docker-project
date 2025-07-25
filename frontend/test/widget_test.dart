import 'package:flutter_test/flutter_test.dart';
import '../lib/main.dart';

void main() {
  testWidgets('App has title and buttons', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our app has the expected title
    expect(find.text('Flutter + Spring Boot + MySQL'), findsOneWidget);

    // Verify that buttons exist
    expect(find.text('Get Message'), findsOneWidget);
    expect(find.text('Set Message'), findsOneWidget);
  });
}