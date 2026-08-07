import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/bs_date.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';

abstract interface class AppCalendarService {
  BsDate toBs(DateTime adDate);

  DateTime toAd(BsDate bsDate);

  CalendarPeriod periodForDate(
    DateTime adDate,
    AppCalendarSystem calendarSystem,
  );

  CalendarPeriod periodFor({
    required AppCalendarSystem calendarSystem,
    required int year,
    required int month,
  });

  CalendarPeriod currentPeriod(
    AppCalendarSystem calendarSystem, {
    DateTime? now,
  });

  CalendarPeriod previousPeriod(CalendarPeriod period);

  CalendarPeriod nextPeriod(CalendarPeriod period);

  bool isDateInPeriod(DateTime date, CalendarPeriod period);

  String formatDate(DateTime adDate, AppCalendarSystem calendarSystem);

  String formatDateAndTime(
    DateTime adTimestamp,
    AppCalendarSystem calendarSystem,
  );

  String formatShortDate(DateTime adDate, AppCalendarSystem calendarSystem);

  String formatMonthYear(CalendarPeriod period);

  String formatMonthName(CalendarPeriod period);

  String formatDayGroup(
    DateTime adDate,
    AppCalendarSystem calendarSystem, {
    DateTime? relativeTo,
  });

  String formatDateSemantics(DateTime adDate, AppCalendarSystem calendarSystem);

  int daysInBsMonth(int year, int month);
}
