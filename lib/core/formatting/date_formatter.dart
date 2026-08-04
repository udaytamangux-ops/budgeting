import 'package:intl/intl.dart';

final class DateFormatter {
  DateFormatter({String locale = 'en_US'})
    : _monthName = DateFormat('MMMM', locale),
      _monthYear = DateFormat('MMMM y', locale),
      _shortMonthYear = DateFormat('MMM y', locale),
      _shortDate = DateFormat('d MMM y', locale),
      _longDate = DateFormat('d MMMM y', locale),
      _dateAndTime = DateFormat('d MMMM y, h:mm a', locale);

  final DateFormat _monthName;
  final DateFormat _monthYear;
  final DateFormat _shortMonthYear;
  final DateFormat _shortDate;
  final DateFormat _longDate;
  final DateFormat _dateAndTime;

  String monthName(DateTime date) => _monthName.format(date.toLocal());

  String monthYear(DateTime date) => _monthYear.format(date.toLocal());

  String shortMonthYear(DateTime date) =>
      _shortMonthYear.format(date.toLocal());

  String shortDate(DateTime date) => _shortDate.format(date.toLocal());

  String longDate(DateTime date) => _longDate.format(date.toLocal());

  String dateAndTime(DateTime date) => _dateAndTime.format(date.toLocal());

  String relativeDate(DateTime date, {DateTime? relativeTo}) {
    final DateTime localDate = date.toLocal();
    final DateTime localNow = (relativeTo ?? DateTime.now()).toLocal();
    final DateTime day = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
    );
    final DateTime today = DateTime(
      localNow.year,
      localNow.month,
      localNow.day,
    );
    final int difference = today.difference(day).inDays;

    return switch (difference) {
      0 => 'Today',
      1 => 'Yesterday',
      _ => shortDate(localDate),
    };
  }

  String transactionGroupLabel(DateTime date, {DateTime? relativeTo}) {
    final String relative = relativeDate(date, relativeTo: relativeTo);
    return relative == 'Today' || relative == 'Yesterday'
        ? relative
        : longDate(date);
  }
}
