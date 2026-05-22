import 'package:flutter/material.dart';
import 'package:flutter_clean_core/src/theme/app_colors.dart';
import 'package:flutter_clean_core/src/theme/app_dimens.dart';
import 'package:flutter_clean_core/src/theme/app_text_styles.dart';
import 'package:flutter_clean_core/src/widgets/app_button.dart';

/// Premium custom empty state widget displaying a structured card with soft shadows,
/// stylized circular icon border, and action button.
class AppEmptyWidget extends StatelessWidget {
  const AppEmptyWidget({
    required this.message,
    super.key,
    this.icon,
    this.title,
    this.actionText,
    this.onAction,
  });

  final String message;
  final IconData? icon;
  final String? title;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.spacing24),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.spacing24,
            vertical: AppDimens.spacing32,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimens.radiusXXLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.spacing20),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.grey100,
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon ?? Icons.folder_open_rounded,
                  size: 44,
                  color: AppColors.grey400,
                ),
              ),
              const SizedBox(height: AppDimens.spacing24),
              Text(
                title ?? 'No Data Found',
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
                  color: AppColors.grey500,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              if (actionText != null && onAction != null) ...[
                const SizedBox(height: AppDimens.spacing24),
                AppButton(
                  text: actionText!,
                  onPressed: onAction,
                  variant: AppButtonVariant.primary,
                  width: 180,
                  size: AppButtonSize.medium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
