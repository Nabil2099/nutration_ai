enum AuthStatus { idle, submitting, submitted, failure }

class AuthState {
  const AuthState([this.status = AuthStatus.idle, this.errorMessage]);
  final AuthStatus status;
  final String? errorMessage;
}
