import 'package:shared_preferences/shared_preferences.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'English(US)';

  Future<String> getCurrentLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_languageKey) ?? _defaultLanguage;
    } catch (e) {
      print('❌ LanguageService: Error getting current language: $e');
      return _defaultLanguage;
    }
  }

  Future<void> setLanguage(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language);
      print('✅ LanguageService: Language set to $language');
    } catch (e) {
      print('❌ LanguageService: Error setting language: $e');
      rethrow;
    }
  }

  String getTranslatedText(String key) {
    final currentLanguage = getCurrentLanguage();
    
    // In a real app, you would use a proper localization system
    // For now, return the key as-is
    return key;
  }

  List<Map<String, String>> getAvailableLanguages() {
    return [
      {'code': 'en', 'name': 'English(US)', 'native': 'English'},
      {'code': 'ko', 'name': 'Korean', 'native': '한국어'},
      {'code': 'es', 'name': 'Spanish', 'native': 'Español'},
      {'code': 'fr', 'name': 'French', 'native': 'Français'},
      {'code': 'de', 'name': 'German', 'native': 'Deutsch'},
    ];
  }
} 