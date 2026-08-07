import 'dart:async';

import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/features/settings/domain/repositories/calendar_preference_repository.dart';

final class InMemoryCalendarPreferenceRepository
    implements CalendarPreferenceRepository {
  InMemoryCalendarPreferenceRepository({
    AppCalendarSystem initialCalendar = AppCalendarSystem.gregorianAd,
    bool initialSetupComplete = false,
  }) : _calendar = initialCalendar,
       _setupComplete = initialSetupComplete;

  AppCalendarSystem _calendar;
  bool _setupComplete;
  final StreamController<AppCalendarSystem> _calendarController =
      StreamController<AppCalendarSystem>.broadcast();
  final StreamController<bool> _setupController =
      StreamController<bool>.broadcast();

  @override
  Future<AppCalendarSystem> getPrimaryCalendar() async => _calendar;

  @override
  Future<bool> isCalendarSetupComplete() async => _setupComplete;

  @override
  Future<void> markCalendarSetupComplete(
    AppCalendarSystem calendarSystem,
  ) async {
    await setPrimaryCalendar(calendarSystem);
    _setupComplete = true;
    _setupController.add(true);
  }

  @override
  Future<void> resetCalendarSetup() async {
    _setupComplete = false;
    _setupController.add(false);
  }

  @override
  Future<void> setPrimaryCalendar(AppCalendarSystem calendarSystem) async {
    _calendar = calendarSystem;
    _calendarController.add(calendarSystem);
  }

  @override
  Stream<bool> watchCalendarSetupComplete() async* {
    yield _setupComplete;
    yield* _setupController.stream;
  }

  @override
  Stream<AppCalendarSystem> watchPrimaryCalendar() async* {
    yield _calendar;
    yield* _calendarController.stream;
  }

  Future<void> dispose() async {
    await _calendarController.close();
    await _setupController.close();
  }
}
