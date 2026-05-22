import 'package:flutter/material.dart';
import 'package:flutter_clean_core/src/theme/app_colors.dart';
import 'package:flutter_clean_core/src/theme/app_dimens.dart';
import 'package:flutter_clean_core/src/theme/app_text_styles.dart';

/// Premium custom bottom sheet utilities.
class AppBottomSheet {
  const AppBottomSheet._();

  /// Show a premium custom bottom sheet with rounded corners, drag handle,
  /// close icon, and auto viewport keyboard adjustment handling.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    bool isDismissible = true,
    bool enableDrag = true,
    double? maxHeight,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppDimens.radiusXXLarge),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // Drag Handle indicator
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              if (title != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.grey900,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(color: AppColors.grey200, height: 1),
              ],
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: AppDimens.spacing16,
                    right: AppDimens.spacing16,
                    top: AppDimens.spacing16,
                    bottom: MediaQuery.of(context).viewInsets.bottom +
                        AppDimens.spacing24,
                  ),
                  child: child,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
