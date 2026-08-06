import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/features/transactions/data/repositories/in_memory_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_type_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';
import '../../../support/test_data.dart';

void main() {
  testWidgets('Home renders a neutral recorded activity overview', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester, useMockTransactions: true);

    expect(find.text('Namaste'), findsOneWidget);
    expect(find.text("Here's your August activity."), findsOneWidget);
    expect(find.text('Aarav Shrestha'), findsNothing);
    expect(find.text('aarav.shrestha@example.com'), findsNothing);
    expect(find.text('AS'), findsNothing);
    expect(find.bySemanticsLabel('Open local profile'), findsOneWidget);
    expect(find.text('Recorded balance'), findsOneWidget);
    expect(find.text('Available balance'), findsNothing);
    expect(find.text('NPR 37,250'), findsOneWidget);
    expect(find.text('NPR 60,000'), findsOneWidget);
    expect(find.text('NPR 22,750'), findsOneWidget);
    expect(find.text('This month'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Net change'), findsNothing);
    expect(find.text('6 transactions recorded'), findsOneWidget);
    expect(find.text('Spent across 4 categories'), findsOneWidget);
    expect(find.byTooltip('Previous month'), findsNothing);
    expect(find.byTooltip('Next month'), findsNothing);
    expect(
      find.bySemanticsLabel(RegExp('Recorded balance, NPR 37,250')),
      findsOneWidget,
    );

    for (final String prohibitedCopy in <String>[
      'Monthly budget',
      'Food budget',
      '57% used',
      'Near limit',
      'Over limit',
      'Within budget',
      'View budget',
    ]) {
      expect(find.text(prohibitedCopy), findsNothing);
    }
  });

  testWidgets('compact Quick Add buttons open the correct transaction mode', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);

    final Finder expenseButton = find.byKey(
      const ValueKey<String>('home_add_expense_button'),
    );
    final Finder incomeButton = find.byKey(
      const ValueKey<String>('home_add_income_button'),
    );
    expect(tester.getSize(expenseButton).height, 48);
    expect(tester.getSize(incomeButton).height, 48);
    expect(
      tester
          .getSize(
            find.byKey(
              const ValueKey<String>('home_quick_actions_to_month_spacing'),
            ),
          )
          .height,
      inInclusiveRange(36, 40),
    );
    expect(find.text('Quick add'), findsNothing);
    expect(find.bySemanticsLabel('Add expense transaction'), findsOneWidget);
    expect(find.bySemanticsLabel('Add income transaction'), findsOneWidget);

    final OutlinedButton expenseControl = tester.widget<OutlinedButton>(
      find.descendant(of: expenseButton, matching: find.byType(OutlinedButton)),
    );
    final OutlinedButton incomeControl = tester.widget<OutlinedButton>(
      find.descendant(of: incomeButton, matching: find.byType(OutlinedButton)),
    );
    expect(
      expenseControl.style?.backgroundColor?.resolve(const <WidgetState>{}),
      AppColors.expenseSurface,
    );
    expect(
      incomeControl.style?.backgroundColor?.resolve(const <WidgetState>{}),
      AppColors.incomeSurface,
    );
    final Icon expenseIcon = tester.widget<Icon>(
      find.descendant(
        of: expenseButton,
        matching: find.byIcon(Icons.remove_circle_outline),
      ),
    );
    final Icon incomeIcon = tester.widget<Icon>(
      find.descendant(
        of: incomeButton,
        matching: find.byIcon(Icons.add_circle_outline),
      ),
    );
    expect(
      (expenseIcon.color! as WidgetStateColor).resolve(const <WidgetState>{}),
      AppColors.expenseAccent,
    );
    expect(
      (incomeIcon.color! as WidgetStateColor).resolve(const <WidgetState>{}),
      AppColors.incomeAccent,
    );
    expect(
      expenseControl.style?.backgroundColor?.resolve(const <WidgetState>{}),
      isNot(AppColors.dangerAction),
    );
    expect(
      expenseControl.style?.backgroundColor?.resolve(const <WidgetState>{
        WidgetState.pressed,
      }),
      AppColors.expenseSurfacePressed,
    );
    expect(
      incomeControl.style?.backgroundColor?.resolve(const <WidgetState>{
        WidgetState.pressed,
      }),
      AppColors.incomeSurfacePressed,
    );

    await tester.tap(expenseButton);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TransactionTypeSelector>(find.byType(TransactionTypeSelector))
          .value,
      TransactionType.expense,
    );

    await tester.tap(find.byTooltip('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(incomeButton);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<TransactionTypeSelector>(find.byType(TransactionTypeSelector))
          .value,
      TransactionType.income,
    );
  });

  testWidgets('View details opens the Summary destination', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester, useMockTransactions: true);

    await tester.tap(find.byKey(const ValueKey<String>('view_summary_button')));
    await tester.pumpAndSettle();

    expect(find.text('Summary'), findsWidgets);
    expect(find.text('Where your money went'), findsOneWidget);
  });

  testWidgets('generic profile control opens the local Profile state', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);

    await tester.tap(find.byKey(const ValueKey<String>('home_profile_button')));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Local profile'), findsOneWidget);
    expect(find.text('No account connected'), findsOneWidget);
  });

  testWidgets('Home renders a useful empty state', (WidgetTester tester) async {
    await pumpBudgetingApp(tester);

    expect(find.text('Recorded balance'), findsOneWidget);
    expect(find.text('NPR 0'), findsNWidgets(3));
    expect(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey<String>('home_add_income_button')),
      findsOneWidget,
    );
    expect(find.text('Start recording your money activity'), findsOneWidget);
    expect(
      find.text(
        'Add your first income or expense to begin building your personal ledger.',
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(
        const ValueKey<String>('home_recent_transactions_empty_state'),
      ),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('No recent transactions yet'), findsOneWidget);
    expect(
      find.text('Income and expenses you add will appear here.'),
      findsOneWidget,
    );
    expect(find.text('Add expense'), findsOneWidget);
    expect(find.text('Add income'), findsOneWidget);
    expect(find.text('Aarav Shrestha'), findsNothing);
    expect(find.textContaining('example.com'), findsNothing);
  });

  testWidgets('the first transaction replaces Home first-use content', (
    WidgetTester tester,
  ) async {
    final InMemoryTransactionRepository repository = await pumpBudgetingApp(
      tester,
    );
    expect(find.text('Start recording your money activity'), findsOneWidget);

    await tester.runAsync(
      () => repository.createTransaction(
        buildTestTransaction(id: 'first-recorded-transaction'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Start recording your money activity'), findsNothing);
    expect(find.text('1 transaction recorded'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Lunch at Thamel'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Lunch at Thamel'), findsOneWidget);
  });

  testWidgets('Recorded Balance explanation is truthful and closable', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 900);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpBudgetingApp(tester);

    final Finder informationButton = find.byKey(
      const ValueKey<String>('recorded_balance_information_button'),
    );
    expect(find.byTooltip('About recorded balance'), findsOneWidget);
    await tester.tap(informationButton);
    await tester.pumpAndSettle();

    expect(find.text('About recorded balance'), findsOneWidget);
    expect(
      find.textContaining(
        'Recorded balance is the difference between the income and expenses '
        'recorded in this app for the current month.',
      ),
      findsOneWidget,
    );
    expect(
      find.textContaining('does not connect to your bank account'),
      findsOneWidget,
    );
    expect(
      find.textContaining('stored locally on this device'),
      findsOneWidget,
    );
    expect(find.text('Stored on this device'), findsOneWidget);
    expect(
      find.text(
        'Your records are not backed up or synchronised across devices.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(
      find.byKey(const ValueKey<String>('close_recorded_balance_information')),
    );
    await tester.pumpAndSettle();
    expect(find.text('About recorded balance'), findsNothing);
    semantics.dispose();
  });

  testWidgets('Home renders loading and repository error states', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(
      tester,
      transactionStream: const Stream<List<FinancialTransaction>>.empty(),
    );
    expect(find.bySemanticsLabel('Loading financial summary'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await pumpBudgetingApp(
      tester,
      transactionStream: Stream<List<FinancialTransaction>>.error(
        StateError('Controlled repository failure'),
      ),
    );
    expect(
      find.text('Your financial summary is unavailable. Try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });
}
