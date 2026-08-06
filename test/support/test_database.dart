import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/features/transactions/data/repositories/drift_transaction_repository.dart';
import 'package:drift/native.dart';

({AppDatabase database, DriftTransactionRepository repository})
createInMemoryTransactionDatabase() {
  final AppDatabase database = AppDatabase(NativeDatabase.memory());
  return (database: database, repository: DriftTransactionRepository(database));
}
