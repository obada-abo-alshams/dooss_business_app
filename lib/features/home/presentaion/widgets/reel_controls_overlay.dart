import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../manager/reels_playback_cubit.dart';
import '../manager/reels_playback_state.dart';

/// Overlay controls for reel video player
/// Shows play/pause button, mute button, and progress indicator
class ReelControlsOverlay extends StatelessWidget {
  final bool showControls;
  final VoidCallback? onToggleControls;

  const ReelControlsOverlay({
    super.key,
    this.showControls = true,
    this.onToggleControls,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReelsPlaybackCubit, ReelsPlaybackState>(
      buildWhen: (previous, current) =>
          previous.playbackState != current.playbackState ||
          previous.isMuted != current.isMuted ||
          previous.position != current.position ||
          previous.duration != current.duration,
      builder: (context, state) {
        if (!showControls) return const SizedBox.shrink();

        return Stack(
          children: [
            // Center play/pause button
            _buildCenterPlayButton(context, state),
            
            // Bottom controls
            _buildBottomControls(context, state),
            
            // Top right mute button
            _buildMuteButton(context, state),
          ],
        );
      },
    );
  }

  Widget _buildCenterPlayButton(BuildContext context, ReelsPlaybackState state) {
    if (state.playbackState == ReelPlaybackState.playing) {
      return const SizedBox.shrink(); // Hide when playing
    }

    IconData icon;
    switch (state.playbackState) {
      case ReelPlaybackState.paused:
        icon = Icons.play_arrow;
        break;
      case ReelPlaybackState.initializing:
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.white,
            strokeWidth: 3,
          ),
        );
      case ReelPlaybackState.error:
        icon = Icons.refresh;
        break;
      default:
        icon = Icons.play_arrow;
    }

    return Center(
      child: GestureDetector(
        onTap: () {
          if (state.playbackState == ReelPlaybackState.error) {
            context.read<ReelsPlaybackCubit>().initializeCurrentVideo();
          } else {
            context.read<ReelsPlaybackCubit>().play();
          }
        },
        child: Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: AppColors.black.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.white,
            size: 40.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, ReelsPlaybackState state) {
    if (state.duration == null || state.position == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 20.h,
      left: 16.w,
      right: 16.w,
      child: Column(
        children: [
          // Progress bar
          _buildProgressBar(context, state),
          SizedBox(height: 8.h),
          
          // Time display
          _buildTimeDisplay(state),
        ],
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, ReelsPlaybackState state) {
    final progress = state.duration!.inMilliseconds > 0
        ? state.position!.inMilliseconds / state.duration!.inMilliseconds
        : 0.0;

    return GestureDetector(
      onTapDown: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        final progress = localPosition.dx / box.size.width;
        final seekPosition = Duration(
          milliseconds: (progress * state.duration!.inMilliseconds).round(),
        );
        context.read<ReelsPlaybackCubit>().seekTo(seekPosition);
      },
      child: Container(
        height: 4.h,
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(2.r),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(ReelsPlaybackState state) {
    final position = _formatDuration(state.position!);
    final duration = _formatDuration(state.duration!);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          position,
          style: AppTextStyles.whiteS12W400,
        ),
        Text(
          duration,
          style: AppTextStyles.whiteS12W400,
        ),
      ],
    );
  }

  Widget _buildMuteButton(BuildContext context, ReelsPlaybackState state) {
    return Positioned(
      top: 50.h,
      right: 16.w,
      child: GestureDetector(
        onTap: () => context.read<ReelsPlaybackCubit>().toggleMute(),
        child: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: AppColors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            state.isMuted ? Icons.volume_off : Icons.volume_up,
            color: AppColors.white,
            size: 20.sp,
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}