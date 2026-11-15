abstract final class AuthValidators {
  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _digitPattern = RegExp(r'[0-9]');

  static String? validateName(String? value) {
    final length = value?.trim().length ?? 0;
    if (length < 2 || length > 80) {
      return 'Enter a name of 2–80 characters.';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (_emailPattern.hasMatch(value?.trim() ?? '')) {
      return null;
    }
    return 'Enter a valid email address.';
  }

  static String? validatePassword(String? value, {required bool isRegister}) {
    if (value == null || value.isEmpty) {
      return 'Enter your password.';
    }
    if (isRegister && (value.length < 8 || !_digitPattern.hasMatch(value))) {
      return 'Use at least 8 characters and 1 number.';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty || value != password) {
      return 'Passwords must match.';
    }
    return null;
  }
}
