import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

abstract final class BudgetPolicy {
  static const Money monthlyLimit = Money(minorUnits: 4000000);

  static const Map<TransactionCategory, Money> categoryLimits =
      <TransactionCategory, Money>{
        TransactionCategory.food: Money(minorUnits: 800000),
        TransactionCategory.transport: Money(minorUnits: 400000),
        TransactionCategory.rentAndHousing: Money(minorUnits: 1000000),
        TransactionCategory.utilities: Money(minorUnits: 350000),
        TransactionCategory.shopping: Money(minorUnits: 300000),
        TransactionCategory.health: Money(minorUnits: 250000),
        TransactionCategory.entertainment: Money(minorUnits: 250000),
      };
}
