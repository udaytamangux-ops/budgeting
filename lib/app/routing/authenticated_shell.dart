import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_elevation.dart';
import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/core/widgets/pressable_scale.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_created_banner.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final class AuthenticatedShell extends StatelessWidget {
  const AuthenticatedShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(child: navigationShell),
          const TransactionCreatedBanner(),
        ],
      ),
      bottomNavigationBar: RepaintBoundary(
        child: SafeArea(
          top: false,
          minimum: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            0,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.signatureSurface),
              border: Border.all(color: AppColors.borderSubtle),
              boxShadow: AppElevation.utilityDockShadow,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.signatureSurface),
              child: BottomAppBar(
                key: const ValueKey<String>('floating_utility_dock'),
                height: 78,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                color: AppColors.surfacePrimary,
                elevation: 0,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: IgnorePointer(
                        child: AnimatedAlign(
                          key: const ValueKey<String>(
                            'navigation_active_indicator',
                          ),
                          alignment: Alignment(
                            _indicatorAlignment(navigationShell.currentIndex),
                            0,
                          ),
                          duration: AppMotion.accessibleDuration(
                            context,
                            AppMotion.navigation,
                          ),
                          curve: AppMotion.emphasized,
                          child: FractionallySizedBox(
                            widthFactor: 0.2,
                            heightFactor: 1,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xxs,
                                vertical: AppSpacing.xs,
                              ),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: AppColors.brandSoft,
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.inputAndChip,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _NavigationDestination(
                            label: 'Home',
                            icon: Icons.home_outlined,
                            selectedIcon: Icons.home_rounded,
                            isSelected: navigationShell.currentIndex == 0,
                            onTap: () => _selectBranch(0),
                          ),
                        ),
                        Expanded(
                          child: _NavigationDestination(
                            label: 'Transactions',
                            icon: Icons.receipt_long_outlined,
                            selectedIcon: Icons.receipt_long_rounded,
                            isSelected: navigationShell.currentIndex == 1,
                            onTap: () => _selectBranch(1),
                          ),
                        ),
                        Expanded(
                          child: _DockAddAction(
                            onTap: () => _openAddTransaction(context),
                          ),
                        ),
                        Expanded(
                          child: _NavigationDestination(
                            label: 'Summary',
                            icon: Icons.donut_large_outlined,
                            selectedIcon: Icons.donut_large,
                            isSelected: navigationShell.currentIndex == 2,
                            onTap: () => _selectBranch(2),
                          ),
                        ),
                        Expanded(
                          child: _NavigationDestination(
                            label: 'Profile',
                            icon: Icons.person_outline,
                            selectedIcon: Icons.person_rounded,
                            isSelected: navigationShell.currentIndex == 3,
                            onTap: () => _selectBranch(3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  double _indicatorAlignment(int index) {
    return switch (index) {
      0 => -1,
      1 => -0.5,
      2 => 0.5,
      _ => 1,
    };
  }

  void _selectBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Future<void> _openAddTransaction(BuildContext context) async {
    final Object? result = await context.push<Object?>(AppRoutes.addExpense);
    if (result != null) {
      navigationShell.goBranch(0);
    }
  }
}

final class _DockAddAction extends StatelessWidget {
  const _DockAddAction({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: PressableScale(
        pressedScale: 0.92,
        child: Semantics(
          button: true,
          label: 'Add transaction from navigation dock',
          excludeSemantics: true,
          onTap: onTap,
          child: SizedBox.square(
            dimension: 56,
            child: Material(
              color: AppColors.brandCobalt,
              borderRadius: BorderRadius.circular(AppRadius.utilitySurface),
              child: InkWell(
                key: const ValueKey<String>('central_add_button'),
                onTap: onTap,
                borderRadius: BorderRadius.circular(AppRadius.utilitySurface),
                overlayColor: const WidgetStatePropertyAll<Color>(
                  AppColors.brandPressed,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.inkOnStrong,
                  size: 28,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _NavigationDestination extends StatelessWidget {
  const _NavigationDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = isSelected
        ? AppColors.brandCobalt
        : AppColors.inkSecondary;
    final Duration duration = AppMotion.accessibleDuration(
      context,
      AppMotion.navigation,
    );
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label navigation destination',
      excludeSemantics: true,
      onTap: onTap,
      child: InkResponse(
        key: ValueKey<String>('navigation_${label.toLowerCase()}'),
        onTap: onTap,
        radius: 32,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AnimatedSlide(
                offset: isSelected ? const Offset(0, -0.1) : Offset.zero,
                duration: duration,
                curve: AppMotion.emphasized,
                child: AnimatedSwitcher(
                  duration: duration,
                  child: Icon(
                    isSelected ? selectedIcon : icon,
                    key: ValueKey<bool>(isSelected),
                    color: color,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
