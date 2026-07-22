import 'package:hive_flutter/hive_flutter.dart';
import '../models/daily_entry.dart';

/// Hand-written Hive TypeAdapter for [DailyEntry].
/// No build_runner needed.
class DailyEntryAdapter extends TypeAdapter<DailyEntry> {
  @override
  final int typeId = 0;

  @override
  DailyEntry read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return DailyEntry(
      id: fields[0] as String,
      platform: fields[1] as String,
      earning: (fields[2] as num).toDouble(),
      fuelCost: (fields[3] as num).toDouble(),
      ordersCount: (fields[4] as num).toInt(),
      date: DateTime.fromMillisecondsSinceEpoch(fields[5] as int),
      notes: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DailyEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.platform)
      ..writeByte(2)
      ..write(obj.earning)
      ..writeByte(3)
      ..write(obj.fuelCost)
      ..writeByte(4)
      ..write(obj.ordersCount)
      ..writeByte(5)
      ..write(obj.date.millisecondsSinceEpoch)
      ..writeByte(6)
      ..write(obj.notes);
  }
}
