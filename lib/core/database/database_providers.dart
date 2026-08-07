import 'dart:async';

import 'package:budgeting_app/core/database/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((
  Ref ref,
) {
  final AppDatabase database = AppDatabase.open();
  ref.onDispose(() => unawaited(database.close()));
  return database;
});
