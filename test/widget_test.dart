import 'package:flutter_test/flutter_test.dart';
import 'package:railbuddy/main.dart';

void main() {
  testWidgets('RailBuddy app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RailBuddyApp());
    expect(find.text('RailBuddy'), findsWidgets);
    expect(find.text('12951 · Mumbai Rajdhani'), findsOneWidget);
  });
}
