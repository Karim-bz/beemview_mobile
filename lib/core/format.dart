const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "Oct 7, 2026" or "—".
String fmtDate(DateTime? d) =>
    d == null ? '—' : '${_months[d.month - 1]} ${d.day}, ${d.year}';

/// "Oct 7".
String fmtShort(DateTime d) => '${_months[d.month - 1]} ${d.day}';

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Whole days from today until [d] (negative = overdue). Null if no date.
int? daysUntil(DateTime? d) {
  if (d == null) return null;
  return dateOnly(d).difference(dateOnly(DateTime.now())).inDays;
}

bool isClosedStatus(String? s) => s == 'done' || s == 'canceled';

/// "44m ago", "2h ago", "3d ago", "Oct 7".
String relTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inHours < 1) return '${diff.inMinutes}m ago';
  if (diff.inDays < 1) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return fmtShort(dt);
}

String greeting() {
  final h = DateTime.now().hour;
  if (h < 12) return 'Good morning';
  if (h < 18) return 'Good afternoon';
  return 'Good evening';
}

String firstName(String full) {
  final t = full.trim();
  if (t.isEmpty) return '';
  return t.split(RegExp(r'\s+')).first;
}
