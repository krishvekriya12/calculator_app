import 'package:flutter/foundation.dart';
import '../../data/models/daily_entry.dart';
import '../../data/repositories/entry_repository.dart';

/// Provides analytics data for the Stats screen.
class StatsProvider extends ChangeNotifier {
  final EntryRepository _repo;

  StatsProvider(this._repo) {
    _repo.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() => notifyListeners();

  // ── Overall ────────────────────────────────────────────────────────────────

  List<DailyEntry> get all => _repo.all;
  double get totalProfit => _repo.totalProfit;
  double get totalEarning => _repo.totalEarning;
  double get totalFuel => _repo.totalFuel;
  int get totalEntries => all.length;

  int get totalOrders => all.fold(0, (s, e) => s + e.ordersCount);

  double get avgEarningPerEntry =>
      totalEntries > 0 ? totalEarning / totalEntries : 0;

  double get avgProfitPerEntry =>
      totalEntries > 0 ? totalProfit / totalEntries : 0;

  // ── Weekly chart (last 7 days) ─────────────────────────────────────────────

  List<WeekDayData> get weeklyData {
    return List.generate(7, (i) {
      final day = DateTime.now().subtract(Duration(days: 6 - i));
      final entries = _repo.forDay(day);
      final profit = entries.fold(0.0, (s, e) => s + e.profit);
      return WeekDayData(date: day, profit: profit);
    });
  }

  /// Max profit in last 7 days (for chart scaling)
  double get maxWeeklyProfit {
    final profits = weeklyData.map((d) => d.profit.abs()).toList();
    return profits.isEmpty ? 1000 : profits.reduce((a, b) => a > b ? a : b);
  }

  // ── Monthly chart (last 30 days) ───────────────────────────────────────────

  List<WeekDayData> get monthlyData {
    return List.generate(30, (i) {
      final day = DateTime.now().subtract(Duration(days: 29 - i));
      final entries = _repo.forDay(day);
      final profit = entries.fold(0.0, (s, e) => s + e.profit);
      return WeekDayData(date: day, profit: profit);
    });
  }

  // ── Best / Worst day ───────────────────────────────────────────────────────

  DailyEntry? get bestEntry {
    if (all.isEmpty) return null;
    return all.reduce((a, b) => a.profit > b.profit ? a : b);
  }

  DailyEntry? get worstEntry {
    if (all.isEmpty) return null;
    return all.reduce((a, b) => a.profit < b.profit ? a : b);
  }

  // ── Platform breakdown ────────────────────────────────────────────────────

  Map<String, double> get platformEarnings {
    final map = <String, double>{};
    for (final e in all) {
      map[e.platform] = (map[e.platform] ?? 0) + e.earning;
    }
    return map;
  }

  Map<String, int> get platformCount {
    final map = <String, int>{};
    for (final e in all) {
      map[e.platform] = (map[e.platform] ?? 0) + 1;
    }
    return map;
  }
}

class WeekDayData {
  final DateTime date;
  final double profit;

  const WeekDayData({required this.date, required this.profit});
}
