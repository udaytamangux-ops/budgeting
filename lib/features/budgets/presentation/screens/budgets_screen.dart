import 'dart:async';

import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/app/theme/app_typography.dart';
import 'package:budgeting_app/core/formatting/currency_formatter.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/core/widgets/app_loading_indicator.dart';
import 'package:budgeting_app/core/widgets/empty_state.dart';
import 'package:budgeting_app/features/budgets/domain/entities/budget_configuration.dart';
import 'package:budgeting_app/features/budgets/domain/entities/monthly_budget_summary.dart';
import 'package:budgeting_app/features/budgets/presentation/controllers/budget_configuration_controller.dart';
import 'package:budgeting_app/features/budgets/presentation/widgets/budget_amount_dialog.dart';
import 'package:budgeting_app/features/budgets/presentation/widgets/budget_progress_indicator.dart';
import 'package:budgeting_app/features/budgets/presentation/widgets/category_budget_item.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

final class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final DateTime current = ref.read(currentDateProvider);
    _selectedMonth = DateTime(current.year, current.month);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<MonthlyBudgetSummary> budget = ref.watch(
      monthlyBudgetSummaryForMonthProvider(_selectedMonth),
    );
    final BudgetConfiguration configuration = ref.watch(
      budgetConfigurationProvider,
    );
    final DateTime currentDate = ref.watch(currentDateProvider);
    final CurrencyFormatter currencyFormatter = ref.watch(
      currencyFormatterProvider,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: budget.when(
              loading: () =>
                  const AppLoadingIndicator(label: 'Loading monthly budget'),
              error: (Object error, StackTrace stackTrace) => AppErrorState(
                message: 'Your budget is unavailable. Try again.',
                onRetry: () => ref.invalidate(transactionListProvider),
              ),
              data: (MonthlyBudgetSummary value) {
                if (!value.hasBudget) {
                  return const EmptyState(
                    title: 'No monthly budget',
                    message:
                        'Set a monthly limit to understand how much is safe '
                        'to spend.',
                    icon: Icons.track_changes_outlined,
                  );
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.navigationClearance,
                  ),
                  children: <Widget>[
                    _MonthSelector(
                      label: ref
                          .watch(dateFormatterProvider)
                          .monthYear(_selectedMonth),
                      onPrevious: () => _changeMonth(-1),
                      onNext: _isCurrentMonth(currentDate)
                          ? null
                          : () => _changeMonth(1),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _SectionHeader(
                      title: 'Monthly overview',
                      action: TextButton.icon(
                        key: const ValueKey<String>('edit_monthly_budget'),
                        onPressed: () {
                          unawaited(
                            _editMonthlyBudget(configuration.monthlyLimit),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Edit budget'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfacePrimary,
                        border: Border.all(color: AppColors.borderSubtle),
                        borderRadius: BorderRadius.circular(AppRadius.medium),
                      ),
                      child: BudgetProgressIndicator(
                        summary: value,
                        currencyFormatter: currencyFormatter,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _UnallocatedBudget(
                      amount: value.unallocatedBudget,
                      currencyFormatter: currencyFormatter,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    _SectionHeader(
                      title: 'Category budgets',
                      action: TextButton.icon(
                        key: const ValueKey<String>('add_category_budget'),
                        onPressed: () {
                          unawaited(_addCategoryBudget(configuration));
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add category'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ...value.categories.expand(
                      (CategoryBudgetProgress category) => <Widget>[
                        CategoryBudgetItem(
                          progress: category,
                          currencyFormatter: currencyFormatter,
                        ),
                        const Divider(),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + offset,
      );
    });
  }

  bool _isCurrentMonth(DateTime currentDate) {
    return _selectedMonth.year == currentDate.year &&
        _selectedMonth.month == currentDate.month;
  }

  Future<void> _editMonthlyBudget(Money currentLimit) async {
    final BudgetAmountResult? result = await showDialog<BudgetAmountResult>(
      context: context,
      builder: (BuildContext dialogContext) => BudgetAmountDialog(
        title: 'Edit monthly budget',
        confirmLabel: 'Save budget',
        initialAmount: currentLimit,
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    ref
        .read(budgetConfigurationProvider.notifier)
        .updateMonthlyLimit(result.amount);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Monthly budget updated for this session.')),
    );
  }

  Future<void> _addCategoryBudget(BudgetConfiguration configuration) async {
    final List<TransactionCategory> available = TransactionCategory.values
        .where(
          (TransactionCategory category) =>
              category.supports(TransactionType.expense) &&
              !configuration.categoryLimits.containsKey(category),
        )
        .toList(growable: false);
    if (available.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All expense categories have a budget.')),
      );
      return;
    }
    final BudgetAmountResult? result = await showDialog<BudgetAmountResult>(
      context: context,
      builder: (BuildContext dialogContext) => BudgetAmountDialog(
        title: 'Add category budget',
        confirmLabel: 'Add budget',
        availableCategories: available,
      ),
    );
    final TransactionCategory? category = result?.category;
    if (result == null || category == null || !mounted) {
      return;
    }
    ref
        .read(budgetConfigurationProvider.notifier)
        .setCategoryLimit(category, result.amount);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${category.visual.label} budget added for this session.',
        ),
      ),
    );
  }
}

final class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          tooltip: 'Previous month',
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        IconButton(
          tooltip: 'Next month',
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

final class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.action});

  final String title;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool shouldStack =
            constraints.maxWidth < 360 ||
            MediaQuery.textScalerOf(context).scale(14) > 20;
        final Widget heading = Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        );
        if (shouldStack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              heading,
              const SizedBox(height: AppSpacing.xs),
              action,
            ],
          );
        }
        return Row(
          children: <Widget>[
            Expanded(child: heading),
            action,
          ],
        );
      },
    );
  }
}

final class _UnallocatedBudget extends StatelessWidget {
  const _UnallocatedBudget({
    required this.amount,
    required this.currencyFormatter,
  });

  final Money amount;
  final CurrencyFormatter currencyFormatter;

  @override
  Widget build(BuildContext context) {
    final bool isOverAllocated = amount.isNegative;
    final String formatted = currencyFormatter.format(amount.absolute);
    final Color foreground = isOverAllocated
        ? AppColors.destructiveAction
        : AppColors.textPrimary;
    final Widget label = Row(
      children: <Widget>[
        Icon(
          isOverAllocated
              ? Icons.error_outline
              : Icons.account_balance_wallet_outlined,
          color: isOverAllocated
              ? AppColors.destructiveAction
              : AppColors.textSecondary,
          size: 20,
        ),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            isOverAllocated
                ? 'Category limits exceed the monthly budget'
                : 'Unallocated monthly budget',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
    final Widget value = Text(
      formatted,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: foreground,
        fontFeatures: AppTypography.tabularFigures,
      ),
    );
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool shouldStack =
            constraints.maxWidth < 360 ||
            MediaQuery.textScalerOf(context).scale(14) > 20;
        if (shouldStack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              label,
              const SizedBox(height: AppSpacing.xs),
              value,
            ],
          );
        }
        return Row(
          children: <Widget>[
            Expanded(child: label),
            const SizedBox(width: AppSpacing.sm),
            value,
          ],
        );
      },
    );
  }
}
