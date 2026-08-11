import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transfers/data/repositories/in_memory_transfer_repository.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:budgeting_app/features/transfers/domain/entities/transfer_enums.dart';
import 'package:budgeting_app/features/transfers/presentation/controllers/add_transfer_controller.dart';
import 'package:budgeting_app/features/transfers/presentation/controllers/transfer_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  ProviderContainer containerFor(
    InMemoryTransferRepository repository, {
    FinancialTransfer? initial,
    TransferFormIntent intent = TransferFormIntent.create,
  }) {
    final container = ProviderContainer(
      overrides: <Override>[
        appClockProvider.overrideWithValue(() => fixedNow),
        transferRepositoryProvider.overrideWithValue(repository),
        if (initial != null) initialTransferProvider.overrideWithValue(initial),
        transferFormIntentProvider.overrideWithValue(intent),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
    'blank transfer is OFF and saves Bank account to Cash exactly',
    () async {
      final repository = InMemoryTransferRepository();
      addTearDown(repository.dispose);
      final container = containerFor(repository);
      final controller = container.read(addTransferControllerProvider.notifier);
      expect(
        container.read(addTransferControllerProvider).countsAsExpense,
        false,
      );

      controller.updateAmount('5000');
      final saved = await controller.submit();

      expect(saved?.amount.minorUnits, 500000);
      expect(saved?.source, TransferSource.bankAccount);
      expect(saved?.destination, TransferDestination.cash);
      expect(saved?.countsAsExpense, isFalse);
      expect(saved?.expenseCategory, isNull);
      expect(await repository.watchTransfers().first, hasLength(1));
    },
  );

  test(
    'Person requires a trimmed name and counted transfer requires category',
    () async {
      final repository = InMemoryTransferRepository();
      addTearDown(repository.dispose);
      final container = containerFor(repository);
      final controller = container.read(addTransferControllerProvider.notifier);
      controller.updateAmount('2000');
      controller.updateDestination(TransferDestination.person);
      controller.updateCountsAsExpense(true);

      expect(await controller.submit(), isNull);
      final state = container.read(addTransferControllerProvider);
      expect(state.destinationNameError, isNotNull);
      expect(state.categoryError, isNotNull);

      controller.updateDestinationName('  Mom  ');
      controller.selectExpenseCategory(TransactionCategory.family);
      final saved = await controller.submit();
      expect(saved?.destinationName, 'Mom');
      expect(saved?.expenseCategory, TransactionCategory.family);
    },
  );

  test(
    'turning Count as expense OFF clears persisted classification',
    () async {
      final original = buildTestTransfer(
        countsAsExpense: true,
        expenseCategory: TransactionCategory.family,
      );
      final repository = InMemoryTransferRepository(
        seedTransfers: <FinancialTransfer>[original],
      );
      addTearDown(repository.dispose);
      final container = containerFor(
        repository,
        initial: original,
        intent: TransferFormIntent.edit,
      );
      final controller = container.read(addTransferControllerProvider.notifier);
      controller.updateCountsAsExpense(false);
      final saved = await controller.submit();
      expect(saved?.countsAsExpense, isFalse);
      expect(saved?.expenseCategory, isNull);
    },
  );

  test('Repeat preserves fields but uses Today', () {
    final original = buildTestTransfer(
      destination: TransferDestination.investment,
      destinationName: 'IPO application',
      countsAsExpense: true,
      expenseCategory: TransactionCategory.other,
      feeMinorUnits: 1000,
      occurredAt: DateTime.utc(2026, 7, 1, 12),
    );
    final repository = InMemoryTransferRepository();
    addTearDown(repository.dispose);
    final container = containerFor(
      repository,
      initial: original,
      intent: TransferFormIntent.repeat,
    );
    final state = container.read(addTransferControllerProvider);
    expect(state.isRepeatDraft, isTrue);
    expect(state.destinationName, 'IPO application');
    expect(state.countsAsExpense, isTrue);
    expect(state.expenseCategory, TransactionCategory.other);
    expect(state.feeInput, '10');
    expect(
      state.occurredDate,
      DateTime(fixedNow.year, fixedNow.month, fixedNow.day),
    );
  });

  test(
    'new future dates are rejected while unchanged legacy future edit survives',
    () async {
      final repository = InMemoryTransferRepository();
      addTearDown(repository.dispose);
      final createContainer = containerFor(repository);
      final create = createContainer.read(
        addTransferControllerProvider.notifier,
      );
      create.updateAmount('10');
      create.updateOccurredDate(fixedNow.add(const Duration(days: 1)));
      expect(await create.submit(), isNull);
      expect(
        createContainer.read(addTransferControllerProvider).dateError,
        isNotNull,
      );

      final legacy = buildTestTransfer(
        id: 'legacy-future',
        occurredAt: fixedNow.add(const Duration(days: 30)),
      );
      final editRepository = InMemoryTransferRepository(
        seedTransfers: <FinancialTransfer>[legacy],
      );
      addTearDown(editRepository.dispose);
      final editContainer = containerFor(
        editRepository,
        initial: legacy,
        intent: TransferFormIntent.edit,
      );
      final edited = await editContainer
          .read(addTransferControllerProvider.notifier)
          .submit();
      expect(edited?.occurredAt, legacy.occurredAt);
    },
  );
}
