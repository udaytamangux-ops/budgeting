import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/formatting/formatting_providers.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/transactions/domain/services/transaction_date_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class QuickDateSelector extends ConsumerWidget {
  const QuickDateSelector({
    required this.date,
    required this.isEnabled,
    required this.onChanged,
    super.key,
  });

  final DateTime date;
  final bool isEnabled;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const TransactionDateService dateService = TransactionDateService();
    final DateTime currentDate = ref.watch(currentDateProvider);
    final QuickDateSelection selection = dateService.selectionFor(
      selectedDate: date,
      currentDate: currentDate,
    );
    final dateFormatter = ref.watch(dateFormatterProvider);
    final String formattedDate = dateFormatter.longDate(date);
    final String formattedToday = dateFormatter.longDate(
      dateService.today(currentDate),
    );
    final String formattedYesterday = dateFormatter.longDate(
      dateService.yesterday(currentDate),
    );

    return Semantics(
      container: true,
      label: 'Transaction date, $formattedDate',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Date', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: <Widget>[
              _QuickDateOption(
                key: const ValueKey<String>('quick_date_today'),
                label: 'Today',
                semanticLabel: 'Today, $formattedToday',
                isSelected: selection == QuickDateSelection.today,
                isEnabled: isEnabled,
                onTap: () => onChanged(dateService.today(currentDate)),
              ),
              _QuickDateOption(
                key: const ValueKey<String>('quick_date_yesterday'),
                label: 'Yesterday',
                semanticLabel: 'Yesterday, $formattedYesterday',
                isSelected: selection == QuickDateSelection.yesterday,
                isEnabled: isEnabled,
                onTap: () => onChanged(dateService.yesterday(currentDate)),
              ),
              _QuickDateOption(
                key: const ValueKey<String>('quick_date_choose'),
                label: 'Choose date',
                semanticLabel: 'Choose date, currently $formattedDate',
                isSelected: selection == QuickDateSelection.chosenDate,
                isEnabled: isEnabled,
                onTap: () => _selectDate(context, currentDate),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            formattedDate,
            key: const ValueKey<String>('selected_transaction_date'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.appColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime currentDate) async {
    final DateTime localCurrent = currentDate.toLocal();
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(localCurrent.year - 5),
      lastDate: DateTime(localCurrent.year + 1),
      helpText: 'Select transaction date',
    );
    if (selected != null) {
      onChanged(selected);
    }
  }
}

final class _QuickDateOption extends StatelessWidget {
  const _QuickDateOption({
    required this.label,
    required this.semanticLabel,
    required this.isSelected,
    required this.isEnabled,
    required this.onTap,
    super.key,
  });

  final String label;
  final String semanticLabel;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      enabled: isEnabled,
      label: semanticLabel,
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
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (isSelected) ...<Widget>[
                    Icon(
                      Icons.check,
                      size: 18,
                      color: context.appColors.primaryAction,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  Flexible(
                    child: Text(
                      label,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
