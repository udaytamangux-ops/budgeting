import 'dart:math' as math;

import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/app/theme/app_typography.dart';
import 'package:budgeting_app/core/formatting/currency_formatter.dart';
import 'package:budgeting_app/features/summary/domain/entities/monthly_category_activity.dart';
import 'package:budgeting_app/features/transactions/domain/entities/money.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

extension CategoryActivityGroupPresentation on CategoryActivityGroup {
  String get displayLabel => category?.visual.label ?? 'Other';

  Color get displayAccent =>
      category?.visual.foreground ?? AppColors.categorySlateAccent;

  Color get displaySurface =>
      category?.visual.background ?? AppColors.categorySlateSurface;

  IconData get displayIcon => category?.visual.icon ?? Icons.more_horiz;
}

final class SpendingDonutChart extends StatelessWidget {
  const SpendingDonutChart({
    required this.groups,
    required this.total,
    required this.type,
    required this.currencyFormatter,
    required this.onGroupSelected,
    this.selectedGroupKey,
    super.key,
  });

  static const double diameter = 224;
  static const double _segmentTargetSize = 48;

  final List<CategoryActivityGroup> groups;
  final Money total;
  final TransactionType type;
  final CurrencyFormatter currencyFormatter;
  final ValueChanged<CategoryActivityGroup> onGroupSelected;
  final String? selectedGroupKey;

