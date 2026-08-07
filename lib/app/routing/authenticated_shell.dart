import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_motion.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_semantic_colors.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/features/transactions/presentation/widgets/transaction_created_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class AuthenticatedShell extends ConsumerWidget {
  const AuthenticatedShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(child: navigationShell),
          const TransactionCreatedBanner(),
        ],
      ),
      extendBody: false,
      bottomNavigationBar: BottomAppBar(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        color: context.appColors.surfacePrimary,
        elevation: 1,
        child: Row(
          children: <Widget>[
            Expanded(
              child: _NavigationDestination(
                label: 'Home',
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                isSelected: navigationShell.currentIndex == 0,
                onTap: () => _selectBranch(0),
              ),
            ),
            Expanded(
              child: _NavigationDestination(
                label: 'Transactions',
                icon: Icons.receipt_long_outlined,
                selectedIcon: Icons.receipt_long,
                isSelected: navigationShell.currentIndex == 1,
                onTap: () => _selectBranch(1),
              ),
            ),
            SizedBox(
              width: 64,
              child: Center(
                child: FloatingActionButton(
                  key: const ValueKey<String>('central_add_button'),
                  tooltip: 'Add transaction',
                  onPressed: () => _openAddTransaction(context),
                  backgroundColor: context.appColors.primaryAction,
                  foregroundColor: Colors.white,
                  elevation: 1,
                  focusElevation: 1,
                  hoverElevation: 1,
                  highlightElevation: 1,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppRadius.large),
                    ),
                  ),
                  child: const Icon(Icons.add),
                ),
              ),
            ),
            Expanded(
              child: _NavigationDestination(
                label: 'Summary',
                icon: Icons.summarize_outlined,
                selectedIcon: Icons.summarize,
                isSelected: navigationShell.currentIndex == 2,
                onTap: () => _selectBranch(2),
              ),
            ),
            Expanded(
              child: _NavigationDestination(
                label: 'Profile',
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                isSelected: navigationShell.currentIndex == 3,
                onTap: () => _selectBranch(3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  Future<void> _openAddTransaction(BuildContext context) async {
    final Object? result = await context.push<Object?>(AppRoutes.addExpense);
    if (result == null) {
      return;
    }
    navigationShell.goBranch(0);
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
        ? context.appColors.primaryAction
        : context.appColors.textSecondary;
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label navigation destination',
      excludeSemantics: true,
      onTap: onTap,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: AnimatedContainer(
          duration: AppMotion.accessibleDuration(context, AppMotion.fast),
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxs,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? context.appColors.primarySubtle
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.medium),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(isSelected ? selectedIcon : icon, color: color, size: 22),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
