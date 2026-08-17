import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/core/calendar/presentation/calendar_period_navigator.dart';
import 'package:budgeting_app/core/calendar/presentation/selected_calendar_period_providers.dart';
import 'package:budgeting_app/core/formatting/currency_formatter.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/app_loading_indicator.dart';
import 'package:budgeting_app/features/money_plan/domain/entities/money_plan.dart';
import 'package:budgeting_app/features/money_plan/presentation/controllers/money_plan_providers.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class MoneyPlanScreen extends ConsumerWidget {
  const MoneyPlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppCalendarService calendarService = ref.watch(
      appCalendarServiceProvider,
    );
    final CalendarPeriod selected = ref.watch(selectedCalendarPeriodProvider);
    final AsyncValue<CalendarPeriodBounds> boundsValue = ref.watch(
      moneyPlanPeriodBoundsProvider,
    );
    final AsyncValue<MoneyPlanPreference?> preferenceValue = ref.watch(
      moneyPlanPreferenceProvider,
    );
    if (boundsValue.isLoading || preferenceValue.isLoading) {
      return const _MoneyPlanStateScaffold(
        child: AppLoadingIndicator(label: 'Loading Money Plan'),
      );
    }
    if (boundsValue.hasError || preferenceValue.hasError) {
      return _MoneyPlanStateScaffold(
        child: AppErrorState(
          message: 'Money Plan is unavailable. Try again.',
          onRetry: () {
            ref.invalidate(moneyPlanPeriodBoundsProvider);
            ref.invalidate(moneyPlanPreferenceProvider);
          },
        ),
      );
    }
    final CalendarPeriodBounds bounds = boundsValue.requireValue;
    final MoneyPlanPreference? preference = preferenceValue.requireValue;
    final AsyncValue<MoneyPlanViewData?> view = ref.watch(
      moneyPlanViewDataProvider(selected),
    );
    final bool isCurrent = selected == bounds.current;
    final AsyncValue<MoneyPlanPeriod?>? carryForward =
        isCurrent &&
            preference?.isEnabled == true &&
            view.hasValue &&
            view.valueOrNull == null
        ? ref.watch(moneyPlanCarryForwardProvider(selected))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Plan'),
        actions: <Widget>[
          if (isCurrent &&
              preference?.isEnabled == true &&
              view.valueOrNull != null)
            TextButton(
              onPressed: () => context.push(AppRoutes.moneyPlanEdit),
              child: const Text('Edit'),
            ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.pageEnd,
              ),
              children: <Widget>[
                CalendarPeriodNavigator(
                  period: selected,
                  bounds: bounds,
                  calendarService: calendarService,
                  onSelected: (CalendarPeriod value) => ref
                      .read(selectedCalendarPeriodProvider.notifier)
                      .select(value),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (carryForward?.isLoading == true)
                  const AppLoadingIndicator(label: 'Preparing Money Plan')
                else if (carryForward?.hasError == true)
                  AppErrorState(
                    message: 'Money Plan could not be prepared. Try again.',
                    onRetry: () =>
                        ref.invalidate(moneyPlanCarryForwardProvider(selected)),
                  )
                else if (preference == null)
                  _UnconfiguredPlan(
                    onSetup: () => context.push(AppRoutes.moneyPlanSetup),
                  )
                else if (!preference.isEnabled && isCurrent)
                  _DisabledPlan(
                    onTurnOn: () => context.push(AppRoutes.moneyPlanSetup),
                  )
                else
                  view.when(
                    loading: () =>
                        const AppLoadingIndicator(label: 'Loading Money Plan'),
                    error: (_, _) => AppErrorState(
                      message: 'Money Plan is unavailable. Try again.',
                      onRetry: () =>
                          ref.invalidate(moneyPlanPeriodProvider(selected)),
                    ),
                    data: (MoneyPlanViewData? data) {
                      if (data == null) {
                        final List<MoneyPlanPeriod> plans =
                            ref.watch(moneyPlanPeriodsProvider).valueOrNull ??
                            const <MoneyPlanPeriod>[];
                        return _MissingHistoricalPlan(
                          period: selected,
                          firstPlan: plans.firstOrNull,
                          calendarService: calendarService,
                        );
                      }
                      return _ConfiguredPlan(
                        data: data,
                        currencyFormatter: ref.watch(currencyFormatterProvider),
                        canEdit: isCurrent && preference.isEnabled,
                        onReviewCategories: () =>
                            context.push(AppRoutes.moneyPlanCategories),
                        onAddIncome: () => context.push(AppRoutes.addIncome),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _MoneyPlanStateScaffold extends StatelessWidget {
  const _MoneyPlanStateScaffold({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Money Plan')),
    body: SafeArea(
      top: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: child,
        ),
      ),
    ),
  );
}

final class _UnconfiguredPlan extends StatelessWidget {
  const _UnconfiguredPlan({required this.onSetup});

  final VoidCallback onSetup;

  @override
  Widget build(BuildContext context) => _PlanSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Give your monthly income a simple direction.',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text(
          'Start with 50 / 30 / 20 and adjust it to fit your situation.',
        ),
        const SizedBox(height: AppSpacing.lg),
        const _RatioLine(label: 'Needs', value: '50%'),
        const _RatioLine(label: 'Wants', value: '30%'),
        const _RatioLine(label: 'Savings target', value: '20%'),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(
          key: const ValueKey<String>('setup_money_plan'),
          onPressed: onSetup,
          child: const Text('Set up Money Plan'),
        ),
      ],
    ),
  );
}

final class _DisabledPlan extends StatelessWidget {
  const _DisabledPlan({required this.onTurnOn});

  final VoidCallback onTurnOn;

  @override
  Widget build(BuildContext context) => _PlanSurface(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Money Plan is off',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        const Text('Previous plan periods remain available.'),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(onPressed: onTurnOn, child: const Text('Turn on')),
      ],
    ),
  );
}

