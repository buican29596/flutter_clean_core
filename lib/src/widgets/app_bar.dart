import 'package:flutter/material.dart';
import 'package:flutter_clean_core/src/theme/app_colors.dart';
import 'package:flutter_clean_core/src/theme/app_text_styles.dart';

/// Premium custom AppBar replacement implementing PreferredSizeWidget.
///
/// Features:
/// - Custom designed circular back button frame with thin subtle borders.
/// - Scrolled-under tinting disabled by default for clean flat styles.
/// - Centered custom title typography styling.
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AppAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackPress,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation = 0,
    this.bottom,
  });

  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackPress;
  final bool centerTitle;
  final Color? backgroundColor;
  final double elevation;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: AppColors.grey900,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null),
      leading: leading ?? _buildLeadingButton(context),
      actions: actions,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? AppColors.white,
      elevation: elevation,
      scrolledUnderElevation: 0,
      bottom: bottom,
    );
  }

  Widget? _buildLeadingButton(BuildContext context) {
    if (!showBackButton) return null;

    final canPop = Navigator.of(context).canPop();
    if (!canPop) return null;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onBackPress ?? () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.grey50,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.grey200),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.grey800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        56.0 + (bottom?.preferredSize.height ?? 0.0),
      );
}
