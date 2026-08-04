import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/session_payment_method_controller.dart';
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

  test(
    'Repeat draft uses original values, Today, and creates a new record',
    () async {
      final FinancialTransaction original = buildTestTransaction(
        id: 'original',
        occurredAt: DateTime.utc(2026, 7, 30, 6, 15),
      );
      final _MockTransactionRepository repository =
          _MockTransactionRepository();
      when(() => repository.createTransaction(any())).thenAnswer((_) async {});
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          appClockProvider.overrideWithValue(() => fixedNow),
          transactionRepositoryProvider.overrideWithValue(repository),
          initialTransactionProvider.overrideWithValue(original),
          transactionFormIntentProvider.overrideWithValue(
            TransactionFormIntent.repeat,
          ),
        ],
      );
      addTearDown(container.dispose);
      final ProviderSubscription<AddTransactionState> subscription = container
          .listen(addTransactionControllerProvider, (_, _) {});
      addTearDown(subscription.close);

      final AddTransactionState draft = container.read(
        addTransactionControllerProvider,
      );
      expect(draft.isRepeatDraft, isTrue);
      expect(draft.isEditing, isFalse);
      expect(draft.amountInput, '1250');
      expect(draft.selectedCategory, original.category);
      expect(draft.paymentMethod, original.paymentMethod);
      expect(draft.merchant, original.merchant);
      expect(draft.note, original.note);
      expect(draft.occurredDate.year, fixedNow.toLocal().year);
      expect(draft.occurredDate.month, fixedNow.toLocal().month);
      expect(draft.occurredDate.day, fixedNow.toLocal().day);

      final FinancialTransaction? repeated = await container
          .read(addTransactionControllerProvider.notifier)
          .submit();

      expect(repeated, isNotNull);
      expect(repeated!.id, isNot(original.id));
      expect(original.occurredAt, DateTime.utc(2026, 7, 30, 6, 15));
      final VerificationResult verification = verify(
        () => repository.createTransaction(captureAny()),
      );
      verification.called(1);
      expect(
        (verification.captured.single as FinancialTransaction).id,
        repeated.id,
      );
      verifyNever(() => repository.updateTransaction(any()));
    },
  );

  test('new Income reuses only the remembered Income payment method', () {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        appClockProvider.overrideWithValue(() => fixedNow),
        initialTransactionTypeProvider.overrideWithValue(
          TransactionType.income,
        ),
      ],
    );
    addTearDown(container.dispose);
    container
        .read(sessionPaymentMethodProvider.notifier)
        .remember(TransactionType.expense, PaymentMethod.eSewa);
    container
        .read(sessionPaymentMethodProvider.notifier)
        .remember(TransactionType.income, PaymentMethod.bankAccount);
    final ProviderSubscription<AddTransactionState> subscription = container
        .listen(addTransactionControllerProvider, (_, _) {});
    addTearDown(subscription.close);

    final AddTransactionState state = container.read(
      addTransactionControllerProvider,
    );
    expect(state.type, TransactionType.income);
    expect(state.paymentMethod, PaymentMethod.bankAccount);
  });
}
