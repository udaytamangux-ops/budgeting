import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/core/calendar/presentation/calendar_period_navigator.dart';
import 'package:budgeting_app/core/calendar/presentation/selected_calendar_period_providers.dart';
import 'package:budgeting_app/core/formatting/currency_formatter.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/app_loading_indicator.dart';
import 'package:budgeting_app/features/monthly_reports/domain/entities/monthly_report_data.dart';
import 'package:budgeting_app/features/monthly_reports/presentation/controllers/monthly_report_export_controller.dart';
import 'package:budgeting_app/features/monthly_reports/presentation/controllers/monthly_report_providers.dart';
import 'package:budgeting_app/features/monthly_reports/presentation/widgets/report_sections.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class MonthlyReportScreen extends ConsumerWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<MonthlyReportData> report = ref.watch(
      monthlyReportProvider,
    );
    final CalendarPeriod selected = ref.watch(
      effectiveSelectedCalendarPeriodProvider,
    );
    final CalendarPeriodBounds bounds =
        ref.watch(calendarPeriodBoundsProvider).valueOrNull ??
        CalendarPeriodBounds(
          earliest: selected,
          current: selected,
          latest: selected,
        );
    final AppCalendarService calendarService = ref.watch(
      appCalendarServiceProvider,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Report')),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: report.when(
              loading: () =>
                  const AppLoadingIndicator(label: 'Loading monthly report'),
              error: (_, _) => AppErrorState(
                message: 'The monthly report is unavailable. Try again.',
                onRetry: () => ref.invalidate(monthlyReportProvider),
              ),
              data: (MonthlyReportData value) => ListView(
                key: const ValueKey<String>('monthly_report_content'),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.pageEnd,
                ),
                children: <Widget>[
                  CalendarPeriodNavigator(
                    period: selected,
                    bounds: bounds,
                    calendarService: calendarService,
                    onSelected: ref
                        .read(selectedCalendarPeriodProvider.notifier)
                        .select,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PeriodHeading(
                    report: value,
                    calendarService: calendarService,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ReportMetricGrid(report: value),
                  if (value.isEmpty) ...<Widget>[
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'No recorded activity for ${value.period.displayLabel}.',
                      textAlign: TextAlign.center,
                    ),
                  ] else ...<Widget>[
                    const SizedBox(height: AppSpacing.xxl),
                    ReportCategoryList(
                      title: 'Where your money went',
                      values: value.expenseCategories,
                      maximumItems: 5,
                      emptyMessage: 'No recorded expenses for this period.',
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    ReportCategoryList(
                      title: 'Where your income came from',
                      values: value.incomeCategories,
                      maximumItems: 5,
                      emptyMessage: 'No recorded income for this period.',
                    ),
                    if (value.transferSummary.count > 0) ...<Widget>[
                      const SizedBox(height: AppSpacing.xxl),
                      _TransferStatement(report: value),
                    ],
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  _ReportActions(report: value),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _PeriodHeading extends StatelessWidget {
  const _PeriodHeading({required this.report, required this.calendarService});

  final MonthlyReportData report;
  final AppCalendarService calendarService;

  @override
  Widget build(BuildContext context) {
    final AppCalendarSystem secondary =
        report.period.calendarSystem == AppCalendarSystem.gregorianAd
        ? AppCalendarSystem.bikramSambatBs
        : AppCalendarSystem.gregorianAd;
    final DateTime lastDay = report.period.endAdExclusive.subtract(
      const Duration(days: 1),
    );
    return Semantics(
      header: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            report.isMonthToDate ? 'Month to date' : 'Monthly report',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            report.period.displayLabel,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '${calendarService.formatDate(report.period.startAdInclusive, secondary)} – '
            '${calendarService.formatDate(lastDay, secondary)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

final class _TransferStatement extends StatelessWidget {
  const _TransferStatement({required this.report});

  final MonthlyReportData report;

  @override
  Widget build(BuildContext context) {
    final CurrencyFormatter formatter = CurrencyFormatter();
    final summary = report.transferSummary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Transfer activity',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(summary.count == 1 ? '1 transfer' : '${summary.count} transfers'),
        Text('${formatter.format(summary.movementTotal)} moved'),
        Text(
          '${formatter.format(summary.countedAsExpenseTotal)} counted as expense',
        ),
        Text('${formatter.format(summary.feeTotal)} fees'),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Movement total shows transfer activity. It is not added again to spending.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

final class _ReportActions extends ConsumerWidget {
  const _ReportActions({required this.report});

  final MonthlyReportData report;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final MonthlyReportExportState exportState = ref.watch(
      monthlyReportExportControllerProvider,
    );
    ref.listen(monthlyReportExportControllerProvider, (
      _,
      MonthlyReportExportState next,
    ) {
      if (next.feedback != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.feedback!)));
        ref
            .read(monthlyReportExportControllerProvider.notifier)
            .clearFeedback();
      }
    });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.monthlyVisualReport),
          icon: const Icon(Icons.donut_large_outlined),
          label: const Text('View visual breakdown'),
        ),
        OutlinedButton.icon(
          onPressed: () => context.push(AppRoutes.monthlyComparison),
          icon: const Icon(Icons.compare_arrows_outlined),
          label: Text(
            report.isMonthToDate
                ? 'Compare with same point last month'
                : 'Compare with previous month',
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => context.go(AppRoutes.transactions),
          icon: const Icon(Icons.receipt_long_outlined),
          label: const Text('View all activity'),
        ),
        const SizedBox(height: AppSpacing.sm),
        FilledButton.icon(
          onPressed: exportState.isBusy
              ? null
              : () => showMonthlyReportExportSheet(context: context, ref: ref),
          icon: const Icon(Icons.picture_as_pdf_outlined),
          label: const Text('Export PDF'),
        ),
        OutlinedButton.icon(
          onPressed: exportState.isBusy
              ? null
              : () => ref
                    .read(monthlyReportExportControllerProvider.notifier)
                    .exportCsv(),
          icon: const Icon(Icons.table_view_outlined),
          label: const Text('Export CSV'),
        ),
      ],
    );
  }
}
