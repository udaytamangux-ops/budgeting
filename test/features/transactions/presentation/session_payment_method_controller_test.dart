import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/session_payment_method_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('remembers expense and income payment methods independently', () {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final SessionPaymentMethodController controller = container.read(
      sessionPaymentMethodProvider.notifier,
    );

    controller.remember(TransactionType.expense, PaymentMethod.eSewa);
    controller.remember(TransactionType.income, PaymentMethod.bankAccount);

    expect(
      container
          .read(sessionPaymentMethodProvider)
          .forType(TransactionType.expense),
      PaymentMethod.eSewa,
    );
    expect(
      container
          .read(sessionPaymentMethodProvider)
          .forType(TransactionType.income),
      PaymentMethod.bankAccount,
    );
  });

  test('a fresh application container starts without remembered values', () {
    final ProviderContainer firstSession = ProviderContainer();
    firstSession
        .read(sessionPaymentMethodProvider.notifier)
        .remember(TransactionType.expense, PaymentMethod.khalti);
    firstSession.dispose();

    final ProviderContainer freshSession = ProviderContainer();
    addTearDown(freshSession.dispose);

    expect(
      freshSession
          .read(sessionPaymentMethodProvider)
          .forType(TransactionType.expense),
      isNull,
    );
    expect(
      freshSession
          .read(sessionPaymentMethodProvider)
          .forType(TransactionType.income),
      isNull,
    );
  });
}
