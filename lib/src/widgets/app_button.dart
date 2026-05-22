import 'package:flutter/material.dart';
import 'package:flutter_clean_core/src/theme/app_colors.dart';
import 'package:flutter_clean_core/src/theme/app_dimens.dart';
import 'package:flutter_clean_core/src/theme/app_text_styles.dart';

enum AppButtonVariant { primary, secondary, outline, text }

enum AppButtonSize { small, medium, large }

/// Premium interactive button widget with tactile press-scale animation,
/// subtle glows, linear gradients, and layout options.
class AppButton extends StatefulWidget {
  const AppButton({
    required this.text,
    super.key,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.width,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;
  final double? width;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading && widget.onPressed != null) {
      _animationController.forward();
    }
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  void _onTapCancel() {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final height = switch (widget.size) {
      AppButtonSize.small => AppDimens.buttonHeightSmall,
      AppButtonSize.medium => AppDimens.buttonHeightMedium,
      AppButtonSize.large => AppDimens.buttonHeightLarge,
    };

    final isClickable =
        !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: isClickable ? widget.onPressed : null,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: height,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: _getBoxDecoration(),
            child: Center(
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _getBoxDecoration() {
    final isClickable =
        !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

    if (!isClickable) {
      return BoxDecoration(
        color: AppColors.grey300,
        borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
      );
    }

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              AppColors.primary,
              Color(0xFF2E65F6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.24),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        );
      case AppButtonVariant.secondary:
        return BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        );
      case AppButtonVariant.outline:
        return BoxDecoration(
          border: Border.all(color: AppColors.primary, width: 1.5),
          borderRadius: BorderRadius.circular(AppDimens.radiusLarge),
        );
      case AppButtonVariant.text:
        return const BoxDecoration();
    }
  }

  Widget _buildContent() {
    final isClickable =
        !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

    final contentColor = switch (widget.variant) {
      AppButtonVariant.primary =>
        isClickable ? AppColors.white : AppColors.grey500,
      AppButtonVariant.secondary =>
        isClickable ? AppColors.primary : AppColors.grey500,
      AppButtonVariant.outline =>
        isClickable ? AppColors.primary : AppColors.grey500,
      AppButtonVariant.text =>
        isClickable ? AppColors.primary : AppColors.grey500,
    };

    if (widget.isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation(contentColor),
        ),
      );
    }

    final textStyle = switch (widget.size) {
      AppButtonSize.small => AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: contentColor,
        ),
      AppButtonSize.medium => AppTextStyles.button.copyWith(color: contentColor),
      AppButtonSize.large => AppTextStyles.button.copyWith(
          fontSize: 16,
          color: contentColor,
        ),
    };

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.icon,
            size: widget.size == AppButtonSize.small
                ? 16
                : AppDimens.iconMedium,
            color: contentColor,
          ),
          const SizedBox(width: AppDimens.spacing8),
          Text(widget.text, style: textStyle),
        ],
      );
    }

    return Text(widget.text, style: textStyle);
  }
}
