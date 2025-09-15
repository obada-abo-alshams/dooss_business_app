import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../manager/reels_playback_cubit.dart';

/// Gesture detector for reel interactions
/// Handles tap, double-tap, and swipe gestures
class ReelGestureDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onSwipeUp;
  final VoidCallback? onSwipeDown;
  final bool enableSwipeGestures;

  const ReelGestureDetector({
    super.key,
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onSwipeUp,
    this.onSwipeDown,
    this.enableSwipeGestures = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _handleTap(context),
      onDoubleTap: onDoubleTap ?? () => _handleDoubleTap(context),
      onPanEnd: enableSwipeGestures ? (details) => _handlePanEnd(context, details) : null,
      child: child,
    );
  }

  void _handleTap(BuildContext context) {
    print('👆 ReelGestureDetector: Single tap detected');
    // Single tap toggles play/pause
    final cubit = context.read<ReelsPlaybackCubit>();
    if (cubit.state.isPlaying) {
      cubit.pause();
    } else {
      cubit.resumeWithSound(); // Resume with sound on tap
    }
  }

  void _handleDoubleTap(BuildContext context) {
    print('👆👆 ReelGestureDetector: Double tap detected');
    // Double tap toggles mute
    final cubit = context.read<ReelsPlaybackCubit>();
    cubit.toggleMute();
  }

  void _handlePanEnd(BuildContext context, DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final cubit = context.read<ReelsPlaybackCubit>();

    // Determine swipe direction based on velocity
    if (velocity.dy > 300) {
      // Swipe down - previous reel
      print('👇 ReelGestureDetector: Swipe down detected - previous reel');
      onSwipeDown?.call();
      cubit.previousReel();
    } else if (velocity.dy < -300) {
      // Swipe up - next reel
      print('👆 ReelGestureDetector: Swipe up detected - next reel');
      onSwipeUp?.call();
      cubit.nextReel();
    }
  }
}