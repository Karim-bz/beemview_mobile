import '../l10n/app_strings.dart';

/// "Oct 7, 2026" or "—".
String fmtDate(AppStrings s, DateTime? d) => d == null ? '—' : s.dateLong(d);

/// "Oct 7".
String fmtShort(AppStrings s, DateTime d) => s.dateShort(d);

DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Whole days from today until [d] (negative = overdue). Null if no date.
int? daysUntil(DateTime? d) {
  if (d == null) return null;
  return dateOnly(d).difference(dateOnly(DateTime.now())).inDays;
}

bool isClosedStatus(String? s) => s == 'done' || s == 'canceled';

/// "44m ago", "2h ago", "3d ago", "Oct 7".
String relTime(AppStrings s, DateTime dt) => s.relTime(dt);

String firstName(String full) {
  final t = full.trim();
  if (t.isEmpty) return '';
  return t.split(RegExp(r'\s+')).first;
}

/// "2026-10-06" — the date format the API expects.
String toApiDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
