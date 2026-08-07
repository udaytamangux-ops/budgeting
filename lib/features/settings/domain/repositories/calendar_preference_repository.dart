import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';

abstract interface class CalendarPreferenceRepository {
  Stream<AppCalendarSystem> watchPrimaryCalendar();

  Future<AppCalendarSystem> getPrimaryCalendar();

  Future<void> setPrimaryCalendar(AppCalendarSystem calendarSystem);

  Stream<bool> watchCalendarSetupComplete();

  Future<bool> isCalendarSetupComplete();

  Future<void> markCalendarSetupComplete(AppCalendarSystem calendarSystem);

  Future<void> resetCalendarSetup();
}
