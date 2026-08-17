import 'package:budgeting_app/app/theme/app_colors.dart';
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
    final FinancialTransaction transaction = buildTestTransaction(
      createdAt: DateTime.utc(2026, 8, 4, 6, 15),
    );
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
    expect(find.text('Paid via'), findsOneWidget);
    expect(find.text('Team lunch'), findsOneWidget);
    expect(find.text('4 August 2026'), findsOneWidget);
    final Finder createdRow = find.byKey(
      const ValueKey<String>('transaction_created_row'),
    );
    expect(
      find.descendant(
        of: createdRow,
        matching: find.textContaining('August 2026'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: createdRow, matching: find.textContaining('Shrawan')),
      findsNothing,
    );
    expect(
      find.descendant(
        of: createdRow,
        matching: find.byKey(
          const ValueKey<String>('transaction_date_secondary'),
        ),
      ),
      findsNothing,
    );

    final Text expenseAmount = tester.widget<Text>(
      find.byKey(const ValueKey<String>('transaction_details_amount')),
    );
    expect(expenseAmount.style?.color, AppColors.expenseText);

    final Finder typePill = find.byKey(
      const ValueKey<String>('transaction_type_pill'),
    );
    final Container expensePill = tester.widget<Container>(typePill);
    expect(
      (expensePill.decoration! as BoxDecoration).color,
      AppColors.expenseSurface,
    );
    expect(
      tester
          .widget<Text>(
            find.descendant(of: typePill, matching: find.text('Expense')),
          )
          .style
          ?.color,
      AppColors.expenseText,
    );
    expect(
      tester
          .widget<Icon>(
            find.descendant(
              of: typePill,
              matching: find.byIcon(Icons.remove_circle_outline),
            ),
          )
          .color,
      AppColors.expenseAccentStrong,
    );
    expect(
      tester.widget<Text>(find.text('Lunch at Thamel')).style?.color,
      AppColors.textPrimary,
    );
    expect(
      tester.widget<Text>(find.text('Cash')).style?.color,
      AppColors.textPrimary,
    );
    expect(
      tester.widget<Text>(find.text('Merchant')).style?.color,
      AppColors.textSecondary,
    );
  });

  testWidgets('Income Details uses income semantics with neutral metadata', (
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

    final Text incomeAmount = tester.widget<Text>(
      find.byKey(const ValueKey<String>('transaction_details_amount')),
    );
    expect(incomeAmount.style?.color, AppColors.incomeAccent);
    expect(find.text('Received via'), findsOneWidget);

    final Finder typePill = find.byKey(
      const ValueKey<String>('transaction_type_pill'),
    );
    final Container incomePill = tester.widget<Container>(typePill);
    expect(
      (incomePill.decoration! as BoxDecoration).color,
      AppColors.incomeSurface,
    );
    expect(
      tester
          .widget<Text>(
            find.descendant(of: typePill, matching: find.text('Income')),
          )
          .style
          ?.color,
      AppColors.incomeAccent,
    );
    expect(
      tester
          .widget<Icon>(
            find.descendant(
              of: typePill,
              matching: find.byIcon(Icons.add_circle_outline),
            ),
          )
          .color,
      AppColors.incomeAccent,
    );
    expect(
      tester.widget<Text>(find.text('Kantipur Tech')).style?.color,
      AppColors.textPrimary,
    );
    expect(
      tester.widget<Text>(find.text('Bank account')).style?.color,
      AppColors.textPrimary,
    );
    expect(
      tester.widget<Text>(find.text('Payer or source')).style?.color,
      AppColors.textSecondary,
    );
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
    final TextButton deleteButton = tester.widget<TextButton>(
      find.byKey(const ValueKey<String>('delete_transaction_button')),
    );
    expect(
      deleteButton.style?.foregroundColor?.resolve(const <WidgetState>{}),
      AppColors.destructiveAction,
    );
    expect(
      deleteButton.style?.foregroundColor?.resolve(const <WidgetState>{}),
      isNot(AppColors.expenseText),
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
    await tester.tap(find.byKey(const ValueKey<String>('amount_input')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('calculator_expression')),
          )
          .data,
      '1250',
    );
    await tester.tap(find.byTooltip('Close calculator'));
    await tester.pumpAndSettle();
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

  testWidgets(
    'Make recurring prefills metadata and starts at next occurrence',
    (WidgetTester tester) async {
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
        find.byKey(const ValueKey<String>('make_recurring_button')),
        280,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(
        find.byKey(const ValueKey<String>('make_recurring_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create recurring transaction'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(
              find.byKey(const ValueKey<String>('amount_input')),
            )
            .controller
            ?.text,
        '1250',
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('recurring_merchant_input')),
        220,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        tester
            .widget<TextField>(
              find.byKey(const ValueKey<String>('recurring_merchant_input')),
            )
            .controller
            ?.text,
        'Lunch at Thamel',
      );
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey<String>('recurring_schedule_summary')),
        280,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Monthly · AD'), findsOneWidget);
      expect(find.text('Every month on day 2'), findsOneWidget);
      expect(find.text('Next: 2 September 2026'), findsOneWidget);
    },
  );

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
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('payment_method_field')),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      tester
          .widget<DropdownButtonFormField<PaymentMethod>>(
            find.byType(DropdownButtonFormField<PaymentMethod>),
          )
          .initialValue,
      PaymentMethod.bankAccount,
    );
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
      expect(
        records.map((FinancialTransaction value) => value.paymentMethod),
        everyElement(PaymentMethod.cash),
      );
      expect(find.text('Expense added · NPR 1,250 · Food'), findsNothing);
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('Expense added · NPR 1,250 · Food'), findsOneWidget);
    },
  );

  testWidgets('Edit loads and can change only the stored payment method', (
    WidgetTester tester,
  ) async {
    final FinancialTransaction transaction = buildTestTransaction(
      occurredAt: DateTime.utc(2026, 8, 2, 6, 15),
      paymentMethod: PaymentMethod.eSewa,
    );
    final repository = await pumpBudgetingApp(
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
    await tester.tap(find.byKey(const ValueKey<String>('amount_input')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey<String>('calculator_expression')),
          )
          .data,
      '1250',
    );
    await tester.tap(find.byTooltip('Close calculator'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('selected_transaction_date')),
      280,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('2 August 2026'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('payment_method_field')),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      tester
          .widget<DropdownButtonFormField<PaymentMethod>>(
            find.byType(DropdownButtonFormField<PaymentMethod>),
          )
          .initialValue,
      PaymentMethod.eSewa,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('payment_method_field')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Khalti').last);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('save_transaction_button')),
    );
    await tester.pumpAndSettle();

    final FinancialTransaction saved =
        (await repository.watchTransactions().first).single;
    expect(saved.paymentMethod, PaymentMethod.khalti);
    expect(saved.occurredAt, transaction.occurredAt);
    expect(saved.id, transaction.id);
  });

  testWidgets('editing an existing transaction does not offer create Undo', (
    WidgetTester tester,
  ) async {
    final FinancialTransaction transaction = buildTestTransaction(
      paymentMethod: PaymentMethod.imePay,
    );
    final repository = await pumpBudgetingApp(
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
    expect(
      (await repository.watchTransactions().first).single.paymentMethod,
      PaymentMethod.imePay,
    );
  });
}
