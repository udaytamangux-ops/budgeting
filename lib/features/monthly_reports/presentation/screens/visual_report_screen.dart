import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/formatting/currency_formatter.dart';
import 'package:budgeting_app/core/formatting/report_percentage_formatter.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/app_loading_indicator.dart';
import 'package:budgeting_app/features/monthly_reports/domain/entities/monthly_report_data.dart';
import 'package:budgeting_app/features/monthly_reports/presentation/controllers/monthly_report_providers.dart';
import 'package:budgeting_app/features/monthly_reports/presentation/widgets/report_donut_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class VisualReportScreen extends ConsumerWidget {
  const VisualReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<MonthlyReportData> report = ref.watch(
      monthlyReportProvider,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Visual report')),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: report.when(
              loading: () =>
                  const AppLoadingIndicator(label: 'Loading visual report'),
              error: (_, _) => const AppErrorState(
                message: 'The visual report is unavailable.',
              ),
              data: (MonthlyReportData value) => ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.pageEnd,
                ),
                children: <Widget>[
                  Text(
                    value.period.displayLabel,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    'Expenses',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _CategoryVisual(
                    semanticName: 'expenses',
                    categories: value.expenseCategories,
                    chartSlices: value.expenseChart,
                    emptyMessage: 'No recorded expenses for this period.',
                  ),
                  if (value.highestExpenseCategory != null ||
                      value.largestExpenseActivity != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.xl),
                    _ExpenseHighlights(report: value),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  Text('Income', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.md),
                  _CategoryVisual(
                    semanticName: 'income',
                    categories: value.incomeCategories,
                    chartSlices: value.incomeChart,
                    emptyMessage: 'No recorded income for this period.',
                  ),
                  if (value.incomeCategories.length > 1 &&
                      (value.largestIncomeSource != null ||
                          value.largestIncomeActivity != null)) ...<Widget>[
                    const SizedBox(height: AppSpacing.xl),
                    _IncomeHighlights(report: value),
                  ],
                  if (value.transferSummary.count > 0) ...<Widget>[
                    const SizedBox(height: AppSpacing.xxl),
                    _TransferVisualSummary(report: value),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _CategoryVisual extends StatelessWidget {
  const _CategoryVisual({
    required this.semanticName,
    required this.categories,
    required this.chartSlices,
    required this.emptyMessage,
  });

  final String semanticName;
  final List<ReportCategoryTotal> categories;
  final List<ReportChartSlice> chartSlices;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Semantics(
        label: emptyMessage,
        child: Text(
          emptyMessage,
          key: ValueKey<String>('${semanticName}_empty_breakdown'),
        ),
      );
    }
    if (categories.length == 1) {
      final ReportCategoryTotal value = categories.single;
      final CurrencyFormatter currency = CurrencyFormatter();
      final String percentage = ReportPercentageFormatter.formatBasisPoints(
        value.basisPoints,
      );
      return Semantics(
        container: true,
        label:
            '${value.displayLabel}, ${currency.format(value.amount)}, '
            '$percentage of recorded $semanticName.',
        child: ExcludeSemantics(
          child: Column(
            key: ValueKey<String>('${semanticName}_single_category'),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                value.displayLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                currency.format(value.amount),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text('$percentage of recorded $semanticName'),
            ],
          ),
        ),
      );
    }
    final String title = semanticName == 'income' ? 'Income' : 'Expenses';
    return ReportDonutChart(
      key: ValueKey<String>('${semanticName}_donut_chart'),
      title: title,
      slices: chartSlices,
      emptyMessage: emptyMessage,
    );
  }
}

final class _TransferVisualSummary extends StatelessWidget {
  const _TransferVisualSummary({required this.report});

  final MonthlyReportData report;

  @override
  Widget build(BuildContext context) {
    final CurrencyFormatter formatter = CurrencyFormatter();
    final TransferReportSummary value = report.transferSummary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Transfers', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        Text(value.count == 1 ? '1 transfer' : '${value.count} transfers'),
        Text('${formatter.format(value.movementTotal)} moved'),
        Text(
          '${formatter.format(value.countedAsExpenseTotal)} counted as expense',
        ),
        Text('${formatter.format(value.feeTotal)} fees'),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Movement is shown as activity volume and is not added again to expenses.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

final class _ExpenseHighlights extends StatelessWidget {
  const _ExpenseHighlights({required this.report});

  final MonthlyReportData report;

  @override
  Widget build(BuildContext context) {
    final CurrencyFormatter formatter = CurrencyFormatter();
    final List<(String, String, String, String?)> rows =
        <(String, String, String, String?)>[
          if (report.highestExpenseCategory case final value?)
            (
              'Highest expense category',
              value.displayLabel,
              formatter.format(value.amount),
              null,
            ),
          if (report.largestExpenseActivity case final value?)
            (
              'Largest expense activity',
              value.label,
              formatter.format(value.rankedAmount),
              value.detail,
            ),
        ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        for (final row in rows)
          ListTile(
            key: ValueKey<String>(row.$1.replaceAll(' ', '_').toLowerCase()),
            contentPadding: EdgeInsets.zero,
            title: Text(row.$1),
            subtitle: Text(
              row.$4 == null || row.$4 == row.$2
                  ? row.$2
                  : '${row.$2}\n${row.$4}',
            ),
            trailing: Text(row.$3, textAlign: TextAlign.end),
          ),
      ],
    );
  }
}

final class _IncomeHighlights extends StatelessWidget {
  const _IncomeHighlights({required this.report});

  final MonthlyReportData report;

  @override
  Widget build(BuildContext context) {
    final CurrencyFormatter formatter = CurrencyFormatter();
    return Column(
      children: <Widget>[
        if (report.largestIncomeSource case final value?)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Largest income source'),
            subtitle: Text(value.displayLabel),
            trailing: Text(formatter.format(value.amount)),
          ),
        if (report.largestIncomeActivity case final value?)
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Largest income activity'),
            subtitle: Text(value.label),
            trailing: Text(formatter.format(value.rankedAmount)),
          ),
      ],
    );
  }
}
