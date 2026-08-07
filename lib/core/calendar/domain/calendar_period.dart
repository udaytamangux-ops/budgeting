import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';

final class CalendarPeriod {
  CalendarPeriod({
    required this.calendarSystem,
    required this.year,
    required this.month,
    required DateTime startAdInclusive,
    required DateTime endAdExclusive,
    required this.displayLabel,
  }) : startAdInclusive = _dateOnlyUtc(startAdInclusive),
       endAdExclusive = _dateOnlyUtc(endAdExclusive) {
    if (!this.endAdExclusive.isAfter(this.startAdInclusive)) {
      throw ArgumentError('Calendar period end must be after its start.');
    }
  }

  final AppCalendarSystem calendarSystem;
  final int year;
  final int month;
  final DateTime startAdInclusive;
  final DateTime endAdExclusive;
  final String displayLabel;

  bool contains(DateTime date) {
    final DateTime instant = date.toUtc();
    return !instant.isBefore(startAdInclusive) &&
        instant.isBefore(endAdExclusive);
  }

  String get identifier =>
      '${calendarSystem.storageValue}:$year:${month.toString().padLeft(2, '0')}';

  static DateTime _dateOnlyUtc(DateTime value) {
    final DateTime utc = value.toUtc();
    return DateTime.utc(utc.year, utc.month, utc.day);
  }

  @override
  bool operator ==(Object other) {
    return other is CalendarPeriod &&
        calendarSystem == other.calendarSystem &&
        year == other.year &&
        month == other.month &&
        startAdInclusive == other.startAdInclusive &&
        endAdExclusive == other.endAdExclusive;
  }

  @override
  int get hashCode => Object.hash(
    calendarSystem,
    year,
    month,
    startAdInclusive,
    endAdExclusive,
  );
}
