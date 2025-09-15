import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../data/models/reel_model.dart';

/// Proper StatefulWidget ReelPlayer for full-screen Instagram-style experience
/// Handles video initialization, playback, pause, dispose, and lifecycle
class FullScreenReelPlayer extends StatefulWidget {
  final ReelModel reel;
  final bool isCurrentReel;
  final VoidCallback? onTap;

  const FullScreenReelPlayer({
    super.key,
    required this.reel,
    required this.isCurrentReel,
    this.onTap,
  });

  @override
  State<FullScreenReelPlayer> createState() => _FullScreenReelPlayerState();
}

class _FullScreenReelPlayerState extends State<FullScreenReelPlayer> with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isPlaying = false;
  bool _hasError = false;
  bool _isMuted = false;
  String? _errorMessage;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    if (widget.isCurrentReel && widget.reel.videoUrl.isNotEmpty) {
      _initializeVideo();
    }
  }

  @override
  void didUpdateWidget(FullScreenReelPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If this reel becomes current, initialize video
    if (!oldWidget.isCurrentReel && widget.isCurrentReel && _controller == null) {
      _initializeVideo();
    }
    
    // If this reel is no longer current, dispose video
    if (oldWidget.isCurrentReel && !widget.isCurrentReel) {
      _disposeController();
    }
    
    // Handle play/pause based on current reel status
    if (widget.isCurrentReel && _isInitialized) {
      if (!_isPlaying) {
        _playVideo();
      }
    } else {
      if (_isPlaying) {
        _pauseVideo();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        _pauseVideo();
        break;
      case AppLifecycleState.resumed:
        if (widget.isCurrentReel && _isInitialized) {
          _playVideo();
        }
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _pauseVideo();
        break;
    }
  }

  Future<void> _initializeVideo() async {
    if (widget.reel.videoUrl.isEmpty) return;

    try {
      print('🎬 FullScreenReelPlayer: Initializing video for reel ${widget.reel.id}');
      
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.reel.videoUrl));
      _controller!.addListener(_onVideoEvent);
      
      await _controller!.initialize();
      await _controller!.setVolume(_isMuted ? 0.0 : 1.0);
      await _controller!.setLooping(true);
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
          _errorMessage = null;
        });
        
        // Auto-play if this is the current reel
        if (widget.isCurrentReel) {
          _playVideo();
        }
      }
      
      print('✅ FullScreenReelPlayer: Video initialized for reel ${widget.reel.id}');
    } catch (e) {
      print('❌ FullScreenReelPlayer: Error initializing video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
          _isInitialized = false;
        });
      }
    }
  }

  void _onVideoEvent() {
    if (_controller == null || !mounted) return;

    final value = _controller!.value;
    
    // Handle errors
    if (value.hasError) {
      print('❌ FullScreenReelPlayer: Video error: ${value.errorDescription}');
      setState(() {
        _hasError = true;
        _errorMessage = value.errorDescription;
        _isPlaying = false;
      });
    }
  }

  void _playVideo() {
    if (_controller?.value.isInitialized == true && !_isPlaying) {
      print('▶️ FullScreenReelPlayer: Playing video ${widget.reel.id}');
      _controller!.play();
      setState(() => _isPlaying = true);
    }
  }

  void _pauseVideo() {
    if (_controller?.value.isInitialized == true && _isPlaying) {
      print('⏸️ FullScreenReelPlayer: Pausing video ${widget.reel.id}');
      _controller!.pause();
      setState(() => _isPlaying = false);
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _pauseVideo();
    } else {
      _playVideo();
    }
  }

  void _toggleMute() {
    if (_controller?.value.isInitialized == true) {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);
      setState(() {});
      print('${_isMuted ? '🔇' : '🔊'} FullScreenReelPlayer: ${_isMuted ? 'Muted' : 'Unmuted'} reel ${widget.reel.id}');
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    // Auto-hide controls after 3 seconds
    if (_showControls) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  void _disposeController() {
    if (_controller != null) {
      print('🗑️ FullScreenReelPlayer: Disposing controller for reel ${widget.reel.id}');
      _controller!.removeListener(_onVideoEvent);
      _controller!.dispose();
      _controller = null;
      _isInitialized = false;
      _isPlaying = false;
    }
  }

  @override
  void dispose() {
    print('🗑️ FullScreenReelPlayer: Disposing widget for reel ${widget.reel.id}');
    WidgetsBinding.instance.removeObserver(this);
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _toggleControls();
        widget.onTap?.call();
      },
      onDoubleTap: _toggleMute,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.black,
        child: Stack(
          children: [
            // Video player or error/loading state
            _buildVideoContent(),
            
            // Reel info overlay
            _buildReelInfoOverlay(),
            
            // Controls overlay (show/hide on tap)
            if (_showControls) _buildControlsOverlay(),
            
            // Actions overlay (right side)
            _buildActionsOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (_hasError) {
      return _buildErrorState();
    }

    if (!_isInitialized || _controller == null) {
      return _buildLoadingState();
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.white,
            strokeWidth: 3,
          ),
          SizedBox(height: 16.h),
          Text(
            'Loading reel...',
            style: AppTextStyles.whiteS16W400,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.white,
            size: 64.sp,
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to load reel',
            style: AppTextStyles.whiteS18W600,
          ),
          if (_errorMessage != null) ...[
            SizedBox(height: 8.h),
            Text(
              _errorMessage!,
              style: AppTextStyles.whiteS14W400,
              textAlign: TextAlign.center,
            ),
          ],
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasError = false;
                _errorMessage = null;
              });
              _initializeVideo();
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildReelInfoOverlay() {
    return Positioned(
      left: 16.w,
      right: 80.w, // Leave space for actions
      bottom: 100.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dealer info
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: AppColors.primary,
                child: Text(
                  (widget.reel.dealerUsername?.isNotEmpty == true)
                      ? widget.reel.dealerUsername![0].toUpperCase()
                      : 'U',
                  style: AppTextStyles.whiteS14W600,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                widget.reel.dealerUsername ?? 'Unknown User',
                style: AppTextStyles.whiteS14W600,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Reel title and description
          Text(
            widget.reel.title,
            style: AppTextStyles.whiteS16W600,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.reel.description?.isNotEmpty == true) ...[
            SizedBox(height: 8.h),
            Text(
              widget.reel.description!,
              style: AppTextStyles.whiteS14W400,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionsOverlay() {
    return Positioned(
      right: 16.w,
      bottom: 100.h,
      child: Column(
        children: [
          _buildActionButton(
            icon: widget.reel.isLiked ? Icons.favorite : Icons.favorite_border,
            label: _formatCount(widget.reel.likesCount),
            onTap: () => print('Like reel ${widget.reel.id}'),
            iconColor: widget.reel.isLiked ? Colors.red : AppColors.white,
          ),
          SizedBox(height: 24.h),
          _buildActionButton(
            icon: Icons.comment,
            label: _formatCount(widget.reel.commentsCount ?? 0),
            onTap: () => print('Comment on reel ${widget.reel.id}'),
          ),
          SizedBox(height: 24.h),
          _buildActionButton(
            icon: Icons.share,
            label: 'Share',
            onTap: () => print('Share reel ${widget.reel.id}'),
          ),
          SizedBox(height: 24.h),
          _buildActionButton(
            icon: _isMuted ? Icons.volume_off : Icons.volume_up,
            label: _isMuted ? 'Unmute' : 'Mute',
            onTap: _toggleMute,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: AppTextStyles.whiteS12W400,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    if (!_isInitialized) return const SizedBox.shrink();

    return Center(
      child: GestureDetector(
        onTap: _togglePlayPause,
        child: Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: AppColors.black.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            color: AppColors.white,
            size: 40.sp,
          ),
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }
}