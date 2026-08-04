import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final class BudgetAmountResult {
  const BudgetAmountResult({required this.amount, this.category});

  final Money amount;
  final TransactionCategory? category;
}

final class BudgetAmountDialog extends StatefulWidget {
  const BudgetAmountDialog({
    required this.title,
    required this.confirmLabel,
    this.initialAmount,
    this.availableCategories = const <TransactionCategory>[],
    super.key,
  });

  final String title;
  final String confirmLabel;
  final Money? initialAmount;
  final List<TransactionCategory> availableCategories;

  @override
  State<BudgetAmountDialog> createState() => _BudgetAmountDialogState();
}

final class _BudgetAmountDialogState extends State<BudgetAmountDialog> {
  late final TextEditingController _amountController;
  TransactionCategory? _selectedCategory;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    final Money? initialAmount = widget.initialAmount;
    _amountController = TextEditingController(
      text: initialAmount == null ? '' : '${initialAmount.minorUnits ~/ 100}',
    );
    _selectedCategory = widget.availableCategories.firstOrNull;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (widget.availableCategories.isNotEmpty) ...<Widget>[
              DropdownButtonFormField<TransactionCategory>(
                key: const ValueKey<String>('budget_category_input'),
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                isExpanded: true,
                items: widget.availableCategories
                    .map(
                      (TransactionCategory category) =>
                          DropdownMenuItem<TransactionCategory>(
                            value: category,
                            child: Text(category.visual.label),
                          ),
                    )
                    .toList(growable: false),
                onChanged: (TransactionCategory? value) {
                  setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            TextField(
              key: const ValueKey<String>('budget_amount_input'),
              controller: _amountController,
              autofocus: true,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              onChanged: (_) {
                if (_amountError != null) {
                  setState(() => _amountError = null);
                }
              },
              onSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                labelText: 'Budget amount',
                prefixText: 'NPR ',
                errorText: _amountError,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }

  void _submit() {
    final int? rupees = int.tryParse(_amountController.text.trim());
    if (rupees == null || rupees <= 0) {
      setState(() {
        _amountError = 'Enter an amount greater than NPR 0.';
      });
      return;
    }
    Navigator.of(context).pop(
      BudgetAmountResult(
        amount: Money(minorUnits: rupees * 100),
        category: _selectedCategory,
      ),
    );
  }
}
