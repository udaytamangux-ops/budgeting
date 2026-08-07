import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/widgets/empty_state.dart';
import 'package:budgeting_app/features/summary/domain/entities/monthly_transaction_summary.dart';
import 'package:budgeting_app/features/summary/presentation/controllers/summary_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class ThisMonthSummary extends ConsumerWidget {
  const ThisMonthSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<MonthlyTransactionSummary> summary = ref.watch(
      currentMonthlyTransactionSummaryProvider,
    );
    return summary.maybeWhen(
      data: (MonthlyTransactionSummary value) {
        if (value.transactionCount == 0) {
          return const _FirstUseMonthlySummary();
        }
        final String transactionFact = value.transactionCount == 1
            ? '1 transaction recorded'
            : '${value.transactionCount} transactions recorded';
        final String categoryFact = value.spendingCategoryCount == 1
            ? 'Spent across 1 category'
            : 'Spent across ${value.spendingCategoryCount} categories';
        return Semantics(
          container: true,
          label: 'This month. $transactionFact. $categoryFact.',
          explicitChildNodes: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final Widget title = Text(
                    'This month',
                    style: Theme.of(context).textTheme.titleLarge,
                  );
                  final Widget action = TextButton(
                    key: const ValueKey<String>('view_summary_button'),
                    onPressed: () => context.go(AppRoutes.summary),
                    child: const Text('View details'),
                  );
                  final bool shouldStack =
                      constraints.maxWidth < 360 &&
                      MediaQuery.textScalerOf(context).scale(14) >= 21;

                  if (shouldStack) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        title,
                        Align(alignment: Alignment.centerRight, child: action),
                      ],
                    );
                  }

                  return Row(
                    children: <Widget>[
                      Expanded(child: title),
                      action,
                    ],
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Column(
                children: <Widget>[
                  _MonthlyFact(
                    icon: Icons.receipt_long_outlined,
                    label: transactionFact,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _MonthlyFact(
                    icon: Icons.category_outlined,
                    label: categoryFact,
                  ),
                ],
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

final class _FirstUseMonthlySummary extends StatelessWidget {
  const _FirstUseMonthlySummary();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('This month', style: Theme.of(context).textTheme.titleLarge),
        const EmptyState(
          key: ValueKey<String>('home_first_use_state'),
          title: 'Start recording your money activity',
          message:
              'Add your first income or expense to begin building your '
              'personal ledger.',
          icon: Icons.edit_note_outlined,
        ),
      ],
    );
  }
}

final class _MonthlyFact extends StatelessWidget {
  const _MonthlyFact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: context.appColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
