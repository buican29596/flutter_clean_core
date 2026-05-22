import 'package:flutter/material.dart';
import 'package:flutter_clean_core/src/theme/app_colors.dart';

/// Convenient extensions on [BuildContext].
extension ContextExtensions on BuildContext {
  // ─── Theme ──────────────────────────────────────────────────────
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  // ─── MediaQuery ─────────────────────────────────────────────────
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => mediaQuery.padding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;
  double get statusBarHeight => padding.top;
  double get bottomBarHeight => padding.bottom;

  // ─── Navigation ─────────────────────────────────────────────────
  NavigatorState get navigator => Navigator.of(this);

  void pop<T>([T? result]) => navigator.pop(result);

  // ─── SnackBar ───────────────────────────────────────────────────
  void _showCustomSnackBar({
    required String message,
    required IconData icon,
    required Color color,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          backgroundColor: Colors.transparent,
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          content: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.grey900,
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(color: color, width: 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  void showSnackBar(String message) {
    _showCustomSnackBar(
      message: message,
      icon: Icons.info_outline_rounded,
      color: AppColors.primary,
    );
  }

  void showSuccessSnackBar(String message) {
    _showCustomSnackBar(
      message: message,
      icon: Icons.check_circle_rounded,
      color: AppColors.success,
    );
  }

  void showErrorSnackBar(String message) {
    _showCustomSnackBar(
      message: message,
      icon: Icons.error_rounded,
      color: AppColors.error,
    );
  }

  void showWarningSnackBar(String message) {
    _showCustomSnackBar(
      message: message,
      icon: Icons.warning_rounded,
      color: AppColors.warning,
    );
  }

  void showInfoSnackBar(String message) {
    _showCustomSnackBar(
      message: message,
      icon: Icons.info_rounded,
      color: AppColors.info,
    );
  }

  // ─── Focus ──────────────────────────────────────────────────────
  void unfocus() => FocusScope.of(this).unfocus();

  // ─── Brightness ─────────────────────────────────────────────────
  bool get isDarkMode => theme.brightness == Brightness.dark;

  // ─── Responsive Breakpoints ─────────────────────────────────────
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;

  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
}
