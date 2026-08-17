import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/features/categories/domain/entities/custom_category.dart';
import 'package:budgeting_app/features/categories/domain/repositories/custom_category_repository.dart';
import 'package:budgeting_app/features/categories/domain/services/category_catalog.dart';
import 'package:budgeting_app/features/categories/presentation/category_icon_data.dart';
import 'package:budgeting_app/features/categories/presentation/controllers/category_providers.dart';
import 'package:budgeting_app/features/categories/presentation/widgets/custom_category_editor_sheet.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

final class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  TransactionType _type = TransactionType.expense;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<CustomCategory>> custom = ref.watch(
      customCategoriesProvider,
    );
    final Set<String>? usedCategoryIds = ref
        .watch(usedCustomCategoryIdsProvider)
        .valueOrNull;
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          children: <Widget>[
            SegmentedButton<TransactionType>(
              segments: const <ButtonSegment<TransactionType>>[
                ButtonSegment<TransactionType>(
                  value: TransactionType.expense,
                  label: Text('Expense'),
                  icon: Icon(Icons.arrow_upward),
                ),
                ButtonSegment<TransactionType>(
                  value: TransactionType.income,
                  label: Text('Income'),
                  icon: Icon(Icons.arrow_downward),
                ),
              ],
              selected: <TransactionType>{_type},
              onSelectionChanged: (Set<TransactionType> value) {
                setState(() => _type = value.single);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Built in', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            ...TransactionCategory.values
                .where((TransactionCategory value) => value.supports(_type))
                .map(
                  (TransactionCategory value) => ListTile(
                    minTileHeight: 56,
                    leading: Icon(
                      CategoryIconData.forKey(
                        CategoryCatalog(
                          const <CustomCategory>[],
                        ).resolve(value).iconKey,
                      ),
                    ),
                    title: Text(value.systemLabel ?? 'Other'),
                    trailing: const Tooltip(
                      message: 'Default category cannot be edited',
                      child: Icon(Icons.lock_outline, size: 18),
                    ),
                  ),
                ),
            const SizedBox(height: AppSpacing.lg),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final Widget title = Text(
                  'Your categories',
                  style: Theme.of(context).textTheme.titleMedium,
                );
                final Widget action = TextButton.icon(
                  key: const ValueKey<String>('add_category_action'),
                  onPressed: () =>
                      showCustomCategoryEditor(context, type: _type),
                  icon: const Icon(Icons.add),
                  label: const Text('Add category'),
                );
                final bool stack =
                    constraints.maxWidth < 340 ||
                    MediaQuery.textScalerOf(context).scale(14) > 22;
                if (stack) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      title,
                      Align(alignment: Alignment.centerRight, child: action),
                    ],
                  );
                }
                return Row(
                  children: <Widget>[
                    Expanded(child: title),
                    action,
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.xs),
            custom.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, _) => const Text('Categories could not be loaded.'),
              data: (List<CustomCategory> values) {
                final List<CustomCategory> matching = values
                    .where((CustomCategory value) => value.type == _type)
                    .toList(growable: false);
                if (matching.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Text('No custom categories yet.'),
                  );
                }
                return Column(
                  children: matching
                      .map((CustomCategory value) {
                        return ListTile(
                          key: ValueKey<String>('manage_${value.id}'),
                          minTileHeight: 56,
                          leading: Icon(CategoryIconData.forKey(value.iconKey)),
                          title: Text(value.name),
                          subtitle: Text(
                            value.isArchived ? 'Archived' : 'Custom',
                          ),
                          trailing: PopupMenuButton<String>(
                            key: ValueKey<String>('manage_menu_${value.id}'),
                            tooltip: 'Manage ${value.name}',
                            onSelected: (String action) => _act(action, value),
                            itemBuilder: (_) => <PopupMenuEntry<String>>[
                              if (!value.isArchived)
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                              PopupMenuItem<String>(
                                value: value.isArchived ? 'restore' : 'archive',
                                child: Text(
                                  value.isArchived ? 'Restore' : 'Archive',
                                ),
                              ),
                              if (value.isArchived &&
                                  usedCategoryIds != null &&
                                  !usedCategoryIds.contains(value.id))
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Delete permanently'),
                                ),
                            ],
                          ),
                        );
                      })
                      .toList(growable: false),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _act(String action, CustomCategory category) async {
    final CustomCategoryRepository repository = ref.read(
      customCategoryRepositoryProvider,
    );
    try {
      if (action == 'edit') {
        await showCustomCategoryEditor(
          context,
          type: category.type,
          existing: category,
        );
      } else if (action == 'archive') {
        await repository.archive(category.id);
      } else if (action == 'restore') {
        await repository.restore(category.id);
      } else if (action == 'delete') {
        final bool used = await repository.isUsed(category.id);
        if (!mounted) return;
        if (used) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'This category is used by financial records and cannot be deleted.',
              ),
            ),
          );
          return;
        }
        final bool confirmed =
            await showDialog<bool>(
              context: context,
              builder: (BuildContext dialogContext) => AlertDialog(
                title: const Text('Delete category permanently?'),
                content: Text('${category.name} will be removed.'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Cancel'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ??
            false;
        if (confirmed) await repository.deleteUnused(category.id);
      }
    } on CustomCategoryException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    }
  }
}
