import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutration_ai/app.dart';
import 'package:nutration_ai/core/theme/app_theme.dart';
import 'package:nutration_ai/core/navigation/main_shell.dart';
import 'package:nutration_ai/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nutration_ai/features/auth/presentation/screens/login_screen.dart';
import 'package:nutration_ai/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:nutration_ai/features/home/presentation/cubit/home_cubit.dart';
import 'package:nutration_ai/features/home/presentation/screens/home_screen.dart';
import 'package:nutration_ai/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:nutration_ai/features/onboarding/data/services/onboarding_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'dart:io';

import 'support.dart';
import 'metrics_test.dart' show meal;

void main() {
  testWidgets(
    'Login validation, password visibility, and signup confirmation',
    (tester) async {
      final auth = MockAuth();
      final cubit = AuthCubit(auth);
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            theme: AppTheme.light,
            home: LoginScreen(onSwitch: () {}),
          ),
        ),
      );
      await tester.tap(find.text('Log in  →'));
      await tester.pump();
      expect(find.text('Enter a valid email address.'), findsOneWidget);
      expect(find.text('Enter your password.'), findsOneWidget);
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(find.byTooltip('Hide password'), findsOneWidget);
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            theme: AppTheme.light,
            home: SignUpScreen(onSwitch: () {}),
          ),
        ),
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full name'),
        'Mona',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email address'),
        'mona@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password1',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Confirm password'),
        'different1',
      );
      await tester.ensureVisible(find.text('Create account  →'));
      await tester.tap(find.text('Create account  →'));
      await tester.pump();
      expect(find.text('Passwords must match.'), findsOneWidget);
      verifyNever(
        () => auth.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
      await tester.pumpWidget(const SizedBox());
      final closing = cubit.close();
      for (var i = 0; i < 10; i++) { await tester.pump(); }
      await closing;
    },
  );

  for (final size in [
    const Size(320, 640),
    const Size(390, 844),
    const Size(1000, 900),
  ]) {
    testWidgets('Home and onboarding fit $size at enlarged text', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final profiles = MockProfiles();
      when(() => profiles.watchProfile('a'))
          .thenAnswer((_) => Stream.value(profile()));
      final cubit = HomeCubit(
        profiles,
        (_, first, last) => Stream.value([meal(1350)]),
        clock: () => DateTime(2026, 11, 15),
      );
      await cubit.start('a');
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            theme: AppTheme.light,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(1.4)),
              child: child!,
            ),
            home: Scaffold(
              body: HomeScreen(onLog: () {}, onProfile: () {}, onCoach: () {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('650'), findsOneWidget);
      expect(tester.takeException(), null);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: OnboardingScreen(onComplete: () {}),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Get Started →'));
      expect(tester.takeException(), null);
      await tester.pumpWidget(const SizedBox());
      final closing = cubit.close();
      for (var i = 0; i < 10; i++) { await tester.pump(); }
      await closing;
    });
  }
  test('Hive onboarding completion persists across reopen', () async {
    final directory = await Directory.systemTemp.createTemp(
      'nutrition_preferences_',
    );
    Hive.init(directory.path);
    final box = await Hive.openBox<dynamic>('onboarding_test');
    final service = OnboardingService(box);
    expect(service.isCompleted, false);
    await service.markCompleted();
    await box.close();
    final reopened = await Hive.openBox<dynamic>('onboarding_test');
    expect(OnboardingService(reopened).isCompleted, true);
    await reopened.close();
    await directory.delete(recursive: true);
  });
  testWidgets(
    'shell keeps tab, Add Meal hides bar, logout removes pushed page',
    (tester) async {
      final auth = MockAuth(), profiles = MockProfiles();
      final onboarding = FakeOnboarding()..completed = true;
      final sessions = StreamController<User?>();
      User? current;
      when(() => auth.authStateChanges()).thenAnswer((_) => sessions.stream);
      when(() => auth.currentUser).thenAnswer((_) => current);
      when(() => auth.signOut()).thenAnswer((_) async {
        current = null;
        sessions.add(null);
      });
      when(
        () => profiles.ensureProfile(
          uid: any(named: 'uid'),
          email: any(named: 'email'),
          preferredName: any(named: 'preferredName'),
        ),
      ).thenAnswer((_) async => profile());
      when(() => profiles.watchProfile('a'))
          .thenAnswer((_) => Stream.value(profile()));
      await tester.pumpWidget(
        App(
          auth: auth,
          profiles: profiles,
          onboarding: onboarding,
          mealReader: (_, first, last) => Stream.value([]),
          screens: TeamScreens(
            addMeal: (_) => Scaffold(
              appBar: AppBar(title: const Text('Team Add Meal')),
              body: const Text('Meal route'),
            ),
          ),
        ),
      );
      current = user();
      sessions.add(current);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Analytics'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Analytics integration pending'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Add Meal'));
      await tester.pumpAndSettle();
      expect(find.text('Team Add Meal'), findsOneWidget);
      expect(find.text('Analytics'), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Analytics integration pending'),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Add Meal'));
      await tester.pumpAndSettle();
      current = null;
      sessions.add(null);
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Team Add Meal'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await sessions.close();
    },
  );
  testWidgets('auth flow switches without stacking root routes', (
    tester,
  ) async {
    final auth = MockAuth(), profiles = MockProfiles();
    final sessions = StreamController<User?>();
    when(() => auth.authStateChanges()).thenAnswer((_) => sessions.stream);
    await tester.pumpWidget(
      App(
        auth: auth,
        profiles: profiles,
        onboarding: FakeOnboarding()..completed = true,
      ),
    );
    sessions.add(null);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('New here? Create an account'));
    await tester.tap(find.text('New here? Create an account'));
    await tester.pumpAndSettle();
    expect(find.text('Create your account'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Welcome back'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await sessions.close();
  });
}
