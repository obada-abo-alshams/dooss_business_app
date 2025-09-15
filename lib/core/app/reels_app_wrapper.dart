import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../style/app_theme.dart';
import 'package:go_router/go_router.dart';
import '../routes/app_router.dart';
import '../routes/route_names.dart';
import '../localization/language_cubit.dart';
import '../localization/app_localizations.dart';
import '../observers/reels_lifecycle_manager.dart';
import '../services/locator_service.dart' as di;
import '../../features/home/presentaion/manager/reels_cubit.dart';

/// App wrapper with integrated reels lifecycle management
/// Keeps the horizontal card UI but manages playback lifecycle properly
class ReelsAppWrapper extends StatefulWidget {
  const ReelsAppWrapper({super.key});

  @override
  State<ReelsAppWrapper> createState() => _ReelsAppWrapperState();
}

class _ReelsAppWrapperState extends State<ReelsAppWrapper> {
  late ReelsLifecycleManager _lifecycleManager;
  late ReelsCubit _reelsCubit;

  @override
  void initState() {
    super.initState();
    
    // Get the singleton reels cubit
    _reelsCubit = di.sl<ReelsCubit>();
    
    // Initialize lifecycle manager
    _lifecycleManager = ReelsLifecycleManager(reelsCubit: _reelsCubit);
    
    print('🎬 ReelsAppWrapper: Initialized with lifecycle manager');
  }

  @override
  void dispose() {
    print('🗑️ ReelsAppWrapper: Disposing lifecycle manager');
    _lifecycleManager.dispose();
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
            BlocProvider.value(value: _reelsCubit), // Provide singleton instance
          ],
          child: BlocBuilder<LanguageCubit, Locale>(
            buildWhen: (previous, current) => previous != current,
            builder: (context, locale) {
              return MaterialApp.router(
                title: 'Dooss Business App',
                theme: AppThemes.lightTheme,
                routerConfig: _createRouterWithObserver(),
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

  GoRouter _createRouterWithObserver() {
    return GoRouter(
      initialLocation: RouteNames.onBoardingScreen,
      observers: [_lifecycleManager], // Add lifecycle manager as observer
      routes: AppRouter._routes,
    );
  }
}