  @override
  Widget build(BuildContext context) {
    final CategoryActivityGroup? selectedGroup = _selectedGroup;
    final String formattedTotal = currencyFormatter.format(total);
    final String totalLabel = type == TransactionType.expense
        ? 'Recorded expenses'
        : 'Recorded income';
    final String semanticSummary = <String>[
      type == TransactionType.expense
          ? 'Spending by category'
          : 'Income by source',
      'Total ${totalLabel.toLowerCase()}, $formattedTotal',
      ...groups.map(
        (CategoryActivityGroup group) =>
            '${group.displayLabel}, ${group.sharePercentage} percent, '
            '${currencyFormatter.format(group.amount)}',
      ),
    ].join('. ');

    return Semantics(
      key: const ValueKey<String>('spending_donut_chart'),
      container: true,
      explicitChildNodes: true,
      label: semanticSummary,
      child: RepaintBoundary(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTapUp: _handleChartTap,
          child: SizedBox.square(
            dimension: diameter,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                ExcludeSemantics(
                  child: CustomPaint(
                    size: const Size.square(diameter),
                    painter: _SpendingDonutPainter(
                      groups: groups,
                      total: total,
                      selectedGroupKey: selectedGroupKey,
                      trackColor: context.appColors.surfaceSecondary,
                      selectionOutlineColor: context.appColors.surfacePrimary,
                    ),
                  ),
                ),
                ExcludeSemantics(
                  child: SizedBox(
                    width: 142,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          selectedGroup?.displayLabel ?? totalLabel,
                          key: const ValueKey<String>('donut_center_label'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            currencyFormatter.format(
                              selectedGroup?.amount ?? total,
                            ),
                            key: const ValueKey<String>('donut_center_amount'),
                            maxLines: 1,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontFeatures: AppTypography.tabularFigures,
                                ),
                          ),
                        ),
                        if (selectedGroup != null) ...<Widget>[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            '${selectedGroup.sharePercentage}%',
                            key: const ValueKey<String>(
                              'donut_center_percentage',
                            ),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: context.appColors.textPrimary,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                ..._segmentTargets(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  CategoryActivityGroup? get _selectedGroup {
    for (int index = 0; index < groups.length; index += 1) {
      final CategoryActivityGroup group = groups[index];
      if (group.selectionKey == selectedGroupKey) {
        return group;
      }
    }
    return null;
  }

  List<Widget> _segmentTargets() {
    if (groups.isEmpty || total.minorUnits <= 0) {
      return const <Widget>[];
    }

    const double fullCircle = math.pi * 2;
    const Offset chartCenter = Offset(diameter / 2, diameter / 2);
    const double targetRadius = diameter / 2 - 24;
    double startAngle = -math.pi / 2;
    final List<Widget> targets = <Widget>[];

    for (int index = 0; index < groups.length; index += 1) {
      final CategoryActivityGroup group = groups[index];
      final double sweepAngle =
          fullCircle * group.amount.minorUnits / total.minorUnits;
      if (!sweepAngle.isFinite || sweepAngle <= 0) {
        continue;
      }
      final double midpoint = startAngle + sweepAngle / 2;
      final Offset rawCenter =
          chartCenter +
          Offset(math.cos(midpoint), math.sin(midpoint)) * targetRadius;
      const double halfTarget = _segmentTargetSize / 2;
      final Offset targetCenter = Offset(
        rawCenter.dx.clamp(halfTarget, diameter - halfTarget),
        rawCenter.dy.clamp(halfTarget, diameter - halfTarget),
      );
      final bool isSelected = group.selectionKey == selectedGroupKey;
      final String formattedAmount = currencyFormatter.format(group.amount);
      targets.add(
        Positioned.fromRect(
          rect: Rect.fromCenter(
            center: targetCenter,
            width: _segmentTargetSize,
            height: _segmentTargetSize,
          ),
          child: Semantics(
            key: ValueKey<String>('donut_segment_${group.selectionKey}'),
            button: true,
            selected: isSelected,
            sortKey: OrdinalSortKey(index.toDouble()),
            label:
                '${group.displayLabel}, $formattedAmount, '
                '${group.sharePercentage} percent, '
                '${isSelected ? 'selected' : 'not selected'}',
            hint: isSelected
                ? 'Tap to keep this category selected'
                : 'Tap to select this category',
            excludeSemantics: true,
            onTap: () => onGroupSelected(group),
            child: const SizedBox.expand(),
          ),
        ),
      );
      startAngle += sweepAngle;
    }
    return targets;
  }

  void _handleChartTap(TapUpDetails details) {
    if (groups.isEmpty || total.minorUnits <= 0) {
      return;
    }
    const Offset center = Offset(diameter / 2, diameter / 2);
    final Offset delta = details.localPosition - center;
    final double distance = delta.distance;
    if (distance < 66 || distance > diameter / 2) {
      return;
    }

    const double fullCircle = math.pi * 2;
    double angle = math.atan2(delta.dy, delta.dx) + math.pi / 2;
    if (angle < 0) {
      angle += fullCircle;
    }
    double accumulatedAngle = 0;
    for (final CategoryActivityGroup group in groups) {
      final double sweepAngle =
          fullCircle * group.amount.minorUnits / total.minorUnits;
      if (!sweepAngle.isFinite || sweepAngle <= 0) {
        continue;
      }
      accumulatedAngle += sweepAngle;
      if (angle <= accumulatedAngle) {
        onGroupSelected(group);
        return;
      }
    }

    onGroupSelected(groups.last);
  }
}

final class _SpendingDonutPainter extends CustomPainter {
  const _SpendingDonutPainter({
    required this.groups,
    required this.total,
    required this.selectedGroupKey,
    required this.trackColor,
    required this.selectionOutlineColor,
  });

  final List<CategoryActivityGroup> groups;
  final Money total;
  final String? selectedGroupKey;
  final Color trackColor;
  final Color selectionOutlineColor;

  @override
  void paint(Canvas canvas, Size size) {
    const double trackWidth = 24;
    const double selectedWidth = 30;
    const double selectedOutlineWidth = 34;
    final Offset center = size.center(Offset.zero);
    final double radius =
        math.min(size.width, size.height) / 2 - selectedOutlineWidth / 2;
    final Rect arcBounds = Rect.fromCircle(center: center, radius: radius);
    final Paint trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = trackWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (groups.isEmpty || total.minorUnits <= 0) {
      return;
    }

    const double fullCircle = math.pi * 2;
    const double preferredGap = math.pi / 90;
    double startAngle = -math.pi / 2;
    for (final CategoryActivityGroup group in groups) {
      final double sweepAngle =
          fullCircle * group.amount.minorUnits / total.minorUnits;
      if (!sweepAngle.isFinite || sweepAngle <= 0) {
        continue;
      }
      final double gap = math.min(preferredGap, sweepAngle * 0.18);
      final double visibleSweep = math.max(0, sweepAngle - gap);
      final bool isSelected = group.selectionKey == selectedGroupKey;
      if (isSelected) {
        final Paint outlinePaint = Paint()
          ..color = selectionOutlineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = selectedOutlineWidth
          ..strokeCap = StrokeCap.butt;
        canvas.drawArc(
          arcBounds,
          startAngle + gap / 2,
          visibleSweep,
          false,
          outlinePaint,
        );
      }
      final Paint segmentPaint = Paint()
        ..color = group.displayAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected
            ? selectedWidth
            : selectedGroupKey == null
            ? trackWidth
            : 20
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        arcBounds,
        startAngle + gap / 2,
        visibleSweep,
        false,
        segmentPaint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _SpendingDonutPainter oldDelegate) {
    if (total != oldDelegate.total ||
        selectedGroupKey != oldDelegate.selectedGroupKey ||
        trackColor != oldDelegate.trackColor ||
        selectionOutlineColor != oldDelegate.selectionOutlineColor ||
        groups.length != oldDelegate.groups.length) {
      return true;
    }
    for (int index = 0; index < groups.length; index += 1) {
      final CategoryActivityGroup current = groups[index];
      final CategoryActivityGroup previous = oldDelegate.groups[index];
      if (current.selectionKey != previous.selectionKey ||
          current.amount != previous.amount ||
          current.sharePercentage != previous.sharePercentage) {
        return true;
      }
    }
    return false;
  }
}
