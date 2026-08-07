import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class CalendarSetupScreen extends ConsumerStatefulWidget {
  const CalendarSetupScreen({this.intendedLocation, super.key});

  final String? intendedLocation;

  @override
  ConsumerState<CalendarSetupScreen> createState() =>
      _CalendarSetupScreenState();
}

final class _CalendarSetupScreenState
    extends ConsumerState<CalendarSetupScreen> {
  AppCalendarSystem _selected = AppCalendarSystem.gregorianAd;
  bool _isContinuing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              key: const ValueKey<String>('calendar_setup_content'),
              shrinkWrap: true,
              padding: const EdgeInsets.all(AppSpacing.xl),
              children: <Widget>[
                Icon(
                  Icons.calendar_month_outlined,
                  size: 48,
                  color: context.appColors.primaryAction,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Choose your calendar',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Which calendar would you like to use most often?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                for (final AppCalendarSystem system
                    in AppCalendarSystem.values) ...<Widget>[
                  _CalendarChoiceCard(
                    key: ValueKey<String>(
                      'calendar_setup_option_${system.name}',
                    ),
                    calendarSystem: system,
                    isSelected: _selected == system,
                    onTap: _isContinuing
                        ? null
                        : () => setState(() => _selected = system),
                  ),
                  if (system != AppCalendarSystem.values.last)
                    const SizedBox(height: AppSpacing.sm),
                ],
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'You can change this later in Profile. The other calendar '
                  'will remain available as secondary date context where '
                  'useful.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.appColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  key: const ValueKey<String>('calendar_setup_continue'),
                  onPressed: _isContinuing ? null : _continue,
                  child: _isContinuing
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.4),
                        )
                      : const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _continue() async {
    setState(() => _isContinuing = true);
    await ref
        .read(calendarPreferenceRepositoryProvider)
        .markCalendarSetupComplete(_selected);
    if (mounted) {
      context.go(widget.intendedLocation ?? AppRoutes.home);
    }
  }
}

final class _CalendarChoiceCard extends StatelessWidget {
  const _CalendarChoiceCard({
    required this.calendarSystem,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final AppCalendarSystem calendarSystem;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color border = isSelected
        ? context.appColors.primaryAction
        : context.appColors.borderSubtle;
    return Semantics(
      button: true,
      selected: isSelected,
      enabled: onTap != null,
      label:
          '${calendarSystem.title}. ${calendarSystem.description}. '
          '${isSelected ? 'Selected' : 'Not selected'}',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: isSelected
            ? context.appColors.primarySubtle
            : context.appColors.surfacePrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.medium),
          side: BorderSide(color: border, width: isSelected ? 2 : 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.medium),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 72),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: <Widget>[
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected
                        ? context.appColors.primaryAction
                        : context.appColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          calendarSystem.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          calendarSystem.description,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: context.appColors.textSecondary,
                              ),
                        ),
                      ],
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
