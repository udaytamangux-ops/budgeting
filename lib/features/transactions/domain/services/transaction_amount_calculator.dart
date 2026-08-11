import 'package:budgeting_app/features/transactions/domain/entities/money.dart';

enum AmountCalculationError { incomplete, divideByZero, nonPositive, tooLarge }

final class AmountCalculationResult {
  const AmountCalculationResult({this.money, this.error});

  final Money? money;
  final AmountCalculationError? error;

  bool get canCommit => money?.isPositive ?? false;

  String? get message => switch (error) {
    AmountCalculationError.incomplete => 'Complete the calculation.',
    AmountCalculationError.divideByZero => 'Cannot divide by zero.',
    AmountCalculationError.nonPositive =>
      'Calculated amount must be greater than NPR 0.',
    AmountCalculationError.tooLarge => 'Calculated amount is too large.',
    null => null,
  };
}

final class TransactionAmountCalculator {
  TransactionAmountCalculator({String initialAmount = ''})
    : _tokens = <String>[_normalizeInitial(initialAmount)];

  factory TransactionAmountCalculator.fromExpression(String expression) {
    final String trimmed = expression.trim();
    if (trimmed.isEmpty || trimmed.length > maximumExpressionLength) {
      return TransactionAmountCalculator();
    }
    final List<String> tokens = trimmed.split(RegExp(r'\s+'));
    for (int index = 0; index < tokens.length; index += 1) {
      final bool isOperatorPosition = index.isOdd;
      final bool isValid = isOperatorPosition
          ? _isOperator(tokens[index])
          : RegExp(r'^\d+(?:\.\d{0,2})?$').hasMatch(tokens[index]);
      if (!isValid) {
        return TransactionAmountCalculator();
      }
    }
    return TransactionAmountCalculator._(tokens);
  }

  TransactionAmountCalculator._(List<String> tokens)
    : _tokens = List<String>.of(tokens);

  static final BigInt maximumMinorUnits = BigInt.from(99999999999);
  static const int maximumExpressionLength = 120;

  final List<String> _tokens;

  String get expression => _tokens.join(' ');

  AmountCalculationResult get result {
    if (_isOperator(_tokens.last)) {
      return const AmountCalculationResult(
        error: AmountCalculationError.incomplete,
      );
    }
    try {
      final _Rational value = _evaluate(_tokens);
      if (value.numerator <= BigInt.zero) {
        return const AmountCalculationResult(
          error: AmountCalculationError.nonPositive,
        );
      }
      final BigInt minorUnits = value.roundedMinorUnits();
      if (minorUnits <= BigInt.zero) {
        return const AmountCalculationResult(
          error: AmountCalculationError.nonPositive,
        );
      }
      if (minorUnits > maximumMinorUnits) {
        return const AmountCalculationResult(
          error: AmountCalculationError.tooLarge,
        );
      }
      return AmountCalculationResult(
        money: Money(minorUnits: minorUnits.toInt()),
      );
    } on _DivideByZeroException {
      return const AmountCalculationResult(
        error: AmountCalculationError.divideByZero,
      );
    } on FormatException {
      return const AmountCalculationResult(
        error: AmountCalculationError.incomplete,
      );
    }
  }

  void enterDigit(int digit) {
    if (digit < 0 || digit > 9) return;
    if (_isOperator(_tokens.last)) _tokens.add('0');
    final String current = _tokens.last;
    final int decimalIndex = current.indexOf('.');
    if (decimalIndex >= 0 && current.length - decimalIndex - 1 >= 2) return;
    final String next = current == '0' ? '$digit' : '$current$digit';
    _replaceLastIfWithinLimit(next);
  }

  void enterDecimal() {
    if (_isOperator(_tokens.last)) _tokens.add('0');
    if (_tokens.last.contains('.')) return;
    _replaceLastIfWithinLimit('${_tokens.last}.');
  }

  void enterOperator(String operator) {
    if (!_isOperator(operator)) return;
    if (_isOperator(_tokens.last)) {
      _tokens[_tokens.length - 1] = operator;
      return;
    }
    if (expression.length + 3 > maximumExpressionLength) return;
    _tokens.add(operator);
  }

