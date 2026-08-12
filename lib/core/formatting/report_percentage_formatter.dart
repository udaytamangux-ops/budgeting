abstract final class ReportPercentageFormatter {
  static String formatBasisPoints(int basisPoints) {
    if (basisPoints <= 0) return '0%';
    if (basisPoints < 10) return '<0.1%';
    if (basisPoints < 100) {
      final int tenths = (basisPoints + 5) ~/ 10;
      return '${tenths ~/ 10}.${tenths % 10}%';
    }
    return '${(basisPoints + 50) ~/ 100}%';
  }
}
