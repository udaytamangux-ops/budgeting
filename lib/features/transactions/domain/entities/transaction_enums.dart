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

/// Stable category identity used by financial records.
///
/// System categories remain compile-time constants with their original stored
/// identifiers. Custom categories use `custom:<uuid>` identifiers and are
/// resolved to owner-scoped metadata by the category catalog.
final class TransactionCategory {
  const TransactionCategory._(this.name, this.systemLabel, this._supportedType);

  factory TransactionCategory.custom(
    String identifier, {
    required TransactionType type,
  }) {
    if (!isCustomIdentifier(identifier)) {
      throw ArgumentError.value(identifier, 'identifier');
    }
    return TransactionCategory._(identifier, null, type);
  }

  final String name;
  final String? systemLabel;
  final TransactionType? _supportedType;

  bool get isCustom => isCustomIdentifier(name);
  bool get isSystem => !isCustom;
  int get index => values.indexOf(this);

  bool supports(TransactionType type) =>
      _supportedType == null || _supportedType == type;

  static bool isCustomIdentifier(String value) =>
      value.startsWith('custom:') && value.length > 'custom:'.length;

  static const TransactionCategory food = TransactionCategory._(
    'food',
    'Food',
    TransactionType.expense,
  );
  static const TransactionCategory transport = TransactionCategory._(
    'transport',
    'Transport',
    TransactionType.expense,
  );
  static const TransactionCategory rentAndHousing = TransactionCategory._(
    'rent_and_housing',
    'Rent & Housing',
    TransactionType.expense,
  );
  static const TransactionCategory utilities = TransactionCategory._(
    'utilities',
    'Utilities',
    TransactionType.expense,
  );
  static const TransactionCategory shopping = TransactionCategory._(
    'shopping',
    'Shopping',
    TransactionType.expense,
  );
  static const TransactionCategory health = TransactionCategory._(
    'health',
    'Health',
    TransactionType.expense,
  );
  static const TransactionCategory education = TransactionCategory._(
    'education',
    'Education',
    TransactionType.expense,
  );
  static const TransactionCategory entertainment = TransactionCategory._(
    'entertainment',
    'Entertainment',
    TransactionType.expense,
  );
  static const TransactionCategory family = TransactionCategory._(
    'family',
    'Family',
    TransactionType.expense,
  );
  static const TransactionCategory feesAndCharges = TransactionCategory._(
    'fees_and_charges',
    'Fees & Charges',
    TransactionType.expense,
  );
  static const TransactionCategory salary = TransactionCategory._(
    'salary',
    'Salary',
    TransactionType.income,
  );
  static const TransactionCategory freelance = TransactionCategory._(
    'freelance',
    'Freelance',
    TransactionType.income,
  );
  static const TransactionCategory business = TransactionCategory._(
    'business',
    'Business',
    TransactionType.income,
  );
  static const TransactionCategory allowance = TransactionCategory._(
    'allowance',
    'Allowance',
    TransactionType.income,
  );
  static const TransactionCategory remittance = TransactionCategory._(
    'remittance',
    'Remittance',
    TransactionType.income,
  );
  static const TransactionCategory gift = TransactionCategory._(
    'gift',
    'Gift',
    TransactionType.income,
  );
  static const TransactionCategory refund = TransactionCategory._(
    'refund',
    'Refund',
    TransactionType.income,
  );
  static const TransactionCategory other = TransactionCategory._(
    'other',
    'Other',
    null,
  );

  static const List<TransactionCategory> values = <TransactionCategory>[
    food,
    transport,
    rentAndHousing,
    utilities,
    shopping,
    health,
    education,
    entertainment,
    family,
    feesAndCharges,
    salary,
    freelance,
    business,
    allowance,
    remittance,
    gift,
    refund,
    other,
  ];

  static TransactionCategory? systemFromIdentifier(String identifier) {
    for (final TransactionCategory category in values) {
      if (category.name == identifier) return category;
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      other is TransactionCategory && other.name == name;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'TransactionCategory($name)';
}
