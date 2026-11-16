import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Environment configuration loaded from `.env` (gitignored) with compile-time
/// `--dart-define` fallbacks.
class EnvConfig {
  const EnvConfig._();

  static const defaultGeminiModel = 'gemini-3.5-flash-lite';

  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Allow booting even if `.env` is absent (e.g. CI or --dart-define).
    }
  }

  static String get geminiApiKey {
    if (dotenv.isInitialized) {
      final value = dotenv.env['GEMINI_API_KEY']?.trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    return const String.fromEnvironment('GEMINI_API_KEY').trim();
  }

  static String get geminiModel {
    if (dotenv.isInitialized) {
      final value = dotenv.env['GEMINI_MODEL']?.trim() ?? '';
      if (value.isNotEmpty) return value;
    }
    const defined = String.fromEnvironment('GEMINI_MODEL');
    return defined.trim().isEmpty ? defaultGeminiModel : defined.trim();
  }
}
