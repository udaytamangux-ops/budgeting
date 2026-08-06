import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/formatting/currency_formatter.dart';
import 'package:budgeting_app/core/widgets/empty_state.dart';
import 'package:budgeting_app/features/summary/domain/entities/monthly_category_activity.dart';
import 'package:budgeting_app/features/summary/presentation/widgets/spending_donut_chart.dart';
import 'package:budgeting_app/features/summary/presentation/widgets/summary_record_row.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_type_selector.dart';
import 'package:flutter/material.dart';

final class CategoryExplorationSection extends StatelessWidget {
  const CategoryExplorationSection({
    required this.activity,
    required this.monthName,
    required this.selectedGroupKey,
    required this.currencyFormatter,
    required this.onTypeChanged,
    required this.onGroupSelected,
    required this.onAllCategoriesSelected,
    required this.onViewTransactions,
    required this.onAddTransaction,
    super.key,
  });

  final MonthlyCategoryActivity activity;
  final String monthName;
  final String? selectedGroupKey;
  final CurrencyFormatter currencyFormatter;
  final ValueChanged<TransactionType> onTypeChanged;
  final ValueChanged<CategoryActivityGroup> onGroupSelected;
  final VoidCallback onAllCategoriesSelected;
  final ValueChanged<CategoryActivityGroup> onViewTransactions;
  final ValueChanged<TransactionType> onAddTransaction;

  @override
  Widget build(BuildContext context) {
    final bool isExpense = activity.type == TransactionType.expense;
    final CategoryActivityGroup? selectedGroup = _selectedGroup;
    final String sectionTitle = isExpense
        ? 'Where your money went'
        : 'Where income came from';
    final String breakdownTitle = isExpense
        ? 'Category breakdown'
        : 'Income source breakdown';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(sectionTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: AppSpacing.md),
        TransactionTypeSelector(
          value: activity.type,
          isEnabled: true,
          onChanged: onTypeChanged,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (activity.groups.isEmpty)
          EmptyState(
            key: ValueKey<String>(
              isExpense ? 'summary_empty_expenses' : 'summary_empty_income',
            ),
            title: isExpense
                ? 'No recorded expenses in $monthName'
                : 'No recorded income in $monthName',
            message: isExpense
                ? 'Expenses recorded for this month will appear here by '
                      'category.'
                : 'Income recorded for this month will appear here by source.',
            icon: isExpense
                ? Icons.receipt_long_outlined
                : Icons.account_balance_wallet_outlined,
            action: FilledButton.icon(
              key: ValueKey<String>(
                isExpense
                    ? 'summary_empty_add_expense'
                    : 'summary_empty_add_income',
              ),
              onPressed: () => onAddTransaction(activity.type),
              icon: const Icon(Icons.add),
              label: Text(isExpense ? 'Add expense' : 'Add income'),
            ),
          )
        else ...<Widget>[
          Center(
            child: SpendingDonutChart(
              groups: activity.groups,
              total: activity.total,
              type: activity.type,
              currencyFormatter: currencyFormatter,
              selectedGroupKey: selectedGroupKey,
              onGroupSelected: onGroupSelected,
            ),
          ),
          _SelectionActions(
            selectedGroup: selectedGroup,
            onAllCategoriesSelected: onAllCategoriesSelected,
            onViewTransactions: onViewTransactions,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(breakdownTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          for (int index = 0; index < activity.groups.length; index += 1) ...[
            _CategoryActivityRow(
              group: activity.groups[index],
              type: activity.type,
              currencyFormatter: currencyFormatter,
              isSelected:
                  activity.groups[index].selectionKey == selectedGroupKey,
              onTap: () => onGroupSelected(activity.groups[index]),
            ),
            if (index < activity.groups.length - 1) const Divider(),
          ],
        ],
      ],
    );
  }

  CategoryActivityGroup? get _selectedGroup {
    for (final CategoryActivityGroup group in activity.groups) {
      if (group.selectionKey == selectedGroupKey) {
        return group;
      }
    }
    return null;
  }
}

final class _SelectionActions extends StatelessWidget {
  const _SelectionActions({
    required this.selectedGroup,
    required this.onAllCategoriesSelected,
    required this.onViewTransactions,
  });

  final CategoryActivityGroup? selectedGroup;
  final VoidCallback onAllCategoriesSelected;
  final ValueChanged<CategoryActivityGroup> onViewTransactions;

  @override
  Widget build(BuildContext context) {
    final CategoryActivityGroup? group = selectedGroup;
    final Widget content = group == null
        ? const SizedBox.shrink(key: ValueKey<String>('no_category_actions'))
        : Padding(
            key: const ValueKey<String>('selected_category_actions'),
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              alignment: WrapAlignment.end,
              children: <Widget>[
                OutlinedButton.icon(
                  key: const ValueKey<String>('all_categories_button'),
                  onPressed: onAllCategoriesSelected,
                  icon: const Icon(Icons.donut_large_outlined),
                  label: const Text('All categories'),
                ),
                FilledButton.icon(
                  key: const ValueKey<String>(
                    'view_category_transactions_button',
                  ),
                  onPressed: () => onViewTransactions(group),
                  icon: const Icon(Icons.receipt_long_outlined),
                  label: const Text('View transactions'),
                ),
              ],
            ),
          );

    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) {
      return content;
    }
    return AnimatedSize(duration: AppMotion.fast, child: content);
  }
}

final class _CategoryActivityRow extends StatelessWidget {
  const _CategoryActivityRow({
    required this.group,
    required this.type,
    required this.currencyFormatter,
    required this.isSelected,
    required this.onTap,
  });

  final CategoryActivityGroup group;
  final TransactionType type;
  final CurrencyFormatter currencyFormatter;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SummaryRecordRow(
      key: ValueKey<String>('summary_category_row_${group.selectionKey}'),
      label: group.displayLabel,
      value: currencyFormatter.format(group.amount),
      supportingText:
          '${group.sharePercentage}% of recorded '
          '${type == TransactionType.expense ? 'expenses' : 'income'}',
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: group.displaySurface,
          shape: BoxShape.circle,
        ),
        child: Icon(group.displayIcon, color: group.displayAccent, size: 20),
      ),
      onTap: onTap,
      isSelected: isSelected,
    );
  }
}
