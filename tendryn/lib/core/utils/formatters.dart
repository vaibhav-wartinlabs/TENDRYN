abstract class Formatters {
  /// South African rand: `R 8 450,00` (space thousands separator, decimal comma).
  /// Render with `AppTextStyles.tabular` so the digits align.
  static String zar(num amount) {
    final cents = (amount.abs() * 100).round();
    final whole = (cents ~/ 100).toString();
    final grouped = whole.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ' ');
    final sign = amount < 0 ? '-' : '';
    return '${sign}R $grouped,${_two(cents % 100)}';
  }

  static const _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  /// `Tuesday, 29 September 2026`
  static String longDate(DateTime d) => '${_weekdays[d.weekday - 1]}, ${d.day} ${_months[d.month - 1]} ${d.year}';

  /// `29 Sep 2026`
  static String shortDate(DateTime d) => '${d.day} ${_months[d.month - 1].substring(0, 3)} ${d.year}';

  /// `2026-09-29` (API query value)
  static String isoDate(DateTime d) => '${d.year}-${_two(d.month)}-${_two(d.day)}';

  /// `Good morning` / `Good afternoon` / `Good evening`
  static String greeting(DateTime d) => d.hour < 12 ? 'Good morning' : (d.hour < 18 ? 'Good afternoon' : 'Good evening');

  /// Rand as shown on the Dashboard: `R 8,450.00` (or `R 8,450` with [decimals] 0).
  static String rand(num amount, {int decimals = 2}) {
    final fixed = amount.abs().toStringAsFixed(decimals);
    final parts = fixed.split('.');
    final grouped = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return '${amount < 0 ? '-' : ''}R $grouped${parts.length > 1 ? '.${parts[1]}' : ''}';
  }

  static String initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  /// `24 min`, `1 h`, `1 h 10 min`
  static String waitingTime(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '$hours h' : '$hours h $rest min';
  }

  /// Initials of a staff member, skipping a leading title: `Sister Naledi Naidoo` -> `NN`.
  static String staffInitials(String name) {
    final clean = name.replaceAll(RegExp(r'^(Dr|Mr|Mrs|Ms|Sister|Nurse)\.?\s+', caseSensitive: false), '').trim();
    final parts = clean.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, parts.first.length >= 2 ? 2 : 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  static String _two(int n) => n.toString().padLeft(2, '0');
}
