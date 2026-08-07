import 'package:bikram_sambat/bikram_sambat.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/bs_date.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:intl/intl.dart';

final class BikramSambatCalendarService implements AppCalendarService {
  BikramSambatCalendarService({String locale = 'en_US'})
    : _adLongDate = DateFormat('d MMMM y', locale),
      _adDateAndTime = DateFormat('d MMMM y, h:mm a', locale),
      _adShortDate = DateFormat('EEE, d MMM', locale),
      _adMonthYear = DateFormat('MMMM y', locale),
      _adMonthName = DateFormat('MMMM', locale),
      _weekday = DateFormat('EEE', locale),
      _time = DateFormat('h:mm a', locale);

  static const int minimumSupportedBsYear = 1969;
  static const int maximumSupportedBsYear = 2200;
  static const Duration _nepalOffset = Duration(hours: 5, minutes: 45);
  static const List<String> _bsMonthNames = <String>[
    'Baishakh',
    'Jestha',
    'Ashadh',
    'Shrawan',
    'Bhadra',
    'Ashwin',
    'Kartik',
    'Marga',
    'Poush',
    'Magh',
    'Falgun',
    'Chaitra',
  ];

  final DateFormat _adLongDate;
  final DateFormat _adDateAndTime;
  final DateFormat _adShortDate;
  final DateFormat _adMonthYear;
  final DateFormat _adMonthName;
  final DateFormat _weekday;
  final DateFormat _time;

  @override
  BsDate toBs(DateTime adDate) {
    final DateTime canonical = _canonicalAdDate(adDate);
    final DateTime minimum = _toAdUnchecked(
      const BsDate(year: minimumSupportedBsYear, month: 1, day: 1),
    );
    final DateTime maximum = _toAdUnchecked(
      const BsDate(year: maximumSupportedBsYear, month: 12, day: 31),
    );
    if (canonical.isBefore(minimum) ||
        !canonical.isBefore(maximum.add(const Duration(days: 1)))) {
      throw RangeError(
        'adDate $canonical is outside the supported Bikram Sambat range '
        '($minimum to $maximum).',
      );
    }
    final BikramSambat converted = canonical.toBikramSambat();
    return BsDate(
      year: converted.year,
      month: converted.month,
      day: converted.day,
    );
  }

  @override
  DateTime toAd(BsDate bsDate) {
    final int maximumDay = daysInBsMonth(bsDate.year, bsDate.month);
    if (bsDate.day > maximumDay) {
      throw RangeError.range(bsDate.day, 1, maximumDay, 'day');
    }
    return _toAdUnchecked(bsDate);
  }

  DateTime _toAdUnchecked(BsDate bsDate) {
    final BikramSambat converted = BikramSambat(
      bsDate.year,
      bsDate.month,
      bsDate.day,
    );
    final DateTime nepalCalendarInstant = converted.toUtc().add(_nepalOffset);
    return DateTime.utc(
      nepalCalendarInstant.year,
      nepalCalendarInstant.month,
      nepalCalendarInstant.day,
    );
  }

  @override
  CalendarPeriod periodForDate(
    DateTime adDate,
    AppCalendarSystem calendarSystem,
  ) {
    final DateTime canonical = _canonicalAdDate(adDate);
    return switch (calendarSystem) {
      AppCalendarSystem.gregorianAd => periodFor(
        calendarSystem: calendarSystem,
        year: canonical.year,
        month: canonical.month,
      ),
      AppCalendarSystem.bikramSambatBs => () {
        final BsDate bs = toBs(canonical);
        return periodFor(
          calendarSystem: calendarSystem,
          year: bs.year,
          month: bs.month,
        );
      }(),
    };
  }

  @override
  CalendarPeriod periodFor({
    required AppCalendarSystem calendarSystem,
    required int year,
    required int month,
  }) {
    if (month < 1 || month > 12) {
      throw RangeError.range(month, 1, 12, 'month');
    }
    return switch (calendarSystem) {
      AppCalendarSystem.gregorianAd => _adPeriod(year, month),
      AppCalendarSystem.bikramSambatBs => _bsPeriod(year, month),
    };
  }

  @override
  CalendarPeriod currentPeriod(
    AppCalendarSystem calendarSystem, {
    DateTime? now,
  }) {
    return periodForDate(now ?? DateTime.now(), calendarSystem);
  }

  @override
  CalendarPeriod previousPeriod(CalendarPeriod period) {
    final int previousYear = period.month == 1 ? period.year - 1 : period.year;
    final int previousMonth = period.month == 1 ? 12 : period.month - 1;
    return periodFor(
      calendarSystem: period.calendarSystem,
      year: previousYear,
      month: previousMonth,
    );
  }

  @override
  CalendarPeriod nextPeriod(CalendarPeriod period) {
    final int nextYear = period.month == 12 ? period.year + 1 : period.year;
    final int nextMonth = period.month == 12 ? 1 : period.month + 1;
    return periodFor(
      calendarSystem: period.calendarSystem,
      year: nextYear,
      month: nextMonth,
    );
  }

