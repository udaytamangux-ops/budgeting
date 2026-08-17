import 'dart:async';

import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/features/categories/domain/entities/custom_category.dart';
import 'package:budgeting_app/features/categories/domain/services/category_catalog.dart';
import 'package:budgeting_app/features/categories/presentation/controllers/category_providers.dart';
import 'package:budgeting_app/features/financial_activity/domain/entities/financial_activity.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/last_saved_transaction_controller.dart';
import 'package:budgeting_app/features/transfers/domain/entities/transfer_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class TransactionCreatedBanner extends ConsumerWidget {
  const TransactionCreatedBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CreatedTransactionConfirmation? confirmation = ref.watch(
      lastSavedTransactionProvider,
    );
    return AnimatedSwitcher(
      duration: AppMotion.accessibleDuration(context, AppMotion.fast),
      child: confirmation == null
          ? const SizedBox.shrink(key: ValueKey<String>('no_confirmation'))
          : _Banner(
              key: ValueKey<String>(confirmation.activity.id),
              confirmation: confirmation,
            ),
    );
  }
}

final class _Banner extends ConsumerWidget {
  const _Banner({required this.confirmation, super.key});

  final CreatedTransactionConfirmation confirmation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String amount = ref
        .watch(currencyFormatterProvider)
        .format(confirmation.activity.amount);
    final String kind = switch (confirmation.activity) {
      TransactionActivity(:final transaction) =>
        transaction.type == TransactionType.expense ? 'Expense' : 'Income',
      TransferActivity() => 'Transfer',
    };
    final String label = switch (confirmation.activity) {
      TransactionActivity(:final transaction) =>
        transaction.category.isCustom
            ? ref
                  .watch(categoryCatalogProvider)
                  .resolve(transaction.category)
                  .label
            : CategoryCatalog(
                const <CustomCategory>[],
              ).resolve(transaction.category).label,
      TransferActivity(:final transfer) =>
        '${transfer.source.label} → ${transfer.destinationDisplayName}',
    };
    final bool failed = confirmation.phase == UndoTransactionPhase.failure;
    final String title = failed
        ? confirmation.activity is TransferActivity
              ? 'Could not undo transfer'
              : 'Could not undo transaction'
        : '$kind added · $amount · $label';
    return Padding(
      key: const ValueKey<String>('transaction_created_banner'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Material(
            color: context.appColors.surfacePrimary,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.medium),
              side: BorderSide(color: context.appColors.borderStrong),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.xs,
                AppSpacing.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Icon(
                        failed ? Icons.error_outline : Icons.check_circle,
                        color: failed
                            ? context.appColors.destructiveAction
                            : context.appColors.primaryAction,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Semantics(
                          liveRegion: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                title,
                                style: Theme.of(context).textTheme.labelLarge,
                              ),
                              if (confirmation.errorMessage != null)
                                Text(
                                  confirmation.errorMessage!,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Dismiss confirmation',
                        onPressed: confirmation.isUndoing
                            ? null
                            : () => ref
                                  .read(lastSavedTransactionProvider.notifier)
                                  .dismiss(
                                    transactionId: confirmation.activity.id,
                                  ),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      key: const ValueKey<String>('undo_created_transaction'),
                      onPressed: confirmation.isUndoing
                          ? null
                          : () => unawaited(
                              ref
                                  .read(lastSavedTransactionProvider.notifier)
                                  .undo(),
                            ),
                      child: confirmation.isUndoing
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(failed ? 'Retry' : 'Undo'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
