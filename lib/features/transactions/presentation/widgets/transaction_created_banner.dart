import 'dart:async';

import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/last_saved_transaction_controller.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_visuals.dart';
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
          : _CreatedTransactionBannerContent(
              key: ValueKey<String>(confirmation.transaction.id),
              confirmation: confirmation,
            ),
    );
  }
}

final class _CreatedTransactionBannerContent extends ConsumerWidget {
  const _CreatedTransactionBannerContent({
    required this.confirmation,
    super.key,
  });

  final CreatedTransactionConfirmation confirmation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String amount = ref
        .watch(currencyFormatterProvider)
        .format(confirmation.transaction.amount);
    final bool isExpense =
        confirmation.transaction.type == TransactionType.expense;
    final bool hasFailure = confirmation.phase == UndoTransactionPhase.failure;
    final String transactionKind = isExpense ? 'Expense' : 'Income';
    final String title = hasFailure
        ? 'Could not undo transaction'
        : '$transactionKind added · $amount · '
              '${confirmation.transaction.category.visual.label}';
    final String? detail = hasFailure ? confirmation.errorMessage! : null;
    final String announcement = detail == null ? title : '$title. $detail';

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
                      Padding(
                        padding: const EdgeInsets.only(top: AppSpacing.xs),
                        child: ExcludeSemantics(
                          child: Icon(
                            hasFailure
                                ? Icons.error_outline
                                : Icons.check_circle,
                            color: hasFailure
                                ? context.appColors.destructiveAction
                                : context.appColors.primaryAction,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Semantics(
                            liveRegion: true,
                            label: announcement,
                            excludeSemantics: true,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  title,
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: hasFailure
                                            ? context
                                                  .appColors
                                                  .destructiveAction
                                            : context.appColors.textPrimary,
                                      ),
                                ),
                                if (detail != null) ...<Widget>[
                                  const SizedBox(height: AppSpacing.xxs),
                                  Text(
                                    detail,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: context
                                              .appColors
                                              .destructiveAction,
                                        ),
                                  ),
                                ],
                              ],
                            ),
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
                                    transactionId: confirmation.transaction.id,
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
                          : Text(hasFailure ? 'Retry' : 'Undo'),
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
