import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_core/src/theme/app_colors.dart';
import 'package:flutter_clean_core/src/widgets/app_shimmer.dart';

/// Premium custom image widget with integrated:
/// - CachedNetworkImage support for automatic caching.
/// - Self-contained custom Shimmer skeleton animations for loading states.
/// - Circular (Avatar style) and rounded rectangular borders.
/// - Handled error state fallbacks.
class AppImage extends StatelessWidget {
  const AppImage({
    required this.imageUrl,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.isCircular = false,
    this.placeholder,
    this.errorWidget,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool isCircular;
  final Widget? placeholder;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    final isNetwork =
        imageUrl.startsWith('http') || imageUrl.startsWith('https');

    Widget imageWidget;
    if (isNetwork) {
      imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) =>
            placeholder ??
            AppShimmer(
              width: width,
              height: height,
              borderRadius: borderRadius,
              isCircular: isCircular,
            ),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildErrorWidget(),
      );
    } else {
      imageWidget = Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _buildErrorWidget(),
      );
    }

    if (isCircular) {
      return ClipOval(child: imageWidget);
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: isCircular ? null : (borderRadius ?? BorderRadius.circular(12)),
          shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_not_supported_rounded,
          color: AppColors.grey400,
        ),
      ),
    );
  }
}


