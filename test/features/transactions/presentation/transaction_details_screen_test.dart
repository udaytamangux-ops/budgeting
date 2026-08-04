import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';
import '../../../support/test_data.dart';

void main() {
  testWidgets('Transaction Details displays the complete record', (
    WidgetTester tester,
  ) async {
    final FinancialTransaction transaction = buildTestTransaction();
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[transaction],
    );

    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lunch at Thamel'));
    await tester.pumpAndSettle();

    expect(find.text('Transaction details'), findsOneWidget);
    expect(find.text('NPR 1,250'), findsOneWidget);
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Lunch at Thamel'), findsOneWidget);
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('Team lunch'), findsOneWidget);
    expect(find.text('4 August 2026'), findsOneWidget);
  });

  testWidgets('Delete confirmation explains the financial consequence', (
    WidgetTester tester,
  ) async {
    final FinancialTransaction transaction = buildTestTransaction();
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[transaction],
    );
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lunch at Thamel'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('delete_transaction_button')),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('delete_transaction_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Delete this transaction?'), findsOneWidget);
    expect(find.text('Food · NPR 1,250 · 4 August 2026'), findsOneWidget);
    expect(
      find.text(
        'Deleting it will update your recorded balance and financial summary.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
    expect(
      find.widgetWithText(FilledButton, 'Delete transaction'),
      findsOneWidget,
    );
  });

  testWidgets('Repeat opens a populated new draft dated Today', (
    WidgetTester tester,
  ) async {
    final FinancialTransaction transaction = buildTestTransaction(
      occurredAt: DateTime.utc(2026, 8, 2, 6, 15),
    );
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[transaction],
    );
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lunch at Thamel'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('repeat_transaction_button')),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('repeat_transaction_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Repeat transaction'), findsOneWidget);
    expect(
      find.text(
        'A new transaction will be created using details from the original.',
      ),
      findsOneWidget,
    );
    expect(find.text('Save expense'), findsOneWidget);
    expect(find.text('Update transaction'), findsNothing);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey<String>('amount_input')))
          .controller
          ?.text,
      '1250',
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('merchant_input')),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Merchant (optional)'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(
            find.byKey(const ValueKey<String>('merchant_input')),
          )
          .controller
          ?.text,
      'Lunch at Thamel',
    );
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('selected_transaction_date')),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('4 August 2026'), findsOneWidget);
  });

  testWidgets('Income Repeat remains a new Save income draft', (
    WidgetTester tester,
  ) async {
    final FinancialTransaction transaction = buildTestTransaction(
      type: TransactionType.income,
      minorUnits: 6000000,
      category: TransactionCategory.salary,
      paymentMethod: PaymentMethod.bankAccount,
      merchant: 'Kantipur Tech',
      note: 'August salary',
    );
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[transaction],
    );
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Kantipur Tech'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('repeat_transaction_button')),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('repeat_transaction_button')),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'A new transaction will be created using details from the original.',
      ),
      findsOneWidget,
    );
    expect(find.text('Save income'), findsOneWidget);
    expect(find.text('Update transaction'), findsNothing);
  });

  testWidgets(
    'Repeat cancel leaves the original unchanged and creates nothing',
    (WidgetTester tester) async {
      final FinancialTransaction transaction = buildTestTransaction();
      final repository = await pumpBudgetingApp(
        tester,
        seedTransactions: <FinancialTransaction>[transaction],
      );
      await tester.tap(find.text('Transactions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lunch at Thamel'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('repeat_transaction_button')),
        280,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('repeat_transaction_button')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Cancel'));
      await tester.pumpAndSettle();

      final List<FinancialTransaction> records = await repository
          .watchTransactions()
          .first;
      expect(records, hasLength(1));
      expect(records.single.id, transaction.id);
      expect(records.single.amount, same(transaction.amount));
    },
  );

  testWidgets(
    'saving Repeat creates a new record without changing the original',
    (WidgetTester tester) async {
      final FinancialTransaction transaction = buildTestTransaction();
      final repository = await pumpBudgetingApp(
        tester,
        seedTransactions: <FinancialTransaction>[transaction],
      );
      await tester.tap(find.text('Transactions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lunch at Thamel'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('repeat_transaction_button')),
        280,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('repeat_transaction_button')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('save_transaction_button')),
      );
      await tester.pumpAndSettle();

      final List<FinancialTransaction> records = await repository
          .watchTransactions()
          .first;
      expect(records, hasLength(2));
      expect(
        records.map((FinancialTransaction value) => value.id),
        contains(transaction.id),
      );
      expect(
        records.map((FinancialTransaction value) => value.id).toSet(),
        hasLength(2),
      );
      final FinancialTransaction original = records.singleWhere(
        (FinancialTransaction value) => value.id == transaction.id,
      );
      expect(original.amount, same(transaction.amount));
      expect(find.text('Expense added · NPR 1,250 · Food'), findsOneWidget);
    },
  );

  testWidgets('Edit preserves the saved transaction date', (
    WidgetTester tester,
  ) async {
    final FinancialTransaction transaction = buildTestTransaction(
      occurredAt: DateTime.utc(2026, 8, 2, 6, 15),
    );
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[transaction],
    );
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lunch at Thamel'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('edit_transaction_button')),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('edit_transaction_button')),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('selected_transaction_date')),
      280,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('2 August 2026'), findsOneWidget);
  });

  testWidgets('editing an existing transaction does not offer create Undo', (
    WidgetTester tester,
  ) async {
    final FinancialTransaction transaction = buildTestTransaction();
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[transaction],
    );
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lunch at Thamel'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('edit_transaction_button')),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('edit_transaction_button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('save_transaction_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Transaction details'), findsOneWidget);
    expect(find.text('Undo'), findsNothing);
  });
}
