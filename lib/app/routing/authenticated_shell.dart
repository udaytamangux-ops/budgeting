import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/theme/app_colors.dart';
import 'package:budgeting_app/app/theme/app_radius.dart';
import 'package:budgeting_app/app/theme/app_spacing.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/last_saved_transaction_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final class AuthenticatedShell extends ConsumerWidget {
  const AuthenticatedShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        key: const ValueKey<String>('central_add_button'),
        tooltip: 'Add transaction',
        onPressed: () => _openAddTransaction(context, ref),
        backgroundColor: AppColors.primaryAction,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.large)),
        ),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        color: AppColors.surfacePrimary,
        elevation: 2,
        notchMargin: AppSpacing.xs,
        shape: const CircularNotchedRectangle(),
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
            const SizedBox(width: 64),
            Expanded(
              child: _NavigationDestination(
                label: 'Budgets',
                icon: Icons.track_changes_outlined,
                selectedIcon: Icons.track_changes,
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

  Future<void> _openAddTransaction(BuildContext context, WidgetRef ref) async {
    final FinancialTransaction? transaction = await context
        .push<FinancialTransaction>(AppRoutes.addExpense);
    if (transaction == null) {
      return;
    }
    ref.read(lastSavedTransactionProvider.notifier).show(transaction);
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
        ? AppColors.primaryAction
        : AppColors.textSecondary;
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$label navigation destination',
      excludeSemantics: true,
      onTap: onTap,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: SizedBox.expand(
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
