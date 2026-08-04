import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter/material.dart';

final class TransactionCategoryVisual {
  const TransactionCategoryVisual({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;
}

extension TransactionCategoryPresentation on TransactionCategory {
  TransactionCategoryVisual get visual {
    return switch (this) {
      TransactionCategory.food => const TransactionCategoryVisual(
        label: 'Food',
        icon: Icons.restaurant_outlined,
        foreground: AppColors.budgetWarning,
        background: AppColors.warningSubtle,
      ),
      TransactionCategory.transport => const TransactionCategoryVisual(
        label: 'Transport',
        icon: Icons.directions_bus_outlined,
        foreground: AppColors.primaryAction,
        background: AppColors.primarySubtle,
      ),
      TransactionCategory.rentAndHousing => const TransactionCategoryVisual(
        label: 'Rent & Housing',
        icon: Icons.home_outlined,
        foreground: AppColors.textPrimary,
        background: AppColors.surfaceSecondary,
      ),
      TransactionCategory.utilities => const TransactionCategoryVisual(
        label: 'Utilities',
        icon: Icons.bolt_outlined,
        foreground: AppColors.budgetWarning,
        background: AppColors.warningSubtle,
      ),
      TransactionCategory.shopping => const TransactionCategoryVisual(
        label: 'Shopping',
        icon: Icons.shopping_bag_outlined,
        foreground: AppColors.primaryAction,
        background: AppColors.primarySubtle,
      ),
      TransactionCategory.health => const TransactionCategoryVisual(
        label: 'Health',
        icon: Icons.health_and_safety_outlined,
        foreground: AppColors.destructiveAction,
        background: AppColors.dangerSubtle,
      ),
      TransactionCategory.education => const TransactionCategoryVisual(
        label: 'Education',
        icon: Icons.school_outlined,
        foreground: AppColors.primaryAction,
        background: AppColors.primarySubtle,
      ),
      TransactionCategory.entertainment => const TransactionCategoryVisual(
        label: 'Entertainment',
        icon: Icons.movie_outlined,
        foreground: AppColors.textSecondary,
        background: AppColors.surfaceSecondary,
      ),
      TransactionCategory.family => const TransactionCategoryVisual(
        label: 'Family',
        icon: Icons.people_outline,
        foreground: AppColors.balancePositive,
        background: AppColors.positiveSubtle,
      ),
      TransactionCategory.salary => const TransactionCategoryVisual(
        label: 'Salary',
        icon: Icons.work_outline,
        foreground: AppColors.balancePositive,
        background: AppColors.positiveSubtle,
      ),
      TransactionCategory.freelance => const TransactionCategoryVisual(
        label: 'Freelance',
        icon: Icons.laptop_outlined,
        foreground: AppColors.balancePositive,
        background: AppColors.positiveSubtle,
      ),
      TransactionCategory.business => const TransactionCategoryVisual(
        label: 'Business',
        icon: Icons.storefront_outlined,
        foreground: AppColors.balancePositive,
        background: AppColors.positiveSubtle,
      ),
      TransactionCategory.allowance => const TransactionCategoryVisual(
        label: 'Allowance',
        icon: Icons.account_balance_wallet_outlined,
        foreground: AppColors.balancePositive,
        background: AppColors.positiveSubtle,
      ),
      TransactionCategory.remittance => const TransactionCategoryVisual(
        label: 'Remittance',
        icon: Icons.public_outlined,
        foreground: AppColors.balancePositive,
        background: AppColors.positiveSubtle,
      ),
      TransactionCategory.gift => const TransactionCategoryVisual(
        label: 'Gift',
        icon: Icons.redeem_outlined,
        foreground: AppColors.balancePositive,
        background: AppColors.positiveSubtle,
      ),
      TransactionCategory.refund => const TransactionCategoryVisual(
        label: 'Refund',
        icon: Icons.replay_outlined,
        foreground: AppColors.balancePositive,
        background: AppColors.positiveSubtle,
      ),
      TransactionCategory.other => const TransactionCategoryVisual(
        label: 'Other',
        icon: Icons.more_horiz,
        foreground: AppColors.textSecondary,
        background: AppColors.surfaceSecondary,
      ),
    };
  }
}

extension PaymentMethodPresentation on PaymentMethod {
  String get label {
    return switch (this) {
      PaymentMethod.cash => 'Cash',
      PaymentMethod.bankAccount => 'Bank account',
      PaymentMethod.card => 'Card',
      PaymentMethod.eSewa => 'eSewa',
      PaymentMethod.khalti => 'Khalti',
      PaymentMethod.imePay => 'IME Pay',
      PaymentMethod.otherDigitalWallet => 'Other digital wallet',
      PaymentMethod.other => 'Other',
    };
  }
}
