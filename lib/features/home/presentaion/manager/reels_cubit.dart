import 'package:flutter/material.dart';
import '../../../../core/cubits/optimized_cubit.dart';
import 'reels_state.dart';

/// Lightweight ReelsCubit for global playback state management
/// Does NOT manage individual video controllers - only global state signals
class ReelsCubit extends OptimizedCubit<ReelsState> {
  ReelsCubit() : super(ReelsState.initial());

  /// Pause all background playback (called when app loses focus or navigates away)
  void pauseBackgroundPlayback() {
    print('⏸️ ReelsCubit: Pausing background playback');
    safeEmit(state.copyWith(isBackgroundPlaybackPaused: true));
  }

  /// Resume background playback (called when app gains focus or returns to home)
  void resumeBackgroundPlayback() {
    print('▶️ ReelsCubit: Resuming background playback');
    safeEmit(state.copyWith(
      isBackgroundPlaybackPaused: false,
      shouldAutoPlay: true,
    ));
  }

  /// Set the currently focused reel (for viewport detection)
  void setFocusedReel(int reelId) {
    if (state.currentFocusedReelId != reelId) {
      print('🎯 ReelsCubit: Focused reel changed to $reelId');
      safeEmit(state.copyWith(currentFocusedReelId: reelId));
    }
  }

  /// Clear focused reel
  void clearFocusedReel() {
    print('🎯 ReelsCubit: Cleared focused reel');
    safeEmit(state.copyWith(currentFocusedReelId: null));
  }

  /// Set home screen state
  void setOnHomeScreen(bool isOnHome) {
    if (state.isOnHomeScreen != isOnHome) {
      print('🏠 ReelsCubit: Home screen state changed to $isOnHome');
      safeEmit(state.copyWith(isOnHomeScreen: isOnHome));
      
      // Auto-pause when leaving home, auto-resume when returning
      if (!isOnHome) {
        pauseBackgroundPlayback();
      } else {
        resumeBackgroundPlayback();
      }
    }
  }

  /// Enable auto-play for current viewport
  void enableAutoPlay() {
    print('🔄 ReelsCubit: Auto-play enabled');
    safeEmit(state.copyWith(shouldAutoPlay: true));
  }

  /// Disable auto-play
  void disableAutoPlay() {
    print('🔄 ReelsCubit: Auto-play disabled');
    safeEmit(state.copyWith(shouldAutoPlay: false));
  }

  /// Handle app lifecycle changes
  void onAppLifecycleChanged(AppLifecycleState lifecycleState) {
    switch (lifecycleState) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        print('📱 ReelsCubit: App paused/inactive - pausing playback');
        pauseBackgroundPlayback();
        break;
      case AppLifecycleState.resumed:
        print('📱 ReelsCubit: App resumed - resuming playback');
        if (state.isOnHomeScreen) {
          resumeBackgroundPlayback();
        }
        break;
      case AppLifecycleState.detached:
        print('📱 ReelsCubit: App detached - pausing playback');
        pauseBackgroundPlayback();
        break;
      case AppLifecycleState.hidden:
        print('📱 ReelsCubit: App hidden - pausing playback');
        pauseBackgroundPlayback();
        break;
    }
  }
}