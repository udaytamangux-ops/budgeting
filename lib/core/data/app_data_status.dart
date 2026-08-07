import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppDataMode { localDevice, cloudSynced }

final class AppDataStatus {
  const AppDataStatus({required this.mode});

  final AppDataMode mode;

  String get storageTitle => switch (mode) {
    AppDataMode.localDevice => 'Stored on this device',
    AppDataMode.cloudSynced => 'Cloud-synchronised storage',
  };

  String get storageDescription => switch (mode) {
    AppDataMode.localDevice =>
      'Your records are stored locally on this device and remain available '
          'after the app is closed. Uninstalling the app or clearing app data '
          'may remove them.',
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
      'Your records are not backed up or synchronised across devices.';

  static const String analyticsTitle = 'No financial data transmission';
  static const String analyticsDescription =
      'No analytics service currently sends transaction amounts, merchants, '
      'notes, or other financial records.';
}

final Provider<AppDataStatus> appDataStatusProvider = Provider<AppDataStatus>(
  (Ref ref) => const AppDataStatus(mode: AppDataMode.localDevice),
);
