import 'package:flutter_test/flutter_test.dart';
import 'package:happy_liver/main.dart';

void main() {
  testWidgets('Notification screen loads', (WidgetTester tester) async {

    await tester.pumpWidget(const HappyLiverApp());

    expect(find.text('Notifications'), findsOneWidget);

  });
}