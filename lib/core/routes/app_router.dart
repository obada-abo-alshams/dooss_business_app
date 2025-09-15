import 'package:dooss_business_app/core/routes/route_names.dart';
import 'package:dooss_business_app/features/auth/presentation/pages/forget_password_screen.dart';
import 'package:dooss_business_app/features/auth/presentation/pages/create_new_password_screen.dart';
import 'package:dooss_business_app/features/auth/presentation/pages/login_screen.dart';
import 'package:dooss_business_app/features/auth/presentation/pages/register_screen.dart';
import 'package:dooss_business_app/features/auth/presentation/pages/verify_otp_page.dart';
import 'package:dooss_business_app/features/cars/presentation/pages/add_car_flow.dart';
import 'package:dooss_business_app/features/cars/presentation/pages/add_car_step4.dart';
import 'package:dooss_business_app/features/chat/data/models/chat_model.dart';
import 'package:dooss_business_app/features/home/presentaion/pages/home_screen.dart';
import 'package:dooss_business_app/features/chat/presentation/pages/chat_list_screen.dart';
import 'package:dooss_business_app/features/chat/presentation/pages/chat_detail_screen.dart';
import 'package:dooss_business_app/features/cars/presentation/pages/cars_screen.dart';
import 'package:dooss_business_app/features/home/presentaion/pages/all_cars_screen.dart';
import 'package:dooss_business_app/features/home/presentaion/pages/all_products_screen.dart';
import 'package:dooss_business_app/features/home/presentaion/pages/product_details_screen.dart';
import 'package:dooss_business_app/features/home/presentaion/pages/car_details_screen.dart';
import 'package:dooss_business_app/features/profile_dealer/presentation/pages/dealer_profile_screen.dart';
import 'package:dooss_business_app/features/profile_dealer/presentation/manager/dealer_profile_cubit.dart';
import 'package:dooss_business_app/features/chat/presentation/pages/chats_list_screen.dart';
import 'package:dooss_business_app/features/chat/presentation/pages/chat_conversation_screen.dart';
import 'package:dooss_business_app/features/cars/presentation/pages/add_car_step1.dart';
import 'package:dooss_business_app/features/home/presentaion/pages/nearby_services_screen.dart';
import 'package:dooss_business_app/features/home/presentaion/pages/service_map_screen.dart';
import 'package:dooss_business_app/features/home/presentaion/pages/service_details_screen.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/service_cubit.dart';
import 'package:dooss_business_app/features/home/data/models/service_model.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/pages/app_type_screen.dart';
import '../../features/auth/presentation/pages/on_boarding_screen.dart';
import '../../features/cars/presentation/pages/add_car_step2.dart';
import '../../features/cars/presentation/pages/add_car_step3.dart';
import '../../features/chat/presentation/manager/chat_cubit.dart';
import '../../core/services/locator_service.dart' as di;
import '../../features/chat/presentation/pages/create_chat_screen.dart';
import '../../features/chat/presentation/pages/chat_test_screen.dart';
import '../../features/home/presentaion/pages/reels_screen.dart';
import '../../features/home/presentaion/pages/full_screen_reels_viewer.dart';
import '../../features/home/presentaion/manager/reel_cubit.dart';
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: RouteNames.onBoardingScreen,
    routes: _routes,
  );

  static GoRouter createRouterWithObserver(NavigatorObserver observer) {
    return GoRouter(
      initialLocation: RouteNames.onBoardingScreen,
      observers: [observer],
      routes: _routes,
    );
  }

  static final List<RouteBase> _routes = [
      GoRoute(
        path: RouteNames.onBoardingScreen,
        builder: (context, state) => const OnBoardingScreen(),
      ),
      GoRoute(
        path: RouteNames.selectAppTypeScreen,
        builder: (context,state) => AppTypeScreen(),
      ),
      GoRoute(
        path: RouteNames.loginScreen,
        builder: (context, state) => LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.rigesterScreen,
        builder: (context, state) => RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgetPasswordPage,
        builder: (context, state) => ForgetPasswordPage(),
      ),
             GoRoute(
         path: RouteNames.verifyForgetPasswordPage,
         builder: (context, state) {
           String phoneNumber = state.extra as String? ?? '';
           return VerifyOtpPage(
             phoneNumber: phoneNumber,
             isResetPassword: true, // تحديد أن هذا reset password flow
           );
         },
       ),
       GoRoute(
         path: RouteNames.verifyRegisterOtpPage,
         builder: (context, state) {
           String phoneNumber = state.extra as String? ?? '';
           return VerifyOtpPage(
             phoneNumber: phoneNumber,
             isResetPassword: false, // تحديد أن هذا register flow
           );
         },
       ),
      GoRoute(
        path: RouteNames.createNewPasswordPage,
        builder: (context, state) {
          String phoneNumber = state.extra as String? ?? '';
          return CreateNewPasswordPage(
            phoneNumber: phoneNumber,
          );
        },
      ),
      GoRoute(
        path: RouteNames.chats,
        builder: (context, state) => const ChatsListScreen(),
      ),
      GoRoute(
        path: RouteNames.chatDetails,
        builder: (context, state) {
          final chat = state.extra as ChatModel;
          return ChatConversationScreen(chatId: chat.id, participantName: chat.dealer);
        },
      ),
      GoRoute(
        path: RouteNames.homeScreen,
        builder: (context, state) => HomeScreen(),
      ),
      GoRoute(
        path: RouteNames.carsScreen,
        builder: (context, state) => const CarsScreen(),
      ),
      GoRoute(
        path: RouteNames.allCarsScreen,
        builder: (context, state) => const AllCarsScreen(),
      ),
              GoRoute(
          path: RouteNames.allProductsScreen,
          builder: (context, state) => const AllProductsScreen(),
        ),
        GoRoute(
          path: '${RouteNames.productDetailsScreen}/:id',
          builder: (context, state) {
            final productId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
            return ProductDetailsScreen(productId: productId);
          },
        ),
        GoRoute(
          path: '/car-details/:id',
          builder: (context, state) {
            final carId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
            return CarDetailsScreen(carId: carId);
          },
        ),
        GoRoute(
          path: '/dealer-profile/:id',
          builder: (context, state) {
            final dealerId = state.pathParameters['id']!;
            final dealerHandle = state.uri.queryParameters['handle'] ?? '@dealer';
                          return BlocProvider(
                create: (context) => di.sl<DealerProfileCubit>(),
                child: DealerProfileScreen(
                  dealerId: dealerId,
                  dealerHandle: dealerHandle,
                ),
              );
          },
        ),
        GoRoute(
          path: RouteNames.chatsListScreen,
          builder: (context, state) => const ChatsListScreen(),
        ),
        GoRoute(
          path: '${RouteNames.chatConversationScreen}/:id',
          builder: (context, state) {
            final chatId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
            final productId = state.extra as int?;
            return BlocProvider(
              create: (_) => di.sl<ChatCubit>(),
              child: ChatConversationScreen(
                chatId: chatId,
                participantName: 'Chat $chatId',
                productId: productId,
              ),
            );
          },
        ),
                 GoRoute(
           path: '/create-chat',
           builder: (context, state) {
             final args = state.extra as Map<String, dynamic>?;
             final dealerId = args?['dealerId'] as int? ?? 0;
             final dealerName = args?['dealerName'] as String? ?? 'Dealer';
             return BlocProvider(
               create: (_) => di.sl<ChatCubit>(),
               child: CreateChatScreen(
                 dealerId: dealerId,
                 dealerName: dealerName,
               ),
             );
           },
         ),
         GoRoute(
           path: '/chat-test',
           builder: (context, state) => const ChatTestScreen(),
         ),
      GoRoute(
        path: RouteNames.addCarFlow,
        builder: (context, state) => AddCarFlow(),
      ),

      GoRoute(
        path: RouteNames.addCarStep1,
        builder: (context, state) => AddCarStep1(onNext: () {}),
      ),
      GoRoute(
        path: RouteNames.addCarStep2,
        builder: (context, state) => AddCarStep2(onNext: () {}),
      ),
      GoRoute(
        path: RouteNames.addCarStep3,
        builder: (context, state) => AddCarStep3(onNext: () {}),
      ),

      GoRoute(
        path: RouteNames.addCarStep4,
        builder: (context, state) => AddCarStep4(onSubmit: () {}),
      ),
      GoRoute(
        path: RouteNames.nearbyServicesScreen,
        builder: (context, state) => BlocProvider(
          create: (context) => di.sl<ServiceCubit>(),
          child: const NearbyServicesScreen(),
        ),
      ),
             GoRoute(
         path: '/service-map',
         builder: (context, state) {
           // Get service from extra parameter (passed from NearbyServicesScreen)
           final service = state.extra as ServiceModel?;
           if (service != null) {
             return ServiceMapScreen(service: service);
           }
           // Fallback: create a placeholder service
           return ServiceMapScreen(
             service: ServiceModel(
               id: 1,
               name: 'Service',
               type: 'mechanic',
               city: 'Dubai',
               address: 'Dubai, UAE',
               image: '',
               phonePrimary: '+971501234567',
               phoneSecondary: '',
               open24h: false,
               openFrom: '08:00',
               openTo: '18:00',
               openNow: true,
               openingText: 'Open until 6:00 PM',
               lat: 25.2048,
               lon: 55.2708,
               callUrl: 'tel:+971501234567',
               mapsUrl: 'https://maps.google.com/?q=25.2048,55.2708',
               osmMapsUrl: 'https://www.openstreetmap.org/?mlat=25.2048&mlon=55.2708',
               geoUrl: 'geo:25.2048,55.2708',
               staticMapUrl: 'https://maps.googleapis.com/maps/api/staticmap?center=25.2048,55.2708&zoom=15&size=400x300&key=YOUR_API_KEY',
               hasPhone: true,
               services: ['Service 1', 'Service 2'],
             ),
           );
         },
       ),
       GoRoute(
         path: '/service-details',
         builder: (context, state) {
           // Get service from extra parameter
           final service = state.extra as ServiceModel?;
           print('🔍 AppRouter: Service Details route accessed');
           print('🔍 AppRouter: Service extra parameter: ${service?.name ?? 'null'}');
           if (service != null) {
             print('✅ AppRouter: Creating ServiceDetailsScreen with service: ${service.name}');
             return ServiceDetailsScreen(service: service);
           }
           // Fallback: create a placeholder service
           return ServiceDetailsScreen(
             service: ServiceModel(
               id: 1,
               name: 'Al Marwan Auto Workshop',
               type: 'mechanic',
               city: 'Dubai',
               address: 'Sheikh Zayed Road, Dubai, United Arab Emirates',
               image: '',
               phonePrimary: '+971 4 654 7412',
               phoneSecondary: '',
               open24h: false,
               openFrom: '08:00',
               openTo: '18:00',
               openNow: true,
               openingText: 'Open until 6:00 PM',
               lat: 25.2048,
               lon: 55.2708,
               callUrl: 'tel:+97146547412',
               mapsUrl: 'https://maps.google.com/?q=25.2048,55.2708',
               osmMapsUrl: 'https://www.openstreetmap.org/?mlat=25.2048&mlon=55.2708',
               geoUrl: 'geo:25.2048,55.2708',
               staticMapUrl: 'https://maps.googleapis.com/maps/api/staticmap?center=25.2048,55.2708&zoom=15&size=400x300&key=YOUR_API_KEY',
               hasPhone: true,
               services: ['Engine Check', 'Oil Change', 'Brake Inspection', 'AC Service'],
             ),
           );
         },
       ),
       
      // Reels Routes
      GoRoute(
        path: RouteNames.reelsScreen,
        builder: (context, state) => const FullScreenReelsViewer(),
      ),
       GoRoute(
         path: RouteNames.reelsWithId,
         builder: (context, state) {
           final reelId = int.tryParse(state.pathParameters['id'] ?? '0') ?? 0;
           return BlocProvider(
             create: (context) => di.sl<ReelCubit>(),
             child: ReelsScreen(initialReelId: reelId),
           );
         },
       ),
       
       // Dealer Profile Routes
       GoRoute(
         path: RouteNames.dealerProfileWithId,
         builder: (context, state) {
           final dealerId = state.pathParameters['id'] ?? '0';
           return BlocProvider(
             create: (context) => di.sl<DealerProfileCubit>(),
             child: DealerProfileScreen(
               dealerId: dealerId,
               dealerHandle: '@cardealer_uae', // Default handle
             ),
           );
         },
       ),
    ];
}