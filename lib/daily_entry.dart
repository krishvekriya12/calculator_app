class DailyEntry {
  final String id;
  final String platform;
  final double earning;
  final double fuelCost;
  final int ordersCount;
  final DateTime date;

  DailyEntry({
    required this.platform,
    required this.earning,
    required this.fuelCost,
    required this.ordersCount,
    required this.date,
  }) : id = DateTime.now().microsecondsSinceEpoch.toString();

  double get profit => earning - fuelCost;
}