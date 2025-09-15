import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class NativeVideoService {
  static VideoPlayerController? _controller;
  
  static Future<void> loadVideo(String url) async {
    try {
      _controller?.dispose();
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await _controller!.initialize();
      print('🎬 NativeVideoService: Video loaded: $url');
    } catch (e) {
      print('❌ NativeVideoService: Error loading video: $e');
    }
  }
  
  static Future<void> play() async {
    try {
      await _controller?.play();
      print('▶️ NativeVideoService: Video playing');
    } catch (e) {
      print('❌ NativeVideoService: Error playing video: $e');
    }
  }
  
  static Future<void> pause() async {
    try {
      await _controller?.pause();
      print('⏸️ NativeVideoService: Video paused');
    } catch (e) {
      print('❌ NativeVideoService: Error pausing video: $e');
    }
  }
  
  static Future<void> stop() async {
    try {
      await _controller?.pause();
      await _controller?.seekTo(Duration.zero);
      print('⏹️ NativeVideoService: Video stopped');
    } catch (e) {
      print('❌ NativeVideoService: Error stopping video: $e');
    }
  }
  
  static Future<void> dispose() async {
    try {
      await _controller?.dispose();
      _controller = null;
      print('🗑️ NativeVideoService: Video disposed');
    } catch (e) {
      print('❌ NativeVideoService: Error disposing video: $e');
    }
  }
  
  static bool isPlaying() {
    return _controller?.value.isPlaying ?? false;
  }
  
  static bool isInitialized() {
    return _controller?.value.isInitialized ?? false;
  }
}

class NativeVideoWidget extends StatefulWidget {
  final String videoUrl;
  final double width;
  final double height;
  final bool muted;
  final bool loop;
  final VoidCallback? onVideoReady;
  final VoidCallback? onVideoEnded;
  final VoidCallback? onVideoError;
  
  const NativeVideoWidget({
    super.key,
    required this.videoUrl,
    required this.width,
    required this.height,
    this.muted = false,
    this.loop = true,
    this.onVideoReady,
    this.onVideoEnded,
    this.onVideoError,
  });

  @override
  State<NativeVideoWidget> createState() => _NativeVideoWidgetState();
}

class _NativeVideoWidgetState extends State<NativeVideoWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isDisposed = false;
  
  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }
  
  @override
  void didUpdateWidget(NativeVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl && !_isDisposed) {
      print('🔄 NativeVideoWidget: Video URL changed from ${oldWidget.videoUrl} to ${widget.videoUrl}');
      _disposeController();
      _initializeVideo();
    }
  }
  
  
  Future<void> _muteVideo() async {
    if (_controller != null && _controller!.value.isInitialized && widget.muted) {
      await _controller!.setVolume(0.0);
      print('🔇 NativeVideoWidget: Video muted');
    }
  }
  
  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      
      _controller!.addListener(() {
        if (_isDisposed) return;
        
        if (_controller!.value.isInitialized && !_isInitialized) {
          if (mounted && !_isDisposed) {
            setState(() {
              _isInitialized = true;
            });
            _muteVideo(); // إيقاف الصوت عند التهيئة
            widget.onVideoReady?.call();
          }
        }
        
        // التحقق من انتهاء الفيديو وإعادة التشغيل
        if (_controller!.value.position >= _controller!.value.duration) {
          widget.onVideoEnded?.call();
          
          // إعادة تشغيل الفيديو إذا كان loop = true
          if (widget.loop && !_isDisposed) {
            _controller!.seekTo(Duration.zero);
            _controller!.play();
            print('🔄 NativeVideoWidget: Video looped');
          }
        }
      });
      
      await _controller!.initialize();
      if (widget.muted) {
        await _controller!.setVolume(0.0); // إيقاف الصوت فقط إذا كان muted = true
      }
      await _controller!.play();
      
      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
        });
      }
      
    } catch (e) {
      print('❌ NativeVideoWidget: Error initializing video: $e');
      widget.onVideoError?.call();
    }
  }
  
  void _disposeController() {
    _controller?.dispose();
    _controller = null;
    if (mounted && !_isDisposed) {
      setState(() {
        _isInitialized = false;
      });
    }
  }
  
  @override
  void dispose() {
    _isDisposed = true;
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }
    
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: VideoPlayer(_controller!),
    );
  }
}
