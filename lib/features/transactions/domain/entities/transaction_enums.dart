enum TransactionType { expense, income }

enum PaymentMethod {
  cash,
  bankAccount,
  card,
  eSewa,
  khalti,
  imePay,
  otherDigitalWallet,
  other,
}

enum TransactionCategory {
  food,
  transport,
  rentAndHousing,
  utilities,
  shopping,
  health,
  education,
  entertainment,
  family,
  salary,
  freelance,
  business,
  allowance,
  remittance,
  gift,
  refund,
  other,
}

extension TransactionCategoryRules on TransactionCategory {
  bool supports(TransactionType type) {
    return switch (this) {
      TransactionCategory.food ||
      TransactionCategory.transport ||
      TransactionCategory.rentAndHousing ||
      TransactionCategory.utilities ||
      TransactionCategory.shopping ||
      TransactionCategory.health ||
      TransactionCategory.education ||
      TransactionCategory.entertainment ||
      TransactionCategory.family => type == TransactionType.expense,
      TransactionCategory.salary ||
      TransactionCategory.freelance ||
      TransactionCategory.business ||
      TransactionCategory.allowance ||
      TransactionCategory.remittance ||
      TransactionCategory.gift ||
      TransactionCategory.refund => type == TransactionType.income,
      TransactionCategory.other => true,
    };
  }
}
