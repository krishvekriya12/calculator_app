/// Immutable model representing one day's earning entry.
class DailyEntry {
  final String id;
  final String platform;
  final double earning;
  final double fuelCost;
  final int ordersCount;
  final DateTime date;
  final String? notes;

  const DailyEntry({
    required this.id,
    required this.platform,
    required this.earning,
    required this.fuelCost,
    required this.ordersCount,
    required this.date,
    this.notes,
  });

  /// Net profit = earning - fuelCost
  double get profit => earning - fuelCost;

  /// Whether this entry made a profit
  bool get isProfit => profit >= 0;

  /// Earnings per order (safe division)
  double get earningPerOrder =>
      ordersCount > 0 ? earning / ordersCount : earning;

  /// Factory that auto-generates a unique ID.
  factory DailyEntry.create({
    required String platform,
    required double earning,
    required double fuelCost,
    required int ordersCount,
    required DateTime date,
    String? notes,
  }) {
    return DailyEntry(
      id: '${date.millisecondsSinceEpoch}_${platform.toLowerCase()}',
      platform: platform,
      earning: earning,
      fuelCost: fuelCost,
      ordersCount: ordersCount,
      date: date,
      notes: notes,
    );
  }

  DailyEntry copyWith({
    String? id,
    String? platform,
    double? earning,
    double? fuelCost,
    int? ordersCount,
    DateTime? date,
    String? notes,
  }) {
    return DailyEntry(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      earning: earning ?? this.earning,
      fuelCost: fuelCost ?? this.fuelCost,
      ordersCount: ordersCount ?? this.ordersCount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'platform': platform,
        'earning': earning,
        'fuelCost': fuelCost,
        'ordersCount': ordersCount,
        'date': date.millisecondsSinceEpoch,
        'notes': notes,
      };

  factory DailyEntry.fromMap(Map<dynamic, dynamic> map) => DailyEntry(
        id: map['id'] as String,
        platform: map['platform'] as String,
        earning: (map['earning'] as num).toDouble(),
        fuelCost: (map['fuelCost'] as num).toDouble(),
        ordersCount: (map['ordersCount'] as num).toInt(),
        date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
        notes: map['notes'] as String?,
      );

  @override
  String toString() =>
      'DailyEntry(id: $id, platform: $platform, profit: $profit)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyEntry &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
