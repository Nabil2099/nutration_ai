import 'package:hive_flutter/hive_flutter.dart';

class OnboardingService {
  OnboardingService(this.preferences);
  final Box<dynamic> preferences;
  static const completedKey = 'onboarding_completed_v1';
  bool get isCompleted =>
      preferences.get(completedKey, defaultValue: false) == true;
  Future<void> markCompleted() => preferences.put(completedKey, true);
}
