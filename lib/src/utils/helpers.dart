import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// General helper functions used across the app.
class Helpers {
  const Helpers._();

  /// Format number with thousand separators.
  static String formatNumber(num number, {int decimalDigits = 0}) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '',
      decimalDigits: decimalDigits,
    ).format(number).trim();
  }

  /// Format currency (VND).
  static String formatCurrency(num amount) {
    return NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    ).format(amount);
  }

  /// Get initials from a full name (e.g., "John Doe" → "JD").
  static String getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Generate a color from a string (useful for avatars).
  static Color getColorFromString(String input) {
    final hash = input.hashCode;
    return Color.fromARGB(
      255,
      (hash & 0xFF0000) >> 16,
      (hash & 0x00FF00) >> 8,
      hash & 0x0000FF,
    );
  }

}

/// Real Timer-based debouncer helper class for handling user inputs.
class Debouncer {
  Debouncer({this.milliseconds = 500});

  final int milliseconds;
  Timer? _timer;

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
