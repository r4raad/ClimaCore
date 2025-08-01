import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get supabaseUrl {
    return dotenv.env['SUPABASE_URL'] ?? '';
  }

  static String get supabaseAnonKey {
    return dotenv.env['SUPABASE_ANON_KEY'] ?? '';
  }

  static bool get isSupabaseConfigured {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }

  // News API keys
  static String get newsApiKey {
    return dotenv.env['NEWS_API_KEY'] ?? '';
  }

  static String get gNewsApiKey {
    return dotenv.env['GNEWS_API_KEY'] ?? '';
  }

  static bool get isNewsApiConfigured {
    return newsApiKey.isNotEmpty && gNewsApiKey.isNotEmpty;
  }

  // Google Maps API key
  static String get googleMapsApiKey {
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  }

  static bool get isGoogleMapsConfigured {
    return googleMapsApiKey.isNotEmpty && googleMapsApiKey != 'YOUR_GOOGLE_MAPS_API_KEY_HERE';
  }
} 