import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

/// Repository for user preferences via SharedPreferences.
class SettingsRepository {
  SettingsRepository._();

  static SettingsRepository? _instance;
  static SharedPreferences? _prefs;

  factory SettingsRepository() {
    _instance ??= SettingsRepository._();
    return _instance!;
  }

  /// Call once during init.
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ── Onboarding ─────────────────────────────────────────────────────────────

  bool get onboardingDone =>
      _prefs?.getBool(AppConstants.prefOnboardingDone) ?? false;

  Future<void> setOnboardingDone() async =>
      _prefs?.setBool(AppConstants.prefOnboardingDone, true);

  // ── User name ──────────────────────────────────────────────────────────────

  String get userName =>
      _prefs?.getString(AppConstants.prefUserName) ?? '';

  Future<void> setUserName(String name) async =>
      _prefs?.setString(AppConstants.prefUserName, name);

  // ── Default platform ───────────────────────────────────────────────────────

  String get defaultPlatform =>
      _prefs?.getString(AppConstants.prefDefaultPlatform) ??
      AppConstants.platforms.first;

  Future<void> setDefaultPlatform(String p) async =>
      _prefs?.setString(AppConstants.prefDefaultPlatform, p);

  // ── Reset ──────────────────────────────────────────────────────────────────

  Future<void> clearAll() async => _prefs?.clear();
}
