import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_visuals.dart';
import 'package:flutter/material.dart';

final class CategorySelector extends StatelessWidget {
  const CategorySelector({
    required this.type,
    required this.selectedCategory,
    required this.onSelected,
    this.recentCategories = const <TransactionCategory>[],
    this.onRecentSelected,
    this.isEnabled = true,
    this.errorText,
    super.key,
  });

  final TransactionType type;
  final TransactionCategory? selectedCategory;
  final ValueChanged<TransactionCategory> onSelected;
  final List<TransactionCategory> recentCategories;
  final ValueChanged<TransactionCategory>? onRecentSelected;
  final bool isEnabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final List<TransactionCategory> categories = TransactionCategory.values
        .where((TransactionCategory category) => category.supports(type))
        .toList(growable: false);
    final String fieldLabel = type == TransactionType.expense
        ? 'Category'
        : 'Income source';
    final String allCategoriesLabel = type == TransactionType.expense
        ? 'All categories'
        : 'All income sources';

    return Semantics(
      container: true,
      label: fieldLabel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(fieldLabel, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          if (recentCategories.length >= 2) ...<Widget>[
            Text('Recent', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: AppSpacing.xs),
            _CategoryOptions(
              categories: recentCategories,
              keyPrefix: 'recent_category',
              selectedCategory: selectedCategory,
              isEnabled: isEnabled,
              onSelected: onRecentSelected ?? onSelected,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              allCategoriesLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          _CategoryOptions(
            categories: categories,
            keyPrefix: 'category',
            selectedCategory: selectedCategory,
            isEnabled: isEnabled,
            onSelected: onSelected,
          ),
          AnimatedSize(
            duration: AppMotion.accessibleDuration(context, AppMotion.fast),
            child: errorText == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.xs),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        errorText!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: context.appColors.destructiveAction,
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

final class _CategoryOptions extends StatelessWidget {
  const _CategoryOptions({
    required this.categories,
    required this.keyPrefix,
    required this.selectedCategory,
    required this.isEnabled,
    required this.onSelected,
  });

  final List<TransactionCategory> categories;
  final String keyPrefix;
  final TransactionCategory? selectedCategory;
  final bool isEnabled;
  final ValueChanged<TransactionCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: categories
          .map((TransactionCategory category) {
            return _CategoryOption(
              key: ValueKey<String>('${keyPrefix}_${category.name}'),
              category: category,
              isSelected: selectedCategory == category,
              isEnabled: isEnabled,
              onTap: () => onSelected(category),
            );
          })
          .toList(growable: false),
    );
  }
}

final class _CategoryOption extends StatelessWidget {
  const _CategoryOption({
    required this.category,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
    super.key,
  });

  final TransactionCategory category;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final TransactionCategoryVisual visual = category.visual;
    return Semantics(
      button: true,
      selected: isSelected,
      enabled: isEnabled,
      label: '${visual.label} category',
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
          overlayColor: WidgetStatePropertyAll<Color>(
            context.appColors.primarySubtle,
          ),
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
                    visual.icon,
                    size: 18,
                    color: isSelected
                        ? context.appColors.primaryAction
                        : visual.foreground,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      visual.label,
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
