final class BsDate {
  const BsDate({required this.year, required this.month, required this.day})
    : assert(month >= 1 && month <= 12),
      assert(day >= 1 && day <= 32);

  final int year;
  final int month;
  final int day;

  @override
  bool operator ==(Object other) {
    return other is BsDate &&
        year == other.year &&
        month == other.month &&
        day == other.day;
  }

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() {
    return '${year.toString().padLeft(4, '0')}-'
        '${month.toString().padLeft(2, '0')}-'
        '${day.toString().padLeft(2, '0')}';
  }
}
