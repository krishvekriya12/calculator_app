import 'package:flutter/foundation.dart';
import '../../data/models/daily_entry.dart';
import '../../data/repositories/entry_repository.dart';

/// Sort order options for the history list.
enum SortOrder { newest, oldest, mostProfit, leastProfit }

/// Provides filtered, sortable history data.
class HistoryProvider extends ChangeNotifier {
  final EntryRepository _repo;

  HistoryProvider(this._repo) {
    _repo.addListener(_onRepoChanged);
  }

  @override
  void dispose() {
    _repo.removeListener(_onRepoChanged);
    super.dispose();
  }

  void _onRepoChanged() {
    _applyFilters();
    notifyListeners();
  }

  // ── Filter state ───────────────────────────────────────────────────────────

  String? _selectedPlatform; // null = All
  SortOrder _sortOrder = SortOrder.newest;
  String _searchQuery = '';

  String? get selectedPlatform => _selectedPlatform;
  SortOrder get sortOrder => _sortOrder;
  String get searchQuery => _searchQuery;

  // ── Derived data ───────────────────────────────────────────────────────────

  List<DailyEntry> _filtered = [];
  List<DailyEntry> get filtered => _filtered;

  double get filteredProfit =>
      _filtered.fold(0.0, (s, e) => s + e.profit);

  double get filteredEarning =>
      _filtered.fold(0.0, (s, e) => s + e.earning);

  // ── Filters ────────────────────────────────────────────────────────────────

  void setPlatform(String? platform) {
    _selectedPlatform = platform;
    _applyFilters();
    notifyListeners();
  }

  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    var list = _selectedPlatform == null
        ? _repo.all
        : _repo.byPlatform(_selectedPlatform!);

    if (_searchQuery.isNotEmpty) {
      list = list
          .where((e) =>
              e.platform.toLowerCase().contains(_searchQuery) ||
              (e.notes?.toLowerCase().contains(_searchQuery) ?? false))
          .toList();
    }

    switch (_sortOrder) {
      case SortOrder.newest:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOrder.oldest:
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOrder.mostProfit:
        list.sort((a, b) => b.profit.compareTo(a.profit));
        break;
      case SortOrder.leastProfit:
        list.sort((a, b) => a.profit.compareTo(b.profit));
        break;
    }

    _filtered = list;
  }

  // ── Mutations ─────────────────────────────────────────────────────────────

  Future<void> deleteEntry(String id) => _repo.delete(id);

  // ── Initialise ─────────────────────────────────────────────────────────────

  void init() {
    _applyFilters();
    notifyListeners();
  }

  /// Sort by integer index (0=newest, 1=oldest, 2=mostProfit, 3=leastProfit)
  void setSortOrderByIndex(int index) {
    _sortOrder = SortOrder.values[index];
    _applyFilters();
    notifyListeners();
  }
}

extension SortOrderLabel on SortOrder {
  String get label {
    switch (this) {
      case SortOrder.newest:
        return 'Naye pehle';
      case SortOrder.oldest:
        return 'Purane pehle';
      case SortOrder.mostProfit:
        return 'Zyada profit';
      case SortOrder.leastProfit:
        return 'Kam profit';
    }
  }
}
