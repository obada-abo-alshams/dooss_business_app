/// Lightweight ReelsState for global playback control
/// Does NOT manage individual video controllers - that's handled by ReelCardPlayer
class ReelsState {
  final bool isBackgroundPlaybackPaused;
  final int? currentFocusedReelId;
  final bool shouldAutoPlay;
  final bool isOnHomeScreen;

  const ReelsState({
    this.isBackgroundPlaybackPaused = false,
    this.currentFocusedReelId,
    this.shouldAutoPlay = false,
    this.isOnHomeScreen = true,
  });

  factory ReelsState.initial() {
    return const ReelsState();
  }

  ReelsState copyWith({
    bool? isBackgroundPlaybackPaused,
    int? currentFocusedReelId,
    bool? shouldAutoPlay,
    bool? isOnHomeScreen,
  }) {
    return ReelsState(
      isBackgroundPlaybackPaused: isBackgroundPlaybackPaused ?? this.isBackgroundPlaybackPaused,
      currentFocusedReelId: currentFocusedReelId ?? this.currentFocusedReelId,
      shouldAutoPlay: shouldAutoPlay ?? this.shouldAutoPlay,
      isOnHomeScreen: isOnHomeScreen ?? this.isOnHomeScreen,
    );
  }

  @override
  String toString() {
    return 'ReelsState(isBackgroundPlaybackPaused: $isBackgroundPlaybackPaused, currentFocusedReelId: $currentFocusedReelId, shouldAutoPlay: $shouldAutoPlay, isOnHomeScreen: $isOnHomeScreen)';
  }
}