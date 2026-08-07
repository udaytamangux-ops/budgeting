import 'package:budgeting_app/core/calendar/data/bikram_sambat_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/bs_date.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late BikramSambatCalendarService service;

  setUp(() {
    service = BikramSambatCalendarService();
  });

  test('converts a verified AD and BS fixture in both directions', () {
    final BsDate bs = service.toBs(DateTime.utc(2001, 12, 13));

    expect(bs, const BsDate(year: 2058, month: 8, day: 28));
    expect(service.toAd(bs), DateTime.utc(2001, 12, 13));
  });

  test('AD to BS to AD round trips date-only values', () {
    for (final DateTime date in <DateTime>[
      DateTime.utc(2026, 1, 1),
      DateTime.utc(2026, 8, 7),
      DateTime.utc(2028, 2, 29),
    ]) {
      expect(service.toAd(service.toBs(date)), date);
    }
  });

  test('BS to AD to BS round trips month and year boundaries', () {
    for (final BsDate date in <BsDate>[
      const BsDate(year: 2082, month: 12, day: 30),
      const BsDate(year: 2083, month: 1, day: 1),
      const BsDate(year: 2083, month: 4, day: 1),
    ]) {
      expect(service.toBs(service.toAd(date)), date);
    }
  });

  test('Gregorian periods use end-exclusive calendar month boundaries', () {
    final CalendarPeriod period = service.periodFor(
      calendarSystem: AppCalendarSystem.gregorianAd,
      year: 2026,
      month: 8,
    );

    expect(period.startAdInclusive, DateTime.utc(2026, 8));
    expect(period.endAdExclusive, DateTime.utc(2026, 9));
    expect(period.contains(DateTime.utc(2026, 8, 31, 23)), isTrue);
    expect(period.contains(DateTime.utc(2026, 9)), isFalse);
    expect(period.displayLabel, 'August 2026');
  });

  test('BS Shrawan uses real converted boundaries', () {
    final CalendarPeriod period = service.periodFor(
      calendarSystem: AppCalendarSystem.bikramSambatBs,
      year: 2083,
      month: 4,
    );

    expect(period.startAdInclusive, DateTime.utc(2026, 7, 17));
    expect(period.endAdExclusive, DateTime.utc(2026, 8, 17));
    expect(period.contains(DateTime.utc(2026, 7, 17, 12)), isTrue);
    expect(period.contains(DateTime.utc(2026, 8, 17)), isFalse);
    expect(period.displayLabel, 'Shrawan 2083');
  });

  test('previous and next BS periods cross year boundaries correctly', () {
    final CalendarPeriod chaitra = service.periodFor(
      calendarSystem: AppCalendarSystem.bikramSambatBs,
      year: 2082,
      month: 12,
    );
    final CalendarPeriod baishakh = service.nextPeriod(chaitra);

    expect(baishakh.year, 2083);
    expect(baishakh.month, 1);
    expect(service.previousPeriod(baishakh), chaitra);
    expect(chaitra.endAdExclusive, baishakh.startAdInclusive);
  });

  test('supported BS range rejects periods outside package bounds', () {
    expect(
      () => service.periodFor(
        calendarSystem: AppCalendarSystem.bikramSambatBs,
        year: 1968,
        month: 1,
      ),
      throwsRangeError,
    );
    expect(
      service.daysInBsMonth(
        BikramSambatCalendarService.minimumSupportedBsYear,
        1,
      ),
      inInclusiveRange(29, 32),
    );
  });

  test('out-of-range display falls back without crashing', () {
    expect(
      service.formatDate(
        DateTime.utc(1900, 1, 1),
        AppCalendarSystem.bikramSambatBs,
      ),
      'BS date unavailable · 1 January 1900',
    );
    expect(
      () => service.toAd(const BsDate(year: 2083, month: 10, day: 32)),
      throwsRangeError,
    );
  });

  test('formats primary labels consistently with English numerals', () {
    final DateTime date = DateTime.utc(2026, 8, 7);

    expect(
      service.formatDate(date, AppCalendarSystem.gregorianAd),
      '7 August 2026',
    );
    expect(
      service.formatDate(date, AppCalendarSystem.bikramSambatBs),
      matches(RegExp(r'^\d+ Shrawan 2083$')),
    );
    expect(
      service.formatDateSemantics(date, AppCalendarSystem.bikramSambatBs),
      contains('Bikram Sambat'),
    );
  });

  test('formats timestamps in the selected calendar without a second date', () {
    final DateTime timestamp = DateTime(2026, 8, 4, 14, 30);

    expect(
      service.formatDateAndTime(timestamp, AppCalendarSystem.gregorianAd),
      '4 August 2026, 2:30 PM',
    );
    expect(
      service.formatDateAndTime(timestamp, AppCalendarSystem.bikramSambatBs),
      '19 Shrawan 2083, 2:30 PM',
    );
  });
}
