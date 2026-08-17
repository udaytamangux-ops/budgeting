import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/features/categories/presentation/controllers/category_providers.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_occurrence.dart';
import 'package:budgeting_app/features/recurring/presentation/controllers/recurring_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class ScheduledTransactionsDueSurface extends ConsumerWidget {
  const ScheduledTransactionsDueSurface({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<RecurringTransactionOccurrence> occurrences =
        ref.watch(pendingRecurringOccurrencesProvider).valueOrNull ??
        const <RecurringTransactionOccurrence>[];
    if (occurrences.isEmpty) {
      return const SizedBox.shrink();
    }
    final String title = occurrences.length == 1
        ? 'Scheduled transaction waiting'
        : '${occurrences.length} scheduled transactions waiting';
    final RecurringTransactionOccurrence first = occurrences.first;
    final String detail = occurrences.length == 1
        ? '${first.merchant ?? ref.watch(categoryCatalogProvider).resolve(first.category).label} · '
              '${ref.watch(currencyFormatterProvider).format(first.amount)}'
        : 'Review each occurrence before recording it.';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Semantics(
        container: true,
        label: '$title. $detail',
        child: Container(
          key: const ValueKey<String>('home_scheduled_due_surface'),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: context.appColors.surfaceSecondary,
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(color: context.appColors.borderSubtle),
          ),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.event_repeat_outlined,
                color: context.appColors.primaryAction,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      detail,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.appColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                key: const ValueKey<String>('review_scheduled_transactions'),
                onPressed: () => context.push(AppRoutes.recurring),
                child: const Text('Review'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
