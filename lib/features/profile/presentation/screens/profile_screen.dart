import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final class ProfileScreen extends StatelessWidget {
  const ProfileScreen({this.showDeveloperInformation = kDebugMode, super.key});

  final bool showDeveloperInformation;

  @override
  Widget build(BuildContext context) {
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
                const _SectionTitle(title: 'Preferences'),
                const SizedBox(height: AppSpacing.sm),
                const _SettingsRegion(
                  children: <Widget>[
                    _SettingsValueTile(
                      icon: Icons.payments_outlined,
                      title: 'Currency',
                      value: 'NPR · Nepalese rupee',
                    ),
                    Divider(),
                    _SettingsValueTile(
                      icon: Icons.calendar_today_outlined,
                      title: 'Date format',
                      value: '4 August 2026',
                    ),
                    Divider(),
                    _SettingsValueTile(
                      icon: Icons.light_mode_outlined,
                      title: 'Theme',
                      value: 'Light',
                    ),
                    Divider(),
                    SwitchListTile(
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
                        value: 'In-memory repository',
                      ),
                      Divider(),
                      _SettingsValueTile(
                        icon: Icons.developer_mode_outlined,
                        title: 'Session',
                        value: 'Development access enabled',
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

final class _ProfileIdentity extends StatelessWidget {
  const _ProfileIdentity();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Local profile, no account connected',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfacePrimary,
          border: Border.all(color: AppColors.borderSubtle),
          borderRadius: BorderRadius.circular(AppRadius.medium),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.primarySubtle,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                color: AppColors.primaryAction,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Local profile',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'No account connected',
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
      color: AppColors.surfacePrimary,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.borderSubtle),
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
