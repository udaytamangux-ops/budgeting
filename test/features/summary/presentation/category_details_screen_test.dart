import 'dart:async';

import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/routing/category_details_route_data.dart';
import 'package:budgeting_app/features/summary/presentation/screens/category_details_screen.dart';
import 'package:budgeting_app/features/summary/presentation/screens/summary_screen.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../support/pump_app.dart';
import '../../../support/test_data.dart';

void main() {
  testWidgets('Category Details presents factual expense category activity', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await _openCategoryDetails(
      tester,
      CategoryDetailsRouteData(
        type: TransactionType.expense,
        categories: <TransactionCategory>[TransactionCategory.food],
        month: DateTime(2026, 8),
      ),
    );

    expect(find.text('Category details'), findsOneWidget);
    expect(find.text('Food'), findsWidgets);
    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('NPR 5,500'), findsOneWidget);
    expect(find.text('24% of August expenses'), findsOneWidget);
    expect(find.text('2 recorded transactions'), findsOneWidget);
    expect(find.text('Average transaction: NPR 2,750'), findsOneWidget);
    expect(find.text('Kathmandu Lunch Club'), findsOneWidget);
    expect(find.text('Bhat-Bhateni'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Expense, NPR 3,300.*Food')),
      findsOneWidget,
    );
  });

  testWidgets('Category Details supports income sources', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await _openCategoryDetails(
      tester,
      CategoryDetailsRouteData(
        type: TransactionType.income,
        categories: <TransactionCategory>[TransactionCategory.salary],
        month: DateTime(2026, 8),
      ),
    );

    expect(find.text('Salary'), findsWidgets);
    expect(find.text('August 2026'), findsOneWidget);
    expect(find.text('NPR 60,000'), findsOneWidget);
    expect(find.text('100% of August income'), findsOneWidget);
    expect(find.text('1 recorded transaction'), findsOneWidget);
    expect(find.text('Average transaction: NPR 60,000'), findsOneWidget);
    expect(find.text('Monthly salary'), findsOneWidget);
  });

  testWidgets('empty category states remain neutral and type-specific', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await _openCategoryDetails(
      tester,
      CategoryDetailsRouteData(
        type: TransactionType.expense,
        categories: <TransactionCategory>[TransactionCategory.health],
        month: DateTime(2026, 8),
      ),
    );

    expect(find.text('No Health activity in August.'), findsOneWidget);
    expect(find.text('0% of August expenses'), findsOneWidget);
    expect(find.textContaining('Average transaction:'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await _pushCategoryDetails(
      tester,
      CategoryDetailsRouteData(
        type: TransactionType.income,
        categories: <TransactionCategory>[TransactionCategory.freelance],
        month: DateTime(2026, 8),
      ),
    );
    expect(find.text('No Freelance activity in August.'), findsOneWidget);
    expect(find.text('0% of August income'), findsOneWidget);
  });

  testWidgets('Summary month and category context survive the nested journey', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey<String>('previous_month_button')),
    );
    await tester.pumpAndSettle();
    final Finder foodRow = find.byKey(
      const ValueKey<String>('summary_category_row_food'),
    );
    await _reveal(tester, foodRow);
    await tester.tap(foodRow);
    await tester.pumpAndSettle();
    await _reveal(
      tester,
      find.byKey(const ValueKey<String>('view_category_transactions_button')),
    );
    await tester.tap(
      find.byKey(const ValueKey<String>('view_category_transactions_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Food'), findsWidgets);
    expect(find.text('July 2026'), findsOneWidget);
    expect(find.text('NPR 5,100'), findsOneWidget);
    expect(find.text('24% of July expenses'), findsOneWidget);
    expect(find.text('Bhat-Bhateni Maharajgunj'), findsOneWidget);
    expect(find.text('Kathmandu Lunch Club'), findsNothing);

    await tester.tap(find.text('Bhat-Bhateni Maharajgunj'));
    await tester.pumpAndSettle();
    expect(find.text('Transaction details'), findsOneWidget);
    expect(find.text('Bhat-Bhateni Maharajgunj'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Category details'), findsOneWidget);
    expect(find.text('July 2026'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    _activeSummaryScrollable(tester).position.jumpTo(0);
    await tester.pump();
    expect(find.text('Summary'), findsWidgets);
    expect(find.text('July 2026'), findsOneWidget);
    expect(find.text('All categories'), findsOneWidget);
  });

  testWidgets('Category Details fits 320 px at 2x text scaling', (
    WidgetTester tester,
  ) async {
    _configureView(tester, width: 320, textScale: 2);
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await _openCategoryDetails(
      tester,
      CategoryDetailsRouteData(
        type: TransactionType.expense,
        categories: <TransactionCategory>[TransactionCategory.food],
        month: DateTime(2026, 8),
      ),
    );
    await _reveal(tester, find.text('Bhat-Bhateni'));

    expect(find.text('Bhat-Bhateni'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Category Details remains bounded at 768 px', (
    WidgetTester tester,
  ) async {
    _configureView(tester, width: 768);
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await _openCategoryDetails(
      tester,
      CategoryDetailsRouteData(
        type: TransactionType.income,
        categories: <TransactionCategory>[TransactionCategory.salary],
        month: DateTime(2026, 8),
      ),
    );

    expect(find.text('Monthly salary'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('large NPR values do not overflow Category Details', (
    WidgetTester tester,
  ) async {
    _configureView(tester, width: 320);
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[
        buildTestTransaction(
          id: 'large-income',
          type: TransactionType.income,
          minorUnits: 98765432100,
          category: TransactionCategory.salary,
          merchant: 'A very long Nepal-based employer source name',
        ),
      ],
    );
    await _openCategoryDetails(
      tester,
      CategoryDetailsRouteData(
        type: TransactionType.income,
        categories: <TransactionCategory>[TransactionCategory.salary],
        month: DateTime(2026, 8),
      ),
    );

    expect(find.text('NPR 987,654,321'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Category Details meets labelled tap-target guidelines', (
    WidgetTester tester,
  ) async {
    _configureView(tester, width: 390);
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpBudgetingApp(tester, useMockTransactions: true);
    await _openCategoryDetails(
      tester,
      CategoryDetailsRouteData(
        type: TransactionType.expense,
        categories: <TransactionCategory>[TransactionCategory.food],
        month: DateTime(2026, 8),
      ),
    );

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    expect(
      find.bySemanticsLabel(RegExp('Food, August 2026, NPR 5,500')),
      findsOneWidget,
    );
    semantics.dispose();
  });
}

Future<void> _reveal(WidgetTester tester, Finder target) async {
  final Finder scrollable = find
      .descendant(
        of: find.byType(CategoryDetailsScreen).evaluate().isNotEmpty
            ? find.byType(CategoryDetailsScreen)
            : find.byType(SummaryScreen),
        matching: find.byType(Scrollable),
      )
      .first;
  if (target.evaluate().isEmpty) {
    await tester.scrollUntilVisible(target, 240, scrollable: scrollable);
  }
  await Scrollable.ensureVisible(
    tester.element(target),
    alignment: 0.45,
    duration: Duration.zero,
  );
  await tester.pump();
}

ScrollableState _activeSummaryScrollable(WidgetTester tester) {
  return tester.state<ScrollableState>(
    find
        .descendant(
          of: find.byType(SummaryScreen),
          matching: find.byType(Scrollable),
        )
        .first,
  );
}

Future<void> _openCategoryDetails(
  WidgetTester tester,
  CategoryDetailsRouteData routeData,
) async {
  await tester.tap(find.text('Summary'));
  await tester.pumpAndSettle();
  await _pushCategoryDetails(tester, routeData);
}

Future<void> _pushCategoryDetails(
  WidgetTester tester,
  CategoryDetailsRouteData routeData,
) async {
  final BuildContext context = tester.element(find.byType(SummaryScreen));
  unawaited(
    GoRouter.of(context).push<void>(AppRoutes.categoryDetails(routeData)),
  );
  await tester.pumpAndSettle();
}

void _configureView(
  WidgetTester tester, {
  required double width,
  double textScale = 1,
}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 900);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}
