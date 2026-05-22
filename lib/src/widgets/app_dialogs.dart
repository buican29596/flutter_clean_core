import 'package:flutter/material.dart';
import 'package:flutter_clean_core/src/theme/app_colors.dart';
import 'package:flutter_clean_core/src/theme/app_dimens.dart';
import 'package:flutter_clean_core/src/theme/app_text_styles.dart';
import 'package:flutter_clean_core/src/widgets/app_button.dart';
import 'package:flutter_clean_core/src/widgets/app_loading.dart';

/// Premium custom dialog utilities including:
/// - Custom ScaleTransitionDialog for high-end pop-in animations.
/// - Un-dismissible loading overlays.
/// - Status dialogs (Success / Error) with circular colored icon frames.
/// - Standardized side-by-side cancel/confirm dialog boxes.
class AppDialogs {
  const AppDialogs._();

  static bool _isLoadingVisible = false;

  /// Show a non-dismissible loading overlay dialog.
  static void showLoading(
    BuildContext context, {
    String message = 'Loading...',
  }) {
    if (_isLoadingVisible) return;
    _isLoadingVisible = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (context) {
        return PopScope(
          canPop: false,
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimens.spacing24,
                  vertical: AppDimens.spacing20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const AppLoading(size: 28, strokeWidth: 3),
                    const SizedBox(width: 16),
                    Text(
                      message,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.grey800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _isLoadingVisible = false;
    });
  }

  /// Hide the currently visible loading dialog.
  static void hideLoading(BuildContext context) {
    if (_isLoadingVisible) {
      Navigator.of(context).pop();
    }
  }

  /// Show a premium custom status dialog (Success / Error / Info).
  static void showStatus({
    required BuildContext context,
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ScaleTransitionDialog(
            child: Container(
              padding: const EdgeInsets.all(AppDimens.spacing24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimens.radiusXXLarge),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppDimens.spacing16),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: AppDimens.spacing20),
                  Text(
                    title,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.grey900,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimens.spacing8),
                  Text(
                    message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimens.spacing24),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: buttonText,
                      onPressed: () {
                        Navigator.of(context).pop();
                        onPressed?.call();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Show a premium Success Dialog.
  static void showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    showStatus(
      context: context,
      title: title,
      message: message,
      icon: Icons.check_rounded,
      iconColor: AppColors.success,
      iconBgColor: AppColors.successLight,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Show a premium Error Dialog.
  static void showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    showStatus(
      context: context,
      title: title,
      message: message,
      icon: Icons.error_outline_rounded,
      iconColor: AppColors.error,
      iconBgColor: AppColors.errorLight,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Show a confirmation dialog with cancel and confirm actions.
  static void showConfirm({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    VoidCallback? onCancel,
  }) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ScaleTransitionDialog(
            child: Container(
              padding: const EdgeInsets.all(AppDimens.spacing24),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppDimens.radiusXXLarge),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.grey900,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppDimens.spacing12),
                  Text(
                    message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  const SizedBox(height: AppDimens.spacing24),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: cancelText,
                          variant: AppButtonVariant.secondary,
                          onPressed: () {
                            Navigator.of(context).pop();
                            onCancel?.call();
                          },
                        ),
                      ),
                      const SizedBox(width: AppDimens.spacing12),
                      Expanded(
                        child: AppButton(
                          text: confirmText,
                          onPressed: () {
                            Navigator.of(context).pop();
                            onConfirm();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Simple stateful scale transition to make popups pop up beautifully.
class ScaleTransitionDialog extends StatefulWidget {
  const ScaleTransitionDialog({required this.child, super.key});

  final Widget child;

  @override
  State<ScaleTransitionDialog> createState() => _ScaleTransitionDialogState();
}

class _ScaleTransitionDialogState extends State<ScaleTransitionDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}
