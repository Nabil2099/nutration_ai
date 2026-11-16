import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/models/meal_entry.dart';
import '../../../../core/data/models/user_profile.dart';
import '../../../../core/data/services/meal_reader.dart';
import '../../../../core/utils/day_key.dart';
import '../../data/models/coach_message.dart';
import '../../data/services/ai_coach_service.dart';
import 'coach_state.dart';

class CoachCubit extends Cubit<CoachState> {
  CoachCubit({
    required this.service,
    UserProfile? profile,
    this.mealReader,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       super(
         CoachState(
           profile: profile,
           messages: [_welcomeMessage(profile, (clock ?? DateTime.now)())],
         ),
       );

  final AiCoachService service;
  final MealPeriodReader? mealReader;
  final DateTime Function() _clock;
  StreamSubscription<List<MealEntry>>? _mealSub;

  static CoachMessage _welcomeMessage(UserProfile? profile, DateTime now) {
    final name = profile?.name ?? 'there';
    final goal = profile?.dailyGoals.calories.round() ?? 2000;
    final carbs = profile?.dailyGoals.carbsG.round() ?? 220;
    final protein = profile?.dailyGoals.proteinG.round() ?? 120;
    return CoachMessage(
      id: 'welcome',
      role: CoachRole.assistant,
      badge: 'Macro Analysis',
      timestamp: now,
      showMacroChart: true,
      fuelIdeaTitle: 'Balanced Fuel Idea',
      fuelIdeaSubtitle: 'Greek yogurt + berries + roasted almonds',
      text:
          'Hi $name! I am synced with your $goal kcal daily target '
          '(${protein}g protein · ${carbs}g carbs). Ask me anything about your '
          'meals, macros, or what to eat next.',
    );
  }

  void start(String uid) {
    _mealSub?.cancel();
    if (mealReader == null || uid.isEmpty) return;
    final today = _clock();
    _mealSub = mealReader!(uid, dayKey(calendarDay(today, -6)), dayKey(today))
        .listen(
          (meals) {
            if (!isClosed) emit(state.copyWith(meals: meals));
          },
          onError: (_) {
            // Keep chat usable even if meal stream fails temporarily.
          },
        );
  }

  Future<void> ask(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty || state.sending) return;

    final now = _clock();
    final userMsg = CoachMessage(
      id: 'u_${now.microsecondsSinceEpoch}',
      role: CoachRole.user,
      text: text,
      timestamp: now,
    );

    final historyBeforePrompt = List<CoachMessage>.from(state.messages);
    emit(
      state.copyWith(
        messages: [...state.messages, userMsg],
        sending: true,
        clearError: true,
      ),
    );

    try {
      final reply = await service.sendMessage(
        history: historyBeforePrompt,
        prompt: text,
        profile: state.profile,
        meals: state.meals,
        now: _clock(),
      );
      if (isClosed) return;
      final aiMsg = CoachMessage(
        id: 'a_${_clock().microsecondsSinceEpoch}',
        role: CoachRole.assistant,
        badge: 'Gemini 3.5 Flash Lite',
        text: reply,
        timestamp: _clock(),
      );
      emit(
        state.copyWith(messages: [...state.messages, aiMsg], sending: false),
      );
    } on AiCoachException catch (e) {
      if (isClosed) return;
      emit(state.copyWith(sending: false, errorMessage: e.message));
    } catch (_) {
      if (isClosed) return;
      emit(
        state.copyWith(
          sending: false,
          errorMessage: 'Could not get a response from AI Coach.',
        ),
      );
    }
  }

  void clearError() {
    if (state.errorMessage != null) {
      emit(state.copyWith(clearError: true));
    }
  }

  @override
  Future<void> close() async {
    await _mealSub?.cancel();
    return super.close();
  }
}
