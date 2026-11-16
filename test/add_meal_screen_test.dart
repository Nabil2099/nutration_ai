import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutration_ai/core/theme/app_theme.dart';
import 'package:nutration_ai/features/meals/presentation/screens/add_meal_screen.dart';

void main() {
  testWidgets('Add Meal renders and updates meal selection', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const AddMealScreen()),
    );
    await tester.pump();

    expect(find.text('Add Meal'), findsOneWidget);
    expect(find.text('Grilled Chicken Breast'), findsOneWidget);
    expect(find.text('Added to Lunch'), findsOneWidget);

    await tester.tap(find.text('Dinner'));
    await tester.pump();
    expect(find.text('Added to Dinner'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Steamed Broccoli'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byTooltip('Add Steamed Broccoli'));
    await tester.pump();
    expect(find.byTooltip('Remove Steamed Broccoli'), findsOneWidget);
    expect(find.text('257 kcal'), findsOneWidget);
  });
}
