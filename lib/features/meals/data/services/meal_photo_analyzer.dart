import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/config/env_config.dart';
import '../models/meal_analysis.dart';

class MealPhotoAnalyzerException implements Exception {
  const MealPhotoAnalyzerException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Analyzes a meal photo and returns the detected foods with estimated
/// portions, calories, and macros. Matches the [AddMealCubit] injection shape.
typedef MealPhotoAnalyzerFn =
    Future<MealAnalysis> Function(Uint8List imageBytes, {String? mealTypeHint});

/// Calls Google AI Studio's Gemini API (`gemini-3.5-flash-lite` by default)
/// with an inline (base64) meal photo and returns structured nutrition data.
class MealPhotoAnalyzer {
  MealPhotoAnalyzer({Dio? dio, String? apiKey, String? model})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(seconds: 45),
              sendTimeout: const Duration(seconds: 30),
              headers: const {'Content-Type': 'application/json'},
            ),
          ),
      _apiKeyOverride = apiKey,
      _modelOverride = model;

  static const _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';

  final Dio _dio;
  final String? _apiKeyOverride;
  final String? _modelOverride;

  String get _apiKey => (_apiKeyOverride ?? EnvConfig.geminiApiKey).trim();
  String get _model => (_modelOverride ?? EnvConfig.geminiModel).trim();

  /// Sends [imageBytes] to Gemini and returns the parsed [MealAnalysis].
  ///
  /// [mealTypeHint] is the meal slot the user is logging (e.g. `Lunch`).
  Future<MealAnalysis> analyze(
    Uint8List imageBytes, {
    String? mealTypeHint,
  }) async {
    final key = _apiKey;
    if (key.isEmpty) {
      throw const MealPhotoAnalyzerException(
        'Missing GEMINI_API_KEY. Add your Google AI Studio key to the .env file and restart the app.',
      );
    }
    if (imageBytes.isEmpty) {
      throw const MealPhotoAnalyzerException(
        'The selected photo is empty. Please try another photo.',
      );
    }

    final payload = <String, dynamic>{
      'contents': [
        {
          'parts': [
            {
              'inline_data': {
                'mime_type': _sniffMimeType(imageBytes),
                'data': base64Encode(imageBytes),
              },
            },
            {'text': _buildPrompt(mealTypeHint)},
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.2,
        'maxOutputTokens': 1024,
        'responseMimeType': 'application/json',
      },
    };

    try {
      final path = _dio.options.baseUrl.isEmpty
          ? '$_baseUrl/models/$_model:generateContent'
          : '/models/$_model:generateContent';

      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: payload,
        options: Options(headers: {'x-goog-api-key': key}),
      );

      final decoded = response.data;
      final candidates = decoded?['candidates'] as List<dynamic>?;
      final parts =
          candidates?.firstOrNull?['content']?['parts'] as List<dynamic>?;
      final text = parts
          ?.map((p) => p is Map ? p['text'] as String? : null)
          .whereType<String>()
          .join('\n')
          .trim();

      if (text == null || text.isEmpty) {
        throw const MealPhotoAnalyzerException(
          'The AI returned an empty response. Please try again.',
        );
      }
      return _parseAnalysis(text);
    } on MealPhotoAnalyzerException {
      rethrow;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const MealPhotoAnalyzerException(
          'Photo analysis timed out. Check your internet connection and try again.',
        );
      }
      final data = e.response?.data;
      final errorMap = data is Map ? data['error'] : null;
      final apiError = errorMap is Map ? errorMap['message'] as String? : null;
      if (apiError != null && apiError.isNotEmpty) {
        throw MealPhotoAnalyzerException('Gemini API error: $apiError');
      }
      final code = e.response?.statusCode;
      if (code != null) {
        throw MealPhotoAnalyzerException(
          'Photo analysis failed ($code). Please try again.',
        );
      }
      throw const MealPhotoAnalyzerException(
        'Could not reach the AI service. Check your connection and try again.',
      );
    } catch (_) {
      throw const MealPhotoAnalyzerException(
        'Could not analyze the photo. Check your connection and try again.',
      );
    }
  }

  String _buildPrompt(String? mealTypeHint) {
    final contextLine = mealTypeHint == null || mealTypeHint.trim().isEmpty
        ? ''
        : 'The user is logging this as: ${mealTypeHint.trim()}.\n';
    return 'You are a nutrition photo analyst inside a calorie-tracking app. '
        'Examine the image and identify every distinct food or drink item '
        'visible.\n\n'
        '$contextLine'
        'Estimate a realistic portion weight in grams for the serving shown '
        '(assume a standard adult meal; cooked weights for cooked foods).\n\n'
        'Return ONLY a JSON object with exactly this shape:\n'
        '{"title": "<short name for the whole meal, max 60 chars>", '
        '"items": [{"name": "<food name, max 50 chars>", '
        '"grams": <number, 5-5000>, "caloriesKcal": <number>, '
        '"proteinG": <number>, "carbsG": <number>, "fatG": <number>, '
        '"emoji": "<single emoji>"}]}\n\n'
        'Rules:\n'
        '- Nutrition values must be totals for the stated grams of each item.\n'
        '- Keep calories consistent with macros: calories ≈ 4*protein + '
        '4*carbs + 9*fat (within 15%).\n'
        '- Combine identical pieces (e.g. 6 nuggets) into one item with the '
        'total grams.\n'
        '- If several components share one sauce or dressing, list it as its '
        'own item only when clearly separate.\n'
        '- If no food is visible, return {"title":"","items":[]}.\n'
        '- JSON only — no markdown, no commentary.';
  }

  /// Strips code fences/prose and validates the model's JSON reply.
  MealAnalysis _parseAnalysis(String text) {
    var raw = text.trim();
    if (raw.startsWith('```')) {
      raw = raw
          .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
          .replaceFirst(RegExp(r'\s*```$'), '');
    }
    final start = raw.indexOf('{');
    final end = raw.lastIndexOf('}');
    if (start >= 0 && end > start) {
      raw = raw.substring(start, end + 1);
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      throw const MealPhotoAnalyzerException(
        'The AI returned an unexpected response. Please try again.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw const MealPhotoAnalyzerException(
        'The AI returned an unexpected response. Please try again.',
      );
    }

    final seenNames = <String>{};
    final items = <AnalyzedMealItem>[];
    final itemsRaw = decoded['items'];
    if (itemsRaw is List) {
      for (final entry in itemsRaw) {
        if (entry is! Map) continue;
        final name = _cleanName(entry['name']);
        if (name.isEmpty || !seenNames.add(name)) continue;

        final grams = _clamp(entry['grams'], min: 5, max: 5000, fallback: 100);
        var calories = _clamp(entry['caloriesKcal'], min: 0, max: 8000);
        final protein = _clamp(entry['proteinG'], min: 0, max: 1000);
        final carbs = _clamp(entry['carbsG'], min: 0, max: 1000);
        final fat = _clamp(entry['fatG'], min: 0, max: 1000);

        // Guard against unit mistakes (e.g. per-100 g values): when calories
        // are wildly off from the macros, trust the Atwater estimate instead.
        final macroKcal = 4 * protein + 4 * carbs + 9 * fat;
        if (macroKcal > 30 && (calories - macroKcal).abs() > macroKcal * 0.5) {
          calories = macroKcal;
        }

        items.add(
          AnalyzedMealItem(
            name: name,
            grams: grams,
            caloriesKcal: calories,
            proteinG: protein,
            carbsG: carbs,
            fatG: fat,
            emoji: _cleanEmoji(entry['emoji']),
          ),
        );
      }
    }

    if (items.isEmpty) {
      throw const MealPhotoAnalyzerException(
        'No food was detected in that photo. Try a clearer shot of the meal.',
      );
    }

    final title = _cleanName(decoded['title']);
    return MealAnalysis(
      title: title.isEmpty ? items.first.name : title,
      items: List.unmodifiable(items),
    );
  }

  String _cleanName(Object? value) {
    if (value is! String) return '';
    final cleaned = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned.length <= 60 ? cleaned : cleaned.substring(0, 60);
  }

  String _cleanEmoji(Object? value) {
    if (value is! String) return '🍽️';
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > 8) return '🍽️';
    return trimmed;
  }

  double _clamp(
    Object? value, {
    required double min,
    required double max,
    required double fallback,
  }) {
    final number = value is num ? value.toDouble() : null;
    if (number == null || number.isNaN || number.isInfinite) return fallback;
    return number.clamp(min, max);
  }

  /// Detects the image format from magic bytes so the payload's `mime_type`
  /// matches the actual bytes (the picker may return PNG or WebP on web).
  String _sniffMimeType(Uint8List bytes) {
    if (bytes.length > 3 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length > 2 &&
        bytes[0] == 0x47 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46) {
      return 'image/gif';
    }
    if (bytes.length > 11 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }
}
