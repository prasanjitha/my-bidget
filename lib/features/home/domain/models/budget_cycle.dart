class BudgetCycle {
  final DateTime startDate;
  final DateTime endDate;
  final String cycleString;

  BudgetCycle({
    required this.startDate,
    required this.endDate,
    required this.cycleString,
  });

  @override
  String toString() {
    return 'BudgetCycle(start: $startDate, end: $endDate, cycle: $cycleString)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BudgetCycle &&
        other.startDate == startDate &&
        other.endDate == endDate &&
        other.cycleString == cycleString;
  }

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode ^ cycleString.hashCode;
}
