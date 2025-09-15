import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/routes/route_names.dart';
import '../manager/reels_playback_cubit.dart';
import '../manager/reels_playback_state.dart';
import 'perfect_video_player.dart';
import 'reel_gesture_detector.dart';
import 'reel_info_overlay.dart';

/// Home screen reel preview widget
/// Shows a single reel with tap-to-fullscreen functionality
class HomeReelPreview extends StatelessWidget {
  final double height;
  final bool autoPlay;

  const HomeReelPreview({
    super.key,
    this.height = 200,
    this.autoPlay = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReelsPlaybackCubit, ReelsPlaybackState>(
      buildWhen: (previous, current) =>
          previous.currentReel != current.currentReel ||
          previous.reels != current.reels ||
          previous.isLoading != current.isLoading ||
          previous.error != current.error,
      builder: (context, state) {
        if (state.isLoading && state.reels.isEmpty) {
          return _buildLoadingPreview();
        }

        if (state.reels.isEmpty) {
          return _buildEmptyPreview();
        }

        return _buildReelPreview(context, state);
      },
    );
  }

  Widget _buildReelPreview(BuildContext context, ReelsPlaybackState state) {
    return Container(
      height: height.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: AppColors.black,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: Stack(
          children: [
            // Video player
            ReelGestureDetector(
              onTap: () => _onReelTap(context),
              enableSwipeGestures: false, // Disable swipe on home preview
              child: PerfectVideoPlayer(
                isCurrentVideo: true,
                onTap: () => _onReelTap(context),
              ),
            ),

            // Gradient overlay for better text visibility
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
                      AppColors.black.withOpacity(0.7),
                    ],
                    stops: const [0.0, 0.5, 0.8, 1.0],
                  ),
                ),
              ),
            ),

            // Reel info overlay
            if (state.currentReel != null)
              ReelInfoOverlay(reel: state.currentReel!),

            // Tap to view all indicator
            Positioned(
              top: 16.h,
              right: 16.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fullscreen,
                      color: AppColors.white,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Tap to view all',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Play indicator when paused
            if (state.playbackState == ReelPlaybackState.paused)
              Center(
                child: Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: AppColors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: AppColors.white,
                    size: 30.sp,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingPreview() {
    return Container(
      height: height.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: AppColors.gray.withOpacity(0.1),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildEmptyPreview() {
    return Container(
      height: height.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: AppColors.gray.withOpacity(0.1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              color: AppColors.gray,
              size: 48.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              'No reels available',
              style: TextStyle(
                color: AppColors.gray,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onReelTap(BuildContext context) {
    print('🎬 HomeReelPreview: Reel tapped - launching full-screen viewer');
    
    // Enter full-screen mode in cubit
    context.read<ReelsPlaybackCubit>().enterFullScreen();
    
    // Navigate to full-screen reels viewer
    context.push(RouteNames.reelsScreen);
  }
}