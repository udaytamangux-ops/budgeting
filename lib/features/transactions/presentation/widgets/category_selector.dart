import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_visuals.dart';
import 'package:flutter/material.dart';

final class CategorySelector extends StatelessWidget {
  const CategorySelector({
    required this.type,
    required this.selectedCategory,
    required this.onSelected,
    this.errorText,
    super.key,
  });

  final TransactionType type;
  final TransactionCategory? selectedCategory;
  final ValueChanged<TransactionCategory> onSelected;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final List<TransactionCategory> categories = TransactionCategory.values
        .where((TransactionCategory category) => category.supports(type))
        .toList(growable: false);

    return Semantics(
      container: true,
      label: 'Category, required',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Category', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: categories
                .map((TransactionCategory category) {
                  final bool isSelected = selectedCategory == category;
                  final TransactionCategoryVisual visual = category.visual;
                  return Semantics(
                    selected: isSelected,
                    button: true,
                    label: '${visual.label} category',
                    excludeSemantics: true,
                    onTap: () => onSelected(category),
                    child: ChoiceChip(
                      key: ValueKey<String>('category_${category.name}'),
                      selected: isSelected,
                      showCheckmark: true,
                      avatar: Icon(visual.icon, size: 18),
                      label: Text(visual.label),
                      onSelected: (_) => onSelected(category),
                    ),
                  );
                })
                .toList(growable: false),
          ),
          if (errorText != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Semantics(
              liveRegion: true,
              child: Text(
                errorText!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
