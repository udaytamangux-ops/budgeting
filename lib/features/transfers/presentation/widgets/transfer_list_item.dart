import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/app/theme/app_typography.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:budgeting_app/features/transfers/domain/entities/transfer_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class TransferListItem extends ConsumerWidget {
  const TransferListItem({
    required this.transfer,
    required this.onTap,
    this.showDate = true,
    this.displayAmount,
    super.key,
  });

  final FinancialTransfer transfer;
  final VoidCallback onTap;
  final bool showDate;
  final Money? displayAmount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Money shownAmount = displayAmount ?? transfer.amount;
    final String amount = ref
        .watch(currencyFormatterProvider)
        .format(shownAmount);
    final primaryCalendar =
        ref.watch(primaryCalendarProvider).valueOrNull ??
        AppCalendarSystem.gregorianAd;
    final String date = ref
        .watch(appCalendarServiceProvider)
        .formatDayGroup(
          transfer.occurredAt,
          primaryCalendar,
          relativeTo: ref.watch(currentDateProvider),
        );
    final bool expenseStyled =
        displayAmount != null || transfer.countsAsExpense;
    final String title =
        '${transfer.source.label} → ${transfer.destinationDisplayName}';
    final String status = transfer.countsAsExpense
        ? 'Transfer · Counted as expense'
        : 'Transfer';
    final String metadata = showDate ? '$status · $date' : status;
    final String amountLabel = expenseStyled ? '−$amount' : amount;

    return Semantics(
      button: true,
      label: '$title, Transfer, $amount, $metadata',
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.small),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.appColors.primarySubtle,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.swap_horiz,
                  color: context.appColors.primaryAction,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      key: ValueKey<String>('transfer_title_${transfer.id}'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      metadata,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 168),
                child: Text(
                  amountLabel,
                  key: ValueKey<String>('transfer_amount_${transfer.id}'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: expenseStyled
                        ? context.appColors.expenseAccent
                        : context.appColors.textPrimary,
                    fontFeatures: AppTypography.tabularFigures,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
