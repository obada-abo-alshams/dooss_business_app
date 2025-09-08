import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dooss_business_app/core/services/locator_service.dart' as di;
import 'package:dooss_business_app/features/home/presentaion/manager/reel_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/home_tab_reel_provider.dart';

class HomeTabServiceProvider extends StatelessWidget {
  const HomeTabServiceProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReelCubit>(
      create: (context) => di.sl<ReelCubit>(),
      child: const HomeTabReelProvider(),
    );
  }
}