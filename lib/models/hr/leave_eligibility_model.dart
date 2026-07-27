class LeaveApplyEligibility {
  final String userId;
  final String today;
  final String minDate;
  final String maxDate;
  final int configuredDays;
  final int effectiveDays;
  final bool restrictedByPayrollLock;
  final String? lockedPayrollEnd;

  LeaveApplyEligibility({
    required this.userId,
    required this.today,
    required this.minDate,
    required this.maxDate,
    required this.configuredDays,
    required this.effectiveDays,
    required this.restrictedByPayrollLock,
    this.lockedPayrollEnd,
  });

  factory LeaveApplyEligibility.fromJson(Map<String, dynamic> json) {
    return LeaveApplyEligibility(
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      today: (json['today'] ?? '').toString(),
      minDate: (json['minDate'] ?? json['min_date'] ?? '').toString(),
      maxDate: (json['maxDate'] ?? json['max_date'] ?? '').toString(),
      configuredDays: int.tryParse(json['configuredDays']?.toString() ??
              json['configured_days']?.toString() ??
              '0') ??
          0,
      effectiveDays: int.tryParse(json['effectiveDays']?.toString() ??
              json['effective_days']?.toString() ??
              '0') ??
          0,
      restrictedByPayrollLock: json['restrictedByPayrollLock'] == true ||
          json['restricted_by_payroll_lock'] == true,
      lockedPayrollEnd: json['lockedPayrollEnd']?.toString() ??
          json['locked_payroll_end']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'today': today,
      'minDate': minDate,
      'maxDate': maxDate,
      'configuredDays': configuredDays,
      'effectiveDays': effectiveDays,
      'restrictedByPayrollLock': restrictedByPayrollLock,
      if (lockedPayrollEnd != null) 'lockedPayrollEnd': lockedPayrollEnd,
    };
  }

  DateTime? get minDateTime => DateTime.tryParse(minDate);
  DateTime? get maxDateTime => DateTime.tryParse(maxDate);
  DateTime? get todayDateTime => DateTime.tryParse(today);
  DateTime? get lockedPayrollEndDateTime =>
      lockedPayrollEnd != null ? DateTime.tryParse(lockedPayrollEnd!) : null;
}
