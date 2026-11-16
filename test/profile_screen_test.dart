import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutration_ai/core/data/models/nutrition_goals.dart';
import 'package:nutration_ai/core/theme/app_theme.dart';
import 'package:nutration_ai/features/profile/presentation/screens/profile_screen.dart';

import 'support.dart';

class _FakeNutritionGoals extends Fake implements NutritionGoals {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeNutritionGoals()));

  testWidgets(
    'Profile displays user data, edits name/goals, units, and logs out',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final profiles = MockProfiles();
      when(() => profiles.updateName('a', 'Alex Rivera'))
          .thenAnswer((_) async {});
      when(() => profiles.updateGoals('a', any())).thenAnswer((_) async {});
      var loggedOut = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ProfileScreen(
              profile: profile(),
              profiles: profiles,
              onLogOut: () => loggedOut = true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Your personal space'), findsOneWidget);
      expect(find.text('Mona'), findsOneWidget);
      expect(find.text('2,000'), findsOneWidget);
      expect(find.text('120g'), findsOneWidget);

      await tester.tap(find.byTooltip('Edit profile name'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.enterText(find.byType(TextFormField).first, 'Alex Rivera');
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Alex Rivera'), findsOneWidget);
      verify(() => profiles.updateName('a', 'Alex Rivera')).called(1);

      await tester.tap(find.text('Edit').first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.enterText(find.byType(TextFormField).first, '2300');
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('2,300'), findsOneWidget);
      verify(() => profiles.updateGoals('a', any())).called(1);

      tester.testTextInput.hide();
      await tester.pump();
      await tester.ensureVisible(find.text('Units'));
      await tester.tap(find.text('Units'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Imperial').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Imperial'), findsOneWidget);

      await tester.ensureVisible(find.text('Log Out'));
      await tester.tap(find.text('Log Out'));
      expect(loggedOut, isTrue);
      expect(tester.takeException(), isNull);
    },
  );
}
