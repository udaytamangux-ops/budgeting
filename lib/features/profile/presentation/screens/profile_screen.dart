import 'dart:async';

import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_service.dart';
import 'package:budgeting_app/core/calendar/domain/app_calendar_system.dart';
import 'package:budgeting_app/features/settings/domain/entities/app_theme_preference.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/theme_preference_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({this.showDeveloperInformation = kDebugMode, super.key});

  final bool showDeveloperInformation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppThemePreference themePreference =
        ref.watch(themePreferenceProvider).valueOrNull ??
        AppThemePreference.system;
    final AppCalendarSystem calendarSystem =
        ref.watch(primaryCalendarProvider).valueOrNull ??
        AppCalendarSystem.gregorianAd;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        top: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.navigationClearance,
              ),
              children: <Widget>[
                const _ProfileIdentity(),
                const SizedBox(height: AppSpacing.xxl),
                const _SectionTitle(title: 'Account'),
                const SizedBox(height: AppSpacing.sm),
                const _GuestAccountSection(),
                const SizedBox(height: AppSpacing.xxl),
                const _SectionTitle(title: 'Appearance'),
                const SizedBox(height: AppSpacing.sm),
                _AppearanceSetting(currentPreference: themePreference),
                const SizedBox(height: AppSpacing.xxl),
                const _SectionTitle(title: 'Preferences'),
                const SizedBox(height: AppSpacing.sm),
                _SettingsRegion(
                  children: <Widget>[
                    const _SettingsValueTile(
                      icon: Icons.payments_outlined,
                      title: 'Currency',
                      value: 'NPR · Nepalese rupee',
                    ),
                    const Divider(),
                    _CalendarSetting(currentCalendar: calendarSystem),
                    const Divider(),
                    const SwitchListTile(
                      key: ValueKey<String>('notifications_setting'),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      secondary: Icon(Icons.notifications_outlined),
                      title: Text('Notifications'),
                      subtitle: Text('Not available in this version'),
                      value: false,
                      onChanged: null,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                const _SectionTitle(title: 'Privacy and data'),
                const SizedBox(height: AppSpacing.sm),
                _SettingsRegion(
                  children: <Widget>[
                    ListTile(
                      key: const ValueKey<String>('privacy_and_data_setting'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      leading: const Icon(Icons.shield_outlined),
                      title: const Text('Privacy and data'),
                      subtitle: const Text(
                        'Review local storage and connections',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(AppRoutes.privacyAndData),
                    ),
                  ],
                ),
                if (showDeveloperInformation) ...<Widget>[
                  const SizedBox(height: AppSpacing.xxl),
                  const _SectionTitle(title: 'Developer information'),
                  const SizedBox(height: AppSpacing.sm),
                  const _SettingsRegion(
                    children: <Widget>[
                      _SettingsValueTile(
                        icon: Icons.storage_outlined,
                        title: 'Data source',
                        value: 'Drift / SQLite local database',
                      ),
                      Divider(),
                      _SettingsValueTile(
                        icon: Icons.person_outline,
                        title: 'Access',
                        value: 'Guest access enabled',
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _CalendarSetting extends ConsumerWidget {
  const _CalendarSetting({required this.currentCalendar});

  final AppCalendarSystem currentCalendar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      key: const ValueKey<String>('calendar_preference_setting'),
      minTileHeight: 56,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      leading: const Icon(Icons.calendar_today_outlined),
      title: const Text('Calendar'),
      subtitle: Text('${currentCalendar.title} · Primary calendar'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => unawaited(_showCalendarSheet(context, ref)),
    );
  }

  Future<void> _showCalendarSheet(BuildContext context, WidgetRef ref) async {
    final AppCalendarService calendarService = ref.read(
      appCalendarServiceProvider,
    );
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          top: false,
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Calendar preference',
                      style: Theme.of(sheetContext).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'The selected calendar controls monthly periods. The '
                      'other remains available as secondary date context.',
                      style: Theme.of(sheetContext).textTheme.bodyMedium
                          ?.copyWith(
                            color: sheetContext.appColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              for (final AppCalendarSystem calendar in AppCalendarSystem.values)
                Semantics(
                  button: true,
                  selected: calendar == currentCalendar,
                  label:
                      '${calendar.title}. ${calendar.description}. '
                      '${calendar == currentCalendar ? 'Selected' : 'Not selected'}',
                  excludeSemantics: true,
                  child: ListTile(
                    key: ValueKey<String>(
                      'calendar_preference_option_${calendar.name}',
                    ),
                    minTileHeight: 64,
                    title: Text(calendar.title),
                    subtitle: Text(
                      calendar == AppCalendarSystem.bikramSambatBs
                          ? calendarService.formatDate(
                              DateTime.utc(2026, 8, 7),
                              calendar,
                            )
                          : calendar.description,
                    ),
                    trailing: Icon(
                      calendar == currentCalendar
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: calendar == currentCalendar
                          ? sheetContext.appColors.primaryAction
                          : sheetContext.appColors.textSecondary,
                    ),
                    selected: calendar == currentCalendar,
                    onTap: () async {
                      await ref
                          .read(calendarPreferenceRepositoryProvider)
                          .setPrimaryCalendar(calendar);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

final class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Using without an account. Records are stored on this device.',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: context.appColors.surfacePrimary,
          border: Border.all(color: context.appColors.borderSubtle),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.appColors.primarySubtle,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_outline,
                color: context.appColors.primaryAction,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Using without an account',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Your records are stored on this device.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _GuestAccountSection extends StatelessWidget {
  const _GuestAccountSection();

  @override
  Widget build(BuildContext context) {
    return _SettingsRegion(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                'Cloud backup and cross-device sync are not available yet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(
                key: const ValueKey<String>('profile_create_account_button'),
                onPressed: () => context.push(AppRoutes.signUp),
                icon: const Icon(Icons.person_add_outlined),
                label: const Text('Create account'),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                key: const ValueKey<String>('profile_sign_in_button'),
                onPressed: () => context.push(AppRoutes.signIn),
                child: const Text('Sign in'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

final class _AppearanceSetting extends ConsumerWidget {
  const _AppearanceSetting({required this.currentPreference});

  final AppThemePreference currentPreference;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SettingsRegion(
      children: <Widget>[
        ListTile(
          key: const ValueKey<String>('appearance_setting'),
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          leading: const Icon(Icons.contrast_outlined),
          title: const Text('Theme'),
          subtitle: Text(_preferenceLabel(context, currentPreference)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () =>
              unawaited(_showAppearanceSheet(context, ref, currentPreference)),
        ),
      ],
    );
  }

  Future<void> _showAppearanceSheet(
    BuildContext context,
    WidgetRef ref,
    AppThemePreference selected,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  child: Text(
                    'Appearance',
                    style: Theme.of(sheetContext).textTheme.titleLarge,
                  ),
                ),
                for (final AppThemePreference preference
                    in AppThemePreference.values)
                  Semantics(
                    selected: preference == selected,
                    button: true,
                    child: ListTile(
                      key: ValueKey<String>('theme_option_${preference.name}'),
                      minTileHeight: 56,
                      title: Text(_optionTitle(preference)),
                      subtitle: preference == AppThemePreference.system
                          ? Text(
                              'Currently follows ${_effectiveSystemLabel(context)}',
                            )
                          : null,
                      trailing: Icon(
                        preference == selected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: preference == selected
                            ? sheetContext.appColors.primaryAction
                            : sheetContext.appColors.textSecondary,
                      ),
                      selected: preference == selected,
                      onTap: () async {
                        await ref
                            .read(themePreferenceRepositoryProvider)
                            .setThemeMode(preference);
                        if (sheetContext.mounted) {
                          Navigator.of(sheetContext).pop();
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _preferenceLabel(BuildContext context, AppThemePreference preference) {
    return preference == AppThemePreference.system
        ? 'System · ${_effectiveSystemLabel(context)}'
        : _optionTitle(preference);
  }

  String _effectiveSystemLabel(BuildContext context) {
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark
        ? 'Dark'
        : 'Light';
  }

  String _optionTitle(AppThemePreference preference) => switch (preference) {
    AppThemePreference.system => 'System',
    AppThemePreference.light => 'Light',
    AppThemePreference.dark => 'Dark',
  };
}

final class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }
}

final class _SettingsRegion extends StatelessWidget {
  const _SettingsRegion({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.appColors.surfacePrimary,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: context.appColors.borderSubtle),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Column(children: children),
    );
  }
}

final class _SettingsValueTile extends StatelessWidget {
  const _SettingsValueTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(value),
    );
  }
}
