import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dooss_business_app/core/services/locator_service.dart' as di;
import 'package:dooss_business_app/features/home/presentaion/manager/service_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/services_section_widget.dart';

class ServicesTabContent extends StatelessWidget {
  const ServicesTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ServiceCubit>(
      create: (context) => di.sl<ServiceCubit>(),
      child: const ServicesTabDataLoader(),
    );
  }
}

class ServicesTabDataLoader extends StatelessWidget {
  const ServicesTabDataLoader({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceCubit>().loadServices(limit: 5);
    });

    return const ServicesSectionWidget();
  }
}