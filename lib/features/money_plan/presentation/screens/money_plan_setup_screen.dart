import 'dart:async';

import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/calendar/domain/calendar_period.dart';
import 'package:budgeting_app/features/categories/domain/entities/custom_category.dart';
import 'package:budgeting_app/features/categories/domain/services/category_catalog.dart';
import 'package:budgeting_app/features/categories/presentation/category_icon_data.dart';
import 'package:budgeting_app/features/categories/presentation/controllers/category_providers.dart';
import 'package:budgeting_app/features/money_plan/domain/entities/money_plan.dart';
import 'package:budgeting_app/features/money_plan/presentation/controllers/money_plan_providers.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class MoneyPlanSplitScreen extends ConsumerStatefulWidget {
  const MoneyPlanSplitScreen({required this.isEditing, super.key});

  final bool isEditing;

  @override
  ConsumerState<MoneyPlanSplitScreen> createState() =>
      _MoneyPlanSplitScreenState();
}

final class _MoneyPlanSplitScreenState
    extends ConsumerState<MoneyPlanSplitScreen> {
  late final TextEditingController _needsController;
  late final TextEditingController _wantsController;
  late final TextEditingController _savingsController;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _needsController = TextEditingController();
    _wantsController = TextEditingController();
    _savingsController = TextEditingController();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    final CalendarPeriod current = ref.read(currentCalendarPeriodProvider);
    final MoneyPlanPeriod? plan = widget.isEditing
        ? await ref.read(moneyPlanRepositoryProvider).getPeriod(current)
        : null;
    await ref
        .read(moneyPlanDraftControllerProvider.notifier)
        .initialize(plan: plan, force: true);
    if (!mounted) return;
    final MoneyPlanDraftState draft = ref.read(
      moneyPlanDraftControllerProvider,
    );
    _needsController.text = '${draft.needsPercent}';
    _wantsController.text = '${draft.wantsPercent}';
    _savingsController.text = '${draft.savingsPercent}';
    setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _needsController.dispose();
    _wantsController.dispose();
    _savingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MoneyPlanDraftState draft = ref.watch(
      moneyPlanDraftControllerProvider,
    );
    return PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          ref.read(moneyPlanDraftControllerProvider.notifier).reset();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.isEditing ? 'Edit Money Plan' : 'Set up Money Plan',
          ),
        ),
        body: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: !_initialized
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      key: const ValueKey<String>('money_plan_split_list'),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        AppSpacing.pageEnd,
                      ),
                      children: <Widget>[
                        Text(
                          'Choose your plan split',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        const Text(
                          '50 / 30 / 20 is a simple starting plan. Adjust it to '
                          'fit your situation.',
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        _PercentField(
                          key: const ValueKey<String>('needs_percent'),
                          controller: _needsController,
                          label: 'Needs',
                          helper: 'Essential everyday spending',
                          onChanged: (int value) => ref
                              .read(moneyPlanDraftControllerProvider.notifier)
                              .setNeeds(value),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _PercentField(
                          key: const ValueKey<String>('wants_percent'),
                          controller: _wantsController,
                          label: 'Wants',
                          helper: 'Flexible or optional spending',
                          onChanged: (int value) => ref
                              .read(moneyPlanDraftControllerProvider.notifier)
                              .setWants(value),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _PercentField(
                          key: const ValueKey<String>('savings_percent'),
                          controller: _savingsController,
                          label: 'Savings target',
                          helper:
                              'Income you aim to leave for savings or future goals',
                          onChanged: (int value) => ref
                              .read(moneyPlanDraftControllerProvider.notifier)
                              .setSavings(value),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Semantics(
                          liveRegion: true,
                          label: _totalMessage(draft),
                          child: Text(
                            _totalMessage(draft),
                            key: const ValueKey<String>('money_plan_total'),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: draft.isValid
                                      ? context.appColors.textPrimary
                                      : context.appColors.expenseText,
                                ),
                          ),
                        ),
                        if (draft.error != null) ...<Widget>[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            draft.error!,
                            style: TextStyle(
                              color: context.appColors.destructiveAction,
                            ),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xl),
                        if (widget.isEditing)
                          OutlinedButton(
                            key: const ValueKey<String>(
                              'review_plan_categories',
                            ),
                            onPressed: draft.isValid && !draft.isSaving
                                ? () => context.push(
                                    AppRoutes.moneyPlanEditCategories,
                                  )
                                : null,
                            child: const Text('Review categories'),
                          )
                        else
                          FilledButton(
                            key: const ValueKey<String>(
                              'review_plan_categories',
                            ),
                            onPressed: draft.isValid && !draft.isSaving
                                ? () => context.push(
                                    AppRoutes.moneyPlanSetupCategories,
                                  )
                                : null,
                            child: const Text('Review categories'),
                          ),
                        if (widget.isEditing) ...<Widget>[
                          const SizedBox(height: AppSpacing.sm),
                          FilledButton(
                            key: const ValueKey<String>(
                              'save_money_plan_changes',
                            ),
                            onPressed: draft.isValid && !draft.isSaving
                                ? _saveChanges
                                : null,
                            child: Text(
                              draft.isSaving ? 'Saving...' : 'Save changes',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextButton(
                            onPressed: draft.isSaving ? null : _turnOff,
                            child: const Text('Turn Money Plan off'),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  String _totalMessage(MoneyPlanDraftState draft) {
    if (draft.total == 100 && draft.isValid) return 'Total 100%';
    if (draft.total < 100) {
      return '${100 - draft.total}% still needs to be assigned.';
    }
    return 'Reduce the plan by ${draft.total - 100}% to reach 100%.';
  }

  Future<void> _turnOff() async {
    final bool success = await ref
        .read(moneyPlanDraftControllerProvider.notifier)
        .turnOff();
    if (success && mounted) context.go(AppRoutes.moneyPlan);
  }

  Future<void> _saveChanges() async {
    final bool saved = await ref
        .read(moneyPlanDraftControllerProvider.notifier)
        .save(ref.read(currentCalendarPeriodProvider));
    if (!mounted || !saved) return;
    ref.read(moneyPlanDraftControllerProvider.notifier).reset();
    context.go(AppRoutes.moneyPlan);
  }
}

final class _PercentField extends StatelessWidget {
  const _PercentField({
    required this.controller,
    required this.label,
    required this.helper,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String helper;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: TextInputType.number,
    inputFormatters: <TextInputFormatter>[
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(3),
    ],
    decoration: InputDecoration(
      labelText: label,
      helperText: helper,
      suffixText: '%',
    ),
    onChanged: (String value) => onChanged(int.tryParse(value) ?? -1),
  );
}

final class MoneyPlanCategoryMappingScreen extends ConsumerStatefulWidget {
  const MoneyPlanCategoryMappingScreen({required this.isEditing, super.key});

  final bool isEditing;

  @override
  ConsumerState<MoneyPlanCategoryMappingScreen> createState() =>
      _MoneyPlanCategoryMappingScreenState();
}

final class _MoneyPlanCategoryMappingScreenState
    extends ConsumerState<MoneyPlanCategoryMappingScreen> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    final CalendarPeriod current = ref.read(currentCalendarPeriodProvider);
    final MoneyPlanPeriod? plan = widget.isEditing
        ? await ref.read(moneyPlanRepositoryProvider).getPeriod(current)
        : null;
    await ref
        .read(moneyPlanDraftControllerProvider.notifier)
        .initialize(plan: plan);
    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    final MoneyPlanDraftState draft = ref.watch(
      moneyPlanDraftControllerProvider,
    );
    final CategoryCatalog catalog = ref.watch(categoryCatalogProvider);
    final List<CategoryDefinition> categories = <CategoryDefinition>[
      ...TransactionCategory.values
          .where(
            (TransactionCategory value) =>
                value.supports(TransactionType.expense),
          )
          .map(catalog.resolve),
      ...catalog.customCategories
          .where(
            (CustomCategory value) => value.type == TransactionType.expense,
          )
          .map((CustomCategory value) => catalog.resolve(value.reference)),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Review your categories')),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: !_initialized
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    key: const ValueKey<String>(
                      'money_plan_category_mapping_list',
                    ),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.pageEnd,
                    ),
                    children: <Widget>[
                      const Text(
                        'These are starting suggestions. Change anything that '
                        'means something different to you.',
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      for (final MoneyPlanGroup group
                          in MoneyPlanGroup.values) ...<Widget>[
                        Text(
                          group.label,
                          key: ValueKey<String>(
                            'money_plan_group_${group.storageValue}',
                          ),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        for (final CategoryDefinition category
                            in categories.where(
                              (CategoryDefinition category) =>
                                  (draft.categoryGroups[category
                                          .reference
                                          .name] ??
                                      MoneyPlanGroup.unassigned) ==
                                  group,
                            ))
                          _CategoryMappingRow(
                            category: category,
                            selected: group,
                            onChanged: (MoneyPlanGroup value) => ref
                                .read(moneyPlanDraftControllerProvider.notifier)
                                .setCategoryGroup(
                                  category.reference.name,
                                  value,
                                ),
                          ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      if (draft.categoryGroups.values
                          .where(
                            (MoneyPlanGroup value) =>
                                value == MoneyPlanGroup.unassigned,
                          )
                          .isNotEmpty)
                        const Text(
                          'Unassigned categories can be reviewed anytime.',
                        ),
                      if (draft.error != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          draft.error!,
                          style: TextStyle(
                            color: context.appColors.destructiveAction,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        key: const ValueKey<String>('save_money_plan'),
                        onPressed: draft.isSaving ? null : _save,
                        child: Text(
                          draft.isSaving
                              ? 'Saving...'
                              : widget.isEditing
                              ? 'Save changes'
                              : 'Start Money Plan',
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final bool saved = await ref
        .read(moneyPlanDraftControllerProvider.notifier)
        .save(ref.read(currentCalendarPeriodProvider));
    if (!mounted || !saved) return;
    ref.read(moneyPlanDraftControllerProvider.notifier).reset();
    context.go(AppRoutes.moneyPlan);
  }
}

final class _CategoryMappingRow extends StatelessWidget {
  const _CategoryMappingRow({
    required this.category,
    required this.selected,
    required this.onChanged,
  });

  final CategoryDefinition category;
  final MoneyPlanGroup selected;
  final ValueChanged<MoneyPlanGroup> onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
    label: '${category.label}, ${selected.label}',
    child: ListTile(
      key: ValueKey<String>('money_plan_category_${category.reference.name}'),
      contentPadding: EdgeInsets.zero,
      leading: Icon(CategoryIconData.forKey(category.iconKey)),
      title: Text(category.label),
      subtitle: category.isArchived ? const Text('Archived') : null,
      trailing: DropdownButton<MoneyPlanGroup>(
        key: ValueKey<String>(
          'money_plan_category_group_${category.reference.name}',
        ),
        value: selected,
        underline: const SizedBox.shrink(),
        onChanged: (MoneyPlanGroup? value) {
          if (value != null) onChanged(value);
        },
        items: <DropdownMenuItem<MoneyPlanGroup>>[
          for (final MoneyPlanGroup group in MoneyPlanGroup.values)
            DropdownMenuItem<MoneyPlanGroup>(
              value: group,
              child: Text(group.label),
            ),
        ],
      ),
    ),
  );
}
