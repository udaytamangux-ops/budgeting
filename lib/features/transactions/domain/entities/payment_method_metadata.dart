import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';

extension PaymentMethodMetadata on PaymentMethod {
  String get stableIdentifier => switch (this) {
    PaymentMethod.cash => 'cash',
    PaymentMethod.bankAccount => 'bank_account',
    PaymentMethod.card => 'card',
    PaymentMethod.eSewa => 'esewa',
    PaymentMethod.khalti => 'khalti',
    PaymentMethod.imePay => 'ime_pay',
    PaymentMethod.otherDigitalWallet => 'other_digital_wallet',
    PaymentMethod.other => 'other',
  };

  String get label => switch (this) {
    PaymentMethod.cash => 'Cash',
    PaymentMethod.bankAccount => 'Bank account',
    PaymentMethod.card => 'Card',
    PaymentMethod.eSewa => 'eSewa',
    PaymentMethod.khalti => 'Khalti',
    PaymentMethod.imePay => 'IME Pay',
    PaymentMethod.otherDigitalWallet => 'Other digital wallet',
    PaymentMethod.other => 'Other',
  };
}

extension TransactionTypePaymentMethodDefault on TransactionType {
  PaymentMethod get defaultPaymentMethod => switch (this) {
    TransactionType.expense => PaymentMethod.cash,
    TransactionType.income => PaymentMethod.bankAccount,
  };
}

abstract final class PaymentMethodCodec {
  static PaymentMethod decode(String stableIdentifier) {
    return switch (stableIdentifier) {
      'cash' => PaymentMethod.cash,
      'bank_account' => PaymentMethod.bankAccount,
      'card' => PaymentMethod.card,
      'esewa' => PaymentMethod.eSewa,
      'khalti' => PaymentMethod.khalti,
      'ime_pay' => PaymentMethod.imePay,
      'other_digital_wallet' => PaymentMethod.otherDigitalWallet,
      'other' => PaymentMethod.other,
      _ => PaymentMethod.other,
    };
  }
}
