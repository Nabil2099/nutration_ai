import '../../../../core/data/models/user_profile.dart';

class ProfileState {
  const ProfileState({
    required this.profile,
    this.units = ProfileUnits.metric,
    this.saving = false,
    this.errorMessage,
  });

  final UserProfile profile;
  final ProfileUnits units;
  final bool saving;
  final String? errorMessage;

  ProfileState copyWith({
    UserProfile? profile,
    ProfileUnits? units,
    bool? saving,
    String? errorMessage,
    bool clearError = false,
  }) => ProfileState(
    profile: profile ?? this.profile,
    units: units ?? this.units,
    saving: saving ?? this.saving,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
  );
}

enum ProfileUnits { metric, imperial }
