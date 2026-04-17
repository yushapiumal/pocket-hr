class FormatUtils {
  static String money(num v) => v.toStringAsFixed(2);
  
  static String dateFromUnixSeconds(int seconds) {
    if (seconds <= 0) return '-';
    final dt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
