import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../../../../core/widgets/brand_mark.dart';
import '../../../../core/theme/app_colors.dart';
import 'auth_text_field.dart';
import 'auth_submit_button.dart';

class AuthForm extends StatefulWidget {
  const AuthForm({super.key, required this.register, required this.onSwitch});
  final bool register;
  final VoidCallback onSwitch;
  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(),
      _email = TextEditingController(),
      _password = TextEditingController(),
      _confirm = TextEditingController();
  @override
  void dispose() {
    for (final c in [_name, _email, _password, _confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final cubit = context.read<AuthCubit>();
    if (widget.register) {
      cubit.register(_name.text, _email.text, _password.text);
    } else {
      cubit.login(_email.text, _password.text);
    }
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<AuthCubit, AuthState>(
    builder: (context, state) {
      final loading = state.status == AuthStatus.submitting;
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.register ? 'Create Account' : 'Sign In'),
          leading: widget.register
              ? BackButton(onPressed: loading ? null : widget.onSwitch)
              : null,
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: BrandMark()),
                      const SizedBox(height: 24),
                      Text(
                        widget.register
                            ? 'Create your account'
                            : 'Welcome back',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.register
                            ? 'Start tracking your nourishment with daily goals.'
                            : 'Sign in to continue your balanced nutrition journey.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Form(
                          key: _form,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (widget.register)
                                AuthTextField(
                                  label: 'Full name',
                                  controller: _name,
                                  icon: Icons.person_outline,
                                  enabled: !loading,
                                  validator: (v) =>
                                      (v?.trim().length ?? 0) < 2 ||
                                          v!.trim().length > 80
                                      ? 'Enter a name of 2–80 characters.'
                                      : null,
                                ),
                              AuthTextField(
                                label: 'Email address',
                                controller: _email,
                                icon: Icons.alternate_email,
                                keyboardType: TextInputType.emailAddress,
                                enabled: !loading,
                                validator: (v) =>
                                    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                        .hasMatch(v?.trim() ?? '')
                                    ? null
                                    : 'Enter a valid email address.',
                              ),
                              AuthTextField(
                                label: 'Password',
                                controller: _password,
                                icon: Icons.lock_outline,
                                password: true,
                                enabled: !loading,
                                last: !widget.register,
                                onSubmit: _submit,
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Enter your password.';
                                  }
                                  if (widget.register &&
                                      (v.length < 8 ||
                                          !RegExp(r'[0-9]').hasMatch(v))) {
                                    return 'Use at least 8 characters and 1 number.';
                                  }
                                  return null;
                                },
                              ),
                              if (widget.register) ...[
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    'Use at least 8 characters and 1 number.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                AuthTextField(
                                  label: 'Confirm password',
                                  controller: _confirm,
                                  icon: Icons.shield_outlined,
                                  password: true,
                                  enabled: !loading,
                                  last: true,
                                  onSubmit: _submit,
                                  validator: (v) =>
                                      v != _password.text || v!.isEmpty
                                      ? 'Passwords must match.'
                                      : null,
                                ),
                              ],
                              if (state.errorMessage != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Semantics(
                                    liveRegion: true,
                                    child: Text(
                                      state.errorMessage!,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .error,
                                      ),
                                    ),
                                  ),
                                ),
                              AuthSubmitButton(
                                loading: loading,
                                label: widget.register
                                    ? 'Create account'
                                    : 'Log in',
                                onPressed: _submit,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Your nutrition journey, one mindful meal at a time.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: loading ? null : widget.onSwitch,
                        child: Text(
                          widget.register
                              ? 'Already have an account? Log in'
                              : 'New here? Create an account',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
