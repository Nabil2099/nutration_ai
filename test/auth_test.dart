import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutration_ai/features/auth/data/services/auth_service.dart';
import 'package:nutration_ai/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nutration_ai/features/auth/presentation/cubit/auth_state.dart';

import 'support.dart';

void main() {
  test('login blocks duplicate requests and maps backend failures', () async {
    final auth = MockAuth(), pending = Completer<void>();
    when(
      () => auth.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) => pending.future);
    final cubit = AuthCubit(auth);
    final first = cubit.login('mona@example.com', 'password');
    await cubit.login('mona@example.com', 'password');
    expect(cubit.state.status, AuthStatus.submitting);
    verify(
      () => auth.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).called(1);
    pending.completeError(FirebaseAuthException(code: 'invalid-credential'));
    await first;
    expect(cubit.state.status, AuthStatus.failure);
    expect(cubit.state.errorMessage, 'Email or password is incorrect.');
    await cubit.close();
  });
  test('AuthService trims email and preserves password spaces', () async {
    final sdk = MockFirebaseAuth(),
        profiles = MockProfiles(),
        credential = MockCredential();
    when(
      () => sdk.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => credential);
    await AuthService(
      sdk,
      profiles,
    ).login(email: ' mona@example.com ', password: ' pass word ');
    verify(
      () => sdk.signInWithEmailAndPassword(
        email: 'mona@example.com',
        password: ' pass word ',
      ),
    ).called(1);
  });
  test('signup saves name after atomic profile creation', () async {
    final sdk = MockFirebaseAuth(),
        profiles = MockProfiles(),
        credential = MockCredential(),
        u = user();
    when(
      () => sdk.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => credential);
    when(() => credential.user).thenReturn(u);
    when(() => u.updateDisplayName(any())).thenAnswer((_) async {});
    when(
      () => profiles.ensureProfile(
        uid: 'a',
        email: any(named: 'email'),
        preferredName: any(named: 'preferredName'),
      ),
    ).thenAnswer((_) async => profile());
    when(() => profiles.saveRegisteredName('a', 'Mona'))
        .thenAnswer((_) async {});
    final service = AuthService(sdk, profiles);
    await service.register(
      email: ' mona@example.com ',
      password: 'password1',
      name: ' Mona ',
    );
    verifyInOrder([
      () => u.updateDisplayName('Mona'),
      () => profiles.ensureProfile(
        uid: 'a',
        email: 'mona@example.com',
        preferredName: 'Mona',
      ),
      () => profiles.saveRegisteredName('a', 'Mona'),
    ]);
    expect(service.registration, null);
    expect(service.pendingName, null);
  });
  test(
    'failed account creation cannot rename an existing account on later login',
    () async {
      final sdk = MockFirebaseAuth(), profiles = MockProfiles();
      when(
        () => sdk.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
      final service = AuthService(sdk, profiles);
      await expectLater(
        service.register(
          email: 'existing@example.com',
          password: 'password1',
          name: 'Wrong Name',
        ),
        throwsA(isA<FirebaseAuthException>()),
      );
      expect(service.pendingName, null);
      verifyNever(() => profiles.saveRegisteredName(any(), any()));
    },
  );
}
