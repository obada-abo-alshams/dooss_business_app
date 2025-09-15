import 'package:flutter/material.dart';
import '../../features/home/presentaion/manager/reels_cubit.dart';

/// Comprehensive lifecycle manager for reels playback
/// Combines WidgetsBindingObserver and RouteObserver functionality
class ReelsLifecycleManager extends NavigatorObserver with WidgetsBindingObserver {
  final ReelsCubit reelsCubit;
  String? _currentRoute;

  ReelsLifecycleManager({required this.reelsCubit}) {
    // Register as app lifecycle observer
    WidgetsBinding.instance.addObserver(this);
  }

  // =================================================================
  // APP LIFECYCLE OBSERVER (WidgetsBindingObserver)
  // =================================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    print('📱 ReelsLifecycleManager: App lifecycle changed to: $state');
    reelsCubit.onAppLifecycleChanged(state);
  }

  // =================================================================
  // ROUTE OBSERVER (NavigatorObserver)
  // =================================================================

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _handleRouteChange(route.settings.name, 'PUSH');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _handleRouteChange(previousRoute.settings.name, 'POP');
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _handleRouteChange(newRoute.settings.name, 'REPLACE');
    }
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    if (previousRoute != null) {
      _handleRouteChange(previousRoute.settings.name, 'REMOVE');
    }
  }

  void _handleRouteChange(String? routeName, String action) {
    final previousRoute = _currentRoute;
    _currentRoute = routeName;
    
    print('🛣️ ReelsLifecycleManager: Route $action - From: $previousRoute To: $routeName');
    
    final isOnHomeScreen = _isHomeRoute(routeName);
    reelsCubit.setOnHomeScreen(isOnHomeScreen);
  }

  bool _isHomeRoute(String? routeName) {
    // Define what constitutes the home screen
    const homeRoutes = [
      '/',
      '/home',
      '/homeScreen',
      null, // Initial route might be null
    ];
    
    return homeRoutes.contains(routeName);
  }

  // =================================================================
  // CLEANUP
  // =================================================================

  void dispose() {
    print('🗑️ ReelsLifecycleManager: Disposing lifecycle observer');
    WidgetsBinding.instance.removeObserver(this);
  }

  // =================================================================
  // GETTERS FOR DEBUGGING
  // =================================================================

  String? get currentRoute => _currentRoute;
  bool get isOnHomeScreen => _isHomeRoute(_currentRoute);
}