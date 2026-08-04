import 'package:budgeting_app/core/widgets/primary_button.dart';
import 'package:budgeting_app/features/transactions/data/repositories/in_memory_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  testWidgets(
    'Add Expense starts in expense mode and validates required input',
    (WidgetTester tester) async {
      await pumpBudgetingApp(tester);
      await tester.tap(
        find.byKey(const ValueKey<String>('home_add_expense_button')),
      );
      await tester.pumpAndSettle();

      final SegmentedButton<TransactionType> segmented = tester.widget(
        find.byType(SegmentedButton<TransactionType>),
      );
      expect(segmented.selected, <TransactionType>{TransactionType.expense});

      PrimaryButton saveButton = tester.widget<PrimaryButton>(
        find.byKey(const ValueKey<String>('save_transaction_button')),
      );
      expect(saveButton.onPressed, isNull);

      await tester.enterText(
        find.byKey(const ValueKey<String>('amount_input')),
        '0',
      );
      await tester.pump();
      expect(find.text('Amount must be greater than NPR 0.'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey<String>('amount_input')),
        '1250',
      );
      await tester.tap(find.byKey(const ValueKey<String>('category_food')));
      await tester.pump();

      final ChoiceChip foodChip = tester.widget<ChoiceChip>(
        find.byKey(const ValueKey<String>('category_food')),
      );
      expect(foodChip.selected, isTrue);
      saveButton = tester.widget<PrimaryButton>(
        find.byKey(const ValueKey<String>('save_transaction_button')),
      );
      expect(saveButton.onPressed, isNotNull);
    },
  );

  testWidgets('successful save updates repository and shows confirmation', (
    WidgetTester tester,
  ) async {
    final InMemoryTransactionRepository repository = await pumpBudgetingApp(
      tester,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('amount_input')),
      '1250',
    );
    await tester.tap(find.byKey(const ValueKey<String>('category_food')));
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('merchant_input')),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('merchant_input')),
      'Lunch at Thamel',
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('save_transaction_button')),
    );
    await tester.pumpAndSettle();

    final List<FinancialTransaction> transactions = await repository
        .watchTransactions()
        .first;
    expect(transactions.first.amount.minorUnits, 125000);
    expect(transactions.first.category, TransactionCategory.food);
    expect(transactions.first.paymentMethod, PaymentMethod.cash);
    expect(find.text('Expense added'), findsOneWidget);
    expect(find.text('NPR 36,000'), findsOneWidget);
    expect(find.text('NPR 24,000'), findsOneWidget);
    expect(find.text('NPR 16,000 left'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Lunch at Thamel'),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Lunch at Thamel'), findsOneWidget);
  });

  testWidgets('save failure preserves entered values and allows retry', (
    WidgetTester tester,
  ) async {
    final InMemoryTransactionRepository repository = await pumpBudgetingApp(
      tester,
    );
    repository.simulateNextCreateFailure();
    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey<String>('amount_input')),
      '1250',
    );
    await tester.tap(find.byKey(const ValueKey<String>('category_food')));
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('merchant_input')),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.enterText(
      find.byKey(const ValueKey<String>('merchant_input')),
      'Lunch at Thamel',
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('save_transaction_button')),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('The transaction could not be saved. Try again.'),
      findsOneWidget,
    );
    final TextField merchantField = tester.widget<TextField>(
      find.byKey(const ValueKey<String>('merchant_input')),
    );
    expect(merchantField.controller?.text, 'Lunch at Thamel');
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('amount_input')),
      -280,
      scrollable: find.byType(Scrollable).first,
    );
    final TextField amountField = tester.widget<TextField>(
      find.byKey(const ValueKey<String>('amount_input')),
    );
    expect(amountField.controller?.text, '1250');
    expect(
      tester
          .widget<ChoiceChip>(
            find.byKey(const ValueKey<String>('category_food')),
          )
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<PrimaryButton>(
            find.byKey(const ValueKey<String>('save_transaction_button')),
          )
          .onPressed,
      isNotNull,
    );
  });
}
