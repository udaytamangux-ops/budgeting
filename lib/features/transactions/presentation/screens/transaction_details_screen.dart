import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/app/theme/app_typography.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/app_loading_indicator.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
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
    final String transactionDate = ref
        .watch(dateFormatterProvider)
        .longDate(transaction.occurredAt);
    final String createdDate = ref
        .watch(dateFormatterProvider)
        .dateAndTime(transaction.createdAt);
    final TransactionCategoryVisual category = transaction.category.visual;
    final bool isIncome = transaction.type == TransactionType.income;

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
              AppSpacing.pageEnd,
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: isIncome
                              ? AppColors.positiveSubtle
                              : AppColors.surfaceSecondary,
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
                              color: isIncome
                                  ? AppColors.balancePositive
                                  : AppColors.textSecondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              isIncome ? 'Income' : 'Expense',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        amount,
                        style: Theme.of(context).textTheme.displaySmall,
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
                _DetailRow(label: 'Merchant', value: transaction.merchant!),
              _DetailRow(
                label: 'Payment method',
                value: transaction.paymentMethod.label,
              ),
              _DetailRow(label: 'Transaction date', value: transactionDate),
              _DetailRow(label: 'Created', value: createdDate),
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
              Semantics(
                button: true,
                label: 'Delete transaction, destructive action',
                child: TextButton.icon(
                  key: const ValueKey<String>('delete_transaction_button'),
                  onPressed: actionState.isDeleting
                      ? null
                      : () => _confirmDelete(context, ref, amount),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.destructiveAction,
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
                      color: AppColors.dangerSubtle,
                      borderRadius: BorderRadius.circular(AppRadius.small),
                    ),
                    child: Text(
                      actionState.errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.destructiveAction,
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
    final String date = ref
        .read(dateFormatterProvider)
        .longDate(transaction.occurredAt);
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
                '${transaction.category.visual.label} · $amount · $date',
                style: Theme.of(dialogContext).textTheme.labelLarge?.copyWith(
                  fontFeatures: AppTypography.tabularFigures,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Deleting it will update your available balance and monthly '
                'budget.',
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
                backgroundColor: AppColors.destructiveAction,
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
}

final class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

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
            child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
          ),
        ],
      ),
    );
  }
}
