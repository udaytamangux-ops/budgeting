import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/app_loading_indicator.dart';
import 'package:budgeting_app/features/money_plan/domain/entities/money_plan.dart';
import 'package:budgeting_app/features/money_plan/presentation/controllers/money_plan_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class MoneyPlanSummaryEntry extends ConsumerWidget {
  const MoneyPlanSummaryEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<MoneyPlanPreference?> preferenceValue = ref.watch(
      moneyPlanPreferenceProvider,
    );
    final AsyncValue<List<MoneyPlanPeriod>> periodsValue = ref.watch(
      moneyPlanPeriodsProvider,
    );
    if (preferenceValue.isLoading || periodsValue.isLoading) {
      return const _SummarySurface(
        child: AppLoadingIndicator(label: 'Loading Money Plan'),
      );
    }
    if (preferenceValue.hasError || periodsValue.hasError) {
      return _SummarySurface(
        child: AppErrorState(
          message: 'Money Plan is unavailable. Try again.',
          onRetry: () {
            ref.invalidate(moneyPlanPreferenceProvider);
            ref.invalidate(moneyPlanPeriodsProvider);
          },
        ),
      );
    }
    final MoneyPlanPreference? preference = preferenceValue.requireValue;
    final List<MoneyPlanPeriod> periods = periodsValue.requireValue;
    final MoneyPlanPeriod? latest = periods.lastOrNull;
    final bool configured = latest != null;

    return _SummarySurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.account_balance_wallet_outlined),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Money Plan',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (!configured) ...<Widget>[
            const Text(
              'Give your monthly income a simple direction with an adjustable '
              '50 / 30 / 20 starting plan.',
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.tonal(
              key: const ValueKey<String>('setup_money_plan_summary'),
              onPressed: () => context.push(AppRoutes.moneyPlanSetup),
              child: const Text('Set up Money Plan'),
            ),
          ] else if (preference?.isEnabled != true) ...<Widget>[
            const Text('Currently off'),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              key: const ValueKey<String>('view_disabled_money_plan_summary'),
              onPressed: () => context.push(AppRoutes.moneyPlan),
              child: const Text('View previous plans / Turn on'),
            ),
          ] else ...<Widget>[
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: AppSpacing.xs,
              children: <Widget>[
                Text('Needs ${latest.ratios.needsPercent}%'),
                Text('Wants ${latest.ratios.wantsPercent}%'),
                Text('Savings ${latest.ratios.savingsPercent}%'),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              key: const ValueKey<String>('view_money_plan_summary'),
              onPressed: () => context.push(AppRoutes.moneyPlan),
              child: const Text("View this month's plan"),
            ),
          ],
        ],
      ),
    );
  }
}

final class _SummarySurface extends StatelessWidget {
  const _SummarySurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey<String>('money_plan_summary_entry'),
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: context.appColors.surfaceSecondary,
      border: Border.all(color: context.appColors.borderSubtle),
      borderRadius: BorderRadius.circular(AppRadius.medium),
    ),
    child: child,
  );
}
