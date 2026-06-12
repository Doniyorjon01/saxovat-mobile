/// Converts an ISO timestamp into a short relative label, e.g. "2 days ago".
/// Falls back to a YYYY-MM-DD date for anything older than a few weeks.
String relativeTime(String iso) {
  DateTime t;
  try {
    t = DateTime.parse(iso).toLocal();
  } catch (_) {
    return iso.length >= 10 ? iso.substring(0, 10) : iso;
  }
  final diff = DateTime.now().difference(t);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) {
    final m = diff.inMinutes;
    return '$m ${m == 1 ? "minute" : "minutes"} ago';
  }
  if (diff.inHours < 24) {
    final h = diff.inHours;
    return '$h ${h == 1 ? "hour" : "hours"} ago';
  }
  if (diff.inDays < 7) {
    final d = diff.inDays;
    return '$d ${d == 1 ? "day" : "days"} ago';
  }
  if (diff.inDays < 30) {
    final w = (diff.inDays / 7).floor();
    return '$w ${w == 1 ? "week" : "weeks"} ago';
  }
  final y = t.year.toString().padLeft(4, '0');
  final mo = t.month.toString().padLeft(2, '0');
  final d = t.day.toString().padLeft(2, '0');
  return '$y-$mo-$d';
}

/// "2026-06-10T..." → "June 2026" (used for "Member since ...").
String monthYear(String? iso) {
  if (iso == null) return '';
  DateTime t;
  try {
    t = DateTime.parse(iso).toLocal();
  } catch (_) {
    return '';
  }
  const months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return '${months[t.month - 1]} ${t.year}';
}
