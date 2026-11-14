import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/data/services/user_profile_service.dart';

class AuthService {
  AuthService(this.auth, this.profiles);
  final FirebaseAuth auth;
  final UserProfileService profiles;
  Future<void>? registration;
  String? _pendingName;
  String? get pendingName => _pendingName;
  Stream<User?> authStateChanges() => auth.authStateChanges();
  User? get currentUser => auth.currentUser;
  Future<void> login({required String email, required String password}) async {
    await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) {
    final completion = Completer<void>();
    registration = completion.future;
    // Attach an error handler even if the auth stream has not emitted yet.
    unawaited(completion.future.catchError((Object _) {}));
    _pendingName = name.trim();
    () async {
      try {
        final result = await auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        await result.user!.updateDisplayName(name.trim());
        await profiles.ensureProfile(
          uid: result.user!.uid,
          email: email.trim(),
          preferredName: name.trim(),
        );
        await profiles.saveRegisteredName(result.user!.uid, name.trim());
        _pendingName = null;
        completion.complete();
      } catch (error, stack) {
        completion.completeError(error, stack);
      } finally {
        registration = null;
      }
    }();
    return completion.future;
  }

  Future<void> signOut() async {
    _pendingName = null;
    await auth.signOut();
  }
}
