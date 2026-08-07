import 'package:budgeting_app/core/database/app_database.dart';
import 'package:budgeting_app/core/database/database_providers.dart';
import 'package:budgeting_app/features/access/presentation/controllers/access_providers.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/calendar_preference_providers.dart';
import 'package:budgeting_app/features/settings/presentation/controllers/theme_preference_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract final class AppBootstrap {
  static Future<ProviderContainer> createContainer({
    AppDatabase? database,
  }) async {
    final ProviderContainer container = ProviderContainer(
      overrides: <Override>[
        if (database != null) appDatabaseProvider.overrideWithValue(database),
      ],
    );
    await Future.wait(<Future<Object?>>[
      container.read(accessModeProvider.future),
      container.read(primaryCalendarProvider.future),
      container.read(calendarSetupCompleteProvider.future),
      container.read(themePreferenceProvider.future),
    ]);
    return container;
  }
}
