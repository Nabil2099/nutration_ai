import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutration_ai/app/cubit/app_cubit.dart';
import 'package:nutration_ai/app/cubit/app_state.dart';
import 'package:nutration_ai/core/data/models/user_profile.dart';

import 'support.dart';

void main() {
  late MockAuth auth;
  late MockProfiles profiles;
  late FakeOnboarding onboarding;
  late StreamController<User?> sessions;
  late AppCubit cubit;
  setUp(() {
    auth = MockAuth();
    profiles = MockProfiles();
    onboarding = FakeOnboarding();
    sessions = StreamController<User?>();
    when(() => auth.authStateChanges()).thenAnswer((_) => sessions.stream);
    when(
      () => profiles.ensureProfile(
        uid: any(named: 'uid'),
        email: any(named: 'email'),
        preferredName: any(named: 'preferredName'),
      ),
    ).thenAnswer(
      (invocation) async => profile(invocation.namedArguments[#uid] as String),
    );
    cubit = AppCubit(auth, onboarding, profiles);
  });
  tearDown(() async {
    await cubit.close();
    await sessions.close();
  });
  test(
    'waits for restored session before choosing first-launch route',
    () async {
      expect(cubit.state.status, AppStatus.checking);
      sessions.add(null);
      await settle();
      expect(cubit.state.status, AppStatus.needsOnboarding);
      await cubit.completeOnboarding();
      expect(onboarding.completed, true);
      expect(cubit.state.status, AppStatus.unauthenticated);
    },
  );
  test('completed installation starts at login', () async {
    onboarding.completed = true;
    sessions.add(null);
    await settle();
    expect(cubit.state.status, AppStatus.unauthenticated);
  });
  test('restored user bypasses onboarding and logout clears profile', () async {
    sessions.add(user());
    await settle();
    expect(cubit.state.status, AppStatus.authenticated);
    sessions.add(null);
    await settle();
    expect(cubit.state.status, AppStatus.unauthenticated);
    expect(cubit.state.profile, null);
  });
  test(
    'failed provisioning retries without registering a second account',
    () async {
      when(
        () => profiles.ensureProfile(
          uid: 'a',
          email: any(named: 'email'),
          preferredName: any(named: 'preferredName'),
        ),
      ).thenThrow(StateError('offline'));
      sessions.add(user());
      await settle();
      expect(cubit.state.status, AppStatus.failure);
      when(
        () => profiles.ensureProfile(
          uid: 'a',
          email: any(named: 'email'),
          preferredName: any(named: 'preferredName'),
        ),
      ).thenAnswer((_) async => profile());
      await cubit.retry();
      expect(cubit.state.status, AppStatus.authenticated);
    },
  );
  test('obsolete profile result cannot restore signed-out user', () async {
    final pending = Completer<UserProfile>();
    when(
      () => profiles.ensureProfile(
        uid: 'a',
        email: any(named: 'email'),
        preferredName: any(named: 'preferredName'),
      ),
    ).thenAnswer((_) => pending.future);
    onboarding.completed = true;
    sessions.add(user());
    await settle();
    sessions.add(null);
    await settle();
    pending.complete(profile());
    await settle();
    expect(cubit.state.status, AppStatus.unauthenticated);
  });
  test(
    'registration readiness blocks Home until identity writes complete',
    () async {
      final writes = Completer<void>();
      when(() => auth.registration).thenAnswer((_) => writes.future);
      sessions.add(user());
      await settle();
      expect(cubit.state.status, AppStatus.preparingUser);
      writes.complete();
      await settle();
      expect(cubit.state.status, AppStatus.authenticated);
    },
  );
  test('failed Hive write never completes onboarding', () async {
    sessions.add(null);
    await settle();
    onboarding.fails = true;
    await cubit.completeOnboarding();
    expect(cubit.state.status, AppStatus.failure);
    expect(onboarding.completed, false);
  });
}
