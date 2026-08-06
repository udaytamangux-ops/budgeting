import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/features/transactions/presentation/controllers/transaction_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class AppBootstrap {
  static Future<ProviderContainer> createContainer({
    AppDatabase? database,
  }) async {
    return ProviderContainer(
      overrides: <Override>[
        if (database != null) appDatabaseProvider.overrideWithValue(database),
      ],
    );
  }
}
