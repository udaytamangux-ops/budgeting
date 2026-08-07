import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/features/settings/domain/repositories/calendar_preference_repository.dart';

final class DriftCalendarPreferenceRepository
    implements CalendarPreferenceRepository {
  const DriftCalendarPreferenceRepository(this._database);

  static const String primaryCalendarKey = 'primary_calendar';
  static const String setupCompleteKey = 'calendar_setup_complete';

  final AppDatabase _database;

  @override
  Future<AppCalendarSystem> getPrimaryCalendar() async {
    return AppCalendarSystemLabels.fromStoredValue(
      await _database.readPreference(primaryCalendarKey),
    );
  }

  @override
  Future<bool> isCalendarSetupComplete() async {
    return await _database.readPreference(setupCompleteKey) == 'true';
  }

  @override
  Future<void> markCalendarSetupComplete(
    AppCalendarSystem calendarSystem,
  ) async {
    await _database.transaction(() async {
      await setPrimaryCalendar(calendarSystem);
      await _database.writePreference(setupCompleteKey, 'true');
    });
  }

  @override
  Future<void> resetCalendarSetup() async {
    await _database.deletePreference(setupCompleteKey);
  }

  @override
  Future<void> setPrimaryCalendar(AppCalendarSystem calendarSystem) {
    return _database.writePreference(
      primaryCalendarKey,
      calendarSystem.storageValue,
    );
  }

  @override
  Stream<bool> watchCalendarSetupComplete() {
    return _database
        .watchPreference(setupCompleteKey)
        .map((String? value) => value == 'true');
  }

  @override
  Stream<AppCalendarSystem> watchPrimaryCalendar() {
    return _database
        .watchPreference(primaryCalendarKey)
        .map(AppCalendarSystemLabels.fromStoredValue);
  }
}
