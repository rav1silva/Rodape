import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper fino sobre [SharedPreferences] para preferências locais simples
/// (token de sessão, CEP escolhido, flags de onboarding).
class HelperPref {
  HelperPref._();

  static const _keyAuthToken = 'auth_token';
  static const _keyOnboardingDone = 'onboarding_done';
  static const _keyCep = 'user_cep';

  static Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAuthToken, token);
  }

  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAuthToken);
  }

  static Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAuthToken);
  }

  static Future<void> setOnboardingDone(bool done) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, done);
  }

  static Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingDone) ?? false;
  }

  static Future<void> saveCep(String cep) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCep, cep);
  }

  static Future<String?> getCep() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCep);
  }
}
