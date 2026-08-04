import 'package:budgeting_app/app/app.dart';
import 'package:budgeting_app/core/utilities/app_clock.dart';
import 'package:budgeting_app/features/transactions/data/repositories/in_memory_transaction_repository.dart';
import 'package:budgeting_app/features/transactions/domain/entities/financial_transaction.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_data.dart';

Future<InMemoryTransactionRepository> pumpBudgetingApp(
  WidgetTester tester, {
  List<FinancialTransaction>? seedTransactions,
  Stream<List<FinancialTransaction>>? transactionStream,
  Duration operationDelay = Duration.zero,
}) async {
  final InMemoryTransactionRepository repository =
      InMemoryTransactionRepository(
        seedTransactions: seedTransactions,
        operationDelay: operationDelay,
        now: () => fixedNow,
      );
  final List<Override> overrides = <Override>[
    appClockProvider.overrideWithValue(() => fixedNow),
    transactionRepositoryProvider.overrideWithValue(repository),
  ];
  if (transactionStream != null) {
    overrides.add(
      transactionListProvider.overrideWith((Ref ref) => transactionStream),
    );
  }
  await tester.pumpWidget(
    ProviderScope(overrides: overrides, child: const BudgetingApp()),
  );
  await tester.pumpAndSettle();
  return repository;
}
