import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutration_ai/core/data/services/user_profile_service.dart';
import 'package:nutration_ai/features/auth/data/services/auth_service.dart';
import 'package:nutration_ai/features/onboarding/data/services/onboarding_service.dart';
import 'package:nutration_ai/core/data/models/user_profile.dart';
import 'package:nutration_ai/core/data/models/nutrition_goals.dart';

class MockUser extends Mock implements User {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockCredential extends Mock implements UserCredential {}

class MockProfiles extends Mock implements UserProfileService {}

class MockAuth extends Mock implements AuthService {}

class FakeOnboarding extends Mock implements OnboardingService {
  bool completed = false;
  bool fails = false;
  @override
  bool get isCompleted => completed;
  @override
  Future<void> markCompleted() async {
    if (fails) throw StateError('disk');
    completed = true;
  }
}

UserProfile profile([
  String uid = 'a',
  NutritionGoals goals = NutritionGoals.defaults,
]) => UserProfile(
  uid: uid,
  name: 'Mona',
  email: 'mona@example.com',
  dailyGoals: goals,
);
Future<void> settle() => Future<void>.delayed(Duration.zero);
MockUser user([String uid = 'a']) {
  final u = MockUser();
  when(() => u.uid).thenReturn(uid);
  when(() => u.email).thenReturn('mona@example.com');
  when(() => u.displayName).thenReturn('Mona');
  return u;
}
