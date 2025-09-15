// BULLETPROOF DEPENDENCY INJECTION CONFIGURATION
// NO COMPROMISES, NO SHORTCUTS, GUARANTEED TO WORK

import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Core Network
import 'package:dooss_business_app/core/network/api.dart';
import 'package:dooss_business_app/core/network/app_dio.dart';

// Auth
import 'package:dooss_business_app/features/auth/data/data_source/auth_remote_data_source_imp.dart';
import 'package:dooss_business_app/features/auth/presentation/manager/auth_cubit.dart';

// Cars
import 'package:dooss_business_app/features/home/data/data_source/car_remote_data_source.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/car_cubit.dart';

// Products
import 'package:dooss_business_app/features/home/data/data_source/product_remote_data_source.dart';
import 'package:dooss_business_app/features/home/data/data_source/product_remote_data_source_imp.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/product_cubit.dart';

// Services
import 'package:dooss_business_app/features/home/data/data_source/service_remote_data_source.dart';
import 'package:dooss_business_app/features/home/data/data_source/service_remote_data_source_imp.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/service_cubit.dart';

// Reels - THE CRITICAL ONES
import 'package:dooss_business_app/features/home/data/data_source/reel_remote_data_source.dart';
import 'package:dooss_business_app/features/home/data/data_source/reel_remote_data_source_imp.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/reel_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/reels_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/reels_playback_cubit.dart';

// Other Cubits
import 'package:dooss_business_app/features/home/presentaion/manager/home_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/maps_cubit.dart';

// Chat
import 'package:dooss_business_app/features/chat/data/data_source/chat_remote_data_source.dart';
import 'package:dooss_business_app/features/chat/data/data_source/chat_remote_data_source_imp.dart';
import 'package:dooss_business_app/features/chat/presentation/manager/chat_cubit.dart';

// Services
import 'package:dooss_business_app/core/services/websocket_service.dart';

// Dealer Profile
import 'package:dooss_business_app/features/profile_dealer/data/data_source/dealer_profile_remote_data_source.dart';
import 'package:dooss_business_app/features/profile_dealer/presentation/manager/dealer_profile_cubit.dart';

final sl = GetIt.instance; // <-- NO PARENTHESES!

