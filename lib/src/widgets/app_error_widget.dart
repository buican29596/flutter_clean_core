import 'package:flutter/material.dart';
import 'package:flutter_clean_core/src/theme/app_colors.dart';
import 'package:flutter_clean_core/src/theme/app_dimens.dart';
import 'package:flutter_clean_core/src/theme/app_text_styles.dart';
import 'package:flutter_clean_core/src/widgets/app_button.dart';

/// Premium custom error state widget displaying an error card with soft red drop shadows,
/// stylized circular error icon border, and primary retry action button.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    required this.message,
    super.key,
    this.onRetry,
    this.icon,
    this.title,
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String? title;

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
                color: AppColors.error.withOpacity(0.06),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: AppColors.error.withOpacity(0.12),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimens.spacing20),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.error_outline_rounded,
                  size: 44,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: AppDimens.spacing24),
              Text(
                title ?? 'Something Went Wrong',
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
              if (onRetry != null) ...[
                const SizedBox(height: AppDimens.spacing24),
                AppButton(
                  text: 'Try Again',
                  onPressed: onRetry,
                  variant: AppButtonVariant.primary,
                  width: 160,
                  icon: Icons.refresh_rounded,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
