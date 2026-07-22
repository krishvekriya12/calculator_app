import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/daily_entry.dart';

/// Repository for [DailyEntry] persistence via Hive.
///
/// Extends [ChangeNotifier] so that [HomeProvider], [HistoryProvider], and
/// [StatsProvider] can react to any mutation without coupling to each other.
class EntryRepository extends ChangeNotifier {
  final Box<DailyEntry> _box;

  EntryRepository(this._box);

  // ── Read ───────────────────────────────────────────────────────────────────

  /// All entries, newest first.
  List<DailyEntry> get all {
    final list = _box.values.toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Entries for a specific calendar day.
  List<DailyEntry> forDay(DateTime day) {
    return all.where((e) => _sameDay(e.date, day)).toList();
  }

  /// Entries for the last [days] calendar days (including today).
  List<DailyEntry> lastDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days - 1));
    final from = DateTime(cutoff.year, cutoff.month, cutoff.day);
    return all.where((e) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      return !d.isBefore(from);
    }).toList();
  }

  /// Entries filtered by platform (null = all).
  List<DailyEntry> byPlatform(String? platform) {
    if (platform == null) return all;
    return all
        .where((e) => e.platform.toLowerCase() == platform.toLowerCase())
        .toList();
  }

  /// Total profit across all entries.
  double get totalProfit =>
      all.fold(0.0, (sum, e) => sum + e.profit);

  /// Total earnings across all entries.
  double get totalEarning =>
      all.fold(0.0, (sum, e) => sum + e.earning);

  /// Total fuel cost across all entries.
  double get totalFuel =>
      all.fold(0.0, (sum, e) => sum + e.fuelCost);

  // ── Write ──────────────────────────────────────────────────────────────────

  Future<void> add(DailyEntry entry) async {
    await _box.put(entry.id, entry);
    notifyListeners();
  }

  Future<void> update(DailyEntry entry) async {
    await _box.put(entry.id, entry);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _box.clear();
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
