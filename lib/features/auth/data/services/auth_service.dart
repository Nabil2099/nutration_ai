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

  void clearPendingName() {
    _pendingName = null;
  }

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
    if (registration != null) {
      return registration!;
    }
    final trimmedEmail = email.trim();
    final trimmedName = name.trim();
    _pendingName = trimmedName;
    final future = _performRegistration(
      email: trimmedEmail,
      password: password,
      name: trimmedName,
    );
    registration = future;
    return future;
  }

  Future<void> _performRegistration({
    required String email,
    required String password,
    required String name,
  }) async {
    var accountCreated = false;
    try {
      final result = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      accountCreated = true;
      await result.user!.updateDisplayName(name);
      await profiles.ensureProfile(
        uid: result.user!.uid,
        email: email,
        preferredName: name,
      );
      await profiles.saveRegisteredName(result.user!.uid, name);
      _pendingName = null;
    } catch (_) {
      if (!accountCreated) {
        _pendingName = null;
      }
      rethrow;
    } finally {
      registration = null;
    }
  }

  Future<void> signOut() async {
    _pendingName = null;
    await auth.signOut();
  }
}
