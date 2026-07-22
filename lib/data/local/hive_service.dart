import 'package:hive_flutter/hive_flutter.dart';
import '../adapters/daily_entry_adapter.dart';
import '../models/daily_entry.dart';
import '../../core/constants/app_constants.dart';

/// Initialises Hive and exposes typed boxes.
class HiveService {
  HiveService._();

  static late Box<DailyEntry> _entriesBox;

  static Box<DailyEntry> get entriesBox => _entriesBox;

  /// Call once from [main] before [runApp].
  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters (guard against duplicate registration)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DailyEntryAdapter());
    }

    _entriesBox = await Hive.openBox<DailyEntry>(AppConstants.hiveEntriesBox);
  }

  /// Deletes all data — used in Settings reset.
  static Future<void> clearAll() async {
    await _entriesBox.clear();
  }
}
