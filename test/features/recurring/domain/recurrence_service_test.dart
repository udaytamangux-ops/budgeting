import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/bs_date.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_enums.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart';
import 'package:budgeting_app/features/recurring/domain/services/recurrence_service.dart';
import 'package:budgeting_app/features/recurring/domain/services/recurring_date_service.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final BikramSambatCalendarService calendar = BikramSambatCalendarService();
  final RecurrenceService service = RecurrenceService(calendar);
  const RecurringDateService dateService = RecurringDateService();

  DateTime canonical(DateTime value) => dateService.canonicalLocalNoon(value);

  RecurringTransactionRule rule({
    required RecurringFrequency frequency,
    required AppCalendarSystem calendarSystem,
    required DateTime first,
    int? anchorDay,
    int? anchorMonth,
  }) {
    final anchors = service.anchorsFor(first, calendarSystem);
    final DateTime date = canonical(first);
    return RecurringTransactionRule(
      id: 'rule',
      type: TransactionType.expense,
      amount: const Money(minorUnits: 10000),
      category: TransactionCategory.utilities,
      paymentMethod: PaymentMethod.cash,
      frequency: frequency,
      recurrenceCalendar: calendarSystem,
      anchorDay: anchorDay ?? anchors.day,
      anchorMonth: anchorMonth ?? anchors.month,
      anchorWeekday: anchors.weekday,
      firstDueDateAd: date,
      nextDueDateAd: date,
      status: RecurringRuleStatus.active,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
  }

  DateTime localDate(DateTime value) {
    final DateTime local = value.toLocal();
    return DateTime(local.year, local.month, local.day);
  }

  test('stable recurrence identifiers decode without UI labels', () {
    for (final RecurringFrequency value in RecurringFrequency.values) {
      expect(
        RecurringFrequencyMetadata.tryParse(value.stableIdentifier),
        value,
      );
    }
    for (final RecurringRuleStatus value in RecurringRuleStatus.values) {
      expect(
        RecurringRuleStatusMetadata.tryParse(value.stableIdentifier),
        value,
      );
    }
    for (final RecurringOccurrenceStatus value
        in RecurringOccurrenceStatus.values) {
      expect(
        RecurringOccurrenceStatusMetadata.tryParse(value.stableIdentifier),
        value,
      );
    }
    expect(RecurringFrequencyMetadata.tryParse('Every month'), isNull);
  });

  test('weekly recurrence advances seven days across year rollover', () {
    final RecurringTransactionRule weekly = rule(
      frequency: RecurringFrequency.weekly,
      calendarSystem: AppCalendarSystem.gregorianAd,
      first: DateTime(2026, 12, 27),
    );
    final DateTime next = service.nextOccurrence(weekly, weekly.firstDueDateAd);
    expect(localDate(next), DateTime(2027, 1, 3));
    expect(next.toLocal().weekday, weekly.anchorWeekday);
  });

  test('weekly sequence is unchanged by display-calendar preference', () {
    final DateTime first = DateTime(2026, 8, 9);
    final RecurringTransactionRule adRule = rule(
      frequency: RecurringFrequency.weekly,
      calendarSystem: AppCalendarSystem.gregorianAd,
      first: first,
    );
    final RecurringTransactionRule bsRule = rule(
      frequency: RecurringFrequency.weekly,
      calendarSystem: AppCalendarSystem.bikramSambatBs,
      first: first,
    );
    expect(
      service.nextOccurrence(adRule, adRule.firstDueDateAd),
      service.nextOccurrence(bsRule, bsRule.firstDueDateAd),
    );
  });

  test('monthly AD day 31 falls back and restores its anchor', () {
    final RecurringTransactionRule monthly = rule(
      frequency: RecurringFrequency.monthly,
      calendarSystem: AppCalendarSystem.gregorianAd,
      first: DateTime(2027, 1, 31),
    );
    final DateTime february = service.nextOccurrence(
      monthly,
      monthly.firstDueDateAd,
    );
    final DateTime march = service.nextOccurrence(monthly, february);
    final DateTime april = service.nextOccurrence(monthly, march);
    expect(localDate(february), DateTime(2027, 2, 28));
    expect(localDate(march), DateTime(2027, 3, 31));
    expect(localDate(april), DateTime(2027, 4, 30));
    expect(monthly.anchorDay, 31);
  });

  test('monthly AD respects leap February and year rollover', () {
    final RecurringTransactionRule monthly = rule(
      frequency: RecurringFrequency.monthly,
      calendarSystem: AppCalendarSystem.gregorianAd,
      first: DateTime(2027, 12, 31),
      anchorDay: 31,
    );
    final DateTime january = service.nextOccurrence(
      monthly,
      monthly.firstDueDateAd,
    );
    final DateTime february = service.nextOccurrence(monthly, january);
    expect(localDate(january), DateTime(2028, 1, 31));
    expect(localDate(february), DateTime(2028, 2, 29));
  });

  test('monthly BS uses real month lengths and restores anchor', () {
    ({int year, int month})? candidate;
    for (int year = 2080; year <= 2090 && candidate == null; year += 1) {
      for (int month = 1; month <= 10; month += 1) {
        if (calendar.daysInBsMonth(year, month) == 32 &&
            calendar.daysInBsMonth(year, month + 1) < 32 &&
            calendar.daysInBsMonth(year, month + 2) == 32) {
          candidate = (year: year, month: month);
          break;
        }
      }
    }
    expect(candidate, isNotNull);
    final BsDate firstBs = BsDate(
      year: candidate!.year,
      month: candidate.month,
      day: 32,
    );
    final RecurringTransactionRule monthly = rule(
      frequency: RecurringFrequency.monthly,
      calendarSystem: AppCalendarSystem.bikramSambatBs,
      first: calendar.toAd(firstBs),
    );
    final DateTime shortMonth = service.nextOccurrence(
      monthly,
      monthly.firstDueDateAd,
    );
    final DateTime restored = service.nextOccurrence(monthly, shortMonth);
    final BsDate shortBs = calendar.toBs(shortMonth);
    final BsDate restoredBs = calendar.toBs(restored);
    expect(shortBs.day, calendar.daysInBsMonth(shortBs.year, shortBs.month));
    expect(shortBs.day, lessThan(32));
    expect(restoredBs.day, 32);
    expect(monthly.anchorDay, 32);
  });

  test('monthly BS crosses its year boundary', () {
    final DateTime first = calendar.toAd(
      const BsDate(year: 2082, month: 12, day: 30),
    );
    final RecurringTransactionRule monthly = rule(
      frequency: RecurringFrequency.monthly,
      calendarSystem: AppCalendarSystem.bikramSambatBs,
      first: first,
    );
    expect(
      calendar.toBs(service.nextOccurrence(monthly, monthly.firstDueDateAd)),
      const BsDate(year: 2083, month: 1, day: 30),
    );
  });

  test('yearly AD restores 29 February after a non-leap fallback', () {
    final RecurringTransactionRule yearly = rule(
      frequency: RecurringFrequency.yearly,
      calendarSystem: AppCalendarSystem.gregorianAd,
      first: DateTime(2028, 2, 29),
    );
    DateTime occurrence = service.nextOccurrence(yearly, yearly.firstDueDateAd);
    expect(localDate(occurrence), DateTime(2029, 2, 28));
    occurrence = service.nextOccurrence(yearly, occurrence);
    occurrence = service.nextOccurrence(yearly, occurrence);
    occurrence = service.nextOccurrence(yearly, occurrence);
    expect(localDate(occurrence), DateTime(2032, 2, 29));
  });

  test('yearly BS uses each year valid month length and rolls year', () {
    ({int year, int month})? candidate;
    for (int year = 2080; year <= 2090 && candidate == null; year += 1) {
      for (int month = 1; month <= 12; month += 1) {
        final int firstLength = calendar.daysInBsMonth(year, month);
        final int nextLength = calendar.daysInBsMonth(year + 1, month);
        if (firstLength > nextLength) {
          candidate = (year: year, month: month);
          break;
        }
      }
    }
    expect(candidate, isNotNull);
    final int anchor = calendar.daysInBsMonth(candidate!.year, candidate.month);
    final RecurringTransactionRule yearly = rule(
      frequency: RecurringFrequency.yearly,
      calendarSystem: AppCalendarSystem.bikramSambatBs,
      first: calendar.toAd(
        BsDate(year: candidate.year, month: candidate.month, day: anchor),
      ),
    );
    final BsDate next = calendar.toBs(
      service.nextOccurrence(yearly, yearly.firstDueDateAd),
    );
    expect(next.year, candidate.year + 1);
    expect(next.month, candidate.month);
    expect(
      next.day,
      calendar.daysInBsMonth(candidate.year + 1, candidate.month),
    );
    expect(yearly.anchorDay, anchor);
  });

  test('next on or after is inclusive and preserves the rule calendar', () {
    final RecurringTransactionRule monthly = rule(
      frequency: RecurringFrequency.monthly,
      calendarSystem: AppCalendarSystem.bikramSambatBs,
      first: calendar.toAd(const BsDate(year: 2083, month: 1, day: 15)),
    );
    expect(
      service.nextOccurrenceOnOrAfter(monthly, monthly.firstDueDateAd),
      monthly.firstDueDateAd,
    );
    expect(monthly.recurrenceCalendar, AppCalendarSystem.bikramSambatBs);
  });

  test('supported-range boundary fails with a controlled message', () {
    final DateTime finalBsDate = calendar.toAd(
      const BsDate(
        year: BikramSambatCalendarService.maximumSupportedBsYear,
        month: 12,
        day: 31,
      ),
    );
    final RecurringTransactionRule monthly = rule(
      frequency: RecurringFrequency.monthly,
      calendarSystem: AppCalendarSystem.bikramSambatBs,
      first: finalBsDate,
    );
    expect(
      () => service.nextOccurrence(monthly, monthly.firstDueDateAd),
      throwsA(
        isA<RecurrenceRangeException>().having(
          (error) => error.message,
          'message',
          contains('supported calendar range'),
        ),
      ),
    );
  });

  test('corrupted anchors are rejected before recurrence loops', () {
    final RecurringTransactionRule invalid = rule(
      frequency: RecurringFrequency.monthly,
      calendarSystem: AppCalendarSystem.gregorianAd,
      first: DateTime(2026, 8, 1),
      anchorDay: 0,
    );
    expect(() => service.validateRule(invalid), throwsFormatException);
  });
}
