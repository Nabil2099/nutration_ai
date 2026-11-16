import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/data/models/nutrition_goals.dart';
import '../../../../core/data/models/user_profile.dart';
import '../../../../core/data/services/user_profile_service.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required UserProfile profile, required this.profiles})
    : super(ProfileState(profile: profile));

  final UserProfileService profiles;

  void selectUnits(ProfileUnits units) => emit(state.copyWith(units: units));

  Future<void> updateName(String name) async {
    if (state.saving) return;
    final trimmed = name.trim();
    if (trimmed.length < 2 || trimmed.length > 80) {
      emit(state.copyWith(errorMessage: 'Name must be 2–80 characters.'));
      return;
    }
    emit(state.copyWith(saving: true, clearError: true));
    try {
      await profiles.updateName(state.profile.uid, trimmed);
      emit(
        state.copyWith(
          profile: state.profile.copyWith(name: trimmed),
          saving: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          saving: false,
          errorMessage:
              'Could not update your name. Check your connection and retry.',
        ),
      );
    }
  }

  Future<void> updateGoals(NutritionGoals goals) async {
    if (state.saving) return;
    if (!goals.isValid) {
      emit(state.copyWith(errorMessage: 'Enter valid daily nutrition goals.'));
      return;
    }
    emit(state.copyWith(saving: true, clearError: true));
    try {
      await profiles.updateGoals(state.profile.uid, goals);
      emit(
        state.copyWith(
          profile: state.profile.copyWith(dailyGoals: goals),
          saving: false,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          saving: false,
          errorMessage:
              'Could not update your goals. Check your connection and retry.',
        ),
      );
    }
  }
}
