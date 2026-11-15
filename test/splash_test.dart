import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutration_ai/core/theme/app_theme.dart';
import 'package:nutration_ai/features/splash/presentation/screens/splash_screen.dart';
import 'package:nutration_ai/main.dart';

void main() {
  testWidgets('reduced motion skips the artificial launch hold', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      Bootstrap(
        initializeServices: () async =>
            const MaterialApp(home: Text('Ready without motion')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ready without motion'), findsOneWidget);
  });

  testWidgets('disposing during startup cancels the presentation timer', (
    tester,
  ) async {
    final services = Completer<Widget>();
    await tester.pumpWidget(
      Bootstrap(initializeServices: () => services.future),
    );
    await tester.pumpWidget(const SizedBox());
    services.complete(const MaterialApp(home: Text('Late result')));
    await tester.pump();
    expect(find.text('Late result'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'launch holds six seconds while services initialize concurrently',
    (tester) async {
      final services = Completer<Widget>();
      await tester.pumpWidget(
        Bootstrap(initializeServices: () => services.future),
      );
      await tester.pump(const Duration(seconds: 4));
      services.complete(const MaterialApp(home: Text('Ready')));
      await tester.pump();
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.text('Ready'), findsNothing);
      await tester.pump(const Duration(milliseconds: 1999));
      expect(find.text('Ready'), findsNothing);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      expect(find.text('Ready'), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    },
  );

  testWidgets('elapsed presentation never substitutes for service readiness', (
    tester,
  ) async {
    final services = Completer<Widget>();
    await tester.pumpWidget(
      Bootstrap(initializeServices: () => services.future),
    );
    await tester.pump(const Duration(seconds: 8));
    expect(find.byType(SplashScreen), findsOneWidget);
    services.complete(const MaterialApp(home: Text('Ready')));
    await tester.pump();
    await tester.pump();
    expect(find.text('Ready'), findsOneWidget);
  });

  testWidgets('startup error is immediate and retry receives its own opening', (
    tester,
  ) async {
    var attempts = 0;
    await tester.pumpWidget(
      Bootstrap(
        initializeServices: () async {
          if (++attempts == 1) throw StateError('offline');
          return const MaterialApp(home: Text('Recovered'));
        },
      ),
    );
    await tester.pump();
    expect(find.text('Retry'), findsOneWidget);
    expect(find.byType(SplashScreen), findsNothing);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);
    await tester.pump(SplashScreen.minimumDuration);
    await tester.pump();
    expect(find.text('Recovered'), findsOneWidget);
    expect(attempts, 2);
  });

  testWidgets('content reveals gradually and disposes active animations', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const SplashScreen()),
    );
    final reveals = find.descendant(
      of: find.byType(SplashScreen),
      matching: find.byType(FadeTransition),
    );
    expect(tester.widget<FadeTransition>(reveals.first).opacity.value, 0);
    await tester.pump(const Duration(milliseconds: 600));
    final middle = tester.widget<FadeTransition>(reveals.first).opacity.value;
    expect(middle, greaterThan(0));
    expect(middle, lessThan(1));
    await tester.pump(const Duration(seconds: 3));
    for (final reveal in tester.widgetList<FadeTransition>(reveals)) {
      expect(reveal.opacity.value, 1);
    }
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      isNull,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('reduced motion shows all content with no repeating animation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        home: const SplashScreen(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nutrition & AI Coach'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(tester.binding.transientCallbackCount, 0);
    for (final reveal in tester.widgetList<FadeTransition>(
      find.descendant(
        of: find.byType(SplashScreen),
        matching: find.byType(FadeTransition),
      ),
    )) {
      expect(reveal.opacity.value, 1);
    }
  });

  for (final size in [
    const Size(320, 568),
    const Size(568, 320),
    const Size(1024, 768),
  ]) {
    testWidgets('splash fits $size with enlarged text', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: const SplashScreen(),
        ),
      );
      await tester.pump(const Duration(seconds: 3));
      await tester.ensureVisible(find.text('Getting things ready…'));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
