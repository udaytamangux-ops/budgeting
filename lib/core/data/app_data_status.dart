import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppDataMode { sessionOnly, localDevice, cloudSynced }

final class AppDataStatus {
  const AppDataStatus({required this.mode});

  final AppDataMode mode;

  String get storageTitle => switch (mode) {
    AppDataMode.sessionOnly => 'Session-only storage',
    AppDataMode.localDevice => 'Local device storage',
    AppDataMode.cloudSynced => 'Cloud-synchronised storage',
  };

  String get storageDescription => switch (mode) {
    AppDataMode.sessionOnly =>
      'Records in this version are kept for the current app session and may '
          'reset when the app restarts.',
    AppDataMode.localDevice =>
      'Records are stored on this device until they are removed.',
    AppDataMode.cloudSynced =>
      'Records are associated with an account and synchronised through the '
          'cloud.',
  };

  static const String bankAccessTitle = 'No bank connection';
  static const String bankAccessDescription =
      'This app does not connect to your bank account, card, digital wallet, '
      'or payment provider.';

  static const String cloudAccessTitle = 'No cloud sync';
  static const String cloudAccessDescription =
      'There is currently no account, cloud backup, or cross-device '
      'synchronisation.';

  static const String analyticsTitle = 'No financial data transmission';
  static const String analyticsDescription =
      'No analytics service currently sends transaction amounts, merchants, '
      'notes, or other financial records.';
}

final Provider<AppDataStatus> appDataStatusProvider = Provider<AppDataStatus>(
  (Ref ref) => const AppDataStatus(mode: AppDataMode.sessionOnly),
);
