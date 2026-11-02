import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lift_off/main.dart';

void main() {
  testWidgets('shows the empty workout list and schedule action', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const LiftOffApp());
    await tester.pumpAndSettle();

    expect(find.text('Lift Off'), findsOneWidget);
    expect(find.text('No workouts scheduled yet.'), findsOneWidget);
    expect(find.text('Schedule a workout'), findsOneWidget);
  });
}
