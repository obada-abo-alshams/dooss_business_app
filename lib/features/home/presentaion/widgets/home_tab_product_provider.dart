import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dooss_business_app/core/services/locator_service.dart' as di;
import 'package:dooss_business_app/features/home/presentaion/manager/service_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/home_tab_service_provider.dart';

class HomeTabProductProvider extends StatelessWidget {
  const HomeTabProductProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ServiceCubit>(
      create: (context) => di.sl<ServiceCubit>(),
      child: const HomeTabServiceProvider(),
    );
  }
}