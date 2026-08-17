import 'dart:async';

import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/features/categories/presentation/widgets/custom_category_editor_sheet.dart';
import 'package:budgeting_app/features/onboarding/presentation/controllers/onboarding_providers.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({this.intendedLocation, super.key});

  final String? intendedLocation;

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

final class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;
  bool _completing = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: _page < 2
                  ? TextButton(
                      key: const ValueKey<String>('onboarding_skip'),
                      onPressed: _completing
                          ? null
                          : () => unawaited(_finish()),
                      child: const Text('Skip'),
                    )
                  : const SizedBox(height: 48),
            ),
            Expanded(
              child: PageView(
                key: const ValueKey<String>('onboarding_pages'),
                controller: _pageController,
                onPageChanged: (int value) => setState(() => _page = value),
                children: const <Widget>[
                  _WelcomeStep(),
                  _NepalStep(),
                  _CategoriesStep(),
                ],
              ),
            ),
            Semantics(
              label: 'Step ${_page + 1} of 3',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List<Widget>.generate(
                  3,
                  (int index) => Padding(
                    padding: const EdgeInsets.all(AppSpacing.xxs),
                    child: Icon(
                      index == _page ? Icons.circle : Icons.circle_outlined,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey<String>('onboarding_primary'),
                  onPressed: _completing
                      ? null
                      : () {
                          if (_page == 2) {
                            unawaited(_finish());
                          } else {
                            _next();
                          }
                        },
                  child: Text(_page == 2 ? 'Start tracking' : 'Next'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _next() {
    unawaited(
      _pageController.nextPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  Future<void> _finish() async {
    setState(() => _completing = true);
    final calendarRepository = ref.read(calendarPreferenceRepositoryProvider);
    if (!await calendarRepository.isCalendarSetupComplete()) {
      await calendarRepository.markCalendarSetupComplete(
        await calendarRepository.getPrimaryCalendar(),
      );
    }
    await ref.read(onboardingPreferenceRepositoryProvider).complete();
    if (mounted) context.go(widget.intendedLocation ?? AppRoutes.home);
  }
}

final class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep();

  @override
  Widget build(BuildContext context) => const _OnboardingStepLayout(
    icon: Icons.receipt_long_outlined,
    title: 'Know where your money went',
    child: Text(
      'Record expenses, income and transfers quickly, then see a clear '
      'monthly picture.',
      textAlign: TextAlign.center,
    ),
  );
}

final class _NepalStep extends StatelessWidget {
  const _NepalStep();

  @override
  Widget build(BuildContext context) => const _OnboardingStepLayout(
    icon: Icons.account_balance_wallet_outlined,
    title: 'Made for everyday money in Nepal',
    child: Column(
      children: <Widget>[
        _FeatureRow(
          icon: Icons.currency_rupee,
          title: 'NPR-first',
          message: 'Nepal-friendly money formatting',
        ),
        _FeatureRow(
          icon: Icons.calendar_month_outlined,
          title: 'AD + BS',
          message: 'Use the calendar that works for you',
        ),
        _FeatureRow(
          icon: Icons.wallet_outlined,
          title: 'Cash, bank & local wallets',
          message: 'Track the ways you actually pay',
        ),
        _FeatureRow(
          icon: Icons.link_off_outlined,
          title: 'No bank connection required',
          message: 'Records can stay on this device',
        ),
      ],
    ),
  );
}

final class _CategoriesStep extends StatelessWidget {
  const _CategoriesStep();

  @override
  Widget build(BuildContext context) {
    return _OnboardingStepLayout(
      icon: Icons.category_outlined,
      title: 'Your categories are ready',
      child: Column(
        children: <Widget>[
          Text(
            'Start with useful defaults. Personalize them later if you want.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.md),
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: <Widget>[
              _CategoryChip(label: 'Food', icon: Icons.restaurant_outlined),
              _CategoryChip(
                label: 'Transport',
                icon: Icons.directions_bus_outlined,
              ),
              _CategoryChip(label: 'Rent & Housing', icon: Icons.home_outlined),
              _CategoryChip(label: 'Utilities', icon: Icons.bolt_outlined),
              _CategoryChip(
                label: 'Shopping',
                icon: Icons.shopping_bag_outlined,
              ),
              _CategoryChip(
                label: 'Health',
                icon: Icons.medical_services_outlined,
              ),
              _CategoryChip(label: '+ more', icon: Icons.more_horiz),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            key: const ValueKey<String>('onboarding_add_category'),
            onPressed: () async {
              await showCustomCategoryEditor(
                context,
                type: TransactionType.expense,
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add your own category'),
          ),
        ],
      ),
    );
  }
}

final class _OnboardingStepLayout extends StatelessWidget {
  const _OnboardingStepLayout({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 1),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 36,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    child,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

final class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox.square(
            dimension: 48,
            child: Icon(icon, color: colors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}
