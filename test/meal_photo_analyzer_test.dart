import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nutration_ai/features/meals/data/services/meal_photo_analyzer.dart';

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

String _reply(Object json) => jsonEncode(json);

void main() {
  final jpegBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10]);

  test('MealPhotoAnalyzer requires a non-empty GEMINI_API_KEY', () async {
    final service = MealPhotoAnalyzer(
      dio: _mockDio((options, handler) {
        handler.resolve(Response(requestOptions: options, statusCode: 200));
      }),
      apiKey: '',
    );

    await expectLater(
      service.analyze(jpegBytes),
      throwsA(
        isA<MealPhotoAnalyzerException>().having(
          (e) => e.message,
          'message',
          contains('GEMINI_API_KEY'),
        ),
      ),
    );
  });

  test('sends the base64 photo, meal-type hint, and JSON mode to Gemini',
      () async {
    late RequestOptions captured;
    final service = MealPhotoAnalyzer(
      apiKey: 'test-key-123',
      model: 'gemini-test-model',
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
                      {
                        'text': _reply({
                          'title': 'Chicken rice plate',
                          'items': [
                            {
                              'name': 'Grilled Chicken',
                              'grams': 150,
                              'caloriesKcal': 316,
                              'proteinG': 30,
                              'carbsG': 0,
                              'fatG': 20,
                              'emoji': '🍗',
                            },
                            {
                              'name': 'White Rice',
                              'grams': 180,
                              'caloriesKcal': 234,
                              'proteinG': 4,
                              'carbsG': 52,
                              'fatG': 1,
                              'emoji': '🍚',
                            },
                          ],
                        }),
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

    final result = await service.analyze(jpegBytes, mealTypeHint: 'Lunch');

    expect(result.title, 'Chicken rice plate');
    expect(result.items, hasLength(2));
    expect(result.items.first.name, 'Grilled Chicken');
    expect(result.items.first.grams, 150);
    expect(
      result.items.first.caloriesPer100g,
      closeTo(316 * 100 / 150, 0.001),
    );
    expect(result.totalCaloriesKcal, closeTo(550, 0.001));
    expect(result.totalProteinG, closeTo(34, 0.001));

    expect(
      captured.uri.toString(),
      'https://generativelanguage.googleapis.com/v1beta'
      '/models/gemini-test-model:generateContent',
    );
    expect(captured.headers['x-goog-api-key'], 'test-key-123');

    final payload = captured.data as Map<String, dynamic>;
    final parts = ((payload['contents'] as List).first as Map)['parts'] as List;
    final inline = (parts[0] as Map)['inline_data'] as Map;
    expect(inline['mime_type'], 'image/jpeg');
    expect(inline['data'], base64Encode(jpegBytes));
    expect((parts[1] as Map)['text'] as String, contains('Lunch'));
    expect(
      (payload['generationConfig'] as Map)['responseMimeType'],
      'application/json',
    );
  });

  test('strips markdown fences and sniffs PNG magic bytes', () async {
    final pngBytes = Uint8List.fromList([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A]);
    late String? sentMime;
    final service = MealPhotoAnalyzer(
      apiKey: 'k',
      model: 'm',
      dio: _mockDio((options, handler) {
        final parts =
            (((options.data as Map)['contents'] as List).first
                as Map)['parts'] as List;
        sentMime = ((parts[0] as Map)['inline_data'] as Map)['mime_type']
            as String;
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
                        'text':
                            '```json\n'
                            '{"title":"Fruit bowl","items":['
                            '{"name":"Banana","grams":120,"caloriesKcal":106,'
                            '"proteinG":1.3,"carbsG":27,"fatG":0.4,"emoji":"🍌"}'
                            ']}\n```',
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

    final result = await service.analyze(pngBytes);

    expect(sentMime, 'image/png');
    expect(result.title, 'Fruit bowl');
    expect(result.items.single.name, 'Banana');
  });

  test('rejects an empty item list as "no food detected"', () async {
    final service = MealPhotoAnalyzer(
      apiKey: 'k',
      model: 'm',
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
                      {'text': _reply({'title': '', 'items': []})},
                    ],
                  },
                },
              ],
            },
          ),
        );
      }),
    );

    await expectLater(
      service.analyze(jpegBytes),
      throwsA(
        isA<MealPhotoAnalyzerException>().having(
          (e) => e.message,
          'message',
          contains('No food was detected'),
        ),
      ),
    );
  });

  test('rejects malformed JSON from the model', () async {
    final service = MealPhotoAnalyzer(
      apiKey: 'k',
      model: 'm',
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
                      {'text': 'sorry, I cannot help with that'},
                    ],
                  },
                },
              ],
            },
          ),
        );
      }),
    );

    await expectLater(
      service.analyze(jpegBytes),
      throwsA(
        isA<MealPhotoAnalyzerException>().having(
          (e) => e.message,
          'message',
          contains('unexpected response'),
        ),
      ),
    );
  });

  test('clamps bad numbers, dedupes names, and repairs kcal vs macros',
      () async {
    final service = MealPhotoAnalyzer(
      apiKey: 'k',
      model: 'm',
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
                        'text': _reply({
                          'title': 'Mixed plate',
                          'items': [
                            {
                              'name': '  Stew   Stew ',
                              'grams': -5,
                              'caloriesKcal': 10,
                              'proteinG': 10,
                              'carbsG': 10,
                              'fatG': 10,
                            },
                            {
                              'name': 'Stew Stew',
                              'grams': 200,
                              'caloriesKcal': 300,
                            },
                          ],
                        }),
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

    final result = await service.analyze(jpegBytes);

    expect(result.items, hasLength(1), reason: 'duplicate names are merged');
    final item = result.items.single;
    expect(item.name, 'Stew Stew');
    expect(item.grams, 5, reason: 'grams are clamped to the 5 g floor');
    // 4*10 + 4*10 + 9*10 = 170 kcal, far from the sent 10 → repaired.
    expect(item.caloriesKcal, closeTo(170, 0.001));
    expect(item.emoji, '🍽️', reason: 'missing emoji falls back');
  });

  test('maps Dio timeouts to a friendly photo-analysis message', () async {
    final service = MealPhotoAnalyzer(
      apiKey: 'k',
      model: 'm',
      dio: _mockDio((options, handler) {
        handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
          ),
        );
      }),
    );

    await expectLater(
      service.analyze(jpegBytes),
      throwsA(
        isA<MealPhotoAnalyzerException>().having(
          (e) => e.message,
          'message',
          contains('timed out'),
        ),
      ),
    );
  });
}
