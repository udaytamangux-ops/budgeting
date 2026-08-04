final class Money implements Comparable<Money> {
  const Money({required this.minorUnits, this.currencyCode = 'NPR'})
    : assert(currencyCode != '');

  const Money.zero({this.currencyCode = 'NPR'}) : minorUnits = 0;

  final int minorUnits;
  final String currencyCode;

  bool get isNegative => minorUnits < 0;
  bool get isPositive => minorUnits > 0;
  bool get isZero => minorUnits == 0;

  Money get absolute => isNegative
      ? Money(minorUnits: -minorUnits, currencyCode: currencyCode)
      : this;

  Money operator +(Money other) {
    _ensureSameCurrency(other);
    return Money(
      minorUnits: minorUnits + other.minorUnits,
      currencyCode: currencyCode,
    );
  }

  Money operator -(Money other) {
    _ensureSameCurrency(other);
    return Money(
      minorUnits: minorUnits - other.minorUnits,
      currencyCode: currencyCode,
    );
  }

  bool operator <(Money other) => compareTo(other) < 0;

  bool operator <=(Money other) => compareTo(other) <= 0;

  bool operator >(Money other) => compareTo(other) > 0;

  bool operator >=(Money other) => compareTo(other) >= 0;

  @override
  int compareTo(Money other) {
    _ensureSameCurrency(other);
    return minorUnits.compareTo(other.minorUnits);
  }

  void _ensureSameCurrency(Money other) {
    if (currencyCode != other.currencyCode) {
      throw ArgumentError(
        'Cannot calculate with $currencyCode and ${other.currencyCode}.',
      );
    }
  }

  @override
  bool operator ==(Object other) {
    return other is Money &&
        other.minorUnits == minorUnits &&
        other.currencyCode == currencyCode;
  }

  @override
  int get hashCode => Object.hash(minorUnits, currencyCode);

  @override
  String toString() => 'Money($currencyCode $minorUnits minor units)';
}
