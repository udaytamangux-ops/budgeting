import 'dart:async';

import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/features/profile/data/mock_profile_source.dart';
import 'package:budgeting_app/features/profile/domain/entities/profile_identity.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

final class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

final class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = false;

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
                _SettingsRegion(
                  children: <Widget>[
                    const _SettingsValueTile(
                      icon: Icons.payments_outlined,
                      title: 'Currency',
                      value: 'NPR · Nepalese rupee',
                    ),
                    const Divider(),
                    const _SettingsValueTile(
                      icon: Icons.calendar_today_outlined,
                      title: 'Date format',
                      value: '4 August 2026',
                    ),
                    const Divider(),
                    const _SettingsValueTile(
                      icon: Icons.light_mode_outlined,
                      title: 'Theme',
                      value: 'Light',
                    ),
                    const Divider(),
                    SwitchListTile(
                      key: const ValueKey<String>('notifications_setting'),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      secondary: const Icon(Icons.notifications_outlined),
                      title: const Text('Notifications'),
                      subtitle: Text(
                        _notificationsEnabled
                            ? 'Budget reminders enabled for this session'
                            : 'Not configured',
                      ),
                      value: _notificationsEnabled,
                      onChanged: (bool value) {
                        setState(() => _notificationsEnabled = value);
                      },
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
                        'Review how your records are stored and managed',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        unawaited(_showPrivacyDetails(context));
                      },
                    ),
                  ],
                ),
                if (kDebugMode) ...<Widget>[
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

  Future<void> _showPrivacyDetails(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Privacy and data',
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Transactions and preferences in this prototype remain only '
                  'in device memory. They are not uploaded and reset when the '
                  'application process restarts.',
                ),
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: Navigator.of(sheetContext).pop,
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
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
    const ProfileIdentity profile = MockProfileSource.profile;
    return Semantics(
      label: 'Profile for ${profile.fullName}, ${profile.email}',
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
              child: Text(
                profile.initials,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.primaryAction,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    profile.fullName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    profile.email,
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
