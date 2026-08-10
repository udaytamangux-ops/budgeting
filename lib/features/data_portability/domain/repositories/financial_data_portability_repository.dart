import 'package:budgeting_app/features/data_portability/domain/entities/financial_data_snapshot.dart';

abstract interface class FinancialDataPortabilityRepository {
  Future<FinancialDataSnapshot> readCurrentOwnerSnapshot();

  /// Replaces only the active owner's financial rows in one database
  /// transaction. A failed insert rolls the entire replacement back.
  Future<void> replaceCurrentOwnerSnapshot(FinancialDataSnapshot snapshot);
}
