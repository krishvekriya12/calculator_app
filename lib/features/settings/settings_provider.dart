import 'package:flutter/foundation.dart';
import '../../data/repositories/settings_repository.dart';

/// Manages user preferences state.
class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repo;

  SettingsProvider(this._repo);

  String get userName => _repo.userName;
  String get defaultPlatform => _repo.defaultPlatform;

  Future<void> setUserName(String name) async {
    await _repo.setUserName(name.trim());
    notifyListeners();
  }

  Future<void> setDefaultPlatform(String platform) async {
    await _repo.setDefaultPlatform(platform);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _repo.clearAll();
    notifyListeners();
  }
}
