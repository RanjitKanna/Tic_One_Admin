import 'package:flutter_test/flutter_test.dart';
import 'package:tic_one_admin/main.dart';

void main() {
  testWidgets('Admin App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TicOneAdminApp());
    expect(find.text('TicOne Admin Console'), findsWidgets);
  });
}