final class _MissingHistoricalPlan extends StatelessWidget {
  const _MissingHistoricalPlan({
    required this.period,
    required this.firstPlan,
    required this.calendarService,
  });

  final CalendarPeriod period;
  final MoneyPlanPeriod? firstPlan;
  final AppCalendarService calendarService;

  @override
  Widget build(BuildContext context) {
    final String selectedLabel = calendarService.formatMonthYear(period);
    final String? firstLabel = firstPlan == null
        ? null
        : calendarService.formatMonthYear(firstPlan!.period);
    return _PlanSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'No Money Plan for $selectedLabel',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            firstLabel == null
                ? 'Money Plan has not been set up.'
                : 'Your Money Plan started in $firstLabel.',
          ),
        ],
      ),
    );
  }
}

final class _ConfiguredPlan extends StatelessWidget {
  const _ConfiguredPlan({
    required this.data,
    required this.currencyFormatter,
    required this.canEdit,
    required this.onReviewCategories,
    required this.onAddIncome,
  });

  final MoneyPlanViewData data;
  final CurrencyFormatter currencyFormatter;
  final bool canEdit;
  final VoidCallback onReviewCategories;
  final VoidCallback onAddIncome;

  @override
  Widget build(BuildContext context) {
    final MoneyPlanSummary summary = data.summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          summary.hasPlanIncome
              ? 'Based on ${currencyFormatter.format(summary.planIncome)} '
                    'recorded income this month.'
              : 'No plan income recorded yet',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (!summary.hasPlanIncome) ...<Widget>[
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Your targets will appear after you record eligible income for '
            'this period. Refunds are not included in Money Plan income.',
          ),
          if (canEdit) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: onAddIncome,
              icon: const Icon(Icons.add),
              label: const Text('Add income'),
            ),
          ],
        ],
        const SizedBox(height: AppSpacing.lg),
        _PlanProgress(
          label: 'Needs',
          recorded: summary.needsRecorded,
          target: summary.needsTarget,
          planPercent: data.plan.ratios.needsPercent,
          hasTarget: summary.hasPlanIncome,
          currencyFormatter: currencyFormatter,
        ),
        const SizedBox(height: AppSpacing.md),
        _PlanProgress(
          label: 'Wants',
          recorded: summary.wantsRecorded,
          target: summary.wantsTarget,
          planPercent: data.plan.ratios.wantsPercent,
          hasTarget: summary.hasPlanIncome,
          currencyFormatter: currencyFormatter,
        ),
        const SizedBox(height: AppSpacing.md),
        _PlanSurface(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Savings target',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                summary.hasPlanIncome
                    ? currencyFormatter.format(summary.savingsTarget)
                    : 'Appears after eligible income is recorded',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text('${data.plan.ratios.savingsPercent}% of plan income'),
              const SizedBox(height: AppSpacing.md),
              Text(
                _remainingCopy(summary, currencyFormatter),
                key: const ValueKey<String>('money_plan_remaining'),
              ),
            ],
          ),
        ),
        if (summary.unassignedRecorded.isPositive) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          _PlanSurface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Unassigned spending',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  currencyFormatter.format(summary.unassignedRecorded),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${summary.unassignedCategoryIds.length} '
                  '${summary.unassignedCategoryIds.length == 1 ? 'category needs' : 'categories need'} review.',
                ),
                if (canEdit)
                  TextButton(
                    onPressed: onReviewCategories,
                    child: const Text('Review categories'),
                  ),
              ],
            ),
          ),
        ] else if (canEdit) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: onReviewCategories,
            child: const Text('Review categories'),
          ),
        ],
      ],
    );
  }

  String _remainingCopy(MoneyPlanSummary summary, CurrencyFormatter formatter) {
    if (summary.remainingAfterSpending.isNegative) {
      return 'Recorded spending is '
          '${formatter.format(summary.remainingAfterSpending.absolute)} '
          'above plan income.';
    }
    if (!summary.hasPlanIncome) {
      return '${formatter.format(summary.totalRecordedSpending)} recorded '
          'spending so far.';
    }
    final String base =
        '${formatter.format(summary.remainingAfterSpending)} '
        'currently remains after recorded spending.';
    final difference = summary.remainingAfterSpending - summary.savingsTarget;
    if (difference.isNegative) {
      return '$base ${formatter.format(difference.absolute)} below your '
          'current savings target.';
    }
    return '$base ${formatter.format(difference)} above your current savings '
        'target.';
  }
}

