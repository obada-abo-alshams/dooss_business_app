import 'dart:async';
import 'package:video_player/video_player.dart';
import '../../../../core/cubits/optimized_cubit.dart';
import '../../data/data_source/reel_remote_data_source.dart';
import '../../data/models/reel_model.dart';
import 'reels_playback_state.dart';

/// Master Cubit for all reels playback functionality
/// Handles play/pause/resume/mute/navigation lifecycle
class ReelsPlaybackCubit extends OptimizedCubit<ReelsPlaybackState> {
  final ReelRemoteDataSource dataSource;
  VideoPlayerController? _currentController;
  Timer? _progressTimer;
  bool _isDisposed = false;

  ReelsPlaybackCubit({required this.dataSource}) : super(ReelsPlaybackState.initial());

  /// Load reels data
  Future<void> loadReels({int page = 1, int pageSize = 20}) async {
    if (_isDisposed) return;
    
    safeEmit(state.copyWith(isLoading: true, error: null));
    
    final result = await dataSource.fetchReels(
      page: page,
      pageSize: pageSize,
      ordering: '-created_at',
    );

    result.fold(
      (failure) {
        print('❌ ReelsPlaybackCubit: Error loading reels: ${failure.message}');
        if (!_isDisposed) {
          safeEmit(state.copyWith(
            error: failure.message,
            isLoading: false,
          ));
        }
      },
      (reelsResponse) {
        print('✅ ReelsPlaybackCubit: Successfully loaded ${reelsResponse.results.length} reels');
        
        final updatedReels = page == 1 
            ? reelsResponse.results 
            : [...state.reels, ...reelsResponse.results];
        
        if (!_isDisposed) {
          safeEmit(state.copyWith(
            reels: updatedReels,
            isLoading: false,
            hasNextPage: reelsResponse.next != null,
            currentPage: page,
            error: null,
          ));
        }
      },
    );
  }

  /// Initialize video controller for current reel
  Future<void> initializeCurrentVideo() async {
    if (_isDisposed || state.currentReel == null) return;
    
    final reel = state.currentReel!;
    if (reel.videoUrl.isEmpty) {
      print('❌ ReelsPlaybackCubit: No video URL for reel ${reel.id}');
      return;
    }

    print('🎬 ReelsPlaybackCubit: Initializing video for reel ${reel.id}');
    
    // Dispose previous controller
    await _disposeCurrentController();
    
    try {
      safeEmit(state.copyWith(playbackState: ReelPlaybackState.initializing));
      
      _currentController = VideoPlayerController.networkUrl(Uri.parse(reel.videoUrl));
      
      // Add listener for video events
      _currentController!.addListener(_onVideoPlayerEvent);
      
      await _currentController!.initialize();
      
      // Set initial volume based on mute state
      await _currentController!.setVolume(state.isMuted ? 0.0 : 1.0);
      
      if (!_isDisposed) {
        safeEmit(state.copyWith(
          controller: _currentController,
          playbackState: ReelPlaybackState.paused,
          duration: _currentController!.value.duration,
          error: null,
        ));
        
        // Auto-play if should auto play
        if (state.shouldAutoPlay) {
          await play();
        }
      }
      
      print('✅ ReelsPlaybackCubit: Video initialized successfully');
    } catch (e) {
      print('❌ ReelsPlaybackCubit: Error initializing video: $e');
      if (!_isDisposed) {
        safeEmit(state.copyWith(
          error: 'Failed to load video: $e',
          playbackState: ReelPlaybackState.error,
        ));
      }
    }
  }

  /// Play current video
  Future<void> play() async {
    if (_isDisposed || _currentController == null || !_currentController!.value.isInitialized) {
      return;
    }

    try {
      await _currentController!.play();
      _startProgressTimer();
      
      if (!_isDisposed) {
        safeEmit(state.copyWith(playbackState: ReelPlaybackState.playing));
      }
      
      print('▶️ ReelsPlaybackCubit: Video playing');
    } catch (e) {
      print('❌ ReelsPlaybackCubit: Error playing video: $e');
    }
  }

  /// Pause current video
  Future<void> pause() async {
    if (_isDisposed || _currentController == null) return;

    try {
      await _currentController!.pause();
      _stopProgressTimer();
      
      if (!_isDisposed) {
        safeEmit(state.copyWith(
          playbackState: ReelPlaybackState.paused,
          position: _currentController!.value.position,
        ));
      }
      
      print('⏸️ ReelsPlaybackCubit: Video paused');
    } catch (e) {
      print('❌ ReelsPlaybackCubit: Error pausing video: $e');
    }
  }

  /// Resume video (muted by default for background play)
  Future<void> resumeMuted() async {
    if (_isDisposed) return;
    
    await setMuted(true);
    await play();
    print('🔇 ReelsPlaybackCubit: Video resumed muted');
  }

