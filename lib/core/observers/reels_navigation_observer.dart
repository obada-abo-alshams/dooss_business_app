import 'package:flutter/material.dart';
import '../../features/home/presentaion/manager/reels_playback_cubit.dart';

/// Navigation observer to detect route changes for reels playback control
/// Pauses video when navigating away from home, resumes when returning
class ReelsNavigationObserver extends NavigatorObserver {
  final ReelsPlaybackCubit reelsPlaybackCubit;
  String? _currentRoute;
  bool _isOnHomeScreen = true;

  ReelsNavigationObserver({required this.reelsPlaybackCubit});

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _handleRouteChange(route.settings.name);
    print('🚀 ReelsNavigationObserver: Pushed route: ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _handleRouteChange(previousRoute.settings.name);
      print('🔙 ReelsNavigationObserver: Popped to route: ${previousRoute.settings.name}');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _handleRouteChange(newRoute.settings.name);
      print('🔄 ReelsNavigationObserver: Replaced route: ${newRoute.settings.name}');
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (previousRoute != null) {
      _handleRouteChange(previousRoute.settings.name);
      print('🗑️ ReelsNavigationObserver: Removed route, back to: ${previousRoute.settings.name}');
    }
  }

  void _handleRouteChange(String? routeName) {
    _currentRoute = routeName;
    final isNowOnHome = _isHomeRoute(routeName);

    if (_isOnHomeScreen && !isNowOnHome) {
      // Navigating away from home - pause video
      print('🚪 ReelsNavigationObserver: Leaving home screen - pausing video');
      reelsPlaybackCubit.onNavigationAway();
      _isOnHomeScreen = false;
    } else if (!_isOnHomeScreen && isNowOnHome) {
      // Returning to home - resume muted
      print('🏠 ReelsNavigationObserver: Returning to home screen - resuming muted');
      reelsPlaybackCubit.onNavigationBack();
      _isOnHomeScreen = true;
    }
  }

  bool _isHomeRoute(String? routeName) {
    // Define what constitutes the home screen
    // Adjust these routes based on your app's routing structure
    const homeRoutes = [
      '/',
      '/home',
      null, // Sometimes the initial route has no name
    ];
    
    return homeRoutes.contains(routeName);
  }

  /// Get current route for debugging
  String? get currentRoute => _currentRoute;
  
  /// Check if currently on home screen
  bool get isOnHomeScreen => _isOnHomeScreen;
}