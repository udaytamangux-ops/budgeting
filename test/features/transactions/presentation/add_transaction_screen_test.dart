import 'dart:ui' show Tristate;

import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/core/widgets/primary_button.dart';
import 'package:budgeting_app/features/summary/presentation/widgets/spending_donut_chart.dart';
import 'package:budgeting_app/features/transactions/data/repositories/in_memory_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_type_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';
import '../../../support/test_data.dart';

void main() {
  testWidgets(
    'Add Expense starts in expense mode and validates required input',
    (WidgetTester tester) async {
      await pumpBudgetingApp(tester);
      await tester.tap(
        find.byKey(const ValueKey<String>('home_add_expense_button')),
      );
      await tester.pumpAndSettle();

      final TransactionTypeSelector selector = tester.widget(
        find.byType(TransactionTypeSelector),
      );
      expect(selector.value, TransactionType.expense);
      expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);

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

      expect(
        tester
            .getSemantics(find.byKey(const ValueKey<String>('category_food')))
            .flagsCollection
            .isSelected,
        Tristate.isTrue,
      );
      saveButton = tester.widget<PrimaryButton>(
        find.byKey(const ValueKey<String>('save_transaction_button')),
      );
      expect(saveButton.onPressed, isNotNull);
    },
  );

  testWidgets('transaction type selector uses approved semantic states', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);
    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();

    final Finder expenseOption = find.byKey(
      const ValueKey<String>('transaction_type_expense'),
    );
    final Finder incomeOption = find.byKey(
      const ValueKey<String>('transaction_type_income'),
    );

    Material optionMaterial(Finder option) => tester.widget<Material>(
      find.descendant(of: option, matching: find.byType(Material)).first,
    );

    Text optionText(Finder option, String label) => tester.widget<Text>(
      find.descendant(of: option, matching: find.text(label)),
    );

    Icon optionIcon(Finder option, IconData icon) => tester.widget<Icon>(
      find.descendant(of: option, matching: find.byIcon(icon)),
    );

    expect(optionMaterial(expenseOption).color, AppColors.expenseSurface);
    expect(
      optionText(expenseOption, 'Expense').style?.color,
      AppColors.expenseText,
    );
    expect(
      optionIcon(expenseOption, Icons.remove_circle_outline).color,
      AppColors.expenseIconAccent,
    );
    expect(optionMaterial(incomeOption).color, AppColors.surfaceSecondary);
    expect(
      optionText(incomeOption, 'Income').style?.color,
      AppColors.textSecondary,
    );

    await tester.tap(incomeOption);
    await tester.pump();

    expect(optionMaterial(expenseOption).color, AppColors.surfaceSecondary);
    expect(
      optionText(expenseOption, 'Expense').style?.color,
      AppColors.textSecondary,
    );
    expect(optionMaterial(incomeOption).color, AppColors.incomeSurface);
    expect(
      optionText(incomeOption, 'Income').style?.color,
      AppColors.incomeAccent,
    );
    expect(
      optionIcon(incomeOption, Icons.add_circle_outline).color,
      AppColors.incomeAccent,
    );
  });

  testWidgets('optional fields expand and income uses contextual terminology', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);
    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('merchant_input')), findsNothing);
    await tester.drag(
      find.byKey(const ValueKey<String>('add_transaction_form_scroll')),
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();
    expect(find.text('Add merchant or note'), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey<String>('optional_fields_toggle')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Merchant (optional)'), findsOneWidget);
    expect(find.text('Note (optional)'), findsOneWidget);

    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_income_button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Income source'), findsOneWidget);
    expect(find.text('Save income'), findsOneWidget);
    expect(find.byIcon(Icons.remove_circle_outline), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey<String>('add_transaction_form_scroll')),
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();
    expect(find.text('Received via'), findsOneWidget);
    expect(find.text('Add payer or note'), findsOneWidget);
  });

  testWidgets('recent categories are derived, unselected, and reusable', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);
    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recent'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('recent_category_food')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('recent_category_utilities')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('recent_category_transport')),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (Widget widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith(
              'recent_category_',
            ),
      ),
      findsNWidgets(3),
    );
    expect(
      tester
          .getSemantics(
            find.byKey(const ValueKey<String>('recent_category_food')),
          )
          .flagsCollection
          .isSelected,
      Tristate.isFalse,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('recent_category_utilities')),
    );
    await tester.pump();

    expect(
      tester
          .getSemantics(
            find.byKey(const ValueKey<String>('recent_category_utilities')),
          )
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
    expect(
      tester
          .getSemantics(
            find.byKey(const ValueKey<String>('category_utilities')),
          )
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
  });

  testWidgets('Recent stays hidden with fewer than two distinct options', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[
        buildTestTransaction(id: 'only-recent-category'),
      ],
    );
    await tester.tap(find.byKey(const ValueKey<String>('central_add_button')));
    await tester.pumpAndSettle();

    expect(find.text('Recent'), findsNothing);
    expect(find.text('All categories'), findsNothing);
    for (final TransactionCategory category in TransactionCategory.values.where(
      (TransactionCategory category) =>
          category.supports(TransactionType.expense),
    )) {
      expect(
        find.byKey(ValueKey<String>('category_${category.name}')),
        findsOneWidget,
      );
    }
  });

  testWidgets('payment method is remembered by type for the current session', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);
    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();
    await _scrollToPaymentMethod(tester);
    await tester.tap(
      find.byKey(const ValueKey<String>('payment_method_field')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('eSewa').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();
    await _scrollToPaymentMethod(tester);
    expect(
      tester
          .widget<DropdownButtonFormField<PaymentMethod>>(
            find.byType(DropdownButtonFormField<PaymentMethod>),
          )
          .initialValue,
      PaymentMethod.eSewa,
    );

    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_income_button')),
    );
    await tester.pumpAndSettle();
    await _scrollToPaymentMethod(tester);
    expect(
      tester
          .widget<DropdownButtonFormField<PaymentMethod>>(
            find.byType(DropdownButtonFormField<PaymentMethod>),
          )
          .initialValue,
      PaymentMethod.cash,
    );
  });

  testWidgets('quick dates default to Today and open the existing picker', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);
    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('quick_date_today')),
      280,
      scrollable: find.byType(Scrollable).first,
    );

    expect(
      tester
          .getSemantics(find.byKey(const ValueKey<String>('quick_date_today')))
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('quick_date_yesterday')),
    );
    await tester.pumpAndSettle();
    expect(find.text('3 August 2026'), findsOneWidget);
    expect(
      tester
          .getSemantics(
            find.byKey(const ValueKey<String>('quick_date_yesterday')),
          )
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
    );

    await tester.tap(find.byKey(const ValueKey<String>('quick_date_choose')));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
  });

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
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('category_food')));
    await tester.drag(
      find.byKey(const ValueKey<String>('add_transaction_form_scroll')),
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('optional_fields_toggle')),
    );
    await tester.pumpAndSettle();
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
    expect(find.text('Expense added · NPR 1,250 · Food'), findsOneWidget);
    expect(find.text('NPR 36,000'), findsOneWidget);
    expect(find.text('NPR 24,000'), findsOneWidget);
    expect(find.text('7 transactions recorded'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
    final Rect bannerBounds = tester.getRect(
      find.byKey(const ValueKey<String>('transaction_created_banner')),
    );
    final Rect navigationBounds = tester.getRect(find.byType(BottomAppBar));
    expect(bannerBounds.bottom, lessThanOrEqualTo(navigationBounds.top));
    expect(find.textContaining('remains in this category'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Lunch at Thamel'),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Lunch at Thamel'), findsOneWidget);
  });

  testWidgets('Undo restores Home and Summary values after a create', (
    WidgetTester tester,
  ) async {
    final InMemoryTransactionRepository repository = await pumpBudgetingApp(
      tester,
    );
    final int originalCount =
        (await repository.watchTransactions().first).length;

    await _createFoodExpense(tester);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byType(SpendingDonutChart),
      280,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      tester
          .widget<SpendingDonutChart>(find.byType(SpendingDonutChart))
          .total
          .minorUnits,
      2400000,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('undo_created_transaction')),
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<SpendingDonutChart>(find.byType(SpendingDonutChart))
          .total
          .minorUnits,
      2275000,
    );
    expect((await repository.watchTransactions().first).length, originalCount);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('NPR 37,250'), findsOneWidget);
    expect(find.text('NPR 22,750'), findsOneWidget);
    expect(find.text('6 transactions recorded'), findsOneWidget);
  });

  testWidgets('failed Undo preserves the record and offers a retry', (
    WidgetTester tester,
  ) async {
    final InMemoryTransactionRepository repository = await pumpBudgetingApp(
      tester,
    );
    await _createFoodExpense(tester);
    repository.simulateNextDeleteFailure();

    await tester.tap(
      find.byKey(const ValueKey<String>('undo_created_transaction')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Could not undo transaction'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(
      (await repository.watchTransactions().first).first.amount.minorUnits,
      125000,
    );
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
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('category_food')));
    await tester.drag(
      find.byKey(const ValueKey<String>('add_transaction_form_scroll')),
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('optional_fields_toggle')),
    );
    await tester.pumpAndSettle();
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
          .getSemantics(find.byKey(const ValueKey<String>('category_food')))
          .flagsCollection
          .isSelected,
      Tristate.isTrue,
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

  testWidgets('save action remains reachable with the keyboard inset', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    addTearDown(tester.view.reset);

    await pumpBudgetingApp(tester);
    await tester.tap(find.byKey(const ValueKey<String>('central_add_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('amount_input')));
    await tester.pump();

    expect(
      find.byKey(const ValueKey<String>('save_transaction_button')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

Future<void> _scrollToPaymentMethod(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.byKey(const ValueKey<String>('payment_method_field')),
    280,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> _createFoodExpense(WidgetTester tester) async {
  await tester.tap(
    find.byKey(const ValueKey<String>('home_add_expense_button')),
  );
  await tester.pumpAndSettle();
  await tester.enterText(
    find.byKey(const ValueKey<String>('amount_input')),
    '1250',
  );
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey<String>('category_food')));
  await tester.pump();
  await tester.tap(
    find.byKey(const ValueKey<String>('save_transaction_button')),
  );
  await tester.pumpAndSettle();
}
