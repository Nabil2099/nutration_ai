import 'package:dio/dio.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/data/models/meal_entry.dart';
import '../../../../core/data/models/user_profile.dart';
import '../../../../core/utils/day_key.dart';
import '../models/coach_message.dart';

class AiCoachException implements Exception {
  const AiCoachException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Calls Google AI Studio's Gemini API (`gemini-3.5-flash-lite` by default)
/// via Dio with the user's live nutrition goals and 7-day meal log context.
class AiCoachService {
  AiCoachService({Dio? dio, String? apiKey, String? model})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 25),
              receiveTimeout: const Duration(seconds: 25),
              sendTimeout: const Duration(seconds: 25),
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

  Future<String> sendMessage({
    required List<CoachMessage> history,
    required String prompt,
    UserProfile? profile,
    List<MealEntry> meals = const [],
    DateTime? now,
  }) async {
    final key = _apiKey;
    if (key.isEmpty) {
      throw const AiCoachException(
        'Missing GEMINI_API_KEY. Add your Google AI Studio key to the .env file and restart the app.',
      );
    }

    final contents = <Map<String, dynamic>>[
      for (final msg in history.take(12))
        {
          'role': msg.role == CoachRole.user ? 'user' : 'model',
          'parts': [
            {'text': msg.text},
          ],
        },
      {
        'role': 'user',
        'parts': [
          {'text': prompt.trim()},
        ],
      },
    ];

    final payload = <String, dynamic>{
      'systemInstruction': {
        'parts': [
          {
            'text': _buildSystemInstruction(
              profile: profile,
              meals: meals,
              today: now ?? DateTime.now(),
            ),
          },
        ],
      },
      'contents': contents,
      'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 512},
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
        throw const AiCoachException(
          'AI Coach returned an empty response. Please try asking again.',
        );
      }
      return text;
    } on AiCoachException {
      rethrow;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw const AiCoachException(
          'AI Coach timed out. Check your internet connection and try again.',
        );
      }
      final data = e.response?.data;
      final errorMap = data is Map ? data['error'] : null;
      final apiError = errorMap is Map ? errorMap['message'] as String? : null;
      if (apiError != null && apiError.isNotEmpty) {
        throw AiCoachException('Gemini API error: $apiError');
      }
      final code = e.response?.statusCode;
      if (code != null) {
        throw AiCoachException('AI Coach request failed ($code).');
      }
      throw const AiCoachException(
        'Could not reach AI Coach. Check your connection and try again.',
      );
    } catch (_) {
      throw const AiCoachException(
        'Could not reach AI Coach. Check your connection and try again.',
      );
    }
  }

  String _buildSystemInstruction({
    required UserProfile? profile,
    required List<MealEntry> meals,
    required DateTime today,
  }) {
    final todayKey = dayKey(today);
    final todayMeals = meals.where((m) => m.localDayKey == todayKey).toList();
    double sum(Iterable<MealEntry> list, double Function(MealEntry) f) =>
        list.fold<double>(0, (acc, item) => acc + f(item));

    final todayKcal = sum(todayMeals, (m) => m.caloriesKcal);
    final todayProtein = sum(todayMeals, (m) => m.proteinG);
    final todayCarbs = sum(todayMeals, (m) => m.carbsG);
    final todayFat = sum(todayMeals, (m) => m.fatG);

    final weekKcal = sum(meals, (m) => m.caloriesKcal);
    final weekProtein = sum(meals, (m) => m.proteinG);
    final weekCarbs = sum(meals, (m) => m.carbsG);
    final weekFat = sum(meals, (m) => m.fatG);

    final goals = profile?.dailyGoals;
    final goalKcal = goals?.calories.round() ?? 2000;
    final goalP = goals?.proteinG.round() ?? 120;
    final goalC = goals?.carbsG.round() ?? 220;
    final goalF = goals?.fatG.round() ?? 65;
    final remainingKcal = (goalKcal - todayKcal).round();
    final remainingP = (goalP - todayProtein).round();
    final remainingC = (goalC - todayCarbs).round();
    final remainingF = (goalF - todayFat).round();

    final mealList = todayMeals.isEmpty
        ? 'none logged yet today'
        : todayMeals
              .map(
                (m) =>
                    '${m.name} (${m.mealType}, ${m.caloriesKcal.round()} kcal, '
                    'P:${m.proteinG.round()}g C:${m.carbsG.round()}g F:${m.fatG.round()}g)',
              )
              .join('; ');

    return 'You are Sage AI, a supportive, expert nutrition coach inside a mobile nutrition app. '
        'Give personalized, practical, and encouraging answers grounded in the user\'s actual numbers below. '
        'Formatting rules:\n'
        '- Keep responses concise (90–140 words), scannable, and well-structured.\n'
        '- Use short paragraphs and at most 3 bullet points starting with "• ".\n'
        '- Wrap key numbers, macro targets, and food names in **bold** (e.g. **120g protein**, **350 kcal**).\n'
        '- Avoid markdown headings (#) or code blocks.\n'
        '- End with one concrete next-step meal or habit suggestion when helpful.\n'
        '- Never give medical diagnoses or prescriptions.\n\n'
        'User: ${profile?.name ?? 'User'}.\n'
        'Daily targets: $goalKcal kcal, ${goalP}g protein, ${goalC}g carbs, ${goalF}g fat.\n'
        'Today ($todayKey): ${todayKcal.round()} kcal consumed '
        '(P:${todayProtein.round()}g, C:${todayCarbs.round()}g, F:${todayFat.round()}g). '
        'Remaining today: $remainingKcal kcal, ${remainingP}g protein, ${remainingC}g carbs, ${remainingF}g fat.\n'
        'Today meals: $mealList.\n'
        '7-day totals: ${weekKcal.round()} kcal '
        '(avg ${(weekKcal / 7).round()} kcal/day, '
        'avg P:${(weekProtein / 7).round()}g, '
        'avg C:${(weekCarbs / 7).round()}g, '
        'avg F:${(weekFat / 7).round()}g).';
  }
}
