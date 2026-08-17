import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/formatting/currency_formatter.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/app_loading_indicator.dart';
import 'package:budgeting_app/features/monthly_reports/domain/entities/monthly_comparison_data.dart';
import 'package:budgeting_app/features/monthly_reports/presentation/controllers/monthly_report_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class MonthComparisonScreen extends ConsumerWidget {
  const MonthComparisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<MonthlyComparisonData> comparison = ref.watch(
      monthlyComparisonProvider,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Month comparison')),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: comparison.when(
              loading: () =>
                  const AppLoadingIndicator(label: 'Loading month comparison'),
              error: (_, _) => const AppErrorState(
                message: 'The month comparison is unavailable.',
              ),
              data: (MonthlyComparisonData value) => ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.pageEnd,
                ),
                children: <Widget>[
                  Text(
                    '${value.currentPeriod.displayLabel} vs ${value.previousPeriod.displayLabel}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    value.isPartialComparison
                        ? 'Compared with the same point last month'
                        : 'Compared with the previous month',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (!value.hasComparableData)
                    Text(value.explanation)
                  else ...<Widget>[
                    _ComparisonMetric(label: 'Income', value: value.income),
                    _ComparisonMetric(label: 'Expenses', value: value.expenses),
                    _ComparisonMetric(
                      label: 'Net change',
                      value: value.netChange,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Semantics(
                      liveRegion: true,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: value.hasPositiveFactualMessage
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Text(value.explanation),
                        ),
                      ),
                    ),
                    if (value.expenseCategoryDeltas.isNotEmpty) ...<Widget>[
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        'Biggest expense changes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final ReportCategoryDelta delta
                          in value.expenseCategoryDeltas.take(5))
                        _DeltaRow(delta: delta),
                    ],
                    if (value.incomeCategoryDeltas.isNotEmpty) ...<Widget>[
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        'Income source changes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      for (final ReportCategoryDelta delta
                          in value.incomeCategoryDeltas.take(3))
                        _DeltaRow(delta: delta),
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
}

final class _ComparisonMetric extends StatelessWidget {
  const _ComparisonMetric({required this.label, required this.value});

  final String label;
  final ReportMetricComparison value;

  @override
  Widget build(BuildContext context) {
    final CurrencyFormatter formatter = CurrencyFormatter();
    final int? basisPoints = value.changeBasisPoints;
    final String change = value.previous.isZero
        ? value.current.isZero
              ? 'No change recorded'
              : 'New this period: ${formatter.format(value.current)}'
        : '${formatter.formatSigned(value.delta)} '
              '(${basisPoints! >= 0 ? '+' : ''}${(basisPoints / 100).toStringAsFixed(1)}%)';
    return Semantics(
      label:
          '$label. Previous ${formatter.format(value.previous)}. '
          'Current ${formatter.format(value.current)}. Change $change.',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '${formatter.format(value.previous)} → ${formatter.format(value.current)}',
                    ),
                    Text(change, textAlign: TextAlign.end),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final class _DeltaRow extends StatelessWidget {
  const _DeltaRow({required this.delta});

  final ReportCategoryDelta delta;

  @override
  Widget build(BuildContext context) {
    final CurrencyFormatter formatter = CurrencyFormatter();
    final String direction = delta.delta.isPositive ? 'Increase' : 'Decrease';
    return Semantics(
      label:
          '${delta.displayLabel}. Previous ${formatter.format(delta.previous)}. '
          'Current ${formatter.format(delta.current)}. $direction ${formatter.format(delta.delta.absolute)}.',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(delta.displayLabel)),
              Flexible(
                child: Text(
                  '${delta.delta.isPositive ? '↑' : '↓'} '
                  '${formatter.format(delta.delta.absolute)}',
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
