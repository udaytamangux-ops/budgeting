import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump_app.dart';
import '../support/test_data.dart';

void main() {
  const List<double> testedWidths = <double>[320, 360, 390, 430, 480, 768];

  for (final double width in testedWidths) {
    testWidgets('Home and Add Expense do not overflow at ${width.toInt()} px', (
      WidgetTester tester,
    ) async {
      _configureView(tester, width: width);
      await pumpBudgetingApp(tester);

      expect(tester.takeException(), isNull);
      await tester.tap(
        find.byKey(const ValueKey<String>('home_add_expense_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Add transaction'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('primary flow remains usable with large system text', (
    WidgetTester tester,
  ) async {
    _configureView(tester, width: 320);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await pumpBudgetingApp(tester);
    expect(find.text('NPR 37,250'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();
    expect(find.text('Add transaction'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('long content and a large NPR amount remain bounded', (
    WidgetTester tester,
  ) async {
    _configureView(tester, width: 320);
    await pumpBudgetingApp(
      tester,
      seedTransactions: <FinancialTransaction>[
        buildTestTransaction(
          id: 'long-content',
          minorUnits: 99999999900,
          category: TransactionCategory.rentAndHousing,
          merchant: 'Kathmandu Metropolitan Household Services and Supplies',
        ),
      ],
    );

    await tester.scrollUntilVisible(
      find.text('Kathmandu Metropolitan Household Services and Supplies'),
      360,
      scrollable: find.byType(Scrollable).first,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('financial animations resolve immediately with reduced motion', (
    WidgetTester tester,
  ) async {
    _configureView(tester, width: 390);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

    await pumpBudgetingApp(tester);
    final Iterable<AnimatedSwitcher> switchers = tester.widgetList(
      find.byType(AnimatedSwitcher),
    );

    expect(switchers, isNotEmpty);
    expect(
      switchers.every(
        (AnimatedSwitcher value) => value.duration == Duration.zero,
      ),
      isTrue,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home and Add Expense meet baseline accessibility guidelines', (
    WidgetTester tester,
  ) async {
    _configureView(tester, width: 390);
    final SemanticsHandle semantics = tester.ensureSemantics();
    await pumpBudgetingApp(tester);

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));

    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });
}

void _configureView(WidgetTester tester, {required double width}) {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = Size(width, 920);
  addTearDown(tester.view.reset);
}
