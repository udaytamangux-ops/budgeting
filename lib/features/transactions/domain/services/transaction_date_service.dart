enum QuickDateSelection { today, yesterday, chosenDate }

final class TransactionDateService {
  const TransactionDateService();

  DateTime today(DateTime currentDate) {
    return localCalendarDate(currentDate);
  }

  DateTime yesterday(DateTime currentDate) {
    final DateTime localToday = today(currentDate);
    return DateTime(localToday.year, localToday.month, localToday.day - 1);
  }

  DateTime localCalendarDate(DateTime date) {
    final DateTime localDate = date.toLocal();
    return DateTime(localDate.year, localDate.month, localDate.day);
  }

  QuickDateSelection selectionFor({
    required DateTime selectedDate,
    required DateTime currentDate,
  }) {
    final DateTime selected = localCalendarDate(selectedDate);
    if (_isSameDate(selected, today(currentDate))) {
      return QuickDateSelection.today;
    }
    if (_isSameDate(selected, yesterday(currentDate))) {
      return QuickDateSelection.yesterday;
    }
    return QuickDateSelection.chosenDate;
  }

  bool _isSameDate(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }
}
