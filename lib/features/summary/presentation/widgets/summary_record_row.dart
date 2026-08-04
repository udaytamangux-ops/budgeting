import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/app/theme/app_typography.dart';
import 'package:flutter/material.dart';

final class SummaryRecordRow extends StatelessWidget {
  const SummaryRecordRow({
    required this.label,
    required this.value,
    this.supportingText,
    this.leading,
    super.key,
  });

  final String label;
  final String value;
  final String? supportingText;
  final Widget? leading;

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
              Text(label, style: Theme.of(context).textTheme.labelLarge),
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

    return Semantics(
      label: <String>[label, value, ?supportingText].join(', '),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: financialValue,
                  ),
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
      ),
    );
  }
}
