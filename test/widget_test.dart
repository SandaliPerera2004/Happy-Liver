import 'package:flutter_test/flutter_test.dart';

import 'package:happy_liver/main.dart';

void main() {
  testWidgets(
    'Happy Liver app smoke test',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const HappyLiverApp(),
      );

      await tester.pump();

      expect(
        find.byType(HappyLiverApp),
        findsOneWidget,
      );
    },
  );
}