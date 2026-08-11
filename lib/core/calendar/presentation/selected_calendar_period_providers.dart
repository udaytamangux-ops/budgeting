import 'package:budgeting_app/core/calendar/domain/app_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/financial_activity/presentation/controllers/financial_activity_providers.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class CalendarPeriodBounds {
  const CalendarPeriodBounds({
    required this.earliest,
    required this.current,
    required this.latest,
  });

  final CalendarPeriod earliest;
  final CalendarPeriod current;
  final CalendarPeriod latest;

  bool contains(CalendarPeriod period) =>
      period.calendarSystem == current.calendarSystem &&
      !period.startAdInclusive.isBefore(earliest.startAdInclusive) &&
      !period.startAdInclusive.isAfter(latest.startAdInclusive);

  bool canGoPrevious(CalendarPeriod period) =>
      period.startAdInclusive.isAfter(earliest.startAdInclusive);

  bool canGoNext(CalendarPeriod period) =>
      period.startAdInclusive.isBefore(latest.startAdInclusive);
}

final NotifierProvider<SelectedCalendarPeriodController, CalendarPeriod>
selectedCalendarPeriodProvider =
    NotifierProvider<SelectedCalendarPeriodController, CalendarPeriod>(
      SelectedCalendarPeriodController.new,
    );

final class SelectedCalendarPeriodController extends Notifier<CalendarPeriod> {
  @override
  CalendarPeriod build() {
    final AppCalendarSystem calendar =
        ref.watch(primaryCalendarProvider).valueOrNull ??
        AppCalendarSystem.gregorianAd;
    return ref
        .watch(appCalendarServiceProvider)
        .currentPeriod(calendar, now: ref.watch(currentDateProvider));
  }

  void select(CalendarPeriod period) {
    if (period.calendarSystem != state.calendarSystem) return;
    state = period;
  }

  void showCurrent() {
    final AppCalendarService service = ref.read(appCalendarServiceProvider);
    state = service.currentPeriod(
      state.calendarSystem,
      now: ref.read(currentDateProvider),
    );
  }
}

final Provider<AsyncValue<CalendarPeriodBounds>> calendarPeriodBoundsProvider =
    Provider<AsyncValue<CalendarPeriodBounds>>((Ref ref) {
      final AppCalendarService service = ref.watch(appCalendarServiceProvider);
      final AppCalendarSystem calendar =
          ref.watch(primaryCalendarProvider).valueOrNull ??
          AppCalendarSystem.gregorianAd;
      final CalendarPeriod current = service.currentPeriod(
        calendar,
        now: ref.watch(currentDateProvider),
      );
      return ref.watch(financialActivityListProvider).whenData((activities) {
        if (activities.isEmpty) {
          return CalendarPeriodBounds(
            earliest: current,
            current: current,
            latest: current,
          );
        }
        DateTime earliestDate = activities.first.occurredAt;
        DateTime latestDate = activities.first.occurredAt;
        for (final FinancialActivity activity in activities.skip(1)) {
          if (activity.occurredAt.isBefore(earliestDate)) {
            earliestDate = activity.occurredAt;
          }
          if (activity.occurredAt.isAfter(latestDate)) {
            latestDate = activity.occurredAt;
          }
        }
        final CalendarPeriod earliestTransaction = service.periodForDate(
          earliestDate,
          calendar,
        );
        final CalendarPeriod latestTransaction = service.periodForDate(
          latestDate,
          calendar,
        );
        return CalendarPeriodBounds(
          earliest:
              earliestTransaction.startAdInclusive.isBefore(
                current.startAdInclusive,
              )
              ? earliestTransaction
              : current,
          current: current,
          latest:
              latestTransaction.startAdInclusive.isAfter(
                current.startAdInclusive,
              )
              ? latestTransaction
              : current,
        );
      });
    });

final Provider<CalendarPeriod> effectiveSelectedCalendarPeriodProvider =
    Provider<CalendarPeriod>((Ref ref) {
      final CalendarPeriod selected = ref.watch(selectedCalendarPeriodProvider);
      final CalendarPeriodBounds? bounds = ref
          .watch(calendarPeriodBoundsProvider)
          .valueOrNull;
      if (bounds == null || bounds.contains(selected)) return selected;
      if (selected.startAdInclusive.isBefore(
        bounds.earliest.startAdInclusive,
      )) {
        return bounds.earliest;
      }
      return bounds.latest;
    });
