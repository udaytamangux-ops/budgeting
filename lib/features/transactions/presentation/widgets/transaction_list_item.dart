import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/app/theme/app_typography.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class TransactionListItem extends ConsumerWidget {
  const TransactionListItem({
    required this.transaction,
    required this.onTap,
    super.key,
  });

  final FinancialTransaction transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TransactionCategoryVisual visual = transaction.category.visual;
    final String formattedAmount = ref
        .watch(currencyFormatterProvider)
        .format(transaction.amount);
    final String formattedDate = ref
        .watch(dateFormatterProvider)
        .relativeDate(transaction.occurredAt);
    final bool isIncome = transaction.type == TransactionType.income;
    final String transactionKind = isIncome ? 'Income' : 'Expense';
    final String amountPrefix = isIncome ? '+' : '−';
    final String title = transaction.merchant ?? visual.label;

    return Semantics(
      button: true,
      label:
          '$transactionKind, $formattedAmount, ${visual.label}, '
          '${transaction.paymentMethod.label}, $formattedDate',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Widget icon = Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: visual.background,
                borderRadius: BorderRadius.circular(AppRadius.small),
              ),
              child: Icon(visual.icon, color: visual.foreground, size: 22),
            );
            final Widget details = _TransactionDetails(
              title: title,
              metadata:
                  '${visual.label} · ${transaction.paymentMethod.label} · '
                  '$formattedDate',
            );
            final Widget amount = _TransactionAmount(
              amount: '$amountPrefix $formattedAmount',
              transactionKind: transactionKind,
              isIncome: isIncome,
            );
            final bool useCompactLayout =
                constraints.maxWidth < 340 ||
                MediaQuery.textScalerOf(context).scale(14) > 20;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  icon,
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: useCompactLayout
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              details,
                              const SizedBox(height: AppSpacing.xs),
                              amount,
                            ],
                          )
                        : Row(
                            children: <Widget>[
                              Expanded(child: details),
                              const SizedBox(width: AppSpacing.sm),
                              Flexible(child: amount),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

final class _TransactionDetails extends StatelessWidget {
  const _TransactionDetails({required this.title, required this.metadata});

  final String title;
  final String metadata;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          metadata,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

final class _TransactionAmount extends StatelessWidget {
  const _TransactionAmount({
    required this.amount,
    required this.transactionKind,
    required this.isIncome,
  });

  final String amount;
  final String transactionKind;
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          amount,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: isIncome ? AppColors.balancePositive : AppColors.textPrimary,
            fontFeatures: AppTypography.tabularFigures,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(transactionKind, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