final class _PlanProgress extends StatelessWidget {
  const _PlanProgress({
    required this.label,
    required this.recorded,
    required this.target,
    required this.planPercent,
    required this.hasTarget,
    required this.currencyFormatter,
  });

  final String label;
  final Money recorded;
  final Money target;
  final int planPercent;
  final bool hasTarget;
  final CurrencyFormatter currencyFormatter;

  @override
  Widget build(BuildContext context) {
    final double progress = !hasTarget || target.minorUnits <= 0
        ? 0
        : (recorded.minorUnits / target.minorUnits).clamp(0.0, 1.0);
    return _PlanSurface(
      child: Semantics(
        label:
            '$label. ${currencyFormatter.format(recorded)} recorded. '
            '${hasTarget ? '${currencyFormatter.format(target)} target.' : 'No target yet.'}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text('${currencyFormatter.format(recorded)} recorded'),
            Text(
              hasTarget
                  ? '${currencyFormatter.format(target)} target · Plan $planPercent%'
                  : 'Plan $planPercent% · Target appears with plan income',
            ),
            if (hasTarget) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              LinearProgressIndicator(value: progress),
              if (recorded > target) ...<Widget>[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${currencyFormatter.format(recorded - target)} above your '
                  'current target.',
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

final class _PlanSurface extends StatelessWidget {
  const _PlanSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      color: context.appColors.surfaceSecondary,
      border: Border.all(color: context.appColors.borderSubtle),
      borderRadius: BorderRadius.circular(AppRadius.medium),
    ),
    child: child,
  );
}

final class _RatioLine extends StatelessWidget {
  const _RatioLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
    child: Row(
      children: <Widget>[
        Expanded(child: Text(label)),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    ),
  );
}
