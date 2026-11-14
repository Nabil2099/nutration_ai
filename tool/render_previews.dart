import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nutration_ai/core/theme/app_theme.dart';
import 'package:nutration_ai/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:nutration_ai/features/auth/presentation/screens/login_screen.dart';
import 'package:nutration_ai/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:nutration_ai/features/home/presentation/cubit/home_cubit.dart';
import 'package:nutration_ai/features/home/presentation/screens/home_screen.dart';
import 'package:nutration_ai/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:nutration_ai/features/splash/presentation/screens/splash_screen.dart';

import '../test/support.dart';
import '../test/metrics_test.dart' show meal;

void main() {
  testWidgets('render review images', (tester) async {
    final font = FontLoader('PlusJakartaSans')
      ..addFont(rootBundle.load('assets/fonts/PlusJakartaSans.ttf'));
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
    tester.view.devicePixelRatio = 1;
    final auth = AuthCubit(MockAuth());
    final profiles = MockProfiles();
    when(() => profiles.watchProfile('a'))
        .thenAnswer((_) => Stream.value(profile()));
    final home = HomeCubit(
      profiles,
      (_, first, last) => Stream.value([meal(1350)]),
      clock: () => DateTime(2026, 11, 15),
    );
    await home.start('a');
    final screens = <String, Widget>{
      'login': BlocProvider.value(
        value: auth,
        child: LoginScreen(onSwitch: () {}),
      ),
      'signup': BlocProvider.value(
        value: auth,
        child: SignUpScreen(onSwitch: () {}),
      ),
      'onboarding': OnboardingScreen(onComplete: () {}),
      'splash': const SplashScreen(),
      'home': BlocProvider.value(
        value: home,
        child: Scaffold(
          appBar: AppBar(title: const Text('Home Dashboard')),
          body: HomeScreen(onLog: () {}, onProfile: () {}, onCoach: () {}),
        ),
      ),
    };
    for (final entry in screens.entries) {
      tester.view.physicalSize = Size(
        390,
        entry.key == 'home'
            ? 1450
            : entry.key == 'onboarding'
            ? 1050
            : 900,
      );
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            key: ValueKey(entry.key),
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            home: entry.value,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump();
      if (entry.key == 'signup') {
        final scroll = tester.state<ScrollableState>(
          find.byType(Scrollable).first,
        );
        scroll.position.jumpTo(0);
        await tester.pump();
      }
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('docs/previews').create(recursive: true);
        await File('docs/previews/${entry.key}.png')
            .writeAsBytes(data!.buffer.asUint8List());
        image.dispose();
      });
    }
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(auth.close);
    await tester.runAsync(home.close);
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
