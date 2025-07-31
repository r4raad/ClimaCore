import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get supabaseUrl {
    // Use hardcoded value instead of environment variable
    return 'https://qrsjqhyueylcyaumqrhy.supabase.co';
  }

  static String get supabaseAnonKey {
    // Use hardcoded value instead of environment variable
    return 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFyc2pxaHl1ZXlsY3lhdW1xcmh5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5NjU1NTYsImV4cCI6MjA2OTU0MTU1Nn0.B0gQWfY_9agbIxpGwYVoNaCRNcyq94IQS2yXQzFbNUQ';
  }

  static bool get isSupabaseConfigured {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }

  // News API keys - using hardcoded values
  static String get newsApiKey {
    return '9e2a2889e5434c26a27b8575ef476643';
  }

  static String get gNewsApiKey {
    return '9325b82ee95c436591389f541e45d3e4';
  }

  static bool get isNewsApiConfigured {
    return newsApiKey.isNotEmpty && gNewsApiKey.isNotEmpty;
  }

  // Google Maps API key - using hardcoded value
  static String get googleMapsApiKey {
    return 'AIzaSyDDbZHL7MXkEvcUF_n4z7mRFKsSUCq7-4Q';
  }

  static bool get isGoogleMapsConfigured {
    return googleMapsApiKey.isNotEmpty && googleMapsApiKey != 'YOUR_GOOGLE_MAPS_API_KEY_HERE';
  }
} 