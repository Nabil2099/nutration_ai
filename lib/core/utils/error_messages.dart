import 'package:firebase_auth/firebase_auth.dart';

String friendlyError(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-email' => 'Enter a valid email address.',
      'weak-password' || 'password-does-not-meet-requirements' =>
        'Choose a stronger password that meets the account policy.',
      'email-already-in-use' =>
        'That account is already registered. Try signing in.',
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' => 'Email or password is incorrect.',
      'network-request-failed' => 'Check your connection and try again.',
      'too-many-requests' => 'Too many attempts. Try again later.',
      'user-disabled' => 'This account is unavailable. Contact support.',
      _ => 'Unable to sign in. Please try again.',
    };
  }
  return 'Unable to load your data. Check your connection and try again.';
}
