import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/auth_service.dart';
import '../../../../core/utils/error_messages.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this.auth) : super(const AuthState());
  final AuthService auth;
  Future<void> login(String email, String password) =>
      _submit(() => auth.login(email: email, password: password));
  Future<void> register(String name, String email, String password) => _submit(
    () => auth.register(name: name, email: email, password: password),
  );
  Future<void> _submit(Future<void> Function() operation) async {
    if (state.status == AuthStatus.submitting) return;
    emit(const AuthState(AuthStatus.submitting));
    try {
      await operation();
      if (!isClosed) emit(const AuthState(AuthStatus.submitted));
    } catch (error) {
      if (!isClosed) emit(AuthState(AuthStatus.failure, friendlyError(error)));
    }
  }

  void clearError() {
    if (state.status != AuthStatus.submitting) emit(const AuthState());
  }
}
