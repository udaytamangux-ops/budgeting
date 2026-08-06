import 'dart:async';

import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/app/theme/app_typography.dart';
import 'package:budgeting_app/core/data/app_data_status.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/monthly_financial_summary.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class AvailableBalanceSummary extends ConsumerWidget {
  const AvailableBalanceSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<MonthlyFinancialSummary> summary = ref.watch(
      monthlyFinancialSummaryProvider,
    );
    return summary.maybeWhen(
      data: (MonthlyFinancialSummary value) {
        final currencyFormatter = ref.watch(currencyFormatterProvider);
        final String recordedBalance = currencyFormatter.format(
          value.availableBalance,
        );
        final String income = currencyFormatter.format(value.income);
        final String expenses = currencyFormatter.format(value.expenses);
        final AppDataStatus dataStatus = ref.watch(appDataStatusProvider);
        return RepaintBoundary(
          child: Container(
            key: const ValueKey<String>('recorded_balance_card'),
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceStrong,
              border: Border.all(color: AppColors.recordedBalanceBorder),
              borderRadius: BorderRadius.circular(AppRadius.signatureSurface),
            ),
            child: Semantics(
              label:
                  'Recorded balance, $recordedBalance. Monthly income, '
                  '$income. Monthly expenses, $expenses.',
              excludeSemantics: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Recorded balance',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: AppColors.inkOnStrongMuted),
                        ),
                      ),
                      IconButton(
                        key: const ValueKey<String>(
                          'recorded_balance_information_button',
                        ),
                        tooltip: 'About recorded balance',
                        onPressed: () => unawaited(
                          _showRecordedBalanceInformation(context, dataStatus),
                        ),
                        style: IconButton.styleFrom(
                          foregroundColor: AppColors.inkOnStrong,
                          backgroundColor: const Color(0x14FFFFFF),
                          minimumSize: const Size.square(48),
                        ),
                        icon: const Icon(Icons.info_outline_rounded, size: 20),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedSwitcher(
                      duration: AppMotion.accessibleDuration(
                        context,
                        AppMotion.financialValue,
                      ),
                      switchInCurve: AppMotion.emphasized,
                      switchOutCurve: AppMotion.exiting,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.08),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                      child: Align(
                        key: ValueKey<int>(value.availableBalance.minorUnits),
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            recordedBalance,
                            maxLines: 1,
                            style: AppTypography.financialDisplay(
                              context,
                              color: AppColors.inkOnStrong,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final bool shouldStack =
                              constraints.maxWidth < 300 ||
                              MediaQuery.textScalerOf(context).scale(14) > 21;
                          final Widget incomeMetric = _SummaryMetric(
                            icon: Icons.south_west_rounded,
                            iconColor: AppColors.incomeAccent,
                            iconSurface: AppColors.incomeSoft,
                            label: 'Income',
                            amount: income,
                            amountKey: value.income,
                          );
                          final Widget expenseMetric = _SummaryMetric(
                            icon: Icons.north_east_rounded,
                            iconColor: AppColors.expenseText,
                            iconSurface: AppColors.expenseSoft,
                            label: 'Expenses',
                            amount: expenses,
                            amountKey: value.expenses,
                          );
                          if (shouldStack) {
                            return Column(
                              children: <Widget>[
                                incomeMetric,
                                const SizedBox(height: AppSpacing.xs),
                                expenseMetric,
                              ],
                            );
                          }
                          return Row(
                            children: <Widget>[
                              Expanded(child: incomeMetric),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(child: expenseMetric),
                            ],
                          );
                        },
                  ),
                ],
              ),
            ),
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
                'Recorded balance is the difference between the income and '
                'expenses recorded in this app for the current month. It may '
                'not match your bank account or wallet balance.',
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
    required this.iconSurface,
    required this.label,
    required this.amount,
    required this.amountKey,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconSurface;
  final String label;
  final String amount;
  final Money amountKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: const Color(0x12FFFFFF),
        borderRadius: BorderRadius.circular(AppRadius.utilitySurface),
        border: Border.all(color: const Color(0x14FFFFFF)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconSurface,
              borderRadius: BorderRadius.circular(AppRadius.compactControl),
            ),
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.inkOnStrongMuted,
                  ),
                ),
                AnimatedSwitcher(
                  duration: AppMotion.accessibleDuration(
                    context,
                    AppMotion.financialValue,
                  ),
                  child: Text(
                    amount,
                    key: ValueKey<int>(amountKey.minorUnits),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.inkOnStrong,
                      fontFeatures: AppTypography.tabularFigures,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
