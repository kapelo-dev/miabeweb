import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  // Clés pour les préférences utilisateur
  static const String _themeModeKey = 'themeMode';
  static const String _languageKey = 'language';

  // Enregistrer le mode thème (clair/sombre)
  static Future<bool> saveThemeMode(String themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_themeModeKey, themeMode);
    } catch (e) {
      print('Erreur lors de l\'enregistrement du thème: $e');
      return false;
    }
  }

  // Récupérer le mode thème
  static Future<String> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_themeModeKey) ?? 'system';
    } catch (e) {
      print('Erreur lors de la récupération du thème: $e');
      return 'system';
    }
  }

  // Enregistrer la langue
  static Future<bool> saveLanguage(String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_languageKey, language);
    } catch (e) {
      print('Erreur lors de l\'enregistrement de la langue: $e');
      return false;
    }
  }

  // Récupérer la langue
  static Future<String> getLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_languageKey) ?? 'fr';
    } catch (e) {
      print('Erreur lors de la récupération de la langue: $e');
      return 'fr';
    }
  }
}
