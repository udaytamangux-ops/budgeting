import 'dart:math' as math;

import 'package:budgeting_app/core/calendar/domain/app_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/bs_date.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_enums.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart';
import 'package:budgeting_app/features/recurring/domain/services/recurring_date_service.dart';

final class RecurrenceRangeException implements Exception {
  const RecurrenceRangeException(this.message);

  final String message;

  @override
  String toString() => message;
}

final class RecurrenceService {
  const RecurrenceService(this._calendarService);

  final AppCalendarService _calendarService;
  static const RecurringDateService _dateService = RecurringDateService();

  void validateRule(RecurringTransactionRule rule) {
    if (rule.anchorDay < 1 || rule.anchorDay > 32) {
      throw const FormatException('The recurring anchor day is invalid.');
    }
    if (rule.anchorMonth < 1 || rule.anchorMonth > 12) {
      throw const FormatException('The recurring anchor month is invalid.');
    }
    if (rule.anchorWeekday < DateTime.monday ||
        rule.anchorWeekday > DateTime.sunday) {
      throw const FormatException('The recurring weekday is invalid.');
    }
    if (!rule.amount.isPositive) {
      throw const FormatException('The recurring amount is invalid.');
    }
    if (rule.recurrenceCalendar == AppCalendarSystem.bikramSambatBs) {
      _calendarService.toBs(rule.firstDueDateAd);
      _calendarService.toBs(rule.nextDueDateAd);
    }
  }

  ({int day, int month, int weekday}) anchorsFor(
    DateTime firstDueDate,
    AppCalendarSystem calendarSystem,
  ) {
    final DateTime canonical = _dateService.canonicalLocalNoon(firstDueDate);
    return switch (calendarSystem) {
      AppCalendarSystem.gregorianAd => (
        day: canonical.day,
        month: canonical.month,
        weekday: canonical.weekday,
      ),
      AppCalendarSystem.bikramSambatBs => () {
        final BsDate bs = _calendarService.toBs(canonical);
        return (day: bs.day, month: bs.month, weekday: canonical.weekday);
      }(),
    };
  }

  DateTime nextOccurrence(RecurringTransactionRule rule, DateTime occurrence) {
    try {
      validateRule(rule);
      return switch (rule.frequency) {
        RecurringFrequency.weekly => _weekly(occurrence),
        RecurringFrequency.monthly => _monthly(rule, occurrence),
        RecurringFrequency.yearly => _yearly(rule, occurrence),
      };
    } on RangeError {
      throw const RecurrenceRangeException(
        'This schedule cannot be extended beyond the supported calendar range.',
      );
    }
  }

  DateTime nextOccurrenceOnOrAfter(
    RecurringTransactionRule rule,
    DateTime target, {
    int maximumSteps = 10000,
  }) {
    DateTime candidate = _dateService.canonicalLocalNoon(rule.firstDueDateAd);
    final DateTime canonicalTarget = _dateService.canonicalLocalNoon(target);
    int steps = 0;
    while (candidate.isBefore(canonicalTarget)) {
      final DateTime next = nextOccurrence(rule, candidate);
      if (!next.isAfter(candidate)) {
        throw const FormatException('The recurring schedule cannot advance.');
      }
      candidate = next;
      steps += 1;
      if (steps > maximumSteps) {
        throw const FormatException('The recurring schedule is invalid.');
      }
    }
    return candidate;
  }

  List<DateTime> occurrencesThrough(
    RecurringTransactionRule rule,
    DateTime through, {
    int maximumOccurrences = 1000,
  }) {
    final DateTime end = _dateService.canonicalLocalNoon(through);
    DateTime candidate = _dateService.canonicalLocalNoon(rule.nextDueDateAd);
    final List<DateTime> occurrences = <DateTime>[];
    while (!candidate.isAfter(end)) {
      occurrences.add(candidate);
      if (occurrences.length >= maximumOccurrences) {
        throw const FormatException(
          'The recurring schedule contains too many missed dates.',
        );
      }
      final DateTime next = nextOccurrence(rule, candidate);
      if (!next.isAfter(candidate)) {
        throw const FormatException('The recurring schedule cannot advance.');
      }
      candidate = next;
    }
    return List<DateTime>.unmodifiable(occurrences);
  }

  DateTime _weekly(DateTime occurrence) {
    final DateTime date = _dateService.canonicalLocalNoon(occurrence);
    return _dateService.canonicalLocalNoon(
      DateTime.utc(date.year, date.month, date.day + 7),
    );
  }

  DateTime _monthly(RecurringTransactionRule rule, DateTime occurrence) {
    return switch (rule.recurrenceCalendar) {
      AppCalendarSystem.gregorianAd => () {
        final DateTime date = _dateService.canonicalLocalNoon(occurrence);
        final int year = date.month == 12 ? date.year + 1 : date.year;
        final int month = date.month == 12 ? 1 : date.month + 1;
        return _adDate(year, month, rule.anchorDay);
      }(),
      AppCalendarSystem.bikramSambatBs => () {
        final BsDate date = _calendarService.toBs(occurrence);
        final int year = date.month == 12 ? date.year + 1 : date.year;
        final int month = date.month == 12 ? 1 : date.month + 1;
        return _bsDate(year, month, rule.anchorDay);
      }(),
    };
  }

  DateTime _yearly(RecurringTransactionRule rule, DateTime occurrence) {
    return switch (rule.recurrenceCalendar) {
      AppCalendarSystem.gregorianAd => () {
        final DateTime date = _dateService.canonicalLocalNoon(occurrence);
        return _adDate(date.year + 1, rule.anchorMonth, rule.anchorDay);
      }(),
      AppCalendarSystem.bikramSambatBs => () {
        final BsDate date = _calendarService.toBs(occurrence);
        return _bsDate(date.year + 1, rule.anchorMonth, rule.anchorDay);
      }(),
    };
  }

  DateTime _adDate(int year, int month, int anchorDay) {
    final int lastDay = DateTime.utc(year, month + 1, 0).day;
    return _dateService.canonicalLocalNoon(
      DateTime.utc(year, month, math.min(anchorDay, lastDay)),
    );
  }

  DateTime _bsDate(int year, int month, int anchorDay) {
    final int lastDay = _calendarService.daysInBsMonth(year, month);
    return _dateService.canonicalLocalNoon(
      _calendarService.toAd(
        BsDate(year: year, month: month, day: math.min(anchorDay, lastDay)),
      ),
    );
  }
}
