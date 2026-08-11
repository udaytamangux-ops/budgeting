import 'dart:async';

import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/app/theme/app_typography.dart';
import 'package:budgeting_app/core/data/app_data_status.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/features/home/presentation/controllers/home_period_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class AvailableBalanceSummary extends ConsumerWidget {
  const AvailableBalanceSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<HomePeriodFinancials> summary = ref.watch(
      homePeriodFinancialsProvider,
    );
    return summary.maybeWhen(
      data: (HomePeriodFinancials value) {
        final String recordedBalance = ref
            .watch(currencyFormatterProvider)
            .format(value.closingRecordedBalance);
        final String income = ref
            .watch(currencyFormatterProvider)
            .format(value.monthly.income);
        final String expenses = ref
            .watch(currencyFormatterProvider)
            .format(value.monthly.expenses);
        final AppDataStatus dataStatus = ref.watch(appDataStatusProvider);
        return Container(
          key: const ValueKey<String>('recorded_balance_card'),
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.appColors.recordedBalanceSurface,
            border: Border.all(color: context.appColors.recordedBalanceBorder),
            borderRadius: BorderRadius.circular(AppRadius.large),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Recorded balance',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        Text(
                          'Through ${value.period.displayLabel}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: context.appColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const ValueKey<String>(
                      'recorded_balance_information_button',
                    ),
                    tooltip: 'About recorded balance',
                    onPressed: () {
                      unawaited(
                        _showRecordedBalanceInformation(context, dataStatus),
                      );
                    },
                    icon: const Icon(Icons.info_outline, size: 20),
                  ),
                ],
              ),
              Semantics(
                label:
                    'Recorded balance through ${value.period.displayLabel}, '
                    '$recordedBalance. Period income, '
                    '$income. Monthly expenses, $expenses.',
                excludeSemantics: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AnimatedSwitcher(
                      duration: AppMotion.accessibleDuration(
                        context,
                        AppMotion.standard,
                      ),
                      child: Text(
                        recordedBalance,
                        key: ValueKey<int>(
                          value.closingRecordedBalance.minorUnits,
                        ),
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _SummaryMetric(
                            icon: Icons.arrow_downward,
                            iconColor: context.appColors.incomeAccent,
                            label: 'Income',
                            amount: income,
                            amountKey: value.monthly.income,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 48,
                          color: context.appColors.borderSubtle,
                        ),
                        Expanded(
                          child: _SummaryMetric(
                            icon: Icons.arrow_upward,
                            iconColor: context.appColors.expenseAccent,
                            label: 'Expenses',
                            amount: expenses,
                            amountKey: value.monthly.expenses,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  Future<void> _showRecordedBalanceInformation(
    BuildContext context,
    AppDataStatus dataStatus,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          scrollable: true,
          title: const Text('About recorded balance'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Recorded balance is the difference between all income and '
                'expenses recorded in this app through the end of the '
                'selected month. It may not match your bank account or wallet '
                'balance.',
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(AppDataStatus.bankAccessDescription),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Only income and expenses recorded in this app are included.',
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                dataStatus.storageTitle,
                style: Theme.of(dialogContext).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(dataStatus.storageDescription),
              const SizedBox(height: AppSpacing.sm),
              const Text(AppDataStatus.cloudAccessDescription),
            ],
          ),
          actions: <Widget>[
            TextButton(
              key: const ValueKey<String>('close_recorded_balance_information'),
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

final class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.amount,
    required this.amountKey,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String amount;
  final Money amountKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 16, color: iconColor),
              const SizedBox(width: AppSpacing.xxs),
              Flexible(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxs),
          AnimatedSwitcher(
            duration: AppMotion.accessibleDuration(context, AppMotion.fast),
            child: Text(
              amount,
              key: ValueKey<int>(amountKey.minorUnits),
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontFeatures: AppTypography.tabularFigures,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
