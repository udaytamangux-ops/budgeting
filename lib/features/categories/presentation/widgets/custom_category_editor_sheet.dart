import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/features/categories/domain/entities/custom_category.dart';
import 'package:budgeting_app/features/categories/domain/repositories/custom_category_repository.dart';
import 'package:budgeting_app/features/categories/domain/services/category_catalog.dart';
import 'package:budgeting_app/features/categories/domain/services/category_icon_keys.dart';
import 'package:budgeting_app/features/categories/presentation/category_icon_data.dart';
import 'package:budgeting_app/features/categories/presentation/controllers/category_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<CustomCategory?> showCustomCategoryEditor(
  BuildContext context, {
  required TransactionType type,
  CustomCategory? existing,
}) {
  return showModalBottomSheet<CustomCategory>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _CustomCategoryEditor(type: type, existing: existing),
  );
}

final class _CustomCategoryEditor extends ConsumerStatefulWidget {
  const _CustomCategoryEditor({required this.type, this.existing});
  final TransactionType type;
  final CustomCategory? existing;

  @override
  ConsumerState<_CustomCategoryEditor> createState() =>
      _CustomCategoryEditorState();
}

final class _CustomCategoryEditorState
    extends ConsumerState<_CustomCategoryEditor> {
  late final TextEditingController _nameController;
  late String _iconKey;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name);
    _iconKey = widget.existing?.iconKey ?? CategoryIconKeys.fallback;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<CustomCategory> customCategories =
        ref.watch(customCategoriesProvider).valueOrNull ??
        const <CustomCategory>[];
    final bool activeLimitReached =
        widget.existing == null &&
        customCategories
                .where(
                  (CustomCategory category) =>
                      category.type == widget.type && !category.isArchived,
                )
                .length >=
            CategoryNameRules.maximumActivePerType;
    final String typeLabel = widget.type == TransactionType.expense
        ? 'Expense'
        : 'Income';
    CustomCategory? archivedDuplicate;
    if (widget.existing == null) {
      final String normalizedInput = CategoryNameRules.normalize(
        _nameController.text,
      );
      for (final CustomCategory category in customCategories) {
        if (category.type == widget.type &&
            category.isArchived &&
            category.normalizedName == normalizedInput) {
          archivedDuplicate = category;
          break;
        }
      }
    }
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              widget.existing == null ? 'Add category' : 'Edit category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (activeLimitReached) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
              Semantics(
                liveRegion: true,
                child: Container(
                  key: const ValueKey<String>('custom_category_limit'),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: context.appColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.appColors.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Custom category limit reached',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'You can have up to 10 active custom $typeLabel '
                        'categories. Archive one in Profile > Categories to '
                        'add another.',
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            TextField(
              key: const ValueKey<String>('custom_category_name'),
              controller: _nameController,
              autofocus: true,
              maxLength: 36,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: widget.type == TransactionType.expense
                    ? 'Expense category name'
                    : 'Income source name',
                errorText: _error,
              ),
              onChanged: (_) => setState(() => _error = null),
            ),
            if (archivedDuplicate != null) ...<Widget>[
              Text(
                '${archivedDuplicate.name} already exists in your archived '
                'categories.',
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: const ValueKey<String>('restore_archived_category'),
                  onPressed: _saving || activeLimitReached
                      ? null
                      : () => _restore(archivedDuplicate!),
                  icon: const Icon(Icons.unarchive_outlined),
                  label: Text('Restore ${archivedDuplicate.name}'),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Text('Icon', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: CategoryIconKeys.customChoices
                  .map((String key) {
                    final bool selected = key == _iconKey;
                    return Semantics(
                      button: true,
                      selected: selected,
                      label: '$key icon${selected ? ', selected' : ''}',
                      child: IconButton.filledTonal(
                        key: ValueKey<String>('category_icon_$key'),
                        onPressed: _saving
                            ? null
                            : () => setState(() => _iconKey = key),
                        style: IconButton.styleFrom(
                          minimumSize: const Size(48, 48),
                          side: selected
                              ? BorderSide(
                                  color: context.appColors.primaryAction,
                                  width: 2,
                                )
                              : null,
                        ),
                        icon: Icon(CategoryIconData.forKey(key)),
                      ),
                    );
                  })
                  .toList(growable: false),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              key: const ValueKey<String>('save_custom_category'),
              onPressed:
                  _saving || activeLimitReached || archivedDuplicate != null
                  ? null
                  : _save,
              child: Text(_saving ? 'Saving…' : 'Save category'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final CustomCategoryRepository repository = ref.read(
        customCategoryRepositoryProvider,
      );
      final CustomCategory saved = widget.existing == null
          ? await repository.create(
              type: widget.type,
              name: _nameController.text,
              iconKey: _iconKey,
            )
          : await repository.update(
              id: widget.existing!.id,
              name: _nameController.text,
              iconKey: _iconKey,
            );
      if (mounted) Navigator.of(context).pop(saved);
    } on CustomCategoryException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _restore(CustomCategory archived) async {
    setState(() => _saving = true);
    try {
      final CustomCategoryRepository repository = ref.read(
        customCategoryRepositoryProvider,
      );
      await repository.restore(archived.id);
      final CustomCategory? restored = await repository.getById(archived.id);
      if (mounted && restored != null) Navigator.of(context).pop(restored);
    } on CustomCategoryException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
