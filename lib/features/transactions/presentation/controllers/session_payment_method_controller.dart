import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class SessionPaymentMethodState {
  const SessionPaymentMethodState({
    this.expensePaymentMethod,
    this.incomePaymentMethod,
  });

  final PaymentMethod? expensePaymentMethod;
  final PaymentMethod? incomePaymentMethod;

  PaymentMethod? forType(TransactionType type) {
    return switch (type) {
      TransactionType.expense => expensePaymentMethod,
      TransactionType.income => incomePaymentMethod,
    };
  }

  SessionPaymentMethodState copyWith({
    PaymentMethod? expensePaymentMethod,
    PaymentMethod? incomePaymentMethod,
  }) {
    return SessionPaymentMethodState(
      expensePaymentMethod: expensePaymentMethod ?? this.expensePaymentMethod,
      incomePaymentMethod: incomePaymentMethod ?? this.incomePaymentMethod,
    );
  }
}

final NotifierProvider<
  SessionPaymentMethodController,
  SessionPaymentMethodState
>
sessionPaymentMethodProvider =
    NotifierProvider<SessionPaymentMethodController, SessionPaymentMethodState>(
      SessionPaymentMethodController.new,
    );

final class SessionPaymentMethodController
    extends Notifier<SessionPaymentMethodState> {
  @override
  SessionPaymentMethodState build() => const SessionPaymentMethodState();

  void remember(TransactionType type, PaymentMethod paymentMethod) {
    state = switch (type) {
      TransactionType.expense => state.copyWith(
        expensePaymentMethod: paymentMethod,
      ),
      TransactionType.income => state.copyWith(
        incomePaymentMethod: paymentMethod,
      ),
    };
  }
}
