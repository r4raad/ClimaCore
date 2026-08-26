import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String _getEnvVar(String key) {
    try {
      final dotenvValue = dotenv.env[key];
      if (dotenvValue != null && dotenvValue.isNotEmpty) {
        return dotenvValue;
      }
    } catch (_) {}
    return '';
  }

  static String get supabaseUrl => _getEnvVar('SUPABASE_URL');
  static String get supabaseAnonKey => _getEnvVar('SUPABASE_ANON_KEY');
  static bool get isSupabaseConfigured => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static String get newsApiKey => _getEnvVar('NEWS_API_KEY');
  static String get gNewsApiKey => _getEnvVar('GNEWS_API_KEY');
  static bool get enableNewsApi => false;
  static bool get isNewsApiConfigured => newsApiKey.isNotEmpty && gNewsApiKey.isNotEmpty;

  static String get googleMapsApiKey => _getEnvVar('GOOGLE_MAPS_API_KEY');
  static bool get isGoogleMapsConfigured => googleMapsApiKey.isNotEmpty;

  static String get geminiApiKey => _getEnvVar('GEMINI_API_KEY');
  static bool get isAIConfigured => geminiApiKey.isNotEmpty;
}