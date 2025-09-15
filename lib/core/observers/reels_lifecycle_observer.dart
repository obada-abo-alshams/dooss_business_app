import 'package:flutter/material.dart';
import '../../features/home/presentaion/manager/reels_playback_cubit.dart';

/// Lifecycle observer to handle app state changes for reels playback
/// Pauses video when app goes to background, resumes when returning
class ReelsLifecycleObserver with WidgetsBindingObserver {
  final ReelsPlaybackCubit reelsPlaybackCubit;
  bool _wasPlayingBeforeBackground = false;

  ReelsLifecycleObserver({required this.reelsPlaybackCubit}) {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    print('🔄 ReelsLifecycleObserver: App lifecycle changed to: $state');
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _handleAppPaused();
        break;
      case AppLifecycleState.resumed:
        _handleAppResumed();
        break;
      case AppLifecycleState.detached:
        _handleAppDetached();
        break;
      case AppLifecycleState.hidden:
        _handleAppHidden();
        break;
    }
  }

  void _handleAppPaused() {
    print('⏸️ ReelsLifecycleObserver: App paused - saving playback state and pausing');
    _wasPlayingBeforeBackground = reelsPlaybackCubit.state.isPlaying;
    reelsPlaybackCubit.pause();
  }

  void _handleAppResumed() {
    print('▶️ ReelsLifecycleObserver: App resumed');
    
    // Only resume if video was playing before going to background
    // and we're still on a screen that should have video playing
    if (_wasPlayingBeforeBackground) {
      print('🔊 ReelsLifecycleObserver: Resuming video (muted)');
      reelsPlaybackCubit.resumeMuted();
    }
    
    _wasPlayingBeforeBackground = false;
  }

  void _handleAppDetached() {
    print('🔌 ReelsLifecycleObserver: App detached - pausing video');
    reelsPlaybackCubit.pause();
  }

  void _handleAppHidden() {
    print('👻 ReelsLifecycleObserver: App hidden - pausing video');
    _wasPlayingBeforeBackground = reelsPlaybackCubit.state.isPlaying;
    reelsPlaybackCubit.pause();
  }

  /// Dispose the observer
  void dispose() {
    print('🗑️ ReelsLifecycleObserver: Disposing lifecycle observer');
    WidgetsBinding.instance.removeObserver(this);
  }
}