import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../style/app_theme.dart';
import '../routes/app_router.dart';
import '../localization/language_cubit.dart';
import '../localization/app_localizations.dart';
import '../observers/reels_navigation_observer.dart';
import '../observers/reels_lifecycle_observer.dart';
import '../services/locator_service.dart' as di;
import '../../features/home/presentaion/manager/reels_playback_cubit.dart';

/// App wrapper with integrated reels playback management
/// Handles navigation and lifecycle observers for seamless video playback
class ReelsIntegratedApp extends StatefulWidget {
  const ReelsIntegratedApp({super.key});

  @override
  State<ReelsIntegratedApp> createState() => _ReelsIntegratedAppState();
}

class _ReelsIntegratedAppState extends State<ReelsIntegratedApp> {
  late ReelsNavigationObserver _navigationObserver;
  late ReelsLifecycleObserver _lifecycleObserver;
  late ReelsPlaybackCubit _reelsPlaybackCubit;

  @override
  void initState() {
    super.initState();
    
    // Get the singleton reels playback cubit
    _reelsPlaybackCubit = di.sl<ReelsPlaybackCubit>();
    
    // Initialize observers
    _navigationObserver = ReelsNavigationObserver(reelsPlaybackCubit: _reelsPlaybackCubit);
    _lifecycleObserver = ReelsLifecycleObserver(reelsPlaybackCubit: _reelsPlaybackCubit);
    
    // Load reels data
    _reelsPlaybackCubit.loadReels();
    
    print('🎬 ReelsIntegratedApp: Initialized with observers and cubit');
  }

  @override
  void dispose() {
    print('🗑️ ReelsIntegratedApp: Disposing observers');
    _lifecycleObserver.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => LanguageCubit()),
            BlocProvider.value(value: _reelsPlaybackCubit), // Provide singleton instance
          ],
          child: BlocBuilder<LanguageCubit, Locale>(
            buildWhen: (previous, current) => previous != current,
            builder: (context, locale) {
              return MaterialApp.router(
                title: 'Dooss Business App',
                theme: AppThemes.lightTheme,
                routerConfig: AppRouter.createRouterWithObserver(_navigationObserver),
                debugShowCheckedModeBanner: false,
                locale: locale,
                supportedLocales: const [
                  Locale('en'),
                  Locale('ar'),
                ],
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
              );
            },
          ),
        );
      },
    );
  }
}