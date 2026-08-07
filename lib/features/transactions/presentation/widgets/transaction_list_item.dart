import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/app/theme/app_typography.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/payment_method_metadata.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class TransactionListItem extends ConsumerWidget {
  const TransactionListItem({
    required this.transaction,
    required this.onTap,
    this.showDate = true,
    super.key,
  });

  final FinancialTransaction transaction;
  final VoidCallback onTap;
  final bool showDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TransactionCategoryVisual visual = transaction.category.visual;
    final String formattedAmount = ref
        .watch(currencyFormatterProvider)
        .format(transaction.amount);
    final AppCalendarSystem primaryCalendar =
        ref.watch(primaryCalendarProvider).valueOrNull ??
        AppCalendarSystem.gregorianAd;
    final String formattedDate = ref
        .watch(appCalendarServiceProvider)
        .formatDayGroup(
          transaction.occurredAt,
          primaryCalendar,
          relativeTo: ref.watch(currentDateProvider),
        );
    final bool isIncome = transaction.type == TransactionType.income;
    final String transactionKind = isIncome ? 'Income' : 'Expense';
    final String amountPrefix = isIncome ? '+' : '−';
    final String title = transaction.merchant ?? visual.label;
    final Color iconForeground = isIncome
        ? context.appColors.incomeAccent
        : visual.foreground;
    final Color iconBackground = isIncome
        ? context.appColors.incomeSurface
        : Theme.of(context).brightness == Brightness.dark
        ? Color.alphaBlend(
            visual.foreground.withValues(alpha: 0.18),
            context.appColors.surfacePrimary,
          )
        : visual.background;

    return Semantics(
      button: true,
      label:
          '$transactionKind, $formattedAmount, ${visual.label}, '
          '${transaction.paymentMethod.label}, $formattedDate, '
          '${primaryCalendar.semanticName}',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.small),
        overlayColor: WidgetStatePropertyAll<Color>(
          context.appColors.primarySubtle,
        ),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final Widget icon = Container(
              key: ValueKey<String>(
                'transaction_category_icon_${transaction.id}',
              ),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(visual.icon, color: iconForeground, size: 20),
            );
            final Widget details = _TransactionDetails(
              transactionId: transaction.id,
              title: title,
              metadata: showDate
                  ? '${visual.label} · ${transaction.paymentMethod.label} · '
                        '$formattedDate'
                  : '${visual.label} · ${transaction.paymentMethod.label}',
            );
            final Widget amount = _TransactionAmount(
              transactionId: transaction.id,
              amount: '$amountPrefix$formattedAmount',
              isIncome: isIncome,
            );
            final bool useStackedLayout =
                MediaQuery.textScalerOf(context).scale(14) > 20;
            final double amountMaxWidth = constraints.maxWidth < 360
                ? 140
                : 168;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  icon,
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: useStackedLayout
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              details,
                              const SizedBox(height: AppSpacing.xs),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: amountMaxWidth,
                                  ),
                                  child: amount,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(child: details),
                              const SizedBox(width: AppSpacing.md),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth: amountMaxWidth,
                                ),
                                child: amount,
                              ),
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
  const _TransactionDetails({
    required this.transactionId,
    required this.title,
    required this.metadata,
  });

  final String transactionId;
  final String title;
  final String metadata;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          key: ValueKey<String>('transaction_title_$transactionId'),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: context.appColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          metadata,
          key: ValueKey<String>('transaction_metadata_$transactionId'),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

final class _TransactionAmount extends StatelessWidget {
  const _TransactionAmount({
    required this.transactionId,
    required this.amount,
    required this.isIncome,
  });

  final String transactionId;
  final String amount;
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    return Text(
      amount,
      key: ValueKey<String>('transaction_amount_$transactionId'),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.end,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: isIncome
            ? context.appColors.incomeAccent
            : context.appColors.expenseAccent,
        fontFeatures: AppTypography.tabularFigures,
      ),
    );
  }
}
