import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../app.dart';
import '../core/config/env_config.dart';
import '../core/data/services/meal_service.dart';
import '../core/data/services/user_profile_service.dart';
import '../core/firebase_bootstrap.dart';
import '../core/navigation/main_shell.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/responsive.dart';
import '../core/widgets/app_error_view.dart';
import '../features/analytics/presentation/screens/analytics_screen.dart';
import '../features/auth/data/services/auth_service.dart';
import '../features/coach/presentation/screens/coach_screen.dart';
import '../features/meals/presentation/screens/add_meal_screen.dart';
import '../features/onboarding/data/services/onboarding_service.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import 'cubit/app_cubit.dart';

class Bootstrap extends StatefulWidget {
  const Bootstrap({super.key, this.initializeServices});

  final Future<Widget> Function()? initializeServices;

  @override
  State<Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<Bootstrap> {
  late Future<Widget> _startup;
  var _hiveInitialized = false;
  final _startupClock = Stopwatch();
  Timer? _presentationTimer;

  @override
  void initState() {
    super.initState();
    _startup = _initialize();
  }

  Future<Widget> _initialize() async {
    _startupClock
      ..reset()
      ..start();
    final minimumElapsed = Completer<void>();
    final reduceMotion = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    _presentationTimer?.cancel();
    _presentationTimer = Timer(
      reduceMotion ? Duration.zero : SplashScreen.minimumDuration,
      minimumElapsed.complete,
    );
    try {
      final app = await (widget.initializeServices?.call() ?? _createApp());
      // Presentation time overlaps real initialization; errors are never delayed.
      await minimumElapsed.future;
      return app;
    } finally {
      _presentationTimer?.cancel();
    }
  }

  @override
  void dispose() {
    _presentationTimer?.cancel();
    _startupClock.stop();
    super.dispose();
  }

  Future<Widget> _createApp() async {
    await EnvConfig.load();
    await initializeFirebase().timeout(const Duration(seconds: 25));
    if (!_hiveInitialized) {
      await Hive.initFlutter();
      _hiveInitialized = true;
    }
    final preferences = await Hive.openBox<dynamic>('preferences');
    final firestore = FirebaseFirestore.instance;
    final profiles = UserProfileService(firestore);
    final meals = MealService(firestore);
    return App(
      auth: AuthService(FirebaseAuth.instance, profiles),
      profiles: profiles,
      onboarding: OnboardingService(preferences),
      mealReader: meals.watchMeals,
      screens: TeamScreens(
        analytics: (context) => AnalyticsScreen(
          mealReader: meals.watchMeals,
          uid: context.read<AppCubit>().state.profile?.uid,
        ),
        coach: (context) => CoachScreen(
          profile: context.read<AppCubit>().state.profile,
          mealReader: meals.watchMeals,
        ),
        addMeal: (context) {
          final uid = context.read<AppCubit>().state.profile?.uid;
          return AddMealScreen(
            onSave: uid == null
                ? null
                : ({
                    required name,
                    required mealType,
                    required servingGrams,
                    required caloriesKcal,
                    required proteinG,
                    required carbsG,
                    required fatG,
                  }) => meals.addMeal(
                    uid: uid,
                    name: name,
                    mealType: mealType,
                    servingGrams: servingGrams,
                    caloriesKcal: caloriesKcal,
                    proteinG: proteinG,
                    carbsG: carbsG,
                    fatG: fatG,
                  ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Widget>(
    future: _startup,
    builder: (context, snapshot) {
      if (snapshot.hasData) return snapshot.data!;
      return withScreenUtil(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          home:
              snapshot.hasError &&
                  snapshot.connectionState == ConnectionState.done
              ? Scaffold(
                  body: AppErrorView(
                    message: 'App services could not start. Check your connection and Firebase platform configuration.',
                    onRetry: () {
                      final startup = _initialize();
                      setState(() {
                        _startup = startup;
                      });
                    },
                  ),
                )
              : SplashScreen(elapsed: _startupClock.elapsed),
        ),
      );
    },
  );
}
