import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:personal_expense_tracker/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PersonalExpenseTrackerApp());
    expect(find.byType(PersonalExpenseTrackerApp), findsOneWidget);
  });
}
