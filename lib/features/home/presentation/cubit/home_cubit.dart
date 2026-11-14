import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/services/user_profile_service.dart';
import '../../../../core/data/services/meal_reader.dart';
import '../../../../core/data/models/user_profile.dart';
import '../../../../core/data/models/meal_entry.dart';
import '../../../../core/utils/day_key.dart';
import '../../data/calculators/home_metrics_calculator.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this.profiles, this.mealReader, {DateTime Function()? clock})
    : clock = clock ?? DateTime.now,
      super(const HomeState(HomeStatus.initial));
  final UserProfileService profiles;
  final MealPeriodReader? mealReader;
  final DateTime Function() clock;
  StreamSubscription<UserProfile>? _profileSub;
  StreamSubscription<List<MealEntry>>? _mealSub;
  Timer? _midnight;
  UserProfile? _profile;
  List<MealEntry>? _meals;
  String? _uid;
  int _generation = 0;
  Future<void> start(String uid) async {
    final gen = ++_generation;
    _uid = uid;
    _profile = null;
    _meals = null;
    emit(const HomeState(HomeStatus.loading));
    _midnight?.cancel();
    await Future.wait([
      if (_profileSub != null) _profileSub!.cancel(),
      if (_mealSub != null) _mealSub!.cancel(),
    ]);
    if (isClosed || gen != _generation) return;
    final today = clock();
    void fail(Object _) {
      if (!isClosed && gen == _generation) {
        emit(
          const HomeState(
            HomeStatus.error,
            message: 'Could not load your daily summary. Check your connection and retry.',
          ),
        );
      }
    }

    _profileSub = profiles.watchProfile(uid).listen((p) {
      if (isClosed || gen != _generation) return;
      _profile = p;
      _recompute();
    }, onError: fail);
    if (mealReader != null) {
      _mealSub = mealReader!(uid, dayKey(calendarDay(today, -6)), dayKey(today))
          .listen((m) {
            if (isClosed || gen != _generation) return;
            _meals = m;
            _recompute();
          }, onError: fail);
    }
    final untilMidnight = calendarDay(today, 1).difference(today);
    _midnight = Timer(untilMidnight, refresh);
  }

  void _recompute() {
    if (_profile == null || isClosed) return;
    if (mealReader == null) {
      emit(HomeState(HomeStatus.disconnected, profile: _profile));
      return;
    }
    if (_meals != null) {
      emit(
        HomeState(
          HomeStatus.loaded,
          summary: const HomeMetricsCalculator().build(
            _profile!,
            _meals!,
            clock(),
          ),
          profile: _profile,
        ),
      );
    }
  }

  Future<void> refresh() async {
    if (_uid != null) await start(_uid!);
  }

  void onAppResumed() {
    if (state.summary?.selectedDayKey != dayKey(clock())) refresh();
  }

  @override
  Future<void> close() async {
    ++_generation;
    _midnight?.cancel();
    print('profile cancel'); await _profileSub?.cancel(); print('profile done');
    print('meal cancel'); await _mealSub?.cancel(); print('meal done');
    print('super close'); return super.close().then((_) {print('super done');});
  }
}
