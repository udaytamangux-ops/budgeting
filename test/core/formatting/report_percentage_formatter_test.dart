import 'package:budgeting_app/core/formatting/report_percentage_formatter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats deterministic basis points for human-readable reports', () {
    expect(ReportPercentageFormatter.formatBasisPoints(9704), '97%');
    expect(ReportPercentageFormatter.formatBasisPoints(208), '2%');
    expect(ReportPercentageFormatter.formatBasisPoints(87), '0.9%');
    expect(ReportPercentageFormatter.formatBasisPoints(1), '<0.1%');
    expect(ReportPercentageFormatter.formatBasisPoints(0), '0%');
  });

  test('handles meaningful formatting boundaries without changing values', () {
    expect(ReportPercentageFormatter.formatBasisPoints(9), '<0.1%');
    expect(ReportPercentageFormatter.formatBasisPoints(10), '0.1%');
    expect(ReportPercentageFormatter.formatBasisPoints(94), '0.9%');
    expect(ReportPercentageFormatter.formatBasisPoints(95), '1.0%');
    expect(ReportPercentageFormatter.formatBasisPoints(100), '1%');
    expect(ReportPercentageFormatter.formatBasisPoints(149), '1%');
    expect(ReportPercentageFormatter.formatBasisPoints(150), '2%');
    expect(ReportPercentageFormatter.formatBasisPoints(10000), '100%');
  });
}
