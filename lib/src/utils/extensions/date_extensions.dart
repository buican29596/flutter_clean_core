import 'package:intl/intl.dart';

/// Convenient extensions on [DateTime].
extension DateTimeExtensions on DateTime {
  /// Format as 'dd/MM/yyyy'.
  String get toDateString => DateFormat('dd/MM/yyyy').format(this);

  /// Format as 'HH:mm'.
  String get toTimeString => DateFormat('HH:mm').format(this);

  /// Format as 'dd/MM/yyyy HH:mm'.
  String get toDateTimeString => DateFormat('dd/MM/yyyy HH:mm').format(this);

  /// Format as 'dd MMM yyyy' (e.g., 01 Jan 2025).
  String get toShortDate => DateFormat('dd MMM yyyy').format(this);

  /// Format with custom pattern.
  String format(String pattern) => DateFormat(pattern).format(this);

  /// Check if the date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if the date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Check if the date is tomorrow.
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year &&
        month == tomorrow.month &&
        day == tomorrow.day;
  }

  /// Get time ago string (e.g., "2 hours ago", "3 days ago").
  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${diff.inDays ~/ 7}w ago';
    if (diff.inDays < 365) return '${diff.inDays ~/ 30}mo ago';
    return '${diff.inDays ~/ 365}y ago';
  }
}
