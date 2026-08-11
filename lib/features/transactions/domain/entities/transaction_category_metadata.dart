import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

extension TransactionCategoryMetadata on TransactionCategory {
  String get displayLabel => switch (this) {
    TransactionCategory.food => 'Food',
    TransactionCategory.transport => 'Transport',
    TransactionCategory.rentAndHousing => 'Rent & Housing',
    TransactionCategory.utilities => 'Utilities',
    TransactionCategory.shopping => 'Shopping',
    TransactionCategory.health => 'Health',
    TransactionCategory.education => 'Education',
    TransactionCategory.entertainment => 'Entertainment',
    TransactionCategory.family => 'Family',
    TransactionCategory.feesAndCharges => 'Fees & Charges',
    TransactionCategory.salary => 'Salary',
    TransactionCategory.freelance => 'Freelance',
    TransactionCategory.business => 'Business',
    TransactionCategory.allowance => 'Allowance',
    TransactionCategory.remittance => 'Remittance',
    TransactionCategory.gift => 'Gift',
    TransactionCategory.refund => 'Refund',
    TransactionCategory.other => 'Other',
  };
}
