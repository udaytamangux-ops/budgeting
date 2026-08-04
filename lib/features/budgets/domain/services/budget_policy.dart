import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

abstract final class BudgetPolicy {
  static const Money monthlyLimit = Money(minorUnits: 4000000);

  static const Map<TransactionCategory, Money> categoryLimits =
      <TransactionCategory, Money>{
        TransactionCategory.food: Money(minorUnits: 800000),
      };
}
