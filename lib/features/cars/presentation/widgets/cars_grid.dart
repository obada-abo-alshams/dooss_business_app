import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/car_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/car_state.dart';
import 'package:dooss_business_app/features/home/data/models/car_model.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/see_all_cars_card.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/car_card_widget.dart';

class CarsGrid extends StatelessWidget {
  const CarsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CarCubit, CarState>(
      buildWhen: (previous, current) =>
          previous.cars != current.cars ||
          previous.filteredCars != current.filteredCars ||
          previous.isLoading != current.isLoading ||
          previous.error != current.error,
      builder: (context, state) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: state.cars.length,
          itemBuilder: (context, index) {
            return CarCardWidget(
              car: state.cars[index],
              onTap: () {
                // Navigate to car details
                context.push('/car-details/${state.cars[index].id}');
              },
            );
          },
        );
      },
    );
  }
} 