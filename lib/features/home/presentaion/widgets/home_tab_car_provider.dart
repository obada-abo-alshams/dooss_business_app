import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dooss_business_app/core/services/locator_service.dart' as di;
import 'package:dooss_business_app/features/home/presentaion/manager/product_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/home_tab_product_provider.dart';

class HomeTabCarProvider extends StatelessWidget {
  const HomeTabCarProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ProductCubit>(
      create: (context) => di.sl<ProductCubit>(),
      child: const HomeTabProductProvider(),
    );
  }
}