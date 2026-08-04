import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/formatting/currency_formatter.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/app_loading_indicator.dart';
import 'package:budgeting_app/core/widgets/empty_state.dart';
import 'package:budgeting_app/features/summary/domain/entities/monthly_transaction_summary.dart';
import 'package:budgeting_app/features/summary/presentation/controllers/summary_providers.dart';
import 'package:budgeting_app/features/summary/presentation/widgets/spending_donut_chart.dart';
import 'package:budgeting_app/features/summary/presentation/widgets/summary_record_row.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

final class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final DateTime current = ref.read(currentDateProvider);
    _selectedMonth = DateTime(current.year, current.month);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<MonthlyTransactionSummary> summary = ref.watch(
      monthlyTransactionSummaryForMonthProvider(_selectedMonth),
    );
    final DateTime currentDate = ref.watch(currentDateProvider);
    final CurrencyFormatter currencyFormatter = ref.watch(
      currencyFormatterProvider,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Summary')),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: summary.when(
              loading: () =>
                  const AppLoadingIndicator(label: 'Loading monthly summary'),
              error: (Object error, StackTrace stackTrace) => AppErrorState(
                message: 'Your transaction summary is unavailable. Try again.',
                onRetry: () => ref.invalidate(transactionListProvider),
              ),
              data: (MonthlyTransactionSummary value) => ListView(
                key: const ValueKey<String>('summary_content'),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.navigationClearance,
                ),
                children: <Widget>[
                  _MonthSelector(
                    label: ref
                        .watch(dateFormatterProvider)
                        .monthYear(_selectedMonth),
                    onPrevious: () => _changeMonth(-1),
                    onNext: _isCurrentMonth(currentDate)
                        ? null
                        : () => _changeMonth(1),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  if (value.transactionCount == 0)
                    const EmptyState(
                      title: 'No transactions this month',
                      message:
                          'Income and expenses recorded for this month will '
                          'appear here.',
                      icon: Icons.summarize_outlined,
                    )
                  else ...<Widget>[
                    _MonthlyRecords(
                      summary: value,
                      currencyFormatter: currencyFormatter,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Where your money went',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (value.spendingGroups.isEmpty)
                      Text(
                        'No expenses were recorded for this month.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    else ...<Widget>[
                      Center(
                        child: SpendingDonutChart(
                          groups: value.spendingGroups,
                          total: value.expenses,
                          currencyFormatter: currencyFormatter,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        'Category breakdown',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ...value.spendingGroups.indexed.expand(
                        ((int, CategorySpendingGroup) entry) => <Widget>[
                          SummaryRecordRow(
                            label: entry.$2.displayLabel,
                            value: currencyFormatter.format(entry.$2.amount),
                            supportingText:
                                '${entry.$2.sharePercentage}% of recorded '
                                'expenses',
                            leading: _CategoryIcon(group: entry.$2),
                          ),
                          const Divider(),
                        ],
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + offset,
      );
    });
  }

  bool _isCurrentMonth(DateTime currentDate) {
    return _selectedMonth.year == currentDate.year &&
        _selectedMonth.month == currentDate.month;
  }
}

final class _MonthlyRecords extends StatelessWidget {
  const _MonthlyRecords({
    required this.summary,
    required this.currencyFormatter,
  });

  final MonthlyTransactionSummary summary;
  final CurrencyFormatter currencyFormatter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('This month', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceSecondary,
            border: Border.all(color: AppColors.borderSubtle),
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Column(
            children: <Widget>[
              SummaryRecordRow(
                label: 'Income',
                value: currencyFormatter.format(summary.income),
              ),
              const Divider(),
              SummaryRecordRow(
                label: 'Expenses',
                value: currencyFormatter.format(summary.expenses),
              ),
              const Divider(),
              SummaryRecordRow(
                label: 'Net change',
                value: currencyFormatter.formatSigned(summary.netChange),
              ),
              const Divider(),
              SummaryRecordRow(
                label: 'Transaction count',
                value: summary.transactionCount == 1
                    ? '1 recorded'
                    : '${summary.transactionCount} recorded',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('summary_month_selector'),
      decoration: BoxDecoration(
        color: AppColors.surfacePrimary,
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            key: const ValueKey<String>('previous_month_button'),
            tooltip: 'Previous month',
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Semantics(
              selected: true,
              label: 'Selected month, $label',
              excludeSemantics: true,
              child: Text(
                label,
                key: const ValueKey<String>('summary_selected_month'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            key: const ValueKey<String>('next_month_button'),
            tooltip: 'Next month',
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

final class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.group});

  final CategorySpendingGroup group;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: group.displaySurface,
        shape: BoxShape.circle,
      ),
      child: Icon(group.displayIcon, color: group.displayAccent, size: 20),
    );
  }
}
