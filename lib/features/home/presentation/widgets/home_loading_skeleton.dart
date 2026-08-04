import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:flutter/material.dart';

final class HomeLoadingSkeleton extends StatelessWidget {
  const HomeLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading financial summary',
      liveRegion: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.navigationClearance,
        ),
        children: const <Widget>[
          _SkeletonBlock(height: 176),
          SizedBox(height: AppSpacing.md),
          Row(
            children: <Widget>[
              Expanded(child: _SkeletonBlock(height: 52)),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: _SkeletonBlock(height: 52)),
            ],
          ),
          SizedBox(height: AppSpacing.xxl),
          _SkeletonBlock(height: 96),
          SizedBox(height: AppSpacing.xxl),
          _SkeletonBlock(height: 64),
          SizedBox(height: AppSpacing.xs),
          _SkeletonBlock(height: 64),
        ],
      ),
    );
  }
}

final class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
      ),
    );
  }
}
