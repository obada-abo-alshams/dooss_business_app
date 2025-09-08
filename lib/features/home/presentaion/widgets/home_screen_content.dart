import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dooss_business_app/core/constants/colors.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/home_app_bar.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/home_bottom_navigation.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/home_tab_selector.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/home_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/home_state.dart';

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreenInitializer();
  }
}

class HomeScreenInitializer extends StatelessWidget {
  const HomeScreenInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.parse(GoRouterState.of(context).uri.toString());
    final tabParam = uri.queryParameters['tab'];
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (tabParam == 'messages') {
        context.read<HomeCubit>().updateCurrentIndex(3);
      }
    });

    return const HomeScreenLayout();
  }
}

class HomeScreenLayout extends StatelessWidget {
  const HomeScreenLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HomeAppBar(),
      body: const HomeScreenBody(),
    );
  }
}

class HomeScreenBody extends StatelessWidget {
  const HomeScreenBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Expanded(child: HomeTabSelector()),
        HomeBottomNavigationWrapper(),
      ],
    );
  }
}

class HomeBottomNavigationWrapper extends StatelessWidget {
  const HomeBottomNavigationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, homeState) {
        return HomeBottomNavigation(
          currentIndex: homeState.currentIndex,
          onTap: (index) {
            context.read<HomeCubit>().updateCurrentIndex(index);
          },
        );
      },
    );
  }
}