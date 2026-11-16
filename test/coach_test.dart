import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutration_ai/core/theme/app_theme.dart';
import 'package:nutration_ai/features/coach/data/services/ai_coach_service.dart';
import 'package:nutration_ai/features/coach/presentation/screens/coach_screen.dart';

import 'metrics_test.dart' show meal;
import 'support.dart';

Dio _mockDio(
  void Function(RequestOptions options, RequestInterceptorHandler handler)
  onRequest,
) {
  final dio = Dio(
    BaseOptions(
      baseUrl: 'https://generativelanguage.googleapis.com/v1beta',
      headers: const {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(InterceptorsWrapper(onRequest: onRequest));
  return dio;
}

void main() {
  test('AiCoachService requires a non-empty GEMINI_API_KEY', () async {
    final service = AiCoachService(
      dio: _mockDio((options, handler) {
        handler.resolve(Response(requestOptions: options, statusCode: 200));
      }),
      apiKey: '',
    );

    await expectLater(
      service.sendMessage(history: const [], prompt: 'Hi'),
      throwsA(
        isA<AiCoachException>().having(
          (e) => e.message,
          'message',
          contains('GEMINI_API_KEY'),
        ),
      ),
    );
  });

  test(
    'AiCoachService calls gemini-3.5-flash-lite via Dio with user meal context',
    () async {
      late RequestOptions captured;

      final service = AiCoachService(
        apiKey: 'test-key-123',
        model: 'gemini-3.5-flash-lite',
        dio: _mockDio((options, handler) {
          captured = options;
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'candidates': [
                  {
                    'content': {
                      'parts': [
                        {'text': 'Try adding Greek yogurt after your workout.'},
                      ],
                    },
                  },
                ],
              },
            ),
          );
        }),
      );

      final reply = await service.sendMessage(
        history: const [],
        prompt: 'Should I eat more protein?',
        profile: profile(),
        meals: [meal(1350, key: '2026-11-16')],
        now: DateTime(2026, 11, 16, 14),
      );

      expect(reply, 'Try adding Greek yogurt after your workout.');
      expect(
        captured.uri.toString(),
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash-lite:generateContent',
      );
      expect(captured.headers['x-goog-api-key'], 'test-key-123');
      final body = captured.data as Map<String, dynamic>;
      final sysText = body['systemInstruction']['parts'][0]['text'] as String;
      expect(sysText, contains('Mona'));
      expect(sysText, contains('1350 kcal'));
    },
  );

  testWidgets('CoachScreen sends a message and renders Gemini reply', (
    tester,
  ) async {
    final service = AiCoachService(
      apiKey: 'test-key-123',
      dio: _mockDio((options, handler) {
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {
                        'text': 'Aim for **200g** of complex carbs before training.',
                      },
                    ],
                  },
                },
              ],
            },
          ),
        );
      }),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CoachScreen(
            profile: profile(),
            mealReader: (_, first, last) =>
                Stream.value([meal(1400, key: '2026-11-16')]),
            service: service,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sage AI'), findsOneWidget);
    expect(find.text('7-Day Macro Distribution'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Should I eat more carbs?');
    await tester.tap(find.byTooltip('Send message'));
    await tester.pumpAndSettle();

    expect(find.text('Should I eat more carbs?'), findsOneWidget);
    expect(
      find.text(
        'Aim for 200g of complex carbs before training.',
        findRichText: true,
      ),
      findsOneWidget,
    );
    expect(find.textContaining('**'), findsNothing);
  });
}
