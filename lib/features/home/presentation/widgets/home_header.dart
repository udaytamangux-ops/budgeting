import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String month = ref
        .watch(appCalendarServiceProvider)
        .formatMonthName(ref.watch(currentCalendarPeriodProvider));

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Namaste', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  "Here's your $month activity.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Semantics(
            button: true,
            label: 'Open local profile',
            excludeSemantics: true,
            child: InkResponse(
              key: const ValueKey<String>('home_profile_button'),
              onTap: () => context.go(AppRoutes.profile),
              radius: 24,
              child: SizedBox.square(
                dimension: 48,
                child: Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.appColors.primarySubtle,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: context.appColors.primaryAction,
                      size: 22,
                    ),
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
