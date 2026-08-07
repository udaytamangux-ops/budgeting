import 'package:budgeting_app/features/transactions/domain/entities/payment_method_metadata.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const Map<PaymentMethod, ({String id, String label})> expected =
      <PaymentMethod, ({String id, String label})>{
        PaymentMethod.cash: (id: 'cash', label: 'Cash'),
        PaymentMethod.bankAccount: (id: 'bank_account', label: 'Bank account'),
        PaymentMethod.card: (id: 'card', label: 'Card'),
        PaymentMethod.eSewa: (id: 'esewa', label: 'eSewa'),
        PaymentMethod.khalti: (id: 'khalti', label: 'Khalti'),
        PaymentMethod.imePay: (id: 'ime_pay', label: 'IME Pay'),
        PaymentMethod.otherDigitalWallet: (
          id: 'other_digital_wallet',
          label: 'Other digital wallet',
        ),
        PaymentMethod.other: (id: 'other', label: 'Other'),
      };

  test('built-ins expose exact stable identifiers and centralized labels', () {
    expect(PaymentMethod.values, expected.keys);
    for (final PaymentMethod method in PaymentMethod.values) {
      expect(method.stableIdentifier, expected[method]!.id);
      expect(method.label, expected[method]!.label);
    }
  });

  test(
    'every stable identifier round-trips through the compatibility codec',
    () {
      for (final PaymentMethod method in PaymentMethod.values) {
        expect(PaymentMethodCodec.decode(method.stableIdentifier), method);
      }
    },
  );

  test('unknown stored identifiers use the neutral Other fallback', () {
    expect(
      PaymentMethodCodec.decode('future_or_malformed_method'),
      PaymentMethod.other,
    );
  });

  test('fresh defaults are type-specific', () {
    expect(TransactionType.expense.defaultPaymentMethod, PaymentMethod.cash);
    expect(
      TransactionType.income.defaultPaymentMethod,
      PaymentMethod.bankAccount,
    );
  });
}
