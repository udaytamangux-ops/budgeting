import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_category_metadata.dart';
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
      TransactionCategory.food => TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.restaurant_outlined,
        foreground: AppColors.expenseAccent,
        background: AppColors.expenseSurface,
      ),
      TransactionCategory.transport => TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.directions_bus_outlined,
        foreground: AppColors.categoryBlueAccent,
        background: AppColors.categoryBlueSurface,
      ),
      TransactionCategory.rentAndHousing => TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.home_outlined,
        foreground: AppColors.categoryVioletAccent,
        background: AppColors.categoryVioletSurface,
      ),
      TransactionCategory.utilities => TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.bolt_outlined,
        foreground: AppColors.categoryAmberAccent,
        background: AppColors.categoryAmberSurface,
      ),
      TransactionCategory.shopping => TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.shopping_bag_outlined,
        foreground: AppColors.categoryPlumAccent,
        background: AppColors.categoryPlumSurface,
      ),
      TransactionCategory.health => TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.health_and_safety_outlined,
        foreground: AppColors.categoryTealAccent,
        background: AppColors.categoryTealSurface,
      ),
      TransactionCategory.education => TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.school_outlined,
        foreground: AppColors.categoryIndigoAccent,
        background: AppColors.categoryIndigoSurface,
      ),
      TransactionCategory.entertainment => TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.movie_outlined,
        foreground: AppColors.categoryEarthAccent,
        background: AppColors.categoryEarthSurface,
      ),
      TransactionCategory.family => TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.people_outline,
        foreground: AppColors.categorySlateAccent,
        background: AppColors.categorySlateSurface,
      ),
      TransactionCategory.salary => TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.work_outline,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      ),
      TransactionCategory.freelance => TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.laptop_outlined,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      ),
      TransactionCategory.business => TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.storefront_outlined,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      ),
      TransactionCategory.allowance => TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.account_balance_wallet_outlined,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      ),
      TransactionCategory.remittance => TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.public_outlined,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      ),
      TransactionCategory.gift => TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.redeem_outlined,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      ),
      TransactionCategory.refund => TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.replay_outlined,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      ),
      TransactionCategory.other => TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.more_horiz,
        foreground: AppColors.categorySlateAccent,
        background: AppColors.categorySlateSurface,
      ),
    };
  }
}
