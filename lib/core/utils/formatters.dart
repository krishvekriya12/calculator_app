import 'package:intl/intl.dart';

/// Utility formatters for currency, dates, and numbers.
class AppFormatters {
  AppFormatters._();

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final _currencyDecimal = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final _compact = NumberFormat.compact(locale: 'en_IN');

  static final _dateShort = DateFormat('dd MMM');
  static final _dateFull = DateFormat('dd MMM yyyy');
  static final _dateTime = DateFormat('dd MMM, hh:mm a');
  static final _dayName = DateFormat('EEE');
  static final _monthYear = DateFormat('MMMM yyyy');
  static final _dayMonthYear = DateFormat('dd MMM, EEE');

  /// Formats a value as Indian rupee (no decimals): ₹1,234
  static String rupee(double value) => _currency.format(value);

  /// Formats a value as Indian rupee (with decimals): ₹1,234.50
  static String rupeeDecimal(double value) => _currencyDecimal.format(value);

  /// Compact number: 1.2K, 45K, 1.2L
  static String compact(double value) => _compact.format(value);

  /// Short date: 22 Jul
  static String dateShort(DateTime date) => _dateShort.format(date);

  /// Full date: 22 Jul 2026
  static String dateFull(DateTime date) => _dateFull.format(date);

  /// Date + time: 22 Jul, 03:45 PM
  static String dateTime(DateTime date) => _dateTime.format(date);

  /// Day abbreviation: Mon
  static String dayName(DateTime date) => _dayName.format(date);

  /// Month + year: July 2026
  static String monthYear(DateTime date) => _monthYear.format(date);

  /// Full readable date: 22 Jul, Tue
  static String entryDate(DateTime date) => _dayMonthYear.format(date);

  /// Returns "Aaj", "Kal", or a formatted date
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);

    final diff = today.difference(d).inDays;
    if (diff == 0) return 'Aaj';
    if (diff == 1) return 'Kal';
    if (diff <= 6) return '$diff din pehle';
    return dateFull(date);
  }

  /// Greeting based on time of day
  static String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Salaam 🌤️';
    if (hour < 17) return 'Salaam 🌞';
    if (hour < 20) return 'Salaam 🌇';
    return 'Salaam 🌙';
  }
}
