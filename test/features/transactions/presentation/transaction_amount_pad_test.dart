import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_amount_pad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/pump_app.dart';

void main() {
  testWidgets('app-owned amount pad evaluates and commits an exact result', (
    WidgetTester tester,
  ) async {
    String? committed;
    await _pumpPad(tester, onDone: (String value) => committed = value);

    await _tapKey(tester, '3');
    await _tapKey(tester, '5');
    await _tapKey(tester, '0');
    await _tapKey(tester, '+');
    await _tapKey(tester, '2');
    await _tapKey(tester, '8');
    await _tapKey(tester, '0');
    await _tapKey(tester, '+');
    await _tapKey(tester, '4');
    await _tapKey(tester, '2');
    await _tapKey(tester, '0');

    expect(find.text('350 + 280 + 420'), findsOneWidget);
    expect(find.text('NPR 1,050'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('calculator_done')));
    expect(committed, '1050');
  });

  testWidgets('divide by zero is controlled and cannot commit', (
    WidgetTester tester,
  ) async {
    String? committed;
    await _pumpPad(
      tester,
      initialAmount: '100',
      onDone: (String value) => committed = value,
    );
    await _tapKey(tester, '\u00f7');
    await _tapKey(tester, '0');

    expect(find.text('Cannot divide by zero.'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey<String>('calculator_done')));
    expect(committed, isNull);
    expect(find.textContaining('Infinity'), findsNothing);
    expect(find.textContaining('NaN'), findsNothing);
  });

  testWidgets('calculator keys expose clear accessible actions', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle semantics = tester.ensureSemantics();
    await _pumpPad(tester);

    expect(find.bySemanticsLabel('Seven'), findsOneWidget);
    expect(find.bySemanticsLabel('Add'), findsOneWidget);
    expect(find.bySemanticsLabel('Subtract'), findsOneWidget);
    expect(find.bySemanticsLabel('Multiply'), findsOneWidget);
    expect(find.bySemanticsLabel('Divide'), findsOneWidget);
    expect(find.bySemanticsLabel('Delete last digit'), findsOneWidget);
    expect(find.bySemanticsLabel('Clear calculation'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('Seven'))
          .flagsCollection
          .isButton,
      isTrue,
    );
    expect(
      tester.getSize(find.bySemanticsLabel('Seven')).height,
      greaterThanOrEqualTo(48),
    );
    semantics.dispose();
  });

  testWidgets('untouched zero is neutral until Done is attempted', (
    WidgetTester tester,
  ) async {
    await _pumpPad(tester);

    expect(
      find.text('Calculated amount must be greater than NPR 0.'),
      findsNothing,
    );
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey<String>('calculator_result')))
          .data,
      'NPR 0',
    );

    await tester.tap(find.byKey(const ValueKey<String>('calculator_done')));
    await tester.pump();
    expect(
      find.text('Calculated amount must be greater than NPR 0.'),
      findsOneWidget,
    );

    await _tapKey(tester, '1');
    expect(
      find.text('Calculated amount must be greater than NPR 0.'),
      findsNothing,
    );
    expect(find.text('NPR 1'), findsOneWidget);
  });

  testWidgets('backspace sits directly beside Divide in the operator row', (
    WidgetTester tester,
  ) async {
    await _pumpPad(tester);

    final Offset divide = tester.getCenter(find.bySemanticsLabel('Divide'));
    final Offset backspace = tester.getCenter(
      find.bySemanticsLabel('Delete last digit'),
    );
    expect((backspace.dy - divide.dy).abs(), lessThan(1));
    expect(backspace.dx, greaterThan(divide.dx));

    await _tapKey(tester, '1');
    await _tapKey(tester, '2');
    await _tapKey(tester, '⌫');
    expect(find.text('NPR 1'), findsOneWidget);
  });

  testWidgets('a freshly opened form calculator shows neutral zero', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);
    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey<String>('amount_input')));
    await tester.pumpAndSettle();

    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey<String>('calculator_result')))
          .data,
      'NPR 0',
    );
    expect(
      find.text('Calculated amount must be greater than NPR 0.'),
      findsNothing,
    );
  });

  testWidgets('amount field opens the pad without a system keyboard', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);
    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();

    final Finder amount = find.byKey(const ValueKey<String>('amount_input'));
    expect(tester.widget<TextField>(amount).keyboardType, TextInputType.none);
    await tester.tap(amount);
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('transaction_amount_pad')),
      findsOneWidget,
    );
    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('Add Income commits calculator output to the shared form', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);
    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_income_button')),
    );
    await tester.pumpAndSettle();
    final Finder amount = find.byKey(const ValueKey<String>('amount_input'));
    await tester.tap(amount);
    await tester.pumpAndSettle();

    await _tapFormKey(tester, '1');
    await _tapFormKey(tester, '0');
    await _tapFormKey(tester, '0');
    await _tapFormKey(tester, '+');
    await _tapFormKey(tester, '2');
    await _tapFormKey(tester, '5');
    tester
        .widget<FilledButton>(
          find.byKey(const ValueKey<String>('calculator_done')),
        )
        .onPressed!();
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(amount).controller?.text, '125');
    expect(
      find.byKey(const ValueKey<String>('transaction_amount_pad')),
      findsNothing,
    );
  });

  testWidgets('closing a reopened calculator preserves committed amount', (
    WidgetTester tester,
  ) async {
    await pumpBudgetingApp(tester);
    await tester.tap(
      find.byKey(const ValueKey<String>('home_add_expense_button')),
    );
    await tester.pumpAndSettle();
    final Finder amount = find.byKey(const ValueKey<String>('amount_input'));
    await tester.tap(amount);
    await tester.pumpAndSettle();
    await _tapFormKey(tester, '5');
    await _tapFormKey(tester, '0');
    await _tapFormKey(tester, '0');
    tester
        .widget<FilledButton>(
          find.byKey(const ValueKey<String>('calculator_done')),
        )
        .onPressed!();
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(amount).controller?.text, '500');

    await tester.scrollUntilVisible(
      amount,
      -180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(amount);
    await tester.pumpAndSettle();
    expect(find.text('500'), findsWidgets);
    await tester.tap(find.byTooltip('Close calculator'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(amount).controller?.text, '500');
  });

  testWidgets('pad fits a 320px dark large-text surface', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 1000);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

    await _pumpPad(tester, initialAmount: '999999999.99');
    expect(find.bySemanticsLabel('Use calculated amount'), findsOneWidget);
    for (final String label in <String>[
      'Add',
      'Subtract',
      'Multiply',
      'Divide',
      'Delete last digit',
    ]) {
      expect(
        tester.getSize(find.bySemanticsLabel(label)).width,
        greaterThanOrEqualTo(48),
      );
    }
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pumpPad(
  WidgetTester tester, {
  String initialAmount = '',
  ValueChanged<String>? onDone,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TransactionAmountPad(
              initialAmount: initialAmount,
              onDone: onDone ?? (_) {},
              onClose: () {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapKey(WidgetTester tester, String value) async {
  await tester.tap(find.byKey(ValueKey<String>('calculator_key_$value')));
  await tester.pump();
}

Future<void> _tapFormKey(WidgetTester tester, String value) async {
  final Finder key = find.byKey(ValueKey<String>('calculator_key_$value'));
  tester.widget<OutlinedButton>(key).onPressed!();
  await tester.pump();
}
