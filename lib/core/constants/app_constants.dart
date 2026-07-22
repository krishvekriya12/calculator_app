/// Global app constants used across all features.
class AppConstants {
  AppConstants._();

  static const String appName = 'Daily Hisaab';
  static const String appTagline = 'Apna hisaab, apni taraqa';
  static const String appVersion = '2.0.0';

  // Hive box names
  static const String hiveEntriesBox = 'entries_box_v2';

  // SharedPreferences keys
  static const String prefOnboardingDone = 'onboarding_done_v2';
  static const String prefUserName = 'user_name';
  static const String prefDefaultPlatform = 'default_platform';

  // Platforms
  static const List<String> platforms = [
    'Zomato',
    'Swiggy',
    'Ola',
    'Uber',
    'Rapido',
    'Dunzo',
    'Other',
  ];

  // Animation durations
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);
  static const Duration splashDuration = Duration(milliseconds: 2600);
}
