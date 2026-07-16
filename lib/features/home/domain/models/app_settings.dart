class AppSettings {
  final String currency;
  final double monthlyAllocation;
  final int budgetCycleStartDay;

  AppSettings({
    this.currency = 'LKR',
    this.monthlyAllocation = 0.0,
    this.budgetCycleStartDay = 1,
  });

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      currency: map['currency'] as String? ?? 'LKR',
      monthlyAllocation: (map['monthlyAllocation'] as num?)?.toDouble() ?? 0.0,
      budgetCycleStartDay: map['budgetCycleStartDay'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'currency': currency,
      'monthlyAllocation': monthlyAllocation,
      'budgetCycleStartDay': budgetCycleStartDay,
    };
  }

  AppSettings copyWith({
    String? currency,
    double? monthlyAllocation,
    int? budgetCycleStartDay,
  }) {
    return AppSettings(
      currency: currency ?? this.currency,
      monthlyAllocation: monthlyAllocation ?? this.monthlyAllocation,
      budgetCycleStartDay: budgetCycleStartDay ?? this.budgetCycleStartDay,
    );
  }
}
