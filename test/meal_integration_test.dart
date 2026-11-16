import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutration_ai/app.dart';
import 'package:nutration_ai/core/data/models/meal_entry.dart';
import 'package:nutration_ai/core/navigation/main_shell.dart';
import 'package:nutration_ai/core/utils/day_key.dart';
import 'package:nutration_ai/features/meals/presentation/cubit/add_meal_cubit.dart';
import 'package:nutration_ai/features/meals/presentation/screens/add_meal_screen.dart';

import 'support.dart';

void main() {
  testWidgets('adding a meal from AddMealScreen updates Home Dashboard live', (
    tester,
  ) async {
    final auth = MockAuth();
    final profiles = MockProfiles();
    final onboarding = FakeOnboarding()..completed = true;
    final sessions = StreamController<User?>();
    final mealsStream = StreamController<List<MealEntry>>.broadcast();
    final logged = <MealEntry>[];
    final currentUser = user();

    when(() => auth.authStateChanges()).thenAnswer((_) => sessions.stream);
    when(() => auth.currentUser).thenReturn(currentUser);
    when(
      () => profiles.ensureProfile(
        uid: any(named: 'uid'),
        email: any(named: 'email'),
        preferredName: any(named: 'preferredName'),
      ),
    ).thenAnswer((_) async => profile());
    when(() => profiles.watchProfile('a'))
        .thenAnswer((_) => Stream.value(profile()));

    await tester.pumpWidget(
      App(
        auth: auth,
        profiles: profiles,
        onboarding: onboarding,
        mealReader: (_, first, last) async* {
          yield List<MealEntry>.unmodifiable(logged);
          yield* mealsStream.stream;
        },
        screens: TeamScreens(
          addMeal: (_) => AddMealScreen(
            onSave:
                ({
                  required name,
                  required mealType,
                  required servingGrams,
                  required caloriesKcal,
                  required proteinG,
                  required carbsG,
                  required fatG,
                }) async {
                  final now = DateTime.now();
                  logged.add(
                    MealEntry(
                      id: 'm1',
                      name: name,
                      mealType: mealType,
                      consumedAt: now,
                      localDayKey: dayKey(now),
                      servingGrams: servingGrams,
                      caloriesKcal: caloriesKcal,
                      proteinG: proteinG,
                      carbsG: carbsG,
                      fatG: fatG,
                    ),
                  );
                  mealsStream.add(List<MealEntry>.unmodifiable(logged));
                },
          ),
        ),
      ),
    );

    sessions.add(currentUser);
    await tester.pumpAndSettle();

    // Initially 0 kcal consumed -> 2000 remaining.
    expect(find.text('2000'), findsOneWidget);
    expect(find.text('0 kcal'), findsOneWidget);

    await tester.tap(find.byTooltip('Add Meal'));
    await tester.pumpAndSettle();

    expect(find.text('Add to My Log'), findsOneWidget);
    await tester.tap(find.text('Add to My Log'));
    await tester.pumpAndSettle();

    // Back on Home Dashboard with the newly added 220 kcal meal reflected.
    expect(find.text('Home Dashboard'), findsOneWidget);
    expect(find.text('1780'), findsOneWidget);
    expect(find.text('220 kcal'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(sessions.close);
    await tester.runAsync(mealsStream.close);
  });

  test('AddMealCubit surfaces error when save fails', () async {
    final cubit = AddMealCubit(
      onSave:
          ({
            required name,
            required mealType,
            required servingGrams,
            required caloriesKcal,
            required proteinG,
            required carbsG,
            required fatG,
          }) async {
            throw StateError('network');
          },
    );

    final ok = await cubit.submit();
    expect(ok, false);
    expect(cubit.state.saving, false);
    expect(cubit.state.errorMessage, isNotNull);
    await cubit.close();
  });
}
