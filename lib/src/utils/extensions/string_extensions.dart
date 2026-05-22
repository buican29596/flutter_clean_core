/// Convenient extensions on [String].
extension StringExtensions on String {
  /// Capitalize the first letter.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalize first letter of each word.
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Check if string is a valid email.
  bool get isValidEmail {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(this);
  }

  /// Check if string is a valid phone number.
  bool get isValidPhone {
    return RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(this);
  }

  /// Check if string is a valid URL.
  bool get isValidUrl {
    return Uri.tryParse(this)?.hasAbsolutePath ?? false;
  }

  /// Truncate string to a given length with ellipsis.
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Remove all whitespace.
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Convert to int, or return null if invalid.
  int? get toIntOrNull => int.tryParse(this);

  /// Convert to double, or return null if invalid.
  double? get toDoubleOrNull => double.tryParse(this);
}

/// Extensions on nullable strings.
extension NullableStringExtensions on String? {
  /// Return true if string is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Return true if string is not null and not empty.
  bool get isNotNullOrEmpty => !isNullOrEmpty;

  /// Return the string or a default value if null/empty.
  String orDefault([String defaultValue = '']) {
    return isNullOrEmpty ? defaultValue : this!;
  }
}