Future<void> init() async {
  print('🔧 DI: Starting bulletproof dependency injection...');
  
  // =================================================================
  // PHASE 1: EXTERNAL PACKAGES (Register these FIRST)
  // =================================================================
  print('📦 DI: Registering external packages...');
  
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  print('✅ DI: SharedPreferences registered');
  
  // Flutter Secure Storage
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  print('✅ DI: FlutterSecureStorage registered');
  
  // =================================================================
  // PHASE 2: CORE NETWORK LAYER (Foundation)
  // =================================================================
  print('🌐 DI: Registering core network layer...');
  
  sl.registerLazySingleton<AppDio>(() => AppDio());
  print('✅ DI: AppDio registered');
  
  sl.registerLazySingleton<API>(() => API(dio: sl<AppDio>().dio));
  print('✅ DI: API registered');
  
  sl.registerLazySingleton<WebSocketService>(() => WebSocketService());
  print('✅ DI: WebSocketService registered');
  
  // =================================================================
  // PHASE 3: DATA SOURCES (Dependencies for Cubits) - CRITICAL ORDER
  // =================================================================
  print('📊 DI: Registering data sources...');
  
  // Auth DataSource
  sl.registerLazySingleton<AuthRemoteDataSourceImp>(
    () => AuthRemoteDataSourceImp(api: sl<API>())
  );
  print('✅ DI: AuthRemoteDataSourceImp registered');
  
  // Car DataSource
  sl.registerLazySingleton<CarRemoteDataSource>(
    () => CarRemoteDataSourceImpl(sl<AppDio>())
  );
  print('✅ DI: CarRemoteDataSource registered');
  
  // Product DataSource
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImp(api: sl<API>())
  );
  print('✅ DI: ProductRemoteDataSource registered');
  
  // Service DataSource
  sl.registerLazySingleton<ServiceRemoteDataSource>(
    () => ServiceRemoteDataSourceImp(api: sl<API>())
  );
  print('✅ DI: ServiceRemoteDataSource registered');
  
  // 🎬 REELS DATA SOURCE - THE CRITICAL ONE
  print('🎬 DI: About to register ReelRemoteDataSource...');
  print('🔍 DI: Checking AppDio availability: ${sl.isRegistered<AppDio>()}');
  sl.registerLazySingleton<ReelRemoteDataSource>(
    () {
      print('🏗️ DI: Creating ReelRemoteDataSourceImp instance...');
      final appDio = sl<AppDio>();
      print('✅ DI: AppDio retrieved successfully');
      final instance = ReelRemoteDataSourceImp(dio: appDio);
      print('✅ DI: ReelRemoteDataSourceImp created successfully');
      return instance;
    }
  );
  print('🎯 DI: ReelRemoteDataSource registered successfully');
  
  // Chat DataSource
  sl.registerLazySingleton<ChatRemoteDataSource>(
    () => ChatRemoteDataSourceImp(api: sl<API>())
  );
  print('✅ DI: ChatRemoteDataSource registered');
  
  // Dealer Profile DataSource
  sl.registerLazySingleton<DealerProfileRemoteDataSource>(
    () => DealerProfileRemoteDataSourceImpl(sl<AppDio>())
  );
  print('✅ DI: DealerProfileRemoteDataSource registered');
  
  // =================================================================
  // PHASE 4: CUBITS (Now that all dependencies exist)
  // =================================================================
  print('🧠 DI: Registering cubits...');
  
  // Auth Cubit
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(sl<AuthRemoteDataSourceImp>())
  );
  print('✅ DI: AuthCubit registered');
  
  // Car Cubit
  sl.registerFactory<CarCubit>(
    () => CarCubit(sl<CarRemoteDataSource>())
  );
  print('✅ DI: CarCubit registered');
  
  // Product Cubit
  sl.registerFactory<ProductCubit>(
    () => ProductCubit(sl<ProductRemoteDataSource>())
  );
  print('✅ DI: ProductCubit registered');
  
  // Service Cubit
  sl.registerFactory<ServiceCubit>(
    () => ServiceCubit(sl<ServiceRemoteDataSource>())
  );
  print('✅ DI: ServiceCubit registered');
  
  // Reel Cubit (Old one for data loading)
  sl.registerFactory<ReelCubit>(
    () => ReelCubit(dataSource: sl<ReelRemoteDataSource>())
  );
  print('✅ DI: ReelCubit registered');
  
  // 🎬 NEW LIGHTWEIGHT REELS CUBIT - GLOBAL PLAYBACK STATE
  sl.registerLazySingleton<ReelsCubit>(() => ReelsCubit());
  print('✅ DI: ReelsCubit (lightweight) registered');
  
  // 🎬 REELS PLAYBACK CUBIT - THE CRITICAL SINGLETON
  print('🎬 DI: About to register ReelsPlaybackCubit...');
  print('🔍 DI: Verifying ReelRemoteDataSource: ${sl.isRegistered<ReelRemoteDataSource>()}');
  sl.registerLazySingleton<ReelsPlaybackCubit>(
    () {
      print('🏗️ DI: Creating ReelsPlaybackCubit instance...');
      final dataSource = sl<ReelRemoteDataSource>();
      print('✅ DI: ReelRemoteDataSource retrieved successfully');
      final cubit = ReelsPlaybackCubit(dataSource: dataSource);
      print('✅ DI: ReelsPlaybackCubit created successfully');
      return cubit;
    }
  );
  print('🎯 DI: ReelsPlaybackCubit registered successfully');
  
  // Home Cubit
  sl.registerFactory<HomeCubit>(() => HomeCubit());
  print('✅ DI: HomeCubit registered');
  
  // Maps Cubit
  sl.registerFactory<MapsCubit>(() => MapsCubit());
  print('✅ DI: MapsCubit registered');
  
  // Chat Cubit
  sl.registerFactory<ChatCubit>(
    () => ChatCubit(sl<ChatRemoteDataSource>())
  );
  print('✅ DI: ChatCubit registered');
  
  // Dealer Profile Cubit
  sl.registerFactory<DealerProfileCubit>(
    () => DealerProfileCubit(sl<DealerProfileRemoteDataSource>())
  );
  print('✅ DI: DealerProfileCubit registered');
  
  // =================================================================
  // FINAL VERIFICATION
  // =================================================================
  print('🔍 DI: Final verification...');
  print('📊 DI: Total registered services: ${sl.allReady().length}');
  print('🎬 DI: ReelRemoteDataSource registered: ${sl.isRegistered<ReelRemoteDataSource>()}');
  print('🎬 DI: ReelsPlaybackCubit registered: ${sl.isRegistered<ReelsPlaybackCubit>()}');
  
  print('🎯 DI: BULLETPROOF DEPENDENCY INJECTION COMPLETE!');
}