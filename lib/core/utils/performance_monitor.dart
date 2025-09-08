import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Performance monitoring utility to track app performance metrics
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final List<double> _frameTimes = [];
  static const int _maxFrameTimeSamples = 100;

  /// Initialize performance monitoring
  void init() {
    if (kDebugMode) {
      SchedulerBinding.instance.addTimingsCallback(_onFrameTimings);
    }
  }

  /// Callback for frame timing data
  void _onFrameTimings(List<FrameTiming> timings) {
    for (final timing in timings) {
      final frameTime = timing.totalSpan.inMicroseconds / 1000.0; // Convert to milliseconds
      _frameTimes.add(frameTime);
      
      // Keep only the latest samples
      if (_frameTimes.length > _maxFrameTimeSamples) {
        _frameTimes.removeAt(0);
      }
      
      // Log performance warnings
      if (frameTime > 16.67) { // 60 FPS threshold
        debugPrint('⚠️ Performance Warning: Frame took ${frameTime.toStringAsFixed(2)}ms');
      }
    }
  }

  /// Get average frame time
  double get averageFrameTime {
    if (_frameTimes.isEmpty) return 0.0;
    return _frameTimes.reduce((a, b) => a + b) / _frameTimes.length;
  }

  /// Get current FPS estimate
  double get currentFPS {
    final avgFrameTime = averageFrameTime;
    if (avgFrameTime <= 0) return 0.0;
    return 1000.0 / avgFrameTime;
  }

  /// Check if app is running smoothly (>= 55 FPS)
  bool get isRunningSmooth => currentFPS >= 55.0;

  /// Get performance summary
  Map<String, dynamic> getPerformanceSummary() {
    return {
      'averageFrameTime': averageFrameTime,
      'currentFPS': currentFPS,
      'isRunningSmooth': isRunningSmooth,
      'totalFramesSampled': _frameTimes.length,
    };
  }

  /// Clear performance data
  void clearData() {
    _frameTimes.clear();
  }

  /// Log performance summary
  void logPerformanceSummary() {
    if (kDebugMode) {
      final summary = getPerformanceSummary();
      debugPrint('📊 Performance Summary:');
      debugPrint('   Average Frame Time: ${summary['averageFrameTime'].toStringAsFixed(2)}ms');
      debugPrint('   Current FPS: ${summary['currentFPS'].toStringAsFixed(1)}');
      debugPrint('   Running Smooth: ${summary['isRunningSmooth']}');
      debugPrint('   Frames Sampled: ${summary['totalFramesSampled']}');
    }
  }
}

/// Extension to easily add performance monitoring to widgets
extension PerformanceWidget on Widget {
  Widget withPerformanceMonitoring({String? name}) {
    if (!kDebugMode) return this;
    
    return Builder(
      builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final monitor = PerformanceMonitor();
          if (name != null) {
            debugPrint('🎯 Widget rendered: $name');
          }
        });
        return this;
      },
    );
  }
}