import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/home_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/home_state.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/home_tab_content.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/services_tab_content.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/reels_tab_content.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/messages_tab_content.dart';
import 'package:dooss_business_app/features/home/presentaion/pages/account_screen.dart';

class HomeTabSelector extends StatelessWidget {
  const HomeTabSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, homeState) {
        switch (homeState.currentIndex) {
          case 0:
            return const HomeTabContent();
          case 1:
            return const ServicesTabContent();
          case 2:
            return const ReelsTabContent();
          case 3:
            return const MessagesTabContent();
          case 4:
            return const AccountScreen();
          default:
            return const UnknownTabContent();
        }
      },
    );
  }
}

class UnknownTabContent extends StatelessWidget {
  const UnknownTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Unknown tab'),
    );
  }
}