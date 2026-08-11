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
        recentPaymentMethodsProvider.overrideWith(
          (Ref ref, TransactionType type) =>
              const AsyncValue<List<PaymentMethod>>.data(<PaymentMethod>[]),
        ),
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

  test('fresh forms use type-specific payment method defaults', () {
    ProviderContainer buildContainer(TransactionType type) {
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          appClockProvider.overrideWithValue(() => fixedNow),
          initialTransactionTypeProvider.overrideWithValue(type),
          recentPaymentMethodsProvider.overrideWith(
            (Ref ref, TransactionType type) =>
                const AsyncValue<List<PaymentMethod>>.data(<PaymentMethod>[]),
          ),
        ],
      );
      addTearDown(container.dispose);
      return container;
    }

    final ProviderContainer expenseContainer = buildContainer(
      TransactionType.expense,
    );
    final ProviderContainer incomeContainer = buildContainer(
      TransactionType.income,
    );

    expect(
      expenseContainer.read(addTransactionControllerProvider).paymentMethod,
      PaymentMethod.cash,
    );
    expect(
      incomeContainer.read(addTransactionControllerProvider).paymentMethod,
      PaymentMethod.bankAccount,
    );
  });

  test('new Income uses its own most recent persisted method', () {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        appClockProvider.overrideWithValue(() => fixedNow),
        initialTransactionTypeProvider.overrideWithValue(
          TransactionType.income,
        ),
        recentPaymentMethodsProvider.overrideWith(
          (Ref ref, TransactionType type) =>
              AsyncValue<List<PaymentMethod>>.data(
                type == TransactionType.expense
                    ? const <PaymentMethod>[PaymentMethod.eSewa]
                    : const <PaymentMethod>[PaymentMethod.khalti],
              ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final ProviderSubscription<AddTransactionState> subscription = container
        .listen(addTransactionControllerProvider, (_, _) {});
    addTearDown(subscription.close);

    final AddTransactionState state = container.read(
      addTransactionControllerProvider,
    );
    expect(state.type, TransactionType.income);
    expect(state.paymentMethod, PaymentMethod.khalti);
  });

  test('Add Income persists the selected payment method', () async {
    final _MockTransactionRepository repository = _MockTransactionRepository();
    when(() => repository.createTransaction(any())).thenAnswer((_) async {});
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        appClockProvider.overrideWithValue(() => fixedNow),
        transactionRepositoryProvider.overrideWithValue(repository),
        initialTransactionTypeProvider.overrideWithValue(
          TransactionType.income,
        ),
        recentPaymentMethodsProvider.overrideWith(
          (Ref ref, TransactionType type) =>
              const AsyncValue<List<PaymentMethod>>.data(<PaymentMethod>[]),
        ),
      ],
    );
    addTearDown(container.dispose);
    final AddTransactionController controller = container.read(
      addTransactionControllerProvider.notifier,
    );

    controller.updateAmount('45000');
    controller.selectCategory(TransactionCategory.salary);
    controller.updatePaymentMethod(PaymentMethod.imePay);
    await controller.submit();

    final VerificationResult verification = verify(
      () => repository.createTransaction(captureAny()),
    );
    verification.called(1);
    final FinancialTransaction saved =
        verification.captured.single as FinancialTransaction;
    expect(saved.type, TransactionType.income);
    expect(saved.paymentMethod, PaymentMethod.imePay);
  });

  test('other form changes do not reset the selected payment method', () {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        appClockProvider.overrideWithValue(() => fixedNow),
        recentPaymentMethodsProvider.overrideWith(
          (Ref ref, TransactionType type) =>
              const AsyncValue<List<PaymentMethod>>.data(<PaymentMethod>[]),
        ),
      ],
    );
    addTearDown(container.dispose);
    final AddTransactionController controller = container.read(
      addTransactionControllerProvider.notifier,
    );

    controller.updatePaymentMethod(PaymentMethod.otherDigitalWallet);
    controller.selectCategory(TransactionCategory.food);
    controller.updateOccurredDate(DateTime(2026, 8, 3));
    controller.updateMerchant('Local merchant');
    controller.updateNote('Manual record');

    expect(
      container.read(addTransactionControllerProvider).paymentMethod,
      PaymentMethod.otherDigitalWallet,
    );
  });

  test('new draft type changes use that type persisted history', () {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        appClockProvider.overrideWithValue(() => fixedNow),
        recentPaymentMethodsProvider.overrideWith(
          (Ref ref, TransactionType type) =>
              AsyncValue<List<PaymentMethod>>.data(
                type == TransactionType.expense
                    ? const <PaymentMethod>[PaymentMethod.eSewa]
                    : const <PaymentMethod>[PaymentMethod.imePay],
              ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final AddTransactionController controller = container.read(
      addTransactionControllerProvider.notifier,
    );
    expect(
      container.read(addTransactionControllerProvider).paymentMethod,
      PaymentMethod.eSewa,
    );

    controller.updateType(TransactionType.income);

    expect(
      container.read(addTransactionControllerProvider).paymentMethod,
      PaymentMethod.imePay,
    );
  });

  test('new transactions reject a future occurrence date', () async {
    final _MockTransactionRepository repository = _MockTransactionRepository();
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        appClockProvider.overrideWithValue(() => fixedNow),
        transactionRepositoryProvider.overrideWithValue(repository),
        recentPaymentMethodsProvider.overrideWith(
          (Ref ref, TransactionType type) =>
              const AsyncValue<List<PaymentMethod>>.data(<PaymentMethod>[]),
        ),
      ],
    );
    addTearDown(container.dispose);
    final AddTransactionController controller = container.read(
      addTransactionControllerProvider.notifier,
    );
    controller
      ..updateAmount('100')
      ..selectCategory(TransactionCategory.food)
      ..updateOccurredDate(DateTime(2026, 8, 5));

    final AddTransactionState state = container.read(
      addTransactionControllerProvider,
    );
    expect(state.occurredDate.day, 4);
    expect(state.dateError, 'Choose Today or an earlier date.');
    expect(state.canSubmit, isFalse);
    expect(await controller.submit(), isNull);
    verifyNever(() => repository.createTransaction(any()));
  });

  test('new income also rejects a future occurrence date', () async {
    final _MockTransactionRepository repository = _MockTransactionRepository();
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        appClockProvider.overrideWithValue(() => fixedNow),
        transactionRepositoryProvider.overrideWithValue(repository),
        initialTransactionTypeProvider.overrideWithValue(
          TransactionType.income,
        ),
        recentPaymentMethodsProvider.overrideWith(
          (Ref ref, TransactionType type) =>
              const AsyncValue<List<PaymentMethod>>.data(<PaymentMethod>[]),
        ),
      ],
    );
    addTearDown(container.dispose);
    final AddTransactionController controller = container.read(
      addTransactionControllerProvider.notifier,
    );
    controller
      ..updateAmount('45000')
      ..selectCategory(TransactionCategory.salary)
      ..updateOccurredDate(DateTime(2026, 8, 5));

    expect(await controller.submit(), isNull);
    expect(
      container.read(addTransactionControllerProvider).dateError,
      'Choose Today or an earlier date.',
    );
    verifyNever(() => repository.createTransaction(any()));
  });

  test('untouched legacy future date is preserved while editing', () async {
    final FinancialTransaction legacy = buildTestTransaction(
      id: 'legacy-future',
      occurredAt: DateTime.utc(2026, 10, 12, 12),
    );
    final _MockTransactionRepository repository = _MockTransactionRepository();
    when(() => repository.updateTransaction(any())).thenAnswer((_) async {});
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        appClockProvider.overrideWithValue(() => fixedNow),
        transactionRepositoryProvider.overrideWithValue(repository),
        initialTransactionProvider.overrideWithValue(legacy),
        transactionFormIntentProvider.overrideWithValue(
          TransactionFormIntent.edit,
        ),
      ],
    );
    addTearDown(container.dispose);
    final AddTransactionController controller = container.read(
      addTransactionControllerProvider.notifier,
    );
    controller.updateMerchant('Updated merchant');

    final FinancialTransaction? saved = await controller.submit();

    expect(saved, isNotNull);
    expect(saved!.occurredAt, DateTime.utc(2026, 10, 12, 12));
    verify(() => repository.updateTransaction(any())).called(1);
  });

  test('changing a legacy future date accepts today but rejects future', () {
    final FinancialTransaction legacy = buildTestTransaction(
      id: 'legacy-future',
      occurredAt: DateTime.utc(2026, 10, 12, 12),
    );
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        appClockProvider.overrideWithValue(() => fixedNow),
        initialTransactionProvider.overrideWithValue(legacy),
        transactionFormIntentProvider.overrideWithValue(
          TransactionFormIntent.edit,
        ),
      ],
    );
    addTearDown(container.dispose);
    final AddTransactionController controller = container.read(
      addTransactionControllerProvider.notifier,
    );

    controller.updateOccurredDate(DateTime(2026, 9, 1));
    expect(
      container.read(addTransactionControllerProvider).dateError,
      isNotNull,
    );
    controller.updateOccurredDate(DateTime(2026, 8, 4));
    final AddTransactionState state = container.read(
      addTransactionControllerProvider,
    );
    expect(state.dateError, isNull);
    expect(state.occurredDate.day, 4);
    expect(state.hasChangedOccurredDate, isTrue);
  });
}
