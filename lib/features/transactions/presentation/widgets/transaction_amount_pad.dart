import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/features/transactions/domain/services/transaction_amount_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class TransactionAmountWorkingState {
  const TransactionAmountWorkingState({
    required this.expression,
    required this.interacted,
    required this.showValidationError,
  });

  final String expression;
  final bool interacted;
  final bool showValidationError;
}

final class TransactionAmountPad extends ConsumerStatefulWidget {
  const TransactionAmountPad({
    required this.initialAmount,
    required this.onDone,
    required this.onClose,
    this.initialExpression,
    this.initiallyInteracted = false,
    this.initiallyShowValidationError = false,
    this.onWorkingStateChanged,
    super.key,
  });

  final String initialAmount;
  final String? initialExpression;
  final bool initiallyInteracted;
  final bool initiallyShowValidationError;
  final ValueChanged<String> onDone;
  final VoidCallback onClose;
  final ValueChanged<TransactionAmountWorkingState>? onWorkingStateChanged;

  @override
  ConsumerState<TransactionAmountPad> createState() =>
      _TransactionAmountPadState();
}

final class _TransactionAmountPadState
    extends ConsumerState<TransactionAmountPad> {
  late final TransactionAmountCalculator _calculator;
  late bool _hasInteracted;
  late bool _showValidationError;

  @override
  void initState() {
    super.initState();
    final String? expression = widget.initialExpression;
    _calculator = expression == null
        ? TransactionAmountCalculator(initialAmount: widget.initialAmount)
        : TransactionAmountCalculator.fromExpression(expression);
    _hasInteracted = widget.initiallyInteracted;
    _showValidationError = widget.initiallyShowValidationError;
  }

  @override
  Widget build(BuildContext context) {
    final AmountCalculationResult result = _calculator.result;
    final bool showError = result.error != null && _showValidationError;
    final String formattedResult = result.money == null
        ? 'NPR 0'
        : ref.watch(currencyFormatterProvider).format(result.money!);
    final String resultText = showError ? result.message! : formattedResult;
    return Semantics(
      container: true,
      label: 'Transaction amount calculator',
      child: SafeArea(
        top: false,
        child: Material(
          key: const ValueKey<String>('transaction_amount_pad'),
          color: context.appColors.surfacePrimary,
          elevation: 8,
          shadowColor: Colors.black.withValues(alpha: 0.12),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: context.appColors.borderSubtle),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.xs,
                AppSpacing.sm,
                AppSpacing.sm,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            SingleChildScrollView(
                              reverse: true,
                              scrollDirection: Axis.horizontal,
                              child: Text(
                                _calculator.expression,
                                key: const ValueKey<String>(
                                  'calculator_expression',
                                ),
                                maxLines: 1,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: context.appColors.textSecondary,
                                    ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Semantics(
                              liveRegion: showError,
                              label: showError
                                  ? resultText
                                  : 'Calculated result $resultText',
                              child: Text(
                                resultText,
                                key: const ValueKey<String>(
                                  'calculator_result',
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      color: showError
                                          ? context.appColors.destructiveAction
                                          : context.appColors.textPrimary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        key: const ValueKey<String>('calculator_close'),
                        tooltip: 'Close calculator',
                        onPressed: widget.onClose,
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _KeyRow(keys: _operatorKeys, onPressed: _handleKey),
                  _KeyRow(keys: _numberRowOne, onPressed: _handleKey),
                  _KeyRow(keys: _numberRowTwo, onPressed: _handleKey),
                  _KeyRow(keys: _numberRowThree, onPressed: _handleKey),
                  _KeyRow(keys: _bottomKeys, onPressed: _handleKey),
                  const SizedBox(height: AppSpacing.xs),
                  SizedBox(
                    width: double.infinity,
                    child: Semantics(
                      button: true,
                      label: 'Use calculated amount',
                      excludeSemantics: true,
                      child: FilledButton(
                        key: const ValueKey<String>('calculator_done'),
                        onPressed: _handleDone,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        child: const Text('Done'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleDone() {
    final AmountCalculationResult result = _calculator.result;
    if (!result.canCommit) {
      setState(() {
        _hasInteracted = true;
        _showValidationError = true;
      });
      _notifyWorkingState();
      return;
    }
    widget.onDone(_calculator.committedAmountText());
  }

  void _handleKey(String value) {
    setState(() {
      switch (value) {
        case 'C':
          _calculator.clear();
          _hasInteracted = false;
          _showValidationError = false;
        case '⌫':
          _calculator.backspace();
          _hasInteracted = true;
        case '.':
          _calculator.enterDecimal();
          _hasInteracted = true;
        case '+' || '−' || '×' || '÷':
          _calculator.enterOperator(value);
          _hasInteracted = true;
        default:
          _calculator.enterDigit(int.parse(value));
          _hasInteracted = true;
      }
      _showValidationError = _showsImmediately(_calculator.result.error);
    });
    _notifyWorkingState();
  }

  void _notifyWorkingState() {
    widget.onWorkingStateChanged?.call(
      TransactionAmountWorkingState(
        expression: _calculator.expression,
        interacted: _hasInteracted,
        showValidationError: _showValidationError,
      ),
    );
  }

  bool _showsImmediately(AmountCalculationError? error) {
    return error == AmountCalculationError.divideByZero ||
        (error == AmountCalculationError.nonPositive &&
            _calculator.expression.contains(' − ')) ||
        error == AmountCalculationError.tooLarge;
  }
}

final class _KeyRow extends StatelessWidget {
  const _KeyRow({required this.keys, required this.onPressed});

  final List<_PadKey> keys;
  final ValueChanged<String> onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (final _PadKey key in keys)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxs),
              child: _CalculatorKey(
                value: key,
                onPressed: () => onPressed(key.value),
              ),
            ),
          ),
      ],
    );
  }
}

const List<_PadKey> _operatorKeys = <_PadKey>[
  _PadKey('+', 'Add'),
  _PadKey('−', 'Subtract'),
  _PadKey('×', 'Multiply'),
  _PadKey('÷', 'Divide'),
  _PadKey('⌫', 'Delete last digit'),
];
const List<_PadKey> _numberRowOne = <_PadKey>[
  _PadKey('1', 'One'),
  _PadKey('2', 'Two'),
  _PadKey('3', 'Three'),
];
const List<_PadKey> _numberRowTwo = <_PadKey>[
  _PadKey('4', 'Four'),
  _PadKey('5', 'Five'),
  _PadKey('6', 'Six'),
];
const List<_PadKey> _numberRowThree = <_PadKey>[
  _PadKey('7', 'Seven'),
  _PadKey('8', 'Eight'),
  _PadKey('9', 'Nine'),
];
const List<_PadKey> _bottomKeys = <_PadKey>[
  _PadKey('C', 'Clear calculation'),
  _PadKey('0', 'Zero'),
  _PadKey('.', 'Decimal point'),
];

final class _PadKey {
  const _PadKey(this.value, this.semanticLabel);

  final String value;
  final String semanticLabel;
}

final class _CalculatorKey extends StatelessWidget {
  const _CalculatorKey({required this.value, required this.onPressed});

  final _PadKey value;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: value.semanticLabel,
      excludeSemantics: true,
      child: OutlinedButton(
        key: ValueKey<String>('calculator_key_${value.value}'),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        ),
        child: Text(value.value),
      ),
    );
  }
}
