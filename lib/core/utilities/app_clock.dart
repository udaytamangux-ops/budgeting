import 'package:flutter_riverpod/flutter_riverpod.dart';

final Provider<DateTime Function()> appClockProvider =
    Provider<DateTime Function()>((Ref ref) => DateTime.now);

final Provider<DateTime> currentDateProvider = Provider<DateTime>(
  (Ref ref) => ref.watch(appClockProvider)(),
);
