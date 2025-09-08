import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Optimized image widget that handles caching, loading states, and memory management
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool enableMemoryCache;
  final bool enableDiskCache;
  final Duration fadeInDuration;

  const OptimizedImage({
    super.key,
    this.imageUrl = '',
    this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
  });

  const OptimizedImage.asset({
    super.key,
    required String this.assetPath,
    this.imageUrl = '',
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
  });

  const OptimizedImage.network({
    super.key,
    required String this.imageUrl,
    this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    // Use asset image if provided
    if (assetPath != null && assetPath!.isNotEmpty) {
      return _buildAssetImage();
    }

    // Use network image if URL is provided
    if (imageUrl.isNotEmpty) {
      return _buildNetworkImage();
    }

    // Return error widget if no valid image source
    return _buildErrorWidget();
  }

  Widget _buildAssetImage() {
    return Image.asset(
      assetPath!,
      width: width,
      height: height,
      fit: fit,
      // Enable caching for better performance
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  Widget _buildNetworkImage() {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      // Enable caching for better performance
      cacheWidth: width?.toInt(),
      cacheHeight: height?.toInt(),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return AnimatedOpacity(
            opacity: 1.0,
            duration: fadeInDuration,
            child: child,
          );
        }
        return _buildPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
  }

  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Icons.broken_image,
            color: Colors.grey[400],
            size: 24.sp,
          ),
        );
  }
}