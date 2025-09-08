import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:dooss_business_app/core/constants/colors.dart';
import 'package:dooss_business_app/core/constants/text_styles.dart';
import 'package:dooss_business_app/core/services/locator_service.dart' as di;
import 'package:dooss_business_app/features/home/presentaion/widgets/home_banner.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/market_reels_section.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/browse_by_type_section.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/cars_available_section.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/home_bottom_navigation.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/home_app_bar.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/content_section.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/car_cubit.dart';
import 'package:dooss_business_app/core/routes/route_names.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/product_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/service_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/reel_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/home_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/car_state.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/product_state.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/service_state.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/reel_state.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/home_state.dart';
import 'package:dooss_business_app/features/chat/presentation/pages/chats_list_screen.dart';
import 'package:dooss_business_app/features/chat/presentation/manager/chat_cubit.dart';
import 'package:dooss_business_app/features/chat/presentation/manager/chat_state.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/services_section_widget.dart';
import 'package:dooss_business_app/features/home/presentaion/pages/reels_screen.dart';
import 'package:dooss_business_app/features/home/presentaion/pages/account_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if we should select a specific tab from URL parameters
    final uri = Uri.parse(GoRouterState.of(context).uri.toString());
    final tabParam = uri.queryParameters['tab'];
    
    // Set initial tab based on URL parameter
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (tabParam == 'messages') {
        context.read<HomeCubit>().updateCurrentIndex(3); // Messages tab
      }
    });
    return BlocProvider<HomeCubit>(
      create: (context) => di.sl<HomeCubit>(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const HomeAppBar(),
        body: Column(
          children: [
            Expanded(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, homeState) {
                  // Show different content based on selected tab
                  switch (homeState.currentIndex) {
                                                    case 0: // Home
                                  return MultiBlocProvider(
                                    providers: [
                                      BlocProvider<CarCubit>(
                                        create: (context) => di.sl<CarCubit>(),
                                        lazy: false,
                                      ),
                                      BlocProvider<ProductCubit>(
                                        create: (context) => di.sl<ProductCubit>(),
                                        lazy: false,
                                      ),
                                      BlocProvider<ServiceCubit>(
                                        create: (context) => di.sl<ServiceCubit>(),
                                        lazy: false,
                                      ),
                                      BlocProvider<ReelCubit>(
                                        create: (context) => di.sl<ReelCubit>(),
                                        lazy: false,
                                      ),
                                    ],
                                    child: const _HomeTabContent(),
                                  );
                    case 1: // Services
                      return BlocProvider<ServiceCubit>(
                        create: (context) => di.sl<ServiceCubit>()..loadServices(limit: 5),
                        child: const ServicesSectionWidget(),
                      );
                    case 2: // Reels
                      return BlocProvider<ReelCubit>(
                        create: (context) => di.sl<ReelCubit>()..loadReels(),
                        child: const ReelsScreen(),
                      );
                    case 3: // Messages
                      return BlocProvider<ChatCubit>(
                        create: (context) => di.sl<ChatCubit>()..loadChats(),
                        child: const ChatsListScreen(),
                      );
                    case 4: // Account
                      return const AccountScreen();
                    default:
                      return const Center(child: Text('Unknown tab'));
                  }
                },
              ),
            ),
            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, homeState) {
                return HomeBottomNavigation(
                  currentIndex: homeState.currentIndex,
                  onTap: (index) {
                    context.read<HomeCubit>().updateCurrentIndex(index);
                  },
                );
              },
            ),
          ],
        ),
      ),

    );
  }
}

/// Optimized home tab content with lazy loading and better performance
class _HomeTabContent extends StatefulWidget {
  const _HomeTabContent();

  @override
  State<_HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<_HomeTabContent>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    // Load data after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  void _loadData() {
    context.read<CarCubit>().loadCars();
    context.read<ProductCubit>().loadProducts();
    context.read<ServiceCubit>().loadServices(limit: 5);
    context.read<ReelCubit>().loadReels();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16.w),
              child: const HomeBanner(),
            ),
            const MarketReelsSection(),
            SizedBox(height: 24.h),
            BlocBuilder<HomeCubit, HomeState>(
              builder: (context, homeState) {
                return BrowseByTypeSection(
                  selectedIndex: homeState.selectedBrowseType,
                  onTap: (index) {
                    context.read<HomeCubit>().updateSelectedBrowseType(index);
                  },
                );
              },
            ),
            SizedBox(height: 24.h),
            const ContentSection(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
