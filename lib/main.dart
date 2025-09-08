import 'package:dooss_business_app/core/style/app_theme.dart';      
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/services/locator_service.dart' as di;
import 'core/routes/app_router.dart';
import 'features/home/presentaion/manager/car_cubit.dart';
import 'core/localization/language_cubit.dart';
import 'core/localization/app_localizations.dart';
import 'core/services/navigation_service.dart';
import 'core/utils/performance_monitor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize dependency injection
  await di.init();
  
  // Initialize performance monitoring
  PerformanceMonitor().init();
  
  // Set up error handling
  FlutterError.onError = (FlutterErrorDetails details) {
    // In production, you might want to send this to a crash reporting service
    FlutterError.presentError(details);
  };
  
  runApp(const MyApp());
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
          create: (_) => di.sl<CarCubit>(),
          child: BlocProvider(
            create: (_) => LanguageCubit(),
            child: BlocBuilder<LanguageCubit, Locale>(
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
          ),
        );
      },
    );
  }
}
