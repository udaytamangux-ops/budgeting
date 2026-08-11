import 'package:budgeting_app/features/transactions/domain/services/transaction_amount_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TransactionAmountCalculator calculate(String first, List<String> keys) {
    final TransactionAmountCalculator calculator = TransactionAmountCalculator(
      initialAmount: first,
    );
    for (final String key in keys) {
      if (int.tryParse(key) case final int digit) {
        calculator.enterDigit(digit);
      } else if (key == '.') {
        calculator.enterDecimal();
      } else {
        calculator.enterOperator(key);
      }
    }
    return calculator;
  }

  test('single integer and decimal convert exactly to Money', () {
    expect(
      TransactionAmountCalculator(
        initialAmount: '1500',
      ).result.money?.minorUnits,
      150000,
    );
    expect(
      TransactionAmountCalculator(
        initialAmount: '1500.50',
      ).result.money?.minorUnits,
      150050,
    );
  });

  test('supports addition subtraction multiplication and division', () {
    expect(
      calculate('500', <String>['+', '2', '5', '0']).result.money?.minorUnits,
      75000,
    );
    expect(
      calculate('1200', <String>['−', '3', '0', '0']).result.money?.minorUnits,
      90000,
    );
    expect(
      calculate('100', <String>['×', '3']).result.money?.minorUnits,
      30000,
    );
    expect(
      calculate('1000', <String>['÷', '4']).result.money?.minorUnits,
      25000,
    );
  });

  test('multiplication and division take precedence', () {
    final TransactionAmountCalculator calculator = calculate('100', <String>[
      '+',
      '2',
      '0',
      '×',
      '2',
    ]);
    expect(calculator.result.money?.minorUnits, 14000);
  });

  test('decimal arithmetic has no binary floating artifact', () {
    final TransactionAmountCalculator calculator = calculate('0.1', <String>[
      '+',
      '0',
      '.',
      '2',
    ]);
    expect(calculator.result.money?.minorUnits, 30);
  });

  test('division rounds to minor units using half-up', () {
    expect(calculate('1', <String>['÷', '6']).result.money?.minorUnits, 17);
    expect(calculate('1', <String>['÷', '8']).result.money?.minorUnits, 13);
  });

  test('a repeated operator replaces the trailing operator', () {
    final TransactionAmountCalculator calculator =
        TransactionAmountCalculator(initialAmount: '500')
          ..enterOperator('+')
          ..enterOperator('×');
    expect(calculator.expression, '500 ×');
  });

  test('leading zero and one decimal per operand remain valid', () {
    final TransactionAmountCalculator calculator = TransactionAmountCalculator()
      ..enterDigit(7)
      ..enterDecimal()
      ..enterDecimal()
      ..enterDigit(5)
      ..enterDigit(0)
      ..enterDigit(9);
    expect(calculator.expression, '7.50');
    expect(calculator.result.money?.minorUnits, 750);
  });

  test('backspace and clear are predictable', () {
    final TransactionAmountCalculator calculator = TransactionAmountCalculator(
      initialAmount: '125',
    )..backspace();
    expect(calculator.expression, '12');
    calculator
      ..enterOperator('+')
      ..backspace();
    expect(calculator.expression, '12');
    calculator.clear();
    expect(calculator.expression, '0');
  });

  test('divide by zero is controlled and cannot commit', () {
    final AmountCalculationResult result = calculate('100', <String>[
      '÷',
      '0',
    ]).result;
    expect(result.error, AmountCalculationError.divideByZero);
    expect(result.canCommit, isFalse);
  });

  test('negative, zero, and trailing-operator results cannot commit', () {
    expect(
      calculate('500', <String>['−', '7', '0', '0']).result.error,
      AmountCalculationError.nonPositive,
    );
    expect(TransactionAmountCalculator().result.canCommit, isFalse);
    expect(
      (TransactionAmountCalculator(
        initialAmount: '500',
      )..enterOperator('+')).result.error,
      AmountCalculationError.incomplete,
    );
  });

  test('values outside the Money input limit are rejected', () {
    final TransactionAmountCalculator calculator =
        TransactionAmountCalculator(initialAmount: '999999999')
          ..enterOperator('×')
          ..enterDigit(9);
    expect(calculator.result.error, AmountCalculationError.tooLarge);
    expect(calculator.result.canCommit, isFalse);
  });
}
