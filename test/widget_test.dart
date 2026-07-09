import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phf_money_management/app.dart';

void main() {
  testWidgets('App landing screen test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Verify that the landing splash text is present.
    expect(find.text('PHF MONEY'), findsOneWidget);
  });
}
