import '../../core/data/models/user_profile.dart';

enum AppStatus {
  checking,
  needsOnboarding,
  unauthenticated,
  preparingUser,
  authenticated,
  failure,
}

class AppState {
  const AppState(this.status, {this.profile, this.message});
  final AppStatus status;
  final UserProfile? profile;
  final String? message;
}
