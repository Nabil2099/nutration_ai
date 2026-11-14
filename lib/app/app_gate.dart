import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../features/auth/data/services/auth_service.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/sign_up_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/home/presentation/cubit/home_cubit.dart';
import '../core/data/services/user_profile_service.dart';
import '../core/data/services/meal_reader.dart';
import '../core/navigation/main_shell.dart';
import '../core/widgets/app_error_view.dart';
import 'cubit/app_cubit.dart';
import 'cubit/app_state.dart';

class AppGate extends StatelessWidget {
  const AppGate({
    super.key,
    required this.auth,
    required this.profiles,
    this.mealReader,
    this.screens = const TeamScreens(),
  });
  final AuthService auth;
  final UserProfileService profiles;
  final MealPeriodReader? mealReader;
  final TeamScreens screens;
  @override
  Widget build(BuildContext context) => BlocBuilder<AppCubit, AppState>(
    builder: (context, state) {
      final cubit = context.read<AppCubit>();
      switch (state.status) {
        case AppStatus.checking:
        case AppStatus.preparingUser:
          return const SplashScreen();
        case AppStatus.needsOnboarding:
          return OnboardingScreen(onComplete: cubit.completeOnboarding);
        case AppStatus.unauthenticated:
          return BlocProvider(
            create: (_) => AuthCubit(auth),
            child: const _AuthFlow(),
          );
        case AppStatus.failure:
          return Scaffold(
            body: AppErrorView(
              message: state.message!,
              onRetry: cubit.retry,
              onSignOut: auth.currentUser == null ? null : cubit.signOut,
            ),
          );
        case AppStatus.authenticated:
          // A session-scoped navigator disposes all pushed pages on logout/UID change.
          return BlocProvider(
            key: ValueKey(state.profile!.uid),
            create: (_) =>
                HomeCubit(profiles, mealReader)..start(state.profile!.uid),
            child: Navigator(
              onGenerateRoute: (_) => MaterialPageRoute<void>(
                builder: (_) => MainShell(screens: screens),
              ),
            ),
          );
      }
    },
  );
}

class _AuthFlow extends StatefulWidget {
  const _AuthFlow();
  @override
  State<_AuthFlow> createState() => _AuthFlowState();
}

class _AuthFlowState extends State<_AuthFlow> {
  bool _register = false;
  void _switch() {
    context.read<AuthCubit>().clearError();
    setState(() => _register = !_register);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_register,
    onPopInvokedWithResult: (popped, _) {
      if (!popped && _register) _switch();
    },
    child: _register
        ? SignUpScreen(onSwitch: _switch)
        : LoginScreen(onSwitch: _switch),
  );
}
