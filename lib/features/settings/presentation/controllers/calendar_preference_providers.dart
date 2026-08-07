import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/core/database/database_providers.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/settings/data/repositories/drift_calendar_preference_repository.dart';
import 'package:budgeting_app/features/settings/domain/repositories/calendar_preference_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<AppCalendarService> appCalendarServiceProvider =
    Provider<AppCalendarService>((Ref ref) {
      return BikramSambatCalendarService();
    });

final Provider<CalendarPreferenceRepository>
calendarPreferenceRepositoryProvider = Provider<CalendarPreferenceRepository>((
  Ref ref,
) {
  return DriftCalendarPreferenceRepository(ref.watch(appDatabaseProvider));
});

final StreamProvider<AppCalendarSystem> primaryCalendarProvider =
    StreamProvider<AppCalendarSystem>((Ref ref) {
      return ref
          .watch(calendarPreferenceRepositoryProvider)
          .watchPrimaryCalendar();
    });

final StreamProvider<bool> calendarSetupCompleteProvider = StreamProvider<bool>(
  (Ref ref) {
    return ref
        .watch(calendarPreferenceRepositoryProvider)
        .watchCalendarSetupComplete();
  },
);

final Provider<CalendarPeriod> currentCalendarPeriodProvider =
    Provider<CalendarPeriod>((Ref ref) {
      final AppCalendarSystem calendarSystem =
          ref.watch(primaryCalendarProvider).valueOrNull ??
          AppCalendarSystem.gregorianAd;
      return ref
          .watch(appCalendarServiceProvider)
          .periodForDate(ref.watch(currentDateProvider), calendarSystem);
    });
