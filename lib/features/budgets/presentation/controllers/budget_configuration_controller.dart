import 'package:budgeting_app/features/budgets/domain/entities/budget_configuration.dart';
import 'package:budgeting_app/features/budgets/domain/services/budget_policy.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final NotifierProvider<BudgetConfigurationController, BudgetConfiguration>
budgetConfigurationProvider =
    NotifierProvider<BudgetConfigurationController, BudgetConfiguration>(
      BudgetConfigurationController.new,
    );

final class BudgetConfigurationController
    extends Notifier<BudgetConfiguration> {
  @override
  BudgetConfiguration build() {
    return BudgetConfiguration(
      monthlyLimit: BudgetPolicy.monthlyLimit,
      categoryLimits: BudgetPolicy.categoryLimits,
    );
  }

  void updateMonthlyLimit(Money limit) {
    if (!limit.isPositive) {
      return;
    }
    state = state.copyWith(monthlyLimit: limit);
  }

  void setCategoryLimit(TransactionCategory category, Money limit) {
    if (!category.supports(TransactionType.expense) || !limit.isPositive) {
      return;
    }
    state = state.copyWith(
      categoryLimits: <TransactionCategory, Money>{
        ...state.categoryLimits,
        category: limit,
      },
    );
  }
}