  @override
  bool isDateInPeriod(DateTime date, CalendarPeriod period) {
    return period.contains(date);
  }

  @override
  String formatDate(DateTime adDate, AppCalendarSystem calendarSystem) {
    return switch (calendarSystem) {
      AppCalendarSystem.gregorianAd => _adLongDate.format(
        _displayAdDate(adDate),
      ),
      AppCalendarSystem.bikramSambatBs => () {
        try {
          final BsDate bs = toBs(adDate);
          return '${bs.day} ${_bsMonthName(bs.month)} ${bs.year}';
        } on RangeError {
          return 'BS date unavailable · '
              '${_adLongDate.format(_displayAdDate(adDate))}';
        }
      }(),
    };
  }

  @override
  String formatDateAndTime(
    DateTime adTimestamp,
    AppCalendarSystem calendarSystem,
  ) {
    final DateTime localTimestamp = adTimestamp.toLocal();
    return switch (calendarSystem) {
      AppCalendarSystem.gregorianAd => _adDateAndTime.format(localTimestamp),
      AppCalendarSystem.bikramSambatBs =>
        '${formatDate(localTimestamp, calendarSystem)}, '
            '${_time.format(localTimestamp)}',
    };
  }

  @override
  String formatShortDate(DateTime adDate, AppCalendarSystem calendarSystem) {
    return switch (calendarSystem) {
      AppCalendarSystem.gregorianAd => _adShortDate.format(
        _displayAdDate(adDate),
      ),
      AppCalendarSystem.bikramSambatBs => () {
        try {
          final BsDate bs = toBs(adDate);
          return '${_weekday.format(_displayAdDate(adDate))}, '
              '${bs.day} ${_bsMonthName(bs.month)}';
        } on RangeError {
          return 'BS date unavailable · '
              '${_adShortDate.format(_displayAdDate(adDate))}';
        }
      }(),
    };
  }

  @override
  String formatMonthYear(CalendarPeriod period) => period.displayLabel;

  @override
  String formatMonthName(CalendarPeriod period) {
    return switch (period.calendarSystem) {
      AppCalendarSystem.gregorianAd => _adMonthName.format(
        _displayAdDate(period.startAdInclusive),
      ),
      AppCalendarSystem.bikramSambatBs => _bsMonthName(period.month),
    };
  }

  @override
  String formatDayGroup(
    DateTime adDate,
    AppCalendarSystem calendarSystem, {
    DateTime? relativeTo,
  }) {
    final DateTime day = _canonicalAdDate(adDate);
    final DateTime today = _canonicalAdDate(relativeTo ?? DateTime.now());
    final int difference = today.difference(day).inDays;
    return switch (difference) {
      0 => 'Today',
      1 => 'Yesterday',
      _ => formatDate(adDate, calendarSystem),
    };
  }

  @override
  String formatDateSemantics(
    DateTime adDate,
    AppCalendarSystem calendarSystem,
  ) {
    return '${formatDate(adDate, calendarSystem)}, '
        '${calendarSystem.semanticName}';
  }

  @override
  int daysInBsMonth(int year, int month) {
    return BikramSambat(year, month).daysInMonth;
  }

  CalendarPeriod _adPeriod(int year, int month) {
    final DateTime start = DateTime.utc(year, month);
    final DateTime end = DateTime.utc(year, month + 1);
    return CalendarPeriod(
      calendarSystem: AppCalendarSystem.gregorianAd,
      year: year,
      month: month,
      startAdInclusive: start,
      endAdExclusive: end,
      displayLabel: _adMonthYear.format(_displayAdDate(start)),
    );
  }

  CalendarPeriod _bsPeriod(int year, int month) {
    if (year < minimumSupportedBsYear || year > maximumSupportedBsYear) {
      throw RangeError.range(
        year,
        minimumSupportedBsYear,
        maximumSupportedBsYear,
        'year',
      );
    }
    final int nextYear = month == 12 ? year + 1 : year;
    final int nextMonth = month == 12 ? 1 : month + 1;
    if (nextYear > maximumSupportedBsYear) {
      throw RangeError('The next BS month is outside the supported range.');
    }
    return CalendarPeriod(
      calendarSystem: AppCalendarSystem.bikramSambatBs,
      year: year,
      month: month,
      startAdInclusive: toAd(BsDate(year: year, month: month, day: 1)),
      endAdExclusive: toAd(BsDate(year: nextYear, month: nextMonth, day: 1)),
      displayLabel: '${_bsMonthName(month)} $year',
    );
  }

  DateTime _canonicalAdDate(DateTime value) {
    final DateTime calendarValue = value.isUtc
        ? value.toUtc()
        : value.toLocal();
    return DateTime.utc(
      calendarValue.year,
      calendarValue.month,
      calendarValue.day,
      12,
    );
  }

  DateTime _displayAdDate(DateTime value) {
    final DateTime canonical = _canonicalAdDate(value);
    return DateTime(canonical.year, canonical.month, canonical.day);
  }

  String _bsMonthName(int month) => _bsMonthNames[month - 1];
}
