import 'dart:async';

import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/app/theme/app_typography.dart';
import 'package:budgeting_app/core/analytics/analytics_event_names.dart';
import 'package:budgeting_app/core/analytics/app_analytics.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/app_loading_indicator.dart';
import 'package:budgeting_app/features/categories/presentation/controllers/category_providers.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/payment_method_metadata.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_details_controller.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class TransactionDetailsScreen extends ConsumerWidget {
  const TransactionDetailsScreen({required this.transactionId, super.key});

  final String transactionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<FinancialTransaction?> transaction = ref.watch(
      transactionByIdProvider(transactionId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction details')),
      body: transaction.when(
        loading: () =>
            const AppLoadingIndicator(label: 'Loading transaction details'),
        error: (Object error, StackTrace stackTrace) => AppErrorState(
          message: 'Transaction details are unavailable. Try again.',
          onRetry: () => ref.invalidate(transactionListProvider),
        ),
        data: (FinancialTransaction? value) {
          if (value == null) {
            return const AppErrorState(
              title: 'Transaction not found',
              message:
                  'This transaction may have been deleted or is no longer '
                  'available.',
            );
          }
          return _TransactionDetailsContent(transaction: value);
        },
      ),
    );
  }
}

final class _TransactionDetailsContent extends ConsumerWidget {
  const _TransactionDetailsContent({required this.transaction});

  final FinancialTransaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TransactionDetailsActionState actionState = ref.watch(
      transactionDetailsControllerProvider(transaction.id),
    );
    final String amount = ref
        .watch(currencyFormatterProvider)
        .format(transaction.amount);
    final AppCalendarSystem primaryCalendar =
        ref.watch(primaryCalendarProvider).valueOrNull ??
        AppCalendarSystem.gregorianAd;
    final AppCalendarSystem secondaryCalendar =
        primaryCalendar == AppCalendarSystem.gregorianAd
        ? AppCalendarSystem.bikramSambatBs
        : AppCalendarSystem.gregorianAd;
    final AppCalendarService calendarService = ref.watch(
      appCalendarServiceProvider,
    );
    final String transactionDate = calendarService.formatDate(
      transaction.occurredAt,
      primaryCalendar,
    );
    final String secondaryTransactionDate = calendarService.formatDate(
      transaction.occurredAt,
      secondaryCalendar,
    );
    final String createdDate = calendarService.formatDateAndTime(
      transaction.createdAt,
      primaryCalendar,
    );
    final TransactionCategoryVisual category = transaction.category.visualFor(
      ref.watch(categoryCatalogProvider).resolve(transaction.category),
    );
    final bool isIncome = transaction.type == TransactionType.income;
    final Color amountColor = isIncome
        ? context.appColors.incomeAccent
        : context.appColors.expenseText;
    final Color typeSurface = isIncome
        ? context.appColors.incomeSurface
        : context.appColors.expenseSurface;
    final Color typeText = isIncome
        ? context.appColors.incomeAccent
        : context.appColors.expenseText;
    final Color typeIcon = isIncome
        ? context.appColors.incomeAccent
        : context.appColors.expenseAccentStrong;

