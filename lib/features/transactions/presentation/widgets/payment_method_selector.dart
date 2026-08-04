import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_visuals.dart';
import 'package:flutter/material.dart';

final class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    required this.type,
    required this.value,
    required this.onChanged,
    this.isEnabled = true,
    super.key,
  });

  final TransactionType type;
  final PaymentMethod value;
  final ValueChanged<PaymentMethod> onChanged;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final String label = type == TransactionType.expense
        ? 'Payment method'
        : 'Received via';
    return Semantics(
      key: const ValueKey<String>('payment_method_field'),
      child: DropdownButtonFormField<PaymentMethod>(
        key: ValueKey<String>(
          'payment_method_dropdown_${type.name}_${value.name}',
        ),
        initialValue: value,
        decoration: InputDecoration(labelText: label),
        isExpanded: true,
        items: PaymentMethod.values
            .map((PaymentMethod method) {
              return DropdownMenuItem<PaymentMethod>(
                value: method,
                child: Text(method.label),
              );
            })
            .toList(growable: false),
        onChanged: isEnabled
            ? (PaymentMethod? method) {
                if (method != null) {
                  onChanged(method);
                }
              }
            : null,
      ),
    );
  }
}
