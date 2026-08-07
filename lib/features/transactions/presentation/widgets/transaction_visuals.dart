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
        foreground: AppColors.expenseAccent,
        background: AppColors.expenseSurface,
      ),
      TransactionCategory.transport => const TransactionCategoryVisual(
        label: 'Transport',
        icon: Icons.directions_bus_outlined,
        foreground: AppColors.categoryBlueAccent,
        background: AppColors.categoryBlueSurface,
      ),
      TransactionCategory.rentAndHousing => const TransactionCategoryVisual(
        label: 'Rent & Housing',
        icon: Icons.home_outlined,
        foreground: AppColors.categoryVioletAccent,
        background: AppColors.categoryVioletSurface,
      ),
      TransactionCategory.utilities => const TransactionCategoryVisual(
        label: 'Utilities',
        icon: Icons.bolt_outlined,
        foreground: AppColors.categoryAmberAccent,
        background: AppColors.categoryAmberSurface,
      ),
      TransactionCategory.shopping => const TransactionCategoryVisual(
        label: 'Shopping',
        icon: Icons.shopping_bag_outlined,
        foreground: AppColors.categoryPlumAccent,
        background: AppColors.categoryPlumSurface,
      ),
      TransactionCategory.health => const TransactionCategoryVisual(
        label: 'Health',
        icon: Icons.health_and_safety_outlined,
        foreground: AppColors.categoryTealAccent,
        background: AppColors.categoryTealSurface,
      ),
      TransactionCategory.education => const TransactionCategoryVisual(
        label: 'Education',
        icon: Icons.school_outlined,
        foreground: AppColors.categoryIndigoAccent,
        background: AppColors.categoryIndigoSurface,
      ),
      TransactionCategory.entertainment => const TransactionCategoryVisual(
        label: 'Entertainment',
        icon: Icons.movie_outlined,
        foreground: AppColors.categoryEarthAccent,
        background: AppColors.categoryEarthSurface,
      ),
      TransactionCategory.family => const TransactionCategoryVisual(
        label: 'Family',
        icon: Icons.people_outline,
        foreground: AppColors.categorySlateAccent,
        background: AppColors.categorySlateSurface,
      ),
      TransactionCategory.salary => const TransactionCategoryVisual(
        label: 'Salary',
        icon: Icons.work_outline,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      ),
      TransactionCategory.freelance => const TransactionCategoryVisual(
        label: 'Freelance',
        icon: Icons.laptop_outlined,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      ),
      TransactionCategory.business => const TransactionCategoryVisual(
        label: 'Business',
        icon: Icons.storefront_outlined,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      ),
      TransactionCategory.allowance => const TransactionCategoryVisual(
        label: 'Allowance',
        icon: Icons.account_balance_wallet_outlined,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      ),
      TransactionCategory.remittance => const TransactionCategoryVisual(
        label: 'Remittance',
        icon: Icons.public_outlined,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      ),
      TransactionCategory.gift => const TransactionCategoryVisual(
        label: 'Gift',
        icon: Icons.redeem_outlined,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      ),
      TransactionCategory.refund => const TransactionCategoryVisual(
        label: 'Refund',
        icon: Icons.replay_outlined,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      ),
      TransactionCategory.other => const TransactionCategoryVisual(
        label: 'Other',
        icon: Icons.more_horiz,
        foreground: AppColors.categorySlateAccent,
        background: AppColors.categorySlateSurface,
      ),
    };
  }
}
