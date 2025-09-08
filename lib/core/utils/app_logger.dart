import 'package:flutter/foundation.dart';

/// High-performance logging utility following clean code standards
class AppLogger {
  AppLogger._();

  /// Log debug information (only in debug mode)
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      final formattedMessage = tag != null ? '[$tag] $message' : message;
      debugPrint('🐛 DEBUG: $formattedMessage');
    }
  }

  /// Log information
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      final formattedMessage = tag != null ? '[$tag] $message' : message;
      debugPrint('ℹ️ INFO: $formattedMessage');
    }
  }

  /// Log warnings
  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      final formattedMessage = tag != null ? '[$tag] $message' : message;
      debugPrint('⚠️ WARNING: $formattedMessage');
    }
  }

  /// Log errors
  static void error(String message, [String? tag, Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      final formattedMessage = tag != null ? '[$tag] $message' : message;
      debugPrint('❌ ERROR: $formattedMessage');
      if (error != null) {
        debugPrint('Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  /// Log success messages
  static void success(String message, [String? tag]) {
    if (kDebugMode) {
      final formattedMessage = tag != null ? '[$tag] $message' : message;
      debugPrint('✅ SUCCESS: $formattedMessage');
    }
  }

  /// Log network requests
  static void network(String method, String url, [int? statusCode]) {
    if (kDebugMode) {
      final status = statusCode != null ? ' - $statusCode' : '';
      debugPrint('🌐 NETWORK: $method $url$status');
    }
  }

  /// Log navigation events
  static void navigation(String route, [String? from]) {
    if (kDebugMode) {
      final fromText = from != null ? ' from $from' : '';
      debugPrint('🧭 NAVIGATION: $route$fromText');
    }
  }

  /// Log performance metrics
  static void performance(String metric, double value, [String? unit]) {
    if (kDebugMode) {
      final unitText = unit != null ? ' $unit' : '';
      debugPrint('📊 PERFORMANCE: $metric: $value$unitText');
    }
  }
}