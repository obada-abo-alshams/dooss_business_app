import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/car_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/product_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/service_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/reel_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/home_tab_scroll_view.dart';

class HomeTabDataLoader extends StatelessWidget {
  const HomeTabDataLoader({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarCubit>().loadCars();
      context.read<ProductCubit>().loadProducts();
      context.read<ServiceCubit>().loadServices(limit: 5);
      context.read<ReelCubit>().loadReels();
    });

    return const HomeTabScrollView();
  }
}