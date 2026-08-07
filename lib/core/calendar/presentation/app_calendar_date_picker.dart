import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/bs_date.dart';
import 'package:flutter/material.dart';

abstract final class AppCalendarDatePicker {
  static Future<DateTime?> show({
    required BuildContext context,
    required AppCalendarSystem calendarSystem,
    required AppCalendarService calendarService,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    return switch (calendarSystem) {
      AppCalendarSystem.gregorianAd => showDatePicker(
        context: context,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
        helpText: 'Select transaction date — AD',
      ),
      AppCalendarSystem.bikramSambatBs => _showBsPicker(
        context: context,
        calendarService: calendarService,
        initialDate: initialDate,
        firstDate: firstDate,
        lastDate: lastDate,
      ),
    };
  }

  static Future<DateTime?> _showBsPicker({
    required BuildContext context,
    required AppCalendarService calendarService,
    required DateTime initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
  }) {
    final BsDate initialBs = calendarService.toBs(initialDate);
    final BsDate firstBs = calendarService.toBs(firstDate);
    final BsDate lastBs = calendarService.toBs(lastDate);
    int selectedYear = initialBs.year;
    int selectedMonth = initialBs.month;
    int selectedDay = initialBs.day;

    return showModalBottomSheet<DateTime>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            final int daysInMonth = calendarService.daysInBsMonth(
              selectedYear,
              selectedMonth,
            );
            if (selectedDay > daysInMonth) {
              selectedDay = daysInMonth;
            }
            final DateTime candidate = calendarService.toAd(
              BsDate(
                year: selectedYear,
                month: selectedMonth,
                day: selectedDay,
              ),
            );
            final DateTime first = _dateOnlyUtc(firstDate);
            final DateTime last = _dateOnlyUtc(lastDate);
            final bool isInRange =
                !candidate.isBefore(first) && !candidate.isAfter(last);
            final String monthName = calendarService.formatMonthName(
              calendarService.periodFor(
                calendarSystem: AppCalendarSystem.bikramSambatBs,
                year: selectedYear,
                month: selectedMonth,
              ),
            );

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom:
                      MediaQuery.viewInsetsOf(sheetContext).bottom +
                      AppSpacing.md,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: ListView(
                    key: const ValueKey<String>('bs_date_picker'),
                    shrinkWrap: true,
                    children: <Widget>[
                      Text(
                        'Select transaction date — BS',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Bikram Sambat · $selectedDay $monthName '
                        '$selectedYear',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Available dates: '
                        '${calendarService.formatDate(firstDate, AppCalendarSystem.bikramSambatBs)} '
                        'to ${calendarService.formatDate(lastDate, AppCalendarSystem.bikramSambatBs)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<int>(
                        key: const ValueKey<String>('bs_date_year'),
                        isExpanded: true,
                        initialValue: selectedYear,
                        decoration: const InputDecoration(labelText: 'BS year'),
                        items: <DropdownMenuItem<int>>[
                          for (
                            int year = firstBs.year;
                            year <= lastBs.year;
                            year += 1
                          )
                            DropdownMenuItem<int>(
                              value: year,
                              child: Text('$year'),
                            ),
                        ],
                        onChanged: (int? value) {
                          if (value != null) {
                            setSheetState(() => selectedYear = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<int>(
                        key: const ValueKey<String>('bs_date_month'),
                        isExpanded: true,
                        initialValue: selectedMonth,
                        decoration: const InputDecoration(
                          labelText: 'BS month',
                        ),
                        items: <DropdownMenuItem<int>>[
                          for (int month = 1; month <= 12; month += 1)
                            DropdownMenuItem<int>(
                              value: month,
                              child: Text(
                                calendarService.formatMonthName(
                                  calendarService.periodFor(
                                    calendarSystem:
                                        AppCalendarSystem.bikramSambatBs,
                                    year: selectedYear,
                                    month: month,
                                  ),
                                ),
                              ),
                            ),
                        ],
                        onChanged: (int? value) {
                          if (value != null) {
                            setSheetState(() => selectedMonth = value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Semantics(
                        key: const ValueKey<String>('bs_date_day'),
                        label: 'BS day',
                        child: DropdownButtonFormField<int>(
                          key: ValueKey<String>(
                            'bs_date_day_${selectedYear}_$selectedMonth',
                          ),
                          isExpanded: true,
                          initialValue: selectedDay,
                          decoration: const InputDecoration(
                            labelText: 'BS day',
                          ),
                          items: <DropdownMenuItem<int>>[
                            for (int day = 1; day <= daysInMonth; day += 1)
                              DropdownMenuItem<int>(
                                value: day,
                                child: Text('$day'),
                              ),
                          ],
                          onChanged: (int? value) {
                            if (value != null) {
                              setSheetState(() => selectedDay = value);
                            }
                          },
                        ),
                      ),
                      if (!isInRange) ...<Widget>[
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'Choose a date within the available transaction '
                          'date range.',
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xl),
                      FilledButton(
                        key: const ValueKey<String>('bs_date_confirm'),
                        onPressed: isInRange
                            ? () => Navigator.of(sheetContext).pop(candidate)
                            : null,
                        child: const Text('Choose date'),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      TextButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  static DateTime _dateOnlyUtc(DateTime value) {
    final DateTime calendarValue = value.isUtc
        ? value.toUtc()
        : value.toLocal();
    return DateTime.utc(
      calendarValue.year,
      calendarValue.month,
      calendarValue.day,
    );
  }
}
