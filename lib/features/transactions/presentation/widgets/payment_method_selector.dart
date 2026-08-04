import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_visuals.dart';
import 'package:flutter/material.dart';

final class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final PaymentMethod value;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<PaymentMethod>(
      key: const ValueKey<String>('payment_method_field'),
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Payment method',
        helperText: 'Required',
      ),
      isExpanded: true,
      items: PaymentMethod.values
          .map((PaymentMethod method) {
            return DropdownMenuItem<PaymentMethod>(
              value: method,
              child: Text(method.label),
            );
          })
          .toList(growable: false),
      onChanged: (PaymentMethod? method) {
        if (method != null) {
          onChanged(method);
        }
      },
    );
  }
}
