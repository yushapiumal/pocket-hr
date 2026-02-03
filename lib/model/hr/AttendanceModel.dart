class AttendanceModel {
  String day;
  String dow;
  String type;
  bool isOffday;
  Map<String, dynamic> boilerPlate;

  AttendanceModel({
    required this.day,
    required this.dow,
    required this.type,
    required this.isOffday,
    required this.boilerPlate,
  });

  /// Parses both legacy API shapes and the new v2 attendance/user records.
  /// This is intentionally defensive (null-safe) to prevent runtime crashes.
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    // If caller already provided boilerPlate in the expected format, use it.
    final bpAny = json['boilerPlate'];
    final Map<String, dynamic> bp = bpAny is Map
        ? Map<String, dynamic>.from(bpAny)
        : <String, dynamic>{};

    // v2 record: attendance punches array
    final attAny = json['attendance'];
    final List<Map<String, dynamic>> punches = (attAny is List)
        ? attAny
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList()
        : <Map<String, dynamic>>[];

    int? inEpoch;
    int? outEpoch;
    for (final p in punches) {
      final t = p['time'];
      final epoch = (t is int) ? t : (t is num ? t.toInt() : int.tryParse(t?.toString() ?? ''));
      if (epoch == null) continue;
      final punchType = (p['type'] ?? '').toString();
      if (punchType == 'in' && inEpoch == null) inEpoch = epoch;
      if (punchType == 'out') outEpoch = epoch;
    }

    final DateTime? base = inEpoch != null
        ? DateTime.fromMillisecondsSinceEpoch(inEpoch * 1000)
        : (outEpoch != null ? DateTime.fromMillisecondsSinceEpoch(outEpoch * 1000) : null);

    final String computedDay = base != null ? _fmtDate(base) : '';
    final String computedDow = base != null ? _fmtDow(base) : '';

    // Resolve day/dow/type from boilerPlate first, then computed values, then json fallbacks.
    final String day = (bp['day'] ?? json['day'] ?? computedDay).toString();
    final String dow = (bp['dow'] ?? json['dow'] ?? computedDow).toString();

    // Very old API might store type under different keys
    final String type = (json['type'] ?? json['attendance_type'] ?? (json['isOffday'] == true ? 'offday' : 'shift')).toString();

    // Determine in/out strings for UI
    final String? inTime = bp['in_time_only']?.toString() ?? (inEpoch != null ? _fmtTime(inEpoch) : null);
    final String? outTime = bp['out_time_only']?.toString() ?? (outEpoch != null ? _fmtTime(outEpoch) : null);

    // Work time formatting as provided by v2
    final String worked = (json['workedHours'] ?? json['worked_hours'] ?? bp['wrkd_hours_fmtd'] ?? '').toString();

    final Map<String, dynamic> boilerPlate = {
      ...bp,
      'day': day,
      'dow': dow,
      'in_time_only': inTime,
      'out_time_only': outTime,
      'wrkd_hours_fmtd': worked.isNotEmpty ? worked : (bp['wrkd_hours_fmtd']),
      'late': bp['late'],
      'over': bp['over'],
    };

    final bool offdayFromJson = json['isOffday'] == true;
    final bool inferredOffday = punches.isEmpty;

    return AttendanceModel(
      day: day,
      dow: dow,
      type: type,
      isOffday: offdayFromJson || inferredOffday,
      boilerPlate: boilerPlate,
    );
  }

  static String _fmtDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  static String _fmtDow(DateTime dt) {
    const dows = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return dows[(dt.weekday - 1).clamp(0, 6)];
  }

  static String _fmtTime(int seconds) {
    final dt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
