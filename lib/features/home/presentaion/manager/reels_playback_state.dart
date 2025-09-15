import 'package:video_player/video_player.dart';
import '../../data/models/reel_model.dart';

enum ReelPlaybackState {
  initializing,
  playing,
  paused,
  muted,
  stopped,
  error,
}

class ReelsPlaybackState {
  final List<ReelModel> reels;
  final int currentIndex;
  final ReelPlaybackState playbackState;
  final VideoPlayerController? controller;
  final bool isLoading;
  final String? error;
  final bool isMuted;
  final bool hasNextPage;
  final int currentPage;
  final bool isFullScreen;
  final bool shouldAutoPlay;
  final Duration? position;
  final Duration? duration;

  const ReelsPlaybackState({
    this.reels = const [],
    this.currentIndex = 0,
    this.playbackState = ReelPlaybackState.stopped,
    this.controller,
    this.isLoading = false,
    this.error,
    this.isMuted = true, // Default to muted for background play
    this.hasNextPage = false,
    this.currentPage = 1,
    this.isFullScreen = false,
    this.shouldAutoPlay = false,
    this.position,
    this.duration,
  });

  factory ReelsPlaybackState.initial() {
    return const ReelsPlaybackState();
  }

  ReelsPlaybackState copyWith({
    List<ReelModel>? reels,
    int? currentIndex,
    ReelPlaybackState? playbackState,
    VideoPlayerController? controller,
    bool? isLoading,
    String? error,
    bool? isMuted,
    bool? hasNextPage,
    int? currentPage,
    bool? isFullScreen,
    bool? shouldAutoPlay,
    Duration? position,
    Duration? duration,
  }) {
    return ReelsPlaybackState(
      reels: reels ?? this.reels,
      currentIndex: currentIndex ?? this.currentIndex,
      playbackState: playbackState ?? this.playbackState,
      controller: controller ?? this.controller,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isMuted: isMuted ?? this.isMuted,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      currentPage: currentPage ?? this.currentPage,
      isFullScreen: isFullScreen ?? this.isFullScreen,
      shouldAutoPlay: shouldAutoPlay ?? this.shouldAutoPlay,
      position: position ?? this.position,
      duration: duration ?? this.duration,
    );
  }

  ReelModel? get currentReel => 
      reels.isNotEmpty && currentIndex < reels.length ? reels[currentIndex] : null;

  bool get isPlaying => playbackState == ReelPlaybackState.playing;
  bool get isPaused => playbackState == ReelPlaybackState.paused;
  bool get isInitialized => controller?.value.isInitialized ?? false;
  bool get hasError => error != null;
}