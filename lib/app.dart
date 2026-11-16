import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app_gate.dart';
import 'app/cubit/app_cubit.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/responsive.dart';
import 'core/data/services/user_profile_service.dart';
import 'core/data/services/meal_reader.dart';
import 'core/navigation/main_shell.dart';
import 'features/auth/data/services/auth_service.dart';
import 'features/onboarding/data/services/onboarding_service.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.auth,
    required this.profiles,
    required this.onboarding,
    this.mealReader,
    this.screens = const TeamScreens(),
  });
  final AuthService auth;
  final UserProfileService profiles;
  final OnboardingService onboarding;
  final MealPeriodReader? mealReader;
  final TeamScreens screens;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => AppCubit(auth, onboarding, profiles),
    child: withScreenUtil(
      child: MaterialApp(
        title: 'Nutrition & AI Coach',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: AppGate(
          auth: auth,
          profiles: profiles,
          mealReader: mealReader,
          screens: screens,
        ),
      ),
    ),
  );
}
