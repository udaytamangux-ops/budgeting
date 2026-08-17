import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/features/categories/domain/entities/custom_category.dart';
import 'package:budgeting_app/features/categories/presentation/category_icon_data.dart';
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
  TransactionCategoryVisual visualFor(CategoryDefinition definition) {
    final TransactionCategoryVisual base = visual;
    return TransactionCategoryVisual(
      label: definition.label,
      icon: CategoryIconData.forKey(definition.iconKey),
      foreground: base.foreground,
      background: base.background,
    );
  }

  TransactionCategoryVisual get visual {
    if (this == TransactionCategory.food) {
      return TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.restaurant_outlined,
        foreground: AppColors.expenseAccent,
        background: AppColors.expenseSurface,
      );
    }
    if (this == TransactionCategory.transport) {
      return TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.directions_bus_outlined,
        foreground: AppColors.categoryBlueAccent,
        background: AppColors.categoryBlueSurface,
      );
    }
    if (this == TransactionCategory.rentAndHousing) {
      return TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.home_outlined,
        foreground: AppColors.categoryVioletAccent,
        background: AppColors.categoryVioletSurface,
      );
    }
    if (this == TransactionCategory.utilities) {
      return TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.bolt_outlined,
        foreground: AppColors.categoryAmberAccent,
        background: AppColors.categoryAmberSurface,
      );
    }
    if (this == TransactionCategory.shopping) {
      return TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.shopping_bag_outlined,
        foreground: AppColors.categoryPlumAccent,
        background: AppColors.categoryPlumSurface,
      );
    }
    if (this == TransactionCategory.health) {
      return TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.health_and_safety_outlined,
        foreground: AppColors.categoryTealAccent,
        background: AppColors.categoryTealSurface,
      );
    }
    if (this == TransactionCategory.education) {
      return TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.school_outlined,
        foreground: AppColors.categoryIndigoAccent,
        background: AppColors.categoryIndigoSurface,
      );
    }
    if (this == TransactionCategory.entertainment) {
      return TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.movie_outlined,
        foreground: AppColors.categoryEarthAccent,
        background: AppColors.categoryEarthSurface,
      );
    }
    if (this == TransactionCategory.family) {
      return TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.people_outline,
        foreground: AppColors.categorySlateAccent,
        background: AppColors.categorySlateSurface,
      );
    }
    if (this == TransactionCategory.feesAndCharges) {
      return TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.receipt_long_outlined,
        foreground: AppColors.categorySlateAccent,
        background: AppColors.categorySlateSurface,
      );
    }
    if (this == TransactionCategory.salary) {
      return TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.work_outline,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      );
    }
    if (this == TransactionCategory.freelance) {
      return TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.laptop_outlined,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      );
    }
    if (this == TransactionCategory.business) {
      return TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.storefront_outlined,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      );
    }
    if (this == TransactionCategory.allowance) {
      return TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.account_balance_wallet_outlined,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      );
    }
    if (this == TransactionCategory.remittance) {
      return TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.public_outlined,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      );
    }
    if (this == TransactionCategory.gift) {
      return TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.redeem_outlined,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      );
    }
    if (this == TransactionCategory.refund) {
      return TransactionCategoryVisual(
        label: displayLabel,
        icon: Icons.replay_outlined,
        foreground: AppColors.incomeAccent,
        background: AppColors.incomeSurface,
      );
    }
    return TransactionCategoryVisual(
      label: displayLabel,
      icon: isCustom ? Icons.label_outline : Icons.more_horiz,
      foreground: AppColors.categorySlateAccent,
      background: AppColors.categorySlateSurface,
    );
  }
}
