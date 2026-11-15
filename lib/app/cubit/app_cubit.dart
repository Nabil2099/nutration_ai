import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/auth/data/services/auth_service.dart';
import '../../features/onboarding/data/services/onboarding_service.dart';
import '../../core/data/services/user_profile_service.dart';
import 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  AppCubit(this.auth, this.onboarding, this.profiles)
    : super(const AppState(AppStatus.checking)) {
    _startupDeadline = Timer(const Duration(seconds: 25), () {
      if (!isClosed && state.status == AppStatus.checking) {
        emit(
          const AppState(
            AppStatus.failure,
            message: 'Session restoration took too long. Please retry.',
          ),
        );
      }
    });
    _subscription = auth.authStateChanges().listen(
      _resolve,
      onError: (Object _) {
        if (!isClosed) {
          emit(
            const AppState(
              AppStatus.failure,
              message: 'Unable to restore your session. Please retry.',
            ),
          );
        }
      },
    );
  }
  final AuthService auth;
  final OnboardingService onboarding;
  final UserProfileService profiles;
  late final StreamSubscription<User?> _subscription;
  User? _user;
  Timer? _startupDeadline;
  Future<void> Function()? _retryAction;
  int _generation = 0;
  bool _completing = false;
  bool _hasSession = false;
  Future<void> _resolve(User? user) async {
    _startupDeadline?.cancel();
    _retryAction = null;
    final generation = ++_generation;
    _user = user;
    if (user == null) {
      emit(
        AppState(
          (onboarding.isCompleted || _hasSession)
              ? AppStatus.unauthenticated
              : AppStatus.needsOnboarding,
        ),
      );
      return;
    }
    _hasSession = true;
    emit(const AppState(AppStatus.preparingUser));
    try {
      await auth.registration?.timeout(const Duration(seconds: 25));
      final pending = auth.pendingName;
      final profile = await profiles
          .ensureProfile(
            uid: user.uid,
            email: user.email ?? '',
            preferredName: pending ?? user.displayName,
          )
          .timeout(const Duration(seconds: 25));

      var ready = profile;
      if (pending != null) {
        await profiles.saveRegisteredName(user.uid, pending);
        auth.clearPendingName();
        ready = profile.copyWith(name: pending.trim());
      }

      if (!isClosed && generation == _generation) {
        // A restored account has already passed the introduction on another
        // installation; persist that fact best-effort so logout/restart cannot replay it.
        if (!onboarding.isCompleted) {
          try {
            await onboarding.markCompleted();
          } catch (_) {
            // Keep authenticated session usable if local preference storage fails.
          }
        }
        if (isClosed || generation != _generation) return;
        emit(AppState(AppStatus.authenticated, profile: ready));
      }
    } catch (_) {
      if (!isClosed && generation == _generation) {
        emit(
          const AppState(
            AppStatus.failure,
            message: 'Your account is signed in, but your profile could not be prepared. Check your connection and retry.',
          ),
        );
      }
    }
  }

  Future<void> retry() =>
      _retryAction?.call() ?? _resolve(auth.currentUser ?? _user);
  Future<void> completeOnboarding() async {
    if (_completing) return;
    _completing = true;
    try {
      await onboarding.markCompleted();
      if (!isClosed) await _resolve(_user);
    } catch (_) {
      _retryAction = completeOnboarding;
      if (!isClosed) {
        emit(
          const AppState(
            AppStatus.failure,
            message: 'Could not save your preferences. Please retry.',
          ),
        );
      }
    } finally {
      _completing = false;
    }
  }

  Future<void> signOut() async {
    try {
      await auth.signOut();
    } catch (_) {
      _retryAction = signOut;
      if (!isClosed) {
        emit(
          const AppState(
            AppStatus.failure,
            message: 'Could not sign out. Check your connection and retry.',
          ),
        );
      }
    }
  }

  @override
  Future<void> close() async {
    ++_generation;
    _startupDeadline?.cancel();
    await _subscription.cancel();
    return super.close();
  }
}
