import 'dart:io';

import 'package:budgeting_app/app/app.dart';
import 'package:budgeting_app/app/bootstrap/app_bootstrap.dart';
import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/features/access/data/repositories/drift_access_preference_repository.dart';
import 'package:budgeting_app/features/access/domain/entities/access_mode.dart';
import 'package:budgeting_app/features/transactions/data/repositories/drift_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('persistent ledger survives connection and app recreation', (
    WidgetTester tester,
  ) async {
    final Directory directory = await Directory.systemTemp.createTemp(
      'budgeting-integration-',
    );
    final File databaseFile = File(
      '${directory.path}${Platform.pathSeparator}transactions.sqlite',
    );
    addTearDown(() async {
      if (directory.existsSync()) {
        await directory.delete(recursive: true);
      }
    });

    _PersistentAppSession session = await _openSession(tester, databaseFile);
    expect(await session.repository.watchTransactions().first, isEmpty);
    expect(find.text('Start recording your money activity'), findsOneWidget);

    await _addTransaction(
      tester,
      homeButtonKey: 'home_add_income_button',
      amount: '5000',
      categoryKey: 'category_salary',
      merchant: 'Kantipur Tech',
    );
    await _addTransaction(
      tester,
      homeButtonKey: 'home_add_expense_button',
      amount: '1250',
      categoryKey: 'category_food',
      merchant: 'Tea House',
    );

    expect(find.text('NPR 3,750'), findsOneWidget);
    expect(find.text('NPR 5,000'), findsOneWidget);
    expect(find.text('NPR 1,250'), findsOneWidget);
    expect(find.text('2 transactions recorded'), findsOneWidget);

    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    expect(find.text('Kantipur Tech'), findsOneWidget);
    expect(find.text('Tea House'), findsOneWidget);

    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    expect(find.text('NPR 5,000'), findsOneWidget);
    expect(find.text('NPR 1,250'), findsWidgets);
    await _revealInScrollable(tester, find.text('Food'));
    expect(find.text('Food'), findsOneWidget);

    await _closeSession(tester, session);
    session = await _openSession(tester, databaseFile);
    expect(find.text('NPR 3,750'), findsOneWidget);
    expect(find.text('2 transactions recorded'), findsOneWidget);

    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tea House'));
    await tester.pumpAndSettle();
    await _revealInScrollable(
      tester,
      find.byKey(const ValueKey<String>('edit_transaction_button')),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('edit_transaction_button')),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey<String>('amount_input')),
      '1500',
    );
    await _revealInScrollable(
      tester,
      find.byKey(const ValueKey<String>('save_transaction_button')),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('save_transaction_button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('NPR 1,500'), findsOneWidget);

    await _closeSession(tester, session);
    session = await _openSession(tester, databaseFile);
    expect(find.text('NPR 3,500'), findsOneWidget);
    expect(find.text('NPR 1,500'), findsOneWidget);

    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kantipur Tech'));
    await tester.pumpAndSettle();
    await _revealInScrollable(
      tester,
      find.byKey(const ValueKey<String>('delete_transaction_button')),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('delete_transaction_button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Delete transaction'));
    await tester.pumpAndSettle();

    await _closeSession(tester, session);
    session = await _openSession(tester, databaseFile);
    final List<FinancialTransaction> remaining = await session.repository
        .watchTransactions()
        .first;
    expect(remaining, hasLength(1));
    expect(remaining.single.type, TransactionType.expense);
    expect(remaining.single.amount.minorUnits, 150000);
    expect(find.text('NPR 0'), findsOneWidget);
    expect(find.text('NPR 1,500'), findsWidgets);

    await _closeSession(tester, session);
  });
}

Future<void> _addTransaction(
  WidgetTester tester, {
  required String homeButtonKey,
  required String amount,
  required String categoryKey,
  required String merchant,
}) async {
  final Finder homeButton = find.byKey(ValueKey<String>(homeButtonKey));
  await tester.ensureVisible(homeButton);
  await tester.tap(homeButton);
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const ValueKey<String>('amount_input')),
    amount,
  );
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.tap(find.byKey(ValueKey<String>(categoryKey)));
  await _revealInScrollable(
    tester,
    find.byKey(const ValueKey<String>('optional_fields_toggle')),
  );
  await tester.tap(
    find.byKey(const ValueKey<String>('optional_fields_toggle')),
  );
  await tester.pumpAndSettle();
  await _revealInScrollable(
    tester,
    find.byKey(const ValueKey<String>('merchant_input')),
  );
  await tester.enterText(
    find.byKey(const ValueKey<String>('merchant_input')),
    merchant,
  );
  FocusManager.instance.primaryFocus?.unfocus();
  await _revealInScrollable(
    tester,
    find.byKey(const ValueKey<String>('save_transaction_button')),
  );
  await tester.tap(
    find.byKey(const ValueKey<String>('save_transaction_button')),
  );
  await tester.pumpAndSettle();
}

Future<void> _revealInScrollable(WidgetTester tester, Finder target) async {
  if (target.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      target,
      280,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await Scrollable.ensureVisible(
    tester.element(target),
    alignment: 0.5,
    duration: Duration.zero,
  );
  await tester.pump();
}

Future<_PersistentAppSession> _openSession(
  WidgetTester tester,
  File databaseFile,
) async {
  final AppDatabase database = AppDatabase(NativeDatabase(databaseFile));
  final DriftAccessPreferenceRepository accessRepository =
      DriftAccessPreferenceRepository(database);
  if (await accessRepository.getAccessMode() == AccessMode.undecided) {
    await accessRepository.setGuestMode();
  }
  final ProviderContainer container = await AppBootstrap.createContainer(
    database: database,
  );
  final DriftTransactionRepository repository =
      container.read(transactionRepositoryProvider)
          as DriftTransactionRepository;
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const BudgetingApp(),
    ),
  );
  await tester.pumpAndSettle();
  return _PersistentAppSession(
    database: database,
    repository: repository,
    container: container,
  );
}

Future<void> _closeSession(
  WidgetTester tester,
  _PersistentAppSession session,
) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();
  session.container.dispose();
  await session.database.close();
}

final class _PersistentAppSession {
  const _PersistentAppSession({
    required this.database,
    required this.repository,
    required this.container,
  });

  final AppDatabase database;
  final DriftTransactionRepository repository;
  final ProviderContainer container;
}
