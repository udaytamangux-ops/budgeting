import 'package:budgeting_app/core/database/database_providers.dart';
import 'package:budgeting_app/features/access/data/repositories/drift_access_preference_repository.dart';
import 'package:budgeting_app/features/access/domain/entities/access_mode.dart';
import 'package:budgeting_app/features/access/domain/repositories/access_preference_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<AccessPreferenceRepository> accessPreferenceRepositoryProvider =
    Provider<AccessPreferenceRepository>((Ref ref) {
      return DriftAccessPreferenceRepository(ref.watch(appDatabaseProvider));
    });

final StreamProvider<AccessMode> accessModeProvider =
    StreamProvider<AccessMode>((Ref ref) {
      return ref.watch(accessPreferenceRepositoryProvider).watchAccessMode();
    });
