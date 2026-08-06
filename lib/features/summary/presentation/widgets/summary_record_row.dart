import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

final class SummaryRecordRow extends StatelessWidget {
  const SummaryRecordRow({
    required this.label,
    required this.value,
    this.supportingText,
    this.leading,
    this.onTap,
    this.isSelected = false,
    this.selectedSurface,
    this.selectedBorder,
    super.key,
  });

  final String label;
  final String value;
  final String? supportingText;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool isSelected;
  final Color? selectedSurface;
  final Color? selectedBorder;

  @override
  Widget build(BuildContext context) {
    final Widget details = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (leading != null) ...<Widget>[
          leading!,
          const SizedBox(width: AppSpacing.sm),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Flexible(
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                  if (isSelected) ...<Widget>[
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(
                      Icons.check_circle,
                      key: ValueKey<String>('selected_record_indicator'),
                      size: 18,
                      color: AppColors.primaryAction,
                    ),
                  ],
                ],
              ),
              if (supportingText != null) ...<Widget>[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  supportingText!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ],
    );
    final Widget financialValue = Text(
      value,
      textAlign: TextAlign.end,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        color: AppColors.textPrimary,
        fontFeatures: AppTypography.tabularFigures,
      ),
    );

    final Widget responsiveContent = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.sm,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double scaledLabelSize = MediaQuery.textScalerOf(
            context,
          ).scale(14);
          final bool shouldStack =
              constraints.maxWidth < 360 && scaledLabelSize >= 21;

          if (shouldStack) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                details,
                const SizedBox(height: AppSpacing.xs),
                Align(alignment: Alignment.centerRight, child: financialValue),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(child: details),
              const SizedBox(width: AppSpacing.md),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 168),
                child: financialValue,
              ),
            ],
          );
        },
      ),
    );

    return Semantics(
      label: <String>[label, value, ?supportingText].join(', '),
      button: onTap != null,
      selected: onTap == null ? null : isSelected,
      excludeSemantics: true,
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.accessibleDuration(context, AppMotion.fast),
        decoration: BoxDecoration(
          color: isSelected
              ? selectedSurface ?? AppColors.primarySubtle
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? selectedBorder ?? AppColors.primaryAction
                : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(AppRadius.small),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.small),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            overlayColor: const WidgetStatePropertyAll<Color>(
              AppColors.primarySubtle,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: responsiveContent,
            ),
          ),
        ),
      ),
    );
  }
}
