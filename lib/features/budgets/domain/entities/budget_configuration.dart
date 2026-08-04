import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

final class BudgetConfiguration {
  BudgetConfiguration({
    required this.monthlyLimit,
    required Map<TransactionCategory, Money> categoryLimits,
  }) : categoryLimits = Map<TransactionCategory, Money>.unmodifiable(
         categoryLimits,
       );

  final Money monthlyLimit;
  final Map<TransactionCategory, Money> categoryLimits;

  BudgetConfiguration copyWith({
    Money? monthlyLimit,
    Map<TransactionCategory, Money>? categoryLimits,
  }) {
    return BudgetConfiguration(
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      categoryLimits: categoryLimits ?? this.categoryLimits,
    );
  }
}
