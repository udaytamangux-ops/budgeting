import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/features/transactions/domain/entities/payment_method_metadata.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter/material.dart';

final class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    required this.type,
    required this.value,
    required this.onChanged,
    this.recentMethods = const <PaymentMethod>[],
    this.onRecentChanged,
    this.isEnabled = true,
    super.key,
  });

  final TransactionType type;
  final PaymentMethod value;
  final List<PaymentMethod> recentMethods;
  final ValueChanged<PaymentMethod> onChanged;
  final ValueChanged<PaymentMethod>? onRecentChanged;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final String label = type == TransactionType.expense
        ? 'Paid via'
        : 'Received via';
    final bool showRecent = recentMethods.length >= 2;
    return Semantics(
      container: true,
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          if (showRecent) ...<Widget>[
            Text('Recent', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: recentMethods
                  .map(
                    (PaymentMethod method) => _RecentPaymentMethodOption(
                      key: ValueKey<String>(
                        'recent_payment_method_${method.stableIdentifier}',
                      ),
                      method: method,
                      isSelected: value == method,
                      isEnabled: isEnabled,
                      onTap: () => (onRecentChanged ?? onChanged).call(method),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('All methods', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
          ],
          Semantics(
            key: const ValueKey<String>('payment_method_field'),
            label: '$label, ${value.label}',
            child: DropdownButtonFormField<PaymentMethod>(
              key: ValueKey<String>(
                'payment_method_dropdown_${type.name}_${value.name}',
              ),
              initialValue: value,
              decoration: InputDecoration(
                prefixIcon: Icon(_paymentMethodIcon(value)),
              ),
              isExpanded: true,
              items: PaymentMethod.values
                  .map(
                    (PaymentMethod method) => DropdownMenuItem<PaymentMethod>(
                      value: method,
                      child: Row(
                        children: <Widget>[
                          Icon(_paymentMethodIcon(method), size: 20),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              method.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: isEnabled
                  ? (PaymentMethod? method) {
                      if (method != null) {
                        onChanged(method);
                      }
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

final class _RecentPaymentMethodOption extends StatelessWidget {
  const _RecentPaymentMethodOption({
    required this.method,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
    super.key,
  });

  final PaymentMethod method;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      enabled: isEnabled,
      label: '${method.label} payment method',
      excludeSemantics: true,
      onTap: isEnabled ? onTap : null,
      child: Material(
        color: isSelected
            ? context.appColors.primarySubtle
            : context.appColors.surfacePrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.small),
          side: BorderSide(
            color: isSelected
                ? context.appColors.primaryAction
                : context.appColors.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(AppRadius.small),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    _paymentMethodIcon(method),
                    size: 18,
                    color: isSelected
                        ? context.appColors.primaryAction
                        : context.appColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      method.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? context.appColors.primaryAction
                            : context.appColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isSelected) ...<Widget>[
                    const SizedBox(width: AppSpacing.xs),
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: context.appColors.primaryAction,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

IconData _paymentMethodIcon(PaymentMethod method) => switch (method) {
  PaymentMethod.cash => Icons.payments_outlined,
  PaymentMethod.bankAccount => Icons.account_balance_outlined,
  PaymentMethod.card => Icons.credit_card_outlined,
  PaymentMethod.eSewa ||
  PaymentMethod.khalti ||
  PaymentMethod.imePay ||
  PaymentMethod.otherDigitalWallet => Icons.account_balance_wallet_outlined,
  PaymentMethod.other => Icons.more_horiz,
};
