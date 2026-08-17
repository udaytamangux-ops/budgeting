import 'dart:async';

import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/app_loading_indicator.dart';
import 'package:budgeting_app/core/widgets/empty_state.dart';
import 'package:budgeting_app/features/categories/presentation/controllers/category_providers.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_enums.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_occurrence.dart';
import 'package:budgeting_app/features/recurring/domain/entities/recurring_transaction_rule.dart';
import 'package:budgeting_app/features/recurring/presentation/controllers/recurring_actions_controller.dart';
import 'package:budgeting_app/features/recurring/presentation/controllers/recurring_providers.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class RecurringTransactionsScreen extends ConsumerWidget {
  const RecurringTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(recurringReconciliationProvider);
    final AsyncValue<List<RecurringTransactionRule>> rules = ref.watch(
      recurringRulesProvider,
    );
    final AsyncValue<List<RecurringTransactionOccurrence>> occurrences = ref
        .watch(pendingRecurringOccurrencesProvider);
    final RecurringActionsState actions = ref.watch(
      recurringActionsControllerProvider,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring transactions'),
        actions: <Widget>[
          IconButton(
            key: const ValueKey<String>('create_recurring_header_action'),
            tooltip: 'Create recurring transaction',
            onPressed: () => context.push(AppRoutes.createRecurring),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _body(context, ref, rules, occurrences, actions),
          ),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<RecurringTransactionRule>> rulesValue,
    AsyncValue<List<RecurringTransactionOccurrence>> occurrencesValue,
    RecurringActionsState actions,
  ) {
    if (rulesValue.isLoading || occurrencesValue.isLoading) {
      return const AppLoadingIndicator(label: 'Loading recurring transactions');
    }
    if (rulesValue.hasError || occurrencesValue.hasError) {
      return AppErrorState(
        message: 'Recurring transactions are unavailable. Try again.',
        onRetry: () {
          ref.invalidate(recurringRulesProvider);
          ref.invalidate(pendingRecurringOccurrencesProvider);
          ref.invalidate(recurringReconciliationProvider);
        },
      );
    }
    final List<RecurringTransactionRule> rules =
        rulesValue.valueOrNull ?? const <RecurringTransactionRule>[];
    final List<RecurringTransactionOccurrence> occurrences =
        occurrencesValue.valueOrNull ??
        const <RecurringTransactionOccurrence>[];
    if (rules.isEmpty && occurrences.isEmpty) {
      return EmptyState(
        title: 'No recurring transactions yet',
        message:
            'Schedule regular income or expenses so you can review them when '
            'they are due.',
        icon: Icons.event_repeat_outlined,
        action: FilledButton.icon(
          key: const ValueKey<String>('create_first_recurring_rule'),
          onPressed: () => context.push(AppRoutes.createRecurring),
          icon: const Icon(Icons.add),
          label: const Text('Create recurring transaction'),
        ),
      );
    }
    final Map<String, RecurringTransactionRule> rulesById =
        <String, RecurringTransactionRule>{
          for (final RecurringTransactionRule rule in rules) rule.id: rule,
        };
    final List<RecurringTransactionRule> active = rules
        .where((rule) => rule.status == RecurringRuleStatus.active)
        .toList(growable: false);
    final List<RecurringTransactionRule> paused = rules
        .where((rule) => rule.status == RecurringRuleStatus.paused)
        .toList(growable: false);
    final AppCalendarSystem primaryCalendar =
        ref.watch(primaryCalendarProvider).valueOrNull ??
        AppCalendarSystem.gregorianAd;
    final AppCalendarService calendarService = ref.watch(
      appCalendarServiceProvider,
    );
    final formatter = ref.watch(currencyFormatterProvider);
    return ListView(
      key: const ValueKey<String>('recurring_transactions_list'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.navigationClearance,
      ),
      children: <Widget>[
        if (actions.errorMessage != null) ...<Widget>[
          Semantics(
            liveRegion: true,
            child: Text(
              actions.errorMessage!,
              style: TextStyle(color: context.appColors.destructiveAction),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (occurrences.isNotEmpty) ...<Widget>[
          _SectionTitle(label: 'Due', count: occurrences.length),
          ...occurrences.map((occurrence) {
            final RecurringTransactionRule? rule = rulesById[occurrence.ruleId];
            return _DueOccurrenceTile(
              occurrence: occurrence,
              rule: rule,
              amount: formatter.format(occurrence.amount),
              date: calendarService.formatDate(
                occurrence.dueDateAd,
                primaryCalendar,
              ),
              isBusy: actions.isBusy(occurrence.id),
              onRecord: () => context.push(
                AppRoutes.recordRecurringOccurrence(occurrence.id),
              ),
              onSkip: () => _confirmSkip(context, ref, occurrence),
            );
          }),
          const SizedBox(height: AppSpacing.xl),
        ],
        if (active.isNotEmpty) ...<Widget>[
          const _SectionTitle(label: 'Upcoming'),
          ...active.map(
            (rule) => _RuleTile(
              rule: rule,
              amount: formatter.format(rule.amount),
              nextDate: calendarService.formatDate(
                rule.nextDueDateAd,
                primaryCalendar,
              ),
              isBusy: actions.isBusy(rule.id),
              onEdit: () => context.push(AppRoutes.editRecurring(rule.id)),
              onPause: () => ref
                  .read(recurringActionsControllerProvider.notifier)
                  .pause(rule.id),
              onResume: null,
              onDelete: () => _confirmDelete(context, ref, rule),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        if (paused.isNotEmpty) ...<Widget>[
          const _SectionTitle(label: 'Paused'),
          ...paused.map(
            (rule) => _RuleTile(
              rule: rule,
              amount: formatter.format(rule.amount),
              nextDate: calendarService.formatDate(
                rule.nextDueDateAd,
                primaryCalendar,
              ),
              isBusy: actions.isBusy(rule.id),
              onEdit: () => context.push(AppRoutes.editRecurring(rule.id)),
              onPause: null,
              onResume: () => ref
                  .read(recurringActionsControllerProvider.notifier)
                  .resume(rule.id),
              onDelete: () => _confirmDelete(context, ref, rule),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmSkip(
    BuildContext context,
    WidgetRef ref,
    RecurringTransactionOccurrence occurrence,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Skip this scheduled occurrence?'),
        content: const Text(
          'No transaction will be recorded. Future occurrences will continue.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => dialogContext.pop(true),
            child: const Text('Skip occurrence'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(recurringActionsControllerProvider.notifier)
          .skip(occurrence.id);
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    RecurringTransactionRule rule,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete recurring schedule?'),
        content: const Text(
          'Future scheduled occurrences will stop. Waiting occurrences will '
          'be dismissed. Previously recorded transactions will remain in '
          'your history.',
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
            child: const Text('Delete schedule'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(recurringActionsControllerProvider.notifier)
          .delete(rule.id);
    }
  }
}

final class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label, this.count});

  final String label;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        count == null ? label : '$label · $count',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

final class _DueOccurrenceTile extends ConsumerWidget {
  const _DueOccurrenceTile({
    required this.occurrence,
    required this.rule,
    required this.amount,
    required this.date,
    required this.isBusy,
    required this.onRecord,
    required this.onSkip,
  });

  final RecurringTransactionOccurrence occurrence;
  final RecurringTransactionRule? rule;
  final String amount;
  final String date;
  final bool isBusy;
  final VoidCallback onRecord;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String title =
        occurrence.merchant ??
        ref.watch(categoryCatalogProvider).resolve(occurrence.category).label;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            '$amount · ${rule?.frequency.label ?? 'Scheduled'} · '
            '${rule?.recurrenceCalendar.shortLabel ?? ''}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            'Due $date',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: <Widget>[
              Expanded(
                child: FilledButton(
                  key: ValueKey<String>('record_occurrence_${occurrence.id}'),
                  onPressed: isBusy ? null : onRecord,
                  child: const Text('Record transaction'),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: OutlinedButton(
                  key: ValueKey<String>('skip_occurrence_${occurrence.id}'),
                  onPressed: isBusy ? null : onSkip,
                  child: const Text('Skip'),
                ),
              ),
            ],
          ),
          const Divider(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

final class _RuleTile extends ConsumerWidget {
  const _RuleTile({
    required this.rule,
    required this.amount,
    required this.nextDate,
    required this.isBusy,
    required this.onEdit,
    required this.onPause,
    required this.onResume,
    required this.onDelete,
  });

  final RecurringTransactionRule rule;
  final String amount;
  final String nextDate;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String title =
        rule.merchant ??
        ref.watch(categoryCatalogProvider).resolve(rule.category).label;
    return Semantics(
      container: true,
      label:
          '$title, $amount, ${rule.frequency.label}, schedule follows '
          '${rule.recurrenceCalendar.semanticName}, next $nextDate',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    '$amount · ${rule.frequency.label} · '
                    '${rule.recurrenceCalendar.shortLabel}',
                  ),
                  Text(
                    rule.status == RecurringRuleStatus.paused
                        ? 'Paused'
                        : 'Next $nextDate',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: context.appColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            if (isBusy)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.sm),
                child: SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              PopupMenuButton<String>(
                tooltip: 'Recurring schedule actions',
                onSelected: (String action) {
                  switch (action) {
                    case 'edit':
                      onEdit();
                    case 'pause':
                      onPause?.call();
                    case 'resume':
                      onResume?.call();
                    case 'delete':
                      onDelete();
                  }
                },
                itemBuilder: (_) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Text('Edit schedule'),
                  ),
                  if (onPause != null)
                    const PopupMenuItem<String>(
                      value: 'pause',
                      child: Text('Pause'),
                    ),
                  if (onResume != null)
                    const PopupMenuItem<String>(
                      value: 'resume',
                      child: Text('Resume'),
                    ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Delete schedule'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
