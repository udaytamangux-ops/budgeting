import 'package:budgeting_app/features/transactions/data/repositories/in_memory_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/last_saved_transaction_controller.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_created_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/test_data.dart';

void main() {
  test('Undo deletes only the confirmed newly created transaction', () async {
    final FinancialTransaction original = buildTestTransaction(id: 'original');
    final FinancialTransaction created = buildTestTransaction(id: 'created');
    final InMemoryTransactionRepository repository =
        InMemoryTransactionRepository(
          seedTransactions: <FinancialTransaction>[original, created],
          operationDelay: Duration.zero,
          now: () => fixedNow,
        );
    addTearDown(repository.dispose);
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        transactionRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final LastSavedTransactionController controller = container.read(
      lastSavedTransactionProvider.notifier,
    );

    controller.show(created);
    expect(await controller.undo(), isTrue);

    expect(await repository.getTransactionById(created.id), isNull);
    expect(await repository.getTransactionById(original.id), same(original));
    expect(container.read(lastSavedTransactionProvider), isNull);
  });

  test(
    'failed Undo keeps recoverable confirmation and the transaction',
    () async {
      final FinancialTransaction created = buildTestTransaction(id: 'created');
      final InMemoryTransactionRepository repository =
          InMemoryTransactionRepository(
            seedTransactions: <FinancialTransaction>[created],
            operationDelay: Duration.zero,
            now: () => fixedNow,
          );
      addTearDown(repository.dispose);
      repository.simulateNextDeleteFailure();
      final ProviderContainer container = ProviderContainer(
        overrides: <Override>[
          transactionRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final LastSavedTransactionController controller = container.read(
        lastSavedTransactionProvider.notifier,
      );

      controller.show(created);
      expect(await controller.undo(), isFalse);

      final CreatedTransactionConfirmation? confirmation = container.read(
        lastSavedTransactionProvider,
      );
      expect(confirmation?.phase, UndoTransactionPhase.failure);
      expect(confirmation?.errorMessage, contains('Try again'));
      expect(await repository.getTransactionById(created.id), same(created));
    },
  );

  testWidgets('Undo action is unavailable after the confirmation timeout', (
    WidgetTester tester,
  ) async {
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final LastSavedTransactionController controller = container.read(
      lastSavedTransactionProvider.notifier,
    );
    controller.show(buildTestTransaction(id: 'created'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(body: TransactionCreatedBanner()),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Undo'), findsOneWidget);

    await tester.pump(
      LastSavedTransactionController.confirmationDuration +
          const Duration(milliseconds: 1),
    );
    await tester.pumpAndSettle();

    expect(find.text('Undo'), findsNothing);
    expect(container.read(lastSavedTransactionProvider), isNull);
  });

  testWidgets('created confirmation fits 320 px at 2x text scaling', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final SemanticsHandle semantics = tester.ensureSemantics();
    final ProviderContainer container = ProviderContainer();
    addTearDown(container.dispose);
    final LastSavedTransactionController controller = container.read(
      lastSavedTransactionProvider.notifier,
    );
    controller.show(buildTestTransaction(id: 'created'));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: TransactionCreatedBanner(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('Expense added · NPR 1,250 · Food'), findsOneWidget);
    expect(
      find.bySemanticsLabel('Expense added · NPR 1,250 · Food'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    controller.dismiss();
    await tester.pump();
    semantics.dispose();
  });

  test('a newer confirmation is not cleared by an earlier Undo', () async {
    final FinancialTransaction first = buildTestTransaction(id: 'first');
    final FinancialTransaction second = buildTestTransaction(id: 'second');
    final InMemoryTransactionRepository repository =
        InMemoryTransactionRepository(
          seedTransactions: <FinancialTransaction>[first, second],
          operationDelay: const Duration(milliseconds: 20),
          now: () => fixedNow,
        );
    addTearDown(repository.dispose);
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        transactionRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
    final LastSavedTransactionController controller = container.read(
      lastSavedTransactionProvider.notifier,
    );

    controller.show(first);
    final Future<bool> firstUndo = controller.undo();
    controller.show(second);
    expect(await firstUndo, isTrue);

    expect(await repository.getTransactionById(first.id), isNull);
    expect(await repository.getTransactionById(second.id), same(second));
    expect(
      container.read(lastSavedTransactionProvider)?.transaction.id,
      second.id,
    );
  });
}
