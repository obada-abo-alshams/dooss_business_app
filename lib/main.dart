import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'core/services/locator_service.dart' as di;
import 'core/app/reels_app_wrapper.dart';
import 'core/utils/performance_monitor.dart';

Future<void> main() async {
  print('🚀 MAIN: Starting app initialization...');
  
  // 1. Ensure binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  print('✅ MAIN: Flutter binding initialized');

  // 2. 🔥 THE KEY FIX: Reset GetIt to clear any stale state
  print('🔥 MAIN: Resetting GetIt to clear stale state...');
  await GetIt.instance.reset();
  print('✅ MAIN: GetIt reset complete');

  // 3. Re-initialize all dependencies
  print('🔧 MAIN: Initializing dependencies...');
  await di.init();
  print('✅ MAIN: Dependencies initialized');

  // 4. Initialize performance monitoring
  PerformanceMonitor().init();
  print('✅ MAIN: Performance monitoring initialized');

  // 5. Set up error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    print('❌ FLUTTER ERROR: ${details.exception}');
    FlutterError.presentError(details);
  };
  print('✅ MAIN: Error handling configured');

  // 6. Run the app
  print('🎬 MAIN: Launching ReelsAppWrapper...');
  runApp(const ReelsAppWrapper());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return BlocProvider(
          create: (_) => LanguageCubit(),
          child: BlocBuilder<LanguageCubit, Locale>(
            buildWhen: (previous, current) => previous != current,
            builder: (context, locale) {
              return MaterialApp.router(
                title: 'Dooss Business App',
                theme: AppThemes.lightTheme,
                routerConfig: AppRouter.router,
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
