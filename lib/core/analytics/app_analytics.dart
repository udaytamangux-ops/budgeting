import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class AppAnalytics {
  void recordEvent(String eventName);
}

final class NoOpAppAnalytics implements AppAnalytics {
  const NoOpAppAnalytics();

  @override
  void recordEvent(String eventName) {}
}

final Provider<AppAnalytics> appAnalyticsProvider = Provider<AppAnalytics>(
  (Ref ref) => const NoOpAppAnalytics(),
);
