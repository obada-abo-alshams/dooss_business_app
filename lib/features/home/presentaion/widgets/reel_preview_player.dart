import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/colors.dart';

/// Simple ReelPreviewPlayer for home screen cards (120x156)
/// Just a preview - no complex playback logic here
class ReelPreviewPlayer extends StatefulWidget {
  final String reelUrl;
  final String? thumbnailUrl;

  const ReelPreviewPlayer({
    super.key,
    required this.reelUrl,
    this.thumbnailUrl,
  });

  @override
  State<ReelPreviewPlayer> createState() => _ReelPreviewPlayerState();
}

class _ReelPreviewPlayerState extends State<ReelPreviewPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.reelUrl.isNotEmpty) {
      _initializePreview();
    }
  }

  Future<void> _initializePreview() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.reelUrl));
      await _controller!.initialize();
      
      // Set volume to 0 and pause - this is just a preview
      await _controller!.setVolume(0.0);
      await _controller!.pause();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      print('❌ ReelPreviewPlayer: Error initializing preview: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120.w,
      height: 156.h,
      decoration: BoxDecoration(
        color: AppColors.black,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: _buildPreviewContent(),
      ),
    );
  }

  Widget _buildPreviewContent() {
    if (_hasError) {
      return _buildErrorState();
    }

    if (!_isInitialized || _controller == null) {
      return _buildLoadingOrThumbnail();
    }

    return Stack(
      children: [
        // Video preview (paused first frame)
        Positioned.fill(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _controller!.value.size.width,
              height: _controller!.value.size.height,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
        
        // Play icon overlay to indicate it's tappable
        Center(
          child: Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.black.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow,
              color: AppColors.white,
              size: 20.sp,
            ),
          ),
        ),
        
        // Gradient overlay for better contrast
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  AppColors.black.withOpacity(0.3),
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOrThumbnail() {
    // If we have a thumbnail, show it while loading
    if (widget.thumbnailUrl?.isNotEmpty == true) {
      return Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              widget.thumbnailUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            ),
          ),
          Center(
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: AppColors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow,
                color: AppColors.white,
                size: 20.sp,
              ),
            ),
          ),
        ],
      );
    }

    // Otherwise show loading or placeholder
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.gray.withOpacity(0.2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library,
              color: AppColors.gray,
              size: 24.sp,
            ),
            SizedBox(height: 4.h),
            if (!_isInitialized && !_hasError)
              SizedBox(
                width: 16.w,
                height: 16.h,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      color: AppColors.gray.withOpacity(0.2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.gray,
              size: 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              'Preview Error',
              style: TextStyle(
                color: AppColors.gray,
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}