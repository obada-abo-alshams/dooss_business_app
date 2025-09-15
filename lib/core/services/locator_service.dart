import 'package:dooss_business_app/core/network/api.dart';
import 'package:dooss_business_app/core/network/app_dio.dart';
import 'package:dooss_business_app/features/auth/data/data_source/auth_remote_data_source_imp.dart';
import 'package:dooss_business_app/features/auth/presentation/manager/auth_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/car_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/product_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/service_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/reel_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/home_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/maps_cubit.dart';
import 'package:dooss_business_app/features/home/data/data_source/car_remote_data_source.dart';
import 'package:dooss_business_app/features/home/data/data_source/product_remote_data_source.dart';
import 'package:dooss_business_app/features/home/data/data_source/product_remote_data_source_imp.dart';
import 'package:dooss_business_app/features/home/data/data_source/service_remote_data_source.dart';
import 'package:dooss_business_app/features/home/data/data_source/service_remote_data_source_imp.dart';
import 'package:dooss_business_app/features/home/data/data_source/reel_remote_data_source.dart';
import 'package:dooss_business_app/features/home/data/data_source/reel_remote_data_source_imp.dart';
import 'package:dooss_business_app/features/chat/data/data_source/chat_remote_data_source.dart';
import 'package:dooss_business_app/features/chat/data/data_source/chat_remote_data_source_imp.dart';
import 'package:dooss_business_app/features/chat/presentation/manager/chat_cubit.dart';
import 'package:dooss_business_app/core/services/websocket_service.dart';
import 'package:dooss_business_app/core/services/token_service.dart';
import 'package:dooss_business_app/features/profile_dealer/data/data_source/dealer_profile_remote_data_source.dart';
import 'package:dooss_business_app/features/profile_dealer/presentation/manager/dealer_profile_cubit.dart';


final sl = GetIt.instance;

Future<void> init() async {
  // Cubits
  sl.registerFactory<CarCubit>(() => CarCubit(sl<CarRemoteDataSource>()));
  sl.registerFactory<ProductCubit>(() => ProductCubit(sl<ProductRemoteDataSource>()));
  sl.registerFactory<ServiceCubit>(() => ServiceCubit(sl<ServiceRemoteDataSource>()));
  sl.registerFactory<ReelCubit>(() => ReelCubit(dataSource: sl<ReelRemoteDataSource>()));
  sl.registerFactory<HomeCubit>(() => HomeCubit());
  sl.registerFactory<MapsCubit>(() => MapsCubit());
  sl.registerFactory<AuthCubit>(()=>AuthCubit(sl<AuthRemoteDataSourceImp>()));
  sl.registerFactory<ChatCubit>(() => ChatCubit(sl<ChatRemoteDataSource>()));
  sl.registerFactory<DealerProfileCubit>(() => DealerProfileCubit(sl<DealerProfileRemoteDataSource>()));

  // DataSources
  sl.registerLazySingleton<AppDio>(()=>AppDio());
  sl.registerLazySingleton<API>(()=>API(dio: sl<AppDio>().dio));
  sl.registerLazySingleton<AuthRemoteDataSourceImp>(()=>AuthRemoteDataSourceImp(api: sl<API>() ));
  sl.registerLazySingleton<CarRemoteDataSource>(() => CarRemoteDataSourceImpl(sl<AppDio>()));
  sl.registerLazySingleton<ProductRemoteDataSource>(() => ProductRemoteDataSourceImp(api: sl<API>()));
  sl.registerLazySingleton<ServiceRemoteDataSource>(() => ServiceRemoteDataSourceImp(api: sl<API>()));
  sl.registerLazySingleton<ReelRemoteDataSource>(() => ReelRemoteDataSourceImp(dio: sl<AppDio>()));
  sl.registerLazySingleton<ChatRemoteDataSource>(() => ChatRemoteDataSourceImp(api: sl<API>()));
  sl.registerLazySingleton<WebSocketService>(() => WebSocketService());
  sl.registerLazySingleton<DealerProfileRemoteDataSource>(() => DealerProfileRemoteDataSourceImpl(sl<AppDio>()));
}