import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutration_ai/core/data/models/user_profile.dart';
import 'package:nutration_ai/core/data/models/meal_entry.dart';
import 'package:nutration_ai/core/data/models/nutrition_goals.dart';
import 'package:nutration_ai/features/home/presentation/cubit/home_cubit.dart';
import 'package:nutration_ai/features/home/presentation/cubit/home_state.dart';

import 'support.dart';
import 'metrics_test.dart' show meal;

void main() {
  test(
    'live meals and goals recompute; account change clears cached data',
    () async {
      final profiles = MockProfiles();
      final p = StreamController<UserProfile>.broadcast();
      final m = StreamController<List<MealEntry>>.broadcast();
      when(() => profiles.watchProfile(any())).thenAnswer((_) => p.stream);
      final cubit = HomeCubit(
        profiles,
        (_, first, last) => m.stream,
        clock: () => DateTime(2026, 11, 15),
      );
      await cubit.start('a');
      p.add(profile());
      m.add([meal(1350)]);
      await settle();
      expect(cubit.state.summary!.remainingCalories, 650);
      p.add(
        profile(
          'a',
          const NutritionGoals(
            calories: 2200,
            proteinG: 140,
            carbsG: 250,
            fatG: 70,
          ),
        ),
      );
      await settle();
      expect(cubit.state.summary!.remainingCalories, 850);
      m.add([]);
      await settle();
      expect(cubit.state.summary!.consumedCalories, 0);
      final switching = cubit.start('b');
      expect(cubit.state.summary, null);
      expect(cubit.state.status, HomeStatus.loading);
      await switching;
      await cubit.close();
      expect(p.hasListener, false);
      expect(m.hasListener, false);
      await p.close();
      await m.close();
    },
  );
  test(
    'missing meal integration stays explicit and midnight changes query range',
    () async {
      final profiles = MockProfiles();
      when(() => profiles.watchProfile(any()))
          .thenAnswer((_) => Stream.value(profile()));
      var now = DateTime(2026, 11, 15, 23, 59);
      final ranges = <String>[];
      final cubit = HomeCubit(profiles, (_, first, last) {
        ranges.add(last);
        return Stream.value([]);
      }, clock: () => now);
      await cubit.start('a');
      await settle();
      now = DateTime(2026, 11, 16);
      cubit.onAppResumed();
      await settle();
      expect(ranges, ['2026-11-15', '2026-11-16']);
      await cubit.close();
      final disconnected = HomeCubit(profiles, null);
      await disconnected.start('a');
      await settle();
      expect(disconnected.state.status, HomeStatus.disconnected);
      expect(disconnected.state.summary, null);
      await disconnected.close();
    },
  );
  test('stream error renders error and refresh resubscribes', () async {
    final profiles = MockProfiles();
    when(() => profiles.watchProfile(any()))
        .thenAnswer((_) => Stream.error(StateError('offline')));
    final cubit = HomeCubit(profiles, (_, first, last) => Stream.value([]));
    await cubit.start('a');
    await settle();
    expect(cubit.state.status, HomeStatus.error);
    when(() => profiles.watchProfile(any()))
        .thenAnswer((_) => Stream.value(profile()));
    await cubit.refresh();
    await settle();
    expect(cubit.state.status, HomeStatus.loaded);
    await cubit.close();
  });
  test('meal failure cannot be hidden by a later profile update', () async {
    final profiles = MockProfiles();
    final p = StreamController<UserProfile>.broadcast();
    final m = StreamController<List<MealEntry>>.broadcast();
    when(() => profiles.watchProfile(any())).thenAnswer((_) => p.stream);
    final cubit = HomeCubit(profiles, (_, first, last) => m.stream);
    await cubit.start('a');
    p.add(profile());
    m.add([]);
    await settle();
    expect(cubit.state.status, HomeStatus.loaded);
    m.addError(StateError('permission denied'));
    await settle();
    p.add(profile());
    await settle();
    expect(cubit.state.status, HomeStatus.error);
    m.add([]);
    await settle();
    expect(cubit.state.status, HomeStatus.loaded);
    await cubit.close();
    await p.close();
    await m.close();
  });
}
