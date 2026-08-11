import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/core/calendar/presentation/selected_calendar_period_providers.dart';
import 'package:flutter/material.dart';

final class CalendarPeriodNavigator extends StatelessWidget {
  const CalendarPeriodNavigator({
    required this.period,
    required this.bounds,
    required this.calendarService,
    required this.onSelected,
    super.key,
  });

  final CalendarPeriod period;
  final CalendarPeriodBounds bounds;
  final AppCalendarService calendarService;
  final ValueChanged<CalendarPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    final bool isCurrent = period == bounds.current;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          key: const ValueKey<String>('calendar_period_navigator'),
          decoration: BoxDecoration(
            color: context.appColors.surfacePrimary,
            border: Border.all(color: context.appColors.borderSubtle),
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Row(
            children: <Widget>[
              IconButton(
                key: const ValueKey<String>('previous_month_button'),
                tooltip: 'Previous month',
                onPressed: bounds.canGoPrevious(period)
                    ? () => onSelected(calendarService.previousPeriod(period))
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Semantics(
                  button: true,
                  label:
                      'Select month, ${calendarService.formatMonthYear(period)}, '
                      '${period.calendarSystem.semanticName}',
                  excludeSemantics: true,
                  child: TextButton(
                    key: const ValueKey<String>('select_month_button'),
                    onPressed: () async {
                      final CalendarPeriod? selected =
                          await showCalendarPeriodPicker(
                            context: context,
                            selectedPeriod: period,
                            bounds: bounds,
                            calendarService: calendarService,
                          );
                      if (selected != null) onSelected(selected);
                    },
                    child: Text(
                      calendarService.formatMonthYear(period),
                      key: const ValueKey<String>('selected_month_label'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              IconButton(
                key: const ValueKey<String>('next_month_button'),
                tooltip: 'Next month',
                onPressed: bounds.canGoNext(period)
                    ? () => onSelected(calendarService.nextPeriod(period))
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        if (!isCurrent) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          TextButton.icon(
            key: const ValueKey<String>('return_current_month'),
            onPressed: () => onSelected(bounds.current),
            icon: const Icon(Icons.today_outlined, size: 18),
            label: const Text('Current month'),
          ),
        ],
      ],
    );
  }
}

Future<CalendarPeriod?> showCalendarPeriodPicker({
  required BuildContext context,
  required CalendarPeriod selectedPeriod,
  required CalendarPeriodBounds bounds,
  required AppCalendarService calendarService,
}) {
  int visibleYear = selectedPeriod.year;
  return showDialog<CalendarPeriod>(
    context: context,
    builder: (BuildContext dialogContext) => StatefulBuilder(
      builder: (BuildContext context, StateSetter setDialogState) {
        final int earliestYear = bounds.earliest.year;
        final int latestYear = bounds.latest.year;
        final double contentWidth = (MediaQuery.sizeOf(context).width - 128)
            .clamp(192.0, 440.0)
            .toDouble();
        final double itemWidth = (contentWidth - AppSpacing.sm * 2) / 3;
        return AlertDialog(
          key: const ValueKey<String>('calendar_period_picker'),
          title: const Text('Select month'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: contentWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      IconButton(
                        tooltip: 'Previous year',
                        onPressed: visibleYear > earliestYear
                            ? () => setDialogState(() => visibleYear -= 1)
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Text(
                          '$visibleYear',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Next year',
                        onPressed: visibleYear < latestYear
                            ? () => setDialogState(() => visibleYear += 1)
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: <Widget>[
                      for (int month = 1; month <= 12; month += 1)
                        _MonthOption(
                          width: itemWidth,
                          period: calendarService.periodFor(
                            calendarSystem: selectedPeriod.calendarSystem,
                            year: visibleYear,
                            month: month,
                          ),
                          selectedPeriod: selectedPeriod,
                          bounds: bounds,
                          calendarService: calendarService,
                          onSelected: (CalendarPeriod value) =>
                              Navigator.of(dialogContext).pop(value),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    ),
  );
}

final class _MonthOption extends StatelessWidget {
  const _MonthOption({
    required this.width,
    required this.period,
    required this.selectedPeriod,
    required this.bounds,
    required this.calendarService,
    required this.onSelected,
  });

  final double width;
  final CalendarPeriod period;
  final CalendarPeriod selectedPeriod;
  final CalendarPeriodBounds bounds;
  final AppCalendarService calendarService;
  final ValueChanged<CalendarPeriod> onSelected;

  @override
  Widget build(BuildContext context) {
    final bool selected = period == selectedPeriod;
    final bool enabled = bounds.contains(period);
    final String label = calendarService.formatMonthName(period);
    return SizedBox(
      width: width,
      child: Semantics(
        button: true,
        enabled: enabled,
        selected: selected,
        label: '$label ${period.year}, ${period.calendarSystem.semanticName}',
        excludeSemantics: true,
        child: OutlinedButton(
          key: ValueKey<String>('month_option_${period.year}_${period.month}'),
          onPressed: enabled ? () => onSelected(period) : null,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(48, 56),
            backgroundColor: selected ? context.appColors.primarySubtle : null,
            side: selected
                ? BorderSide(color: context.appColors.primaryAction, width: 2)
                : null,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxs,
              vertical: AppSpacing.xs,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (selected) const Icon(Icons.check, size: 16),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
