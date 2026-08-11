enum TransferSource {
  cash,
  bankAccount,
  eSewa,
  khalti,
  imePay,
  otherDigitalWallet,
  other,
}

enum TransferDestination {
  cash,
  bankAccount,
  eSewa,
  khalti,
  imePay,
  otherDigitalWallet,
  person,
  investment,
  other,
}

extension TransferSourceMetadata on TransferSource {
  String get stableIdentifier => switch (this) {
    TransferSource.cash => 'cash',
    TransferSource.bankAccount => 'bank_account',
    TransferSource.eSewa => 'esewa',
    TransferSource.khalti => 'khalti',
    TransferSource.imePay => 'ime_pay',
    TransferSource.otherDigitalWallet => 'other_digital_wallet',
    TransferSource.other => 'other',
  };

  String get label => switch (this) {
    TransferSource.cash => 'Cash',
    TransferSource.bankAccount => 'Bank account',
    TransferSource.eSewa => 'eSewa',
    TransferSource.khalti => 'Khalti',
    TransferSource.imePay => 'IME Pay',
    TransferSource.otherDigitalWallet => 'Other digital wallet',
    TransferSource.other => 'Other',
  };

  static TransferSource? tryParse(String value) {
    for (final TransferSource source in TransferSource.values) {
      if (source.stableIdentifier == value) return source;
    }
    return null;
  }
}

extension TransferDestinationMetadata on TransferDestination {
  String get stableIdentifier => switch (this) {
    TransferDestination.cash => 'cash',
    TransferDestination.bankAccount => 'bank_account',
    TransferDestination.eSewa => 'esewa',
    TransferDestination.khalti => 'khalti',
    TransferDestination.imePay => 'ime_pay',
    TransferDestination.otherDigitalWallet => 'other_digital_wallet',
    TransferDestination.person => 'person',
    TransferDestination.investment => 'investment',
    TransferDestination.other => 'other',
  };

  String get label => switch (this) {
    TransferDestination.cash => 'Cash',
    TransferDestination.bankAccount => 'Bank account',
    TransferDestination.eSewa => 'eSewa',
    TransferDestination.khalti => 'Khalti',
    TransferDestination.imePay => 'IME Pay',
    TransferDestination.otherDigitalWallet => 'Other digital wallet',
    TransferDestination.person => 'Person',
    TransferDestination.investment => 'Investment',
    TransferDestination.other => 'Other',
  };

  bool get requiresName => switch (this) {
    TransferDestination.person ||
    TransferDestination.investment ||
    TransferDestination.other => true,
    _ => false,
  };

  String get destinationFieldLabel => switch (this) {
    TransferDestination.person => 'Person name',
    TransferDestination.investment => 'Investment name',
    TransferDestination.other => 'Destination',
    _ => 'Destination',
  };

  static TransferDestination? tryParse(String value) {
    for (final TransferDestination destination in TransferDestination.values) {
      if (destination.stableIdentifier == value) return destination;
    }
    return null;
  }
}