  /// Resume with sound (for full-screen experience)
  Future<void> resumeWithSound() async {
    if (_isDisposed) return;
    
    await setMuted(false);
    await play();
    print('🔊 ReelsPlaybackCubit: Video resumed with sound');
  }

  /// Set mute state
  Future<void> setMuted(bool muted) async {
    if (_isDisposed || _currentController == null) return;

    try {
      await _currentController!.setVolume(muted ? 0.0 : 1.0);
      
      if (!_isDisposed) {
        safeEmit(state.copyWith(isMuted: muted));
      }
      
      print('${muted ? '🔇' : '🔊'} ReelsPlaybackCubit: Volume ${muted ? 'muted' : 'unmuted'}');
    } catch (e) {
      print('❌ ReelsPlaybackCubit: Error setting volume: $e');
    }
  }

  /// Toggle mute state
  Future<void> toggleMute() async {
    await setMuted(!state.isMuted);
  }

  /// Change to specific reel index
  Future<void> changeToIndex(int index) async {
    if (_isDisposed || index < 0 || index >= state.reels.length) return;
    
    print('🔄 ReelsPlaybackCubit: Changing to reel index $index');
    
    safeEmit(state.copyWith(currentIndex: index));
    await initializeCurrentVideo();
  }

  /// Move to next reel
  Future<void> nextReel() async {
    if (_isDisposed) return;
    
    final nextIndex = state.currentIndex + 1;
    if (nextIndex < state.reels.length) {
      await changeToIndex(nextIndex);
    } else if (state.hasNextPage) {
      // Load more reels
      await loadReels(page: state.currentPage + 1);
    }
  }

  /// Move to previous reel
  Future<void> previousReel() async {
    if (_isDisposed) return;
    
    final prevIndex = state.currentIndex - 1;
    if (prevIndex >= 0) {
      await changeToIndex(prevIndex);
    }
  }

  /// Enter full-screen mode
  void enterFullScreen() {
    if (_isDisposed) return;
    
    safeEmit(state.copyWith(
      isFullScreen: true,
      shouldAutoPlay: true,
    ));
    print('📱 ReelsPlaybackCubit: Entered full-screen mode');
  }

  /// Exit full-screen mode
  void exitFullScreen() {
    if (_isDisposed) return;
    
    safeEmit(state.copyWith(
      isFullScreen: false,
      shouldAutoPlay: false,
    ));
    print('📱 ReelsPlaybackCubit: Exited full-screen mode');
  }

  /// Handle navigation away (pause video)
  Future<void> onNavigationAway() async {
    print('🚪 ReelsPlaybackCubit: Navigation away detected - pausing video');
    await pause();
  }

  /// Handle navigation back (resume muted)
  Future<void> onNavigationBack() async {
    print('🏠 ReelsPlaybackCubit: Navigation back detected - resuming muted');
    await resumeMuted();
  }

  /// Seek to specific position
  Future<void> seekTo(Duration position) async {
    if (_isDisposed || _currentController == null) return;

    try {
      await _currentController!.seekTo(position);
      print('⏭️ ReelsPlaybackCubit: Seeked to ${position.inSeconds}s');
    } catch (e) {
      print('❌ ReelsPlaybackCubit: Error seeking: $e');
    }
  }

  /// Video player event listener
  void _onVideoPlayerEvent() {
    if (_isDisposed || _currentController == null) return;

    final value = _currentController!.value;
    
    // Update position
    if (!_isDisposed) {
      safeEmit(state.copyWith(position: value.position));
    }

    // Handle video completion
    if (value.position >= value.duration && value.duration.inMilliseconds > 0) {
      print('🔄 ReelsPlaybackCubit: Video completed, moving to next');
      nextReel();
    }

    // Handle errors
    if (value.hasError) {
      print('❌ ReelsPlaybackCubit: Video player error: ${value.errorDescription}');
      if (!_isDisposed) {
        safeEmit(state.copyWith(
          error: value.errorDescription ?? 'Video playback error',
          playbackState: ReelPlaybackState.error,
        ));
      }
    }
  }

  /// Start progress timer
  void _startProgressTimer() {
    _stopProgressTimer();
    _progressTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!_isDisposed && _currentController != null) {
        safeEmit(state.copyWith(position: _currentController!.value.position));
      }
    });
  }

  /// Stop progress timer
  void _stopProgressTimer() {
    _progressTimer?.cancel();
    _progressTimer = null;
  }

  /// Dispose current video controller
  Future<void> _disposeCurrentController() async {
    if (_currentController != null) {
      _currentController!.removeListener(_onVideoPlayerEvent);
      await _currentController!.dispose();
      _currentController = null;
      print('🗑️ ReelsPlaybackCubit: Controller disposed');
    }
  }

  @override
  Future<void> close() async {
    print('🔒 ReelsPlaybackCubit: Closing and cleaning up resources');
    _isDisposed = true;
    _stopProgressTimer();
    await _disposeCurrentController();
    super.close();
  }
}