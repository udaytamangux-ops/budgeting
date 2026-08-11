import 'package:budgeting_app/app/routing/app_route_names.dart';
import 'package:budgeting_app/app/routing/app_routes.dart';
import 'package:budgeting_app/app/routing/authenticated_shell.dart';
import 'package:budgeting_app/app/routing/category_details_route_data.dart';
import 'package:budgeting_app/app/routing/transaction_form_route.dart';
import 'package:budgeting_app/app/routing/transfer_form_route.dart';
import 'package:budgeting_app/core/widgets/app_error_state.dart';
import 'package:budgeting_app/features/access/domain/entities/access_mode.dart';
import 'package:budgeting_app/features/access/presentation/controllers/access_providers.dart';
import 'package:budgeting_app/features/access/presentation/screens/access_choice_screen.dart';
import 'package:budgeting_app/features/access/presentation/screens/account_unavailable_screen.dart';
import 'package:budgeting_app/features/home/presentation/screens/home_screen.dart';
import 'package:budgeting_app/features/profile/presentation/screens/privacy_and_data_screen.dart';
import 'package:budgeting_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:budgeting_app/features/recurring/presentation/screens/recurring_rule_form_route.dart';
import 'package:budgeting_app/features/recurring/presentation/screens/recurring_transactions_screen.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/settings/presentation/screens/calendar_setup_screen.dart';
import 'package:budgeting_app/features/summary/presentation/screens/category_details_screen.dart';
import 'package:budgeting_app/features/summary/presentation/screens/summary_screen.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/domain/entities/transaction_enums.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/add_transaction_controller.dart';
import 'package:budgeting_app/features/transactions/presentation/screens/transaction_details_screen.dart';
import 'package:budgeting_app/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:budgeting_app/features/transfers/domain/entities/financial_transfer.dart';
import 'package:budgeting_app/features/transfers/presentation/controllers/add_transfer_controller.dart';
import 'package:budgeting_app/features/transfers/presentation/screens/add_transfer_screen.dart';
import 'package:budgeting_app/features/transfers/presentation/screens/transfer_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  final ChangeNotifier refreshNotifier = ref.watch(_routerRefreshProvider);
  final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: refreshNotifier,
    redirect: (BuildContext context, GoRouterState state) {
      final AccessMode accessMode =
          ref.read(accessModeProvider).valueOrNull ?? AccessMode.undecided;
      final bool calendarSetupComplete =
          ref.read(calendarSetupCompleteProvider).valueOrNull ?? false;
      final String location = state.matchedLocation;
      final bool isAccessEntry =
          location == AppRoutes.access ||
          location == AppRoutes.signIn ||
          location == AppRoutes.signUp;
      final bool isCalendarSetup = location == AppRoutes.calendarSetup;
      final bool hasAccess = accessMode != AccessMode.undecided;

      if (!hasAccess && !isAccessEntry) {
        final String requestedLocation = state.uri.toString();
        final Map<String, String> query = requestedLocation.startsWith('/app/')
            ? <String, String>{'from': requestedLocation}
            : const <String, String>{};
        return Uri(path: AppRoutes.access, queryParameters: query).toString();
      }

      if (hasAccess && location == AppRoutes.access) {
        final String? intended = _safeIntendedLocation(
          state.uri.queryParameters['from'],
        );
        if (!calendarSetupComplete) {
          return _calendarSetupLocation(intended);
        }
        return intended ?? AppRoutes.home;
      }

      if (hasAccess &&
          !calendarSetupComplete &&
          !isCalendarSetup &&
          !isAccessEntry) {
        return _calendarSetupLocation(
          _safeIntendedLocation(state.uri.toString()),
        );
      }

      if (hasAccess && calendarSetupComplete && isCalendarSetup) {
        return _safeIntendedLocation(state.uri.queryParameters['from']) ??
            AppRoutes.home;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.access,
        name: AppRouteNames.access,
        builder: (BuildContext context, GoRouterState state) {
          return AccessChoiceScreen(
            intendedLocation: _safeIntendedLocation(
              state.uri.queryParameters['from'],
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.calendarSetup,
        name: AppRouteNames.calendarSetup,
        builder: (BuildContext context, GoRouterState state) {
          return CalendarSetupScreen(
            intendedLocation: _safeIntendedLocation(
              state.uri.queryParameters['from'],
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.signIn,
        name: AppRouteNames.signIn,
        builder: (_, _) =>
            const AccountUnavailableScreen(actionTitle: 'Sign in'),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        name: AppRouteNames.signUp,
        builder: (_, _) =>
            const AccountUnavailableScreen(actionTitle: 'Create account'),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.addExpense,
        name: AppRouteNames.addTransaction,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final bool isNewTransfer =
              state.uri.queryParameters['type'] == 'transfer' &&
              state.uri.queryParameters['transferId'] == null &&
              state.uri.queryParameters['repeatTransferId'] == null;
          if (isNewTransfer) {
            return MaterialPage<FinancialTransfer>(
              key: state.pageKey,
              fullscreenDialog: true,
              child: const AddTransferScreen(),
            );
          }
          final TransactionType initialType =
              state.uri.queryParameters['type'] == 'income'
              ? TransactionType.income
              : TransactionType.expense;
          final String? editTransactionId =
              state.uri.queryParameters['transactionId'];
          final String? repeatTransactionId =
              state.uri.queryParameters['repeatTransactionId'];
          final String? occurrenceId =
              state.uri.queryParameters['occurrenceId'];
          final String? transferId = state.uri.queryParameters['transferId'];
          final String? repeatTransferId =
              state.uri.queryParameters['repeatTransferId'];
          if (transferId != null || repeatTransferId != null) {
            return MaterialPage<Object?>(
              key: state.pageKey,
              fullscreenDialog: true,
              child: TransferFormRoute(
                transferId: transferId ?? repeatTransferId!,
                intent: transferId != null
                    ? TransferFormIntent.edit
                    : TransferFormIntent.repeat,
              ),
            );
          }
          final TransactionFormIntent intent = occurrenceId != null
              ? TransactionFormIntent.recurringOccurrence
              : repeatTransactionId != null
              ? TransactionFormIntent.repeat
              : editTransactionId != null
              ? TransactionFormIntent.edit
              : TransactionFormIntent.create;
          return MaterialPage<FinancialTransaction>(
            key: state.pageKey,
            fullscreenDialog: true,
            child: TransactionFormRoute(
              initialType: initialType,
              transactionId: repeatTransactionId ?? editTransactionId,
              recurringOccurrenceId: occurrenceId,
              intent: intent,
            ),
          );
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.recurring,
        name: AppRouteNames.recurring,
        builder: (_, _) => const RecurringTransactionsScreen(),
        routes: <RouteBase>[
          GoRoute(
            path: 'new',
            name: AppRouteNames.createRecurring,
            pageBuilder: (BuildContext context, GoRouterState state) {
              return MaterialPage<void>(
                key: state.pageKey,
                fullscreenDialog: true,
                child: RecurringRuleFormRoute(
                  sourceTransactionId:
                      state.uri.queryParameters['sourceTransactionId'],
                ),
              );
            },
          ),
          GoRoute(
            path: ':ruleId/edit',
            name: AppRouteNames.editRecurring,
            pageBuilder: (BuildContext context, GoRouterState state) {
              return MaterialPage<void>(
                key: state.pageKey,
                fullscreenDialog: true,
                child: RecurringRuleFormRoute(
                  ruleId: state.pathParameters['ruleId']!,
                ),
              );
            },
          ),
        ],
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
                    path: 'transfers/:transferId',
                    name: AppRouteNames.transferDetails,
                    builder: (BuildContext context, GoRouterState state) {
                      return TransferDetailsScreen(
                        transferId: state.pathParameters['transferId']!,
                      );
                    },
                  ),
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
                      final CategoryDetailsRouteData?
                      routeData = CategoryDetailsRouteData.tryParse(
                        typeIdentifier: state.pathParameters['transactionType'],
                        categoryIdentifiers:
                            state.pathParameters['categoryIds'],
                        year: state.uri.queryParameters['year'],
                        month: state.uri.queryParameters['month'],
                        calendarSystem: state.uri.queryParameters['calendar'],
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
                routes: <RouteBase>[
                  GoRoute(
                    path: 'privacy-and-data',
                    name: AppRouteNames.privacyAndData,
                    builder: (_, _) => const PrivacyAndDataScreen(),
                  ),
                ],
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

final Provider<ChangeNotifier> _routerRefreshProvider =
    Provider<ChangeNotifier>((Ref ref) {
      final _RouterRefreshNotifier notifier = _RouterRefreshNotifier();
      ref.listen<AsyncValue<AccessMode>>(accessModeProvider, (_, _) {
        notifier.refresh();
      });
      ref.listen<AsyncValue<bool>>(calendarSetupCompleteProvider, (_, _) {
        notifier.refresh();
      });
      ref.onDispose(notifier.dispose);
      return notifier;
    });

final class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

String? _safeIntendedLocation(String? value) {
  return value != null && value.startsWith('/app/') ? value : null;
}

String _calendarSetupLocation(String? intendedLocation) {
  return Uri(
    path: AppRoutes.calendarSetup,
    queryParameters: intendedLocation == null
        ? null
        : <String, String>{'from': intendedLocation},
  ).toString();
}
