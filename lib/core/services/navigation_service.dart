import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/app_logger.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  /// Navigate to login screen
  static void navigateToLogin(BuildContext context) {
    AppLogger.navigation('/login', 'current_screen');
    if (context.mounted) {
      context.go('/login');
    }
  }
  
  /// Navigate to home screen
  static void navigateToHome(BuildContext context) {
    AppLogger.navigation('/home', 'current_screen');
    if (context.mounted) {
      context.go('/home');
    }
  }
  
  /// Navigate to login from anywhere in the app
  static void navigateToLoginFromAnywhere() {
    AppLogger.navigation('/login', 'global_navigation');
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.go('/login');
    } else {
      AppLogger.warning('No context available for navigation', 'NavigationService');
    }
  }
  
  /// Clear stack and navigate to login
  static void clearStackAndNavigateToLogin(BuildContext context) {
    AppLogger.navigation('/login', 'clear_stack');
    if (context.mounted) {
      context.go('/login');
    }
  }
}