    return SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.navigationClearance,
            ),
            children: <Widget>[
              Semantics(
                label:
                    '${isIncome ? 'Income' : 'Expense'}, $amount, '
                    '${category.label}',
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        key: const ValueKey<String>('transaction_type_pill'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: typeSurface,
                          borderRadius: BorderRadius.circular(AppRadius.small),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              isIncome
                                  ? Icons.add_circle_outline
                                  : Icons.remove_circle_outline,
                              size: 18,
                              color: typeIcon,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              isIncome ? 'Income' : 'Expense',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(color: typeText),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        key: const ValueKey<String>(
                          'transaction_details_amount',
                        ),
                        amount,
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall?.copyWith(color: amountColor),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: <Widget>[
                          Icon(category.icon, color: category.foreground),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            category.label,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const Divider(),
              if (transaction.merchant != null)
                _DetailRow(
                  label: isIncome ? 'Payer or source' : 'Merchant',
                  value: transaction.merchant!,
                ),
              _DetailRow(
                label: isIncome ? 'Received via' : 'Paid via',
                value: transaction.paymentMethod.label,
              ),
              _DetailRow(
                label: 'Transaction date',
                value: transactionDate,
                secondaryValue:
                    '${secondaryCalendar.shortLabel} · '
                    '$secondaryTransactionDate',
                semanticValue:
                    '$transactionDate, ${primaryCalendar.semanticName}. '
                    '$secondaryTransactionDate, '
                    '${secondaryCalendar.semanticName}',
              ),
              _DetailRow(
                key: const ValueKey<String>('transaction_created_row'),
                label: 'Created',
                value: createdDate,
              ),
              if (transaction.note != null)
                _DetailRow(label: 'Note', value: transaction.note!),
              const Divider(),
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                key: const ValueKey<String>('edit_transaction_button'),
                onPressed: actionState.isDeleting
                    ? null
                    : () => context.push<FinancialTransaction>(
                        AppRoutes.editTransaction(transaction.id),
                      ),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit transaction'),
              ),
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                key: const ValueKey<String>('repeat_transaction_button'),
                onPressed: actionState.isDeleting
                    ? null
                    : () => unawaited(_repeatTransaction(context, ref)),
                icon: const Icon(Icons.replay_outlined),
                label: const Text('Repeat transaction'),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextButton.icon(
                key: const ValueKey<String>('make_recurring_button'),
                onPressed: actionState.isDeleting
                    ? null
                    : () =>
                          context.push(AppRoutes.makeRecurring(transaction.id)),
                icon: const Icon(Icons.event_repeat_outlined),
                label: const Text('Make recurring'),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              Semantics(
                button: true,
                label: 'Delete transaction, destructive action',
                child: TextButton.icon(
                  key: const ValueKey<String>('delete_transaction_button'),
                  onPressed: actionState.isDeleting
                      ? null
                      : () => _confirmDelete(context, ref, amount),
                  style: TextButton.styleFrom(
                    foregroundColor: context.appColors.destructiveAction,
                    minimumSize: const Size(48, 48),
                  ),
                  icon: actionState.isDeleting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                  label: Text(
                    actionState.isDeleting
                        ? 'Deleting transaction'
                        : 'Delete transaction',
                  ),
                ),
              ),
              if (actionState.errorMessage != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Semantics(
                  liveRegion: true,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: context.appColors.dangerSubtle,
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Text(
                      actionState.errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.appColors.destructiveAction,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String amount,
  ) async {
    final AppCalendarSystem primaryCalendar =
        ref.read(primaryCalendarProvider).valueOrNull ??
        AppCalendarSystem.gregorianAd;
    final String date = ref
        .read(appCalendarServiceProvider)
        .formatDate(transaction.occurredAt, primaryCalendar);
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete this transaction?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${ref.watch(categoryCatalogProvider).resolve(transaction.category).label} · $amount · $date',
                style: Theme.of(dialogContext).textTheme.labelLarge?.copyWith(
                  fontFeatures: AppTypography.tabularFigures,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Deleting it will update your recorded balance and financial '
                'summary.',
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => dialogContext.pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => dialogContext.pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: context.appColors.destructiveAction,
              ),
              child: const Text('Delete transaction'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }
    final bool deleted = await ref
        .read(transactionDetailsControllerProvider(transaction.id).notifier)
        .deleteTransaction();
    if (deleted && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transaction deleted.')));
      context.pop();
    }
  }

  Future<void> _repeatTransaction(BuildContext context, WidgetRef ref) async {
    ref
        .read(appAnalyticsProvider)
        .recordEvent(AnalyticsEventNames.transactionRepeatStarted);
    await context.push<FinancialTransaction>(
      AppRoutes.repeatTransaction(transaction.id),
    );
  }
}

final class _DetailRow extends StatelessWidget {
  const _DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.secondaryValue,
    this.semanticValue,
  });

  final String label;
  final String value;
  final String? secondaryValue;
  final String? semanticValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 132,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Semantics(
              label: semanticValue,
              excludeSemantics: semanticValue != null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(value, style: Theme.of(context).textTheme.bodyLarge),
                  if (secondaryValue != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      secondaryValue!,
                      key: const ValueKey<String>('transaction_date_secondary'),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
