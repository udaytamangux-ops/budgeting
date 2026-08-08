final class RecurringDateService {
  const RecurringDateService();

  DateTime canonicalLocalNoon(DateTime value) {
    final DateTime local = value.toLocal();
    return DateTime(local.year, local.month, local.day, 12).toUtc();
  }

  int compare(DateTime first, DateTime second) {
    return canonicalLocalNoon(first).compareTo(canonicalLocalNoon(second));
  }

  bool isSameDay(DateTime first, DateTime second) {
    return compare(first, second) == 0;
  }
}
