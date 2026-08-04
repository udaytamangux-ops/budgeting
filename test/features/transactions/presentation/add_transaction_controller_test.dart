import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../support/test_data.dart';

final class _MockTransactionRepository extends Mock
    implements TransactionRepository {}

void main() {
  setUpAll(() => registerFallbackValue(buildTestTransaction()));

  test('maps validated form input and calls repository once', () async {
    final _MockTransactionRepository repository = _MockTransactionRepository();
    when(() => repository.createTransaction(any())).thenAnswer((_) async {});
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        appClockProvider.overrideWithValue(() => fixedNow),
        transactionRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final ProviderSubscription<AddTransactionState> subscription = container
        .listen(addTransactionControllerProvider, (_, _) {});
    addTearDown(subscription.close);
    final AddTransactionController controller = container.read(
      addTransactionControllerProvider.notifier,
    );

    controller.updateAmount('1250');
    controller.selectCategory(TransactionCategory.food);
    final FinancialTransaction? saved = await controller.submit();

    expect(saved, isNotNull);
    expect(saved!.amount.minorUnits, 125000);
    expect(saved.category, TransactionCategory.food);
    expect(saved.paymentMethod, PaymentMethod.cash);
    verify(() => repository.createTransaction(any())).called(1);
  });
}
