import 'package:budgeting_app/app/bootstrap/development_session.dart';
import 'package:budgeting_app/app/routing/app_route_names.dart';
import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/routing/authenticated_shell.dart';
import 'package:budgeting_app/app/routing/category_details_route_data.dart';
import 'package:budgeting_app/app/routing/transaction_form_route.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/features/auth/presentation/screens/authentication_placeholder_screen.dart';
import 'package:budgeting_app/features/home/presentation/screens/home_screen.dart';
import 'package:budgeting_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:budgeting_app/features/summary/presentation/screens/category_details_screen.dart';
import 'package:budgeting_app/features/summary/presentation/screens/summary_screen.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgeting_app/features/transactions/presentation/screens/transaction_details_screen.dart';
import 'package:budgeting_app/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  ref.watch(sessionStatusProvider);
  final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.welcome,
        name: AppRouteNames.welcome,
        builder: (_, _) =>
            const AuthenticationPlaceholderScreen(title: 'Welcome'),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: AppRouteNames.login,
        builder: (_, _) =>
            const AuthenticationPlaceholderScreen(title: 'Log in'),
      ),
      GoRoute(
        path: AppRoutes.signup,
        name: AppRouteNames.signup,
        builder: (_, _) =>
            const AuthenticationPlaceholderScreen(title: 'Sign up'),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: AppRouteNames.onboarding,
        builder: (_, _) =>
            const AuthenticationPlaceholderScreen(title: 'Onboarding'),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.addExpense,
        name: AppRouteNames.addTransaction,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final TransactionType initialType =
              state.uri.queryParameters['type'] == 'income'
              ? TransactionType.income
              : TransactionType.expense;
          final String? editTransactionId =
              state.uri.queryParameters['transactionId'];
          final String? repeatTransactionId =
              state.uri.queryParameters['repeatTransactionId'];
          final TransactionFormIntent intent = repeatTransactionId != null
              ? TransactionFormIntent.repeat
              : editTransactionId != null
              ? TransactionFormIntent.edit
              : TransactionFormIntent.create;
          return MaterialPage<void>(
            key: state.pageKey,
            fullscreenDialog: true,
            child: TransactionFormRoute(
              initialType: initialType,
              transactionId: repeatTransactionId ?? editTransactionId,
              intent: intent,
            ),
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) {
              return AuthenticatedShell(navigationShell: navigationShell);
            },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                name: AppRouteNames.home,
                builder: (_, _) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.transactions,
                name: AppRouteNames.transactions,
                builder: (_, _) => const TransactionsScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: ':transactionId',
                    name: AppRouteNames.transactionDetails,
                    builder: (BuildContext context, GoRouterState state) {
                      return TransactionDetailsScreen(
                        transactionId: state.pathParameters['transactionId']!,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.budgets,
                name: AppRouteNames.budgets,
                builder: (_, _) => const SummaryScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'category/:transactionType/:categoryIds',
                    name: AppRouteNames.categoryDetails,
                    builder: (BuildContext context, GoRouterState state) {
                      final CategoryDetailsRouteData? routeData =
                          CategoryDetailsRouteData.tryParse(
                            typeIdentifier:
                                state.pathParameters['transactionType'],
                            categoryIdentifiers:
                                state.pathParameters['categoryIds'],
                            year: state.uri.queryParameters['year'],
                            month: state.uri.queryParameters['month'],
                          );
                      if (routeData == null) {
                        return Scaffold(
                          appBar: AppBar(title: const Text('Category details')),
                          body: const AppErrorState(
                            title: 'Category not found',
                            message:
                                'This category link is incomplete or invalid.',
                          ),
                        );
                      }
                      return CategoryDetailsScreen(routeData: routeData);
                    },
                    routes: <RouteBase>[
                      GoRoute(
                        path: 'transactions/:transactionId',
                        name: AppRouteNames.categoryTransactionDetails,
                        builder: (BuildContext context, GoRouterState state) {
                          return TransactionDetailsScreen(
                            transactionId:
                                state.pathParameters['transactionId']!,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.profile,
                name: AppRouteNames.profile,
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
