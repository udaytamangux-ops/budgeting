import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

abstract final class BudgetPolicy {
  static const Money monthlyLimit = Money(minorUnits: 4000000);

  static final Map<TransactionCategory, Money> categoryLimits =
      <TransactionCategory, Money>{
        TransactionCategory.food: const Money(minorUnits: 800000),
        TransactionCategory.transport: const Money(minorUnits: 400000),
        TransactionCategory.rentAndHousing: const Money(minorUnits: 1000000),
        TransactionCategory.utilities: const Money(minorUnits: 350000),
        TransactionCategory.shopping: const Money(minorUnits: 300000),
        TransactionCategory.health: const Money(minorUnits: 250000),
        TransactionCategory.entertainment: const Money(minorUnits: 250000),
      };
}
