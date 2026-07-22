import 'package:flutter/foundation.dart';
import '../../data/models/daily_entry.dart';
import '../../data/repositories/entry_repository.dart';

/// Provides data for the Home screen: today's entries + summary.
class HomeProvider extends ChangeNotifier {
  final EntryRepository _repo;

  HomeProvider(this._repo) {
    _repo.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() => notifyListeners();

  // ── Today ──────────────────────────────────────────────────────────────────

  List<DailyEntry> get todayEntries => _repo.forDay(DateTime.now());

  double get todayEarning =>
      todayEntries.fold(0.0, (s, e) => s + e.earning);

  double get todayFuel =>
      todayEntries.fold(0.0, (s, e) => s + e.fuelCost);

  double get todayProfit =>
      todayEntries.fold(0.0, (s, e) => s + e.profit);

  int get todayOrders =>
      todayEntries.fold(0, (s, e) => s + e.ordersCount);

  // ── Recent (last 10 for home feed) ────────────────────────────────────────

  List<DailyEntry> get recentEntries => _repo.all.take(15).toList();

  // ── Overall totals ────────────────────────────────────────────────────────

  double get totalProfit => _repo.totalProfit;
  double get totalEarning => _repo.totalEarning;
  double get totalFuel => _repo.totalFuel;
  int get totalEntries => _repo.all.length;

  // ── Last 7 days chart data ────────────────────────────────────────────────

  /// Returns list of 7 [_DayData] — index 0 = 6 days ago, index 6 = today.
  List<DayData> get last7DaysData {
    return List.generate(7, (i) {
      final day = DateTime.now().subtract(Duration(days: 6 - i));
      final entries = _repo.forDay(day);
      final earning = entries.fold(0.0, (s, e) => s + e.earning);
      final fuel = entries.fold(0.0, (s, e) => s + e.fuelCost);
      return DayData(date: day, earning: earning, fuel: fuel);
    });
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  Future<void> addEntry(DailyEntry entry) => _repo.add(entry);

  Future<void> deleteEntry(String id) => _repo.delete(id);
}

class DayData {
  final DateTime date;
  final double earning;
  final double fuel;

  const DayData({
    required this.date,
    required this.earning,
    required this.fuel,
  });

  double get profit => earning - fuel;
}
