import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/colors.dart';
import '../manager/reels_playback_cubit.dart';
import '../manager/reels_playback_state.dart';

/// Perfect aspect ratio video player with no cropping or distortion
/// Uses LayoutBuilder and AspectRatio for dynamic sizing
class PerfectVideoPlayer extends StatefulWidget {
  final bool isCurrentVideo;
  final VoidCallback? onTap;

  const PerfectVideoPlayer({
    super.key,
    required this.isCurrentVideo,
    this.onTap,
  });

  @override
  State<PerfectVideoPlayer> createState() => _PerfectVideoPlayerState();
}

class _PerfectVideoPlayerState extends State<PerfectVideoPlayer> {
  @override
  void dispose() {
    // StatefulWidget for proper disposal - this is the valid exception
    print('🗑️ PerfectVideoPlayer: Disposing video player widget');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReelsPlaybackCubit, ReelsPlaybackState>(
      buildWhen: (previous, current) =>
          previous.controller != current.controller ||
          previous.playbackState != current.playbackState ||
          previous.isLoading != current.isLoading ||
          previous.error != current.error,
      builder: (context, state) {
        if (!widget.isCurrentVideo || state.controller == null) {
          return _buildPlaceholder(state);
        }

        if (!state.isInitialized) {
          return _buildLoadingState();
        }

        return _buildVideoPlayer(state);
      },
    );
  }

  /// Build the perfect aspect ratio video player
  Widget _buildVideoPlayer(ReelsPlaybackState state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final controller = state.controller!;
        final videoAspectRatio = controller.value.aspectRatio;
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;
        final screenAspectRatio = screenWidth / screenHeight;

        return GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: screenWidth,
            height: screenHeight,
            color: AppColors.black,
            child: Center(
              child: _buildAspectRatioContainer(
                videoAspectRatio: videoAspectRatio,
                screenAspectRatio: screenAspectRatio,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                controller: controller,
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build aspect ratio container with perfect fit
  Widget _buildAspectRatioContainer({
    required double videoAspectRatio,
    required double screenAspectRatio,
    required double screenWidth,
    required double screenHeight,
    required VideoPlayerController controller,
  }) {
    // Calculate the perfect dimensions to fill screen without distortion
    double containerWidth;
    double containerHeight;

    if (videoAspectRatio > screenAspectRatio) {
      // Video is wider than screen - fit to screen height
      containerHeight = screenHeight;
      containerWidth = containerHeight * videoAspectRatio;
    } else {
      // Video is taller than screen - fit to screen width
      containerWidth = screenWidth;
      containerHeight = containerWidth / videoAspectRatio;
    }

    return SizedBox(
      width: containerWidth,
      height: containerHeight,
      child: AspectRatio(
        aspectRatio: videoAspectRatio,
        child: VideoPlayer(controller),
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Container(
      color: AppColors.black,
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.white,
          strokeWidth: 2,
        ),
      ),
    );
  }

  /// Build placeholder when video not available
  Widget _buildPlaceholder(ReelsPlaybackState state) {
    return Container(
      color: AppColors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (state.hasError) ...[
              Icon(
                Icons.error_outline,
                color: AppColors.white,
                size: 48.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                'Video Error',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                state.error ?? 'Unknown error',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.7),
                  fontSize: 14.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Icon(
                Icons.video_library,
                color: AppColors.white.withOpacity(0.5),
                size: 48.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                state.currentReel?.title ?? 'No Video',
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.7),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}