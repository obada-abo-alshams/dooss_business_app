import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dooss_business_app/core/services/locator_service.dart' as di;
import 'package:dooss_business_app/features/home/presentaion/manager/reel_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/pages/reels_screen.dart';

class ReelsTabContent extends StatelessWidget {
  const ReelsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReelCubit>(
      create: (context) => di.sl<ReelCubit>(),
      child: const ReelsTabDataLoader(),
    );
  }
}

class ReelsTabDataLoader extends StatelessWidget {
  const ReelsTabDataLoader({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReelCubit>().loadReels();
    });

    return const ReelsScreen();
  }
}