  void backspace() {
    if (_tokens.length == 1 && _tokens.single == '0') return;
    if (_isOperator(_tokens.last)) {
      _tokens.removeLast();
      return;
    }
    final String current = _tokens.last;
    if (current.length <= 1) {
      if (_tokens.length == 1) {
        _tokens[0] = '0';
      } else {
        _tokens.removeLast();
      }
      return;
    }
    _tokens[_tokens.length - 1] = current.substring(0, current.length - 1);
  }

  void clear() {
    _tokens
      ..clear()
      ..add('0');
  }

  String committedAmountText() {
    final Money? money = result.money;
    if (money == null || !result.canCommit) return '';
    final int whole = money.minorUnits ~/ 100;
    final int minor = money.minorUnits % 100;
    return minor == 0 ? '$whole' : '$whole.${minor.toString().padLeft(2, '0')}';
  }

  void _replaceLastIfWithinLimit(String replacement) {
    final int projected =
        expression.length - _tokens.last.length + replacement.length;
    if (projected <= maximumExpressionLength) {
      _tokens[_tokens.length - 1] = replacement;
    }
  }

  static String _normalizeInitial(String input) {
    final String trimmed = input.trim();
    return RegExp(r'^\d+(?:\.\d{0,2})?$').hasMatch(trimmed) ? trimmed : '0';
  }

  static bool _isOperator(String value) =>
      value == '+' || value == '−' || value == '×' || value == '÷';

  static _Rational _evaluate(List<String> tokens) {
    final List<_Rational> terms = <_Rational>[];
    final List<String> additiveOperators = <String>[];
    _Rational current = _Rational.parse(tokens.first);
    for (int index = 1; index < tokens.length; index += 2) {
      if (index + 1 >= tokens.length) throw const FormatException();
      final String operator = tokens[index];
      final _Rational operand = _Rational.parse(tokens[index + 1]);
      if (operator == '×') {
        current = current.multiply(operand);
      } else if (operator == '÷') {
        current = current.divide(operand);
      } else {
        terms.add(current);
        additiveOperators.add(operator);
        current = operand;
      }
    }
    terms.add(current);
    _Rational total = terms.first;
    for (int index = 0; index < additiveOperators.length; index += 1) {
      total = additiveOperators[index] == '+'
          ? total.add(terms[index + 1])
          : total.subtract(terms[index + 1]);
    }
    return total;
  }
}

final class _Rational {
  _Rational(BigInt numerator, BigInt denominator)
    : numerator = denominator.isNegative ? -numerator : numerator,
      denominator = denominator.abs() {
    if (denominator == BigInt.zero) throw const _DivideByZeroException();
  }

  factory _Rational.parse(String value) {
    if (!RegExp(r'^\d+(?:\.\d{0,2})?$').hasMatch(value)) {
      throw const FormatException();
    }
    final List<String> parts = value.split('.');
    if (parts.length == 1 || parts[1].isEmpty) {
      return _Rational(BigInt.parse(parts.first), BigInt.one);
    }
    final BigInt denominator = BigInt.from(10).pow(parts[1].length);
    return _Rational(
      BigInt.parse(parts.first) * denominator + BigInt.parse(parts[1]),
      denominator,
    );
  }

  final BigInt numerator;
  final BigInt denominator;

  _Rational add(_Rational other) => _Rational(
    numerator * other.denominator + other.numerator * denominator,
    denominator * other.denominator,
  );

  _Rational subtract(_Rational other) => _Rational(
    numerator * other.denominator - other.numerator * denominator,
    denominator * other.denominator,
  );

  _Rational multiply(_Rational other) =>
      _Rational(numerator * other.numerator, denominator * other.denominator);

  _Rational divide(_Rational other) {
    if (other.numerator == BigInt.zero) {
      throw const _DivideByZeroException();
    }
    return _Rational(
      numerator * other.denominator,
      denominator * other.numerator,
    );
  }

  BigInt roundedMinorUnits() {
    final BigInt scaled = numerator * BigInt.from(100);
    final BigInt whole = scaled ~/ denominator;
    final BigInt remainder = scaled.remainder(denominator).abs();
    if (remainder * BigInt.two >= denominator) {
      return scaled.isNegative ? whole - BigInt.one : whole + BigInt.one;
    }
    return whole;
  }
}

final class _DivideByZeroException implements Exception {
  const _DivideByZeroException();
}
