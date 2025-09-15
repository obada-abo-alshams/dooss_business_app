import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:dooss_business_app/core/routes/route_names.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/cars_available_section.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/products_section.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/services_section.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/reels_section.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/messages_section.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/account_section.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/loading_section.dart';
import 'package:dooss_business_app/features/home/presentaion/widgets/error_section.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/home_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/home_state.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/car_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/car_state.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/product_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/product_state.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/service_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/service_state.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/reel_cubit.dart';
import 'package:dooss_business_app/features/home/presentaion/manager/reel_state.dart';

class ContentSection extends StatelessWidget {
  const ContentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      buildWhen: (previous, current) =>
          previous.currentIndex != current.currentIndex ||
          previous.selectedBrowseType != current.selectedBrowseType,
      builder: (context, homeState) {
        // If we're on the home tab, show content based on browse type
        if (homeState.currentIndex == 0) {
          switch (homeState.selectedBrowseType) {
            case 0: // Cars
              return BlocBuilder<CarCubit, CarState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return LoadingSection(title: 'Cars Available Now');
                  } else if (state.error != null) {
                    return ErrorSection(title: 'Cars Available Now', message: state.error!);
                  } else if (state.cars.isNotEmpty) {
                                         return CarsAvailableSection(
                       cars: state.cars,
                       onViewAllPressed: () {
                         context.push(RouteNames.allCarsScreen);
                       },
                       onCarPressed: () {
                         // Navigate to car details
                         context.push('/car-details/${state.cars.first.id}');
                       },
                     );
                  } else {
                    return LoadingSection(title: 'Cars Available Now');
                  }
                },
              );
            case 1: // Products
              return BlocBuilder<ProductCubit, ProductState>(
                buildWhen: (previous, current) =>
                    previous.products != current.products ||
                    previous.isLoading != current.isLoading ||
                    previous.error != current.error,
                builder: (context, state) {
                  if (state.isLoading) {
                    return LoadingSection(title: 'Car Products');
                  } else if (state.error != null) {
                    return ErrorSection(title: 'Car Products', message: state.error!);
                  } else if (state.products.isNotEmpty) {
                    return ProductsSection(products: state.products);
                  } else {
                    return LoadingSection(title: 'Car Products');
                  }
                },
              );
            case 2: // Services
              return BlocBuilder<ServiceCubit, ServiceState>(
                buildWhen: (previous, current) =>
                    previous.services != current.services ||
                    previous.isLoading != current.isLoading ||
                    previous.error != current.error,
                builder: (context, state) {
                  if (state.isLoading) {
                    return LoadingSection(title: 'Nearby Car Services');
                  } else if (state.error != null) {
                    return ErrorSection(title: 'Nearby Car Services', message: state.error!);
                  } else if (state.services.isNotEmpty) {
                    return ServicesSection(services: state.services);
                  } else {
                    return LoadingSection(title: 'Nearby Car Services');
                  }
                },
              );
            default:
              return BlocBuilder<CarCubit, CarState>(
                buildWhen: (previous, current) =>
                    previous.cars != current.cars ||
                    previous.isLoading != current.isLoading ||
                    previous.error != current.error,
                builder: (context, state) {
                  if (state.isLoading) {
                    return LoadingSection(title: 'Cars Available Now');
                  } else if (state.error != null) {
                    return ErrorSection(title: 'Cars Available Now', message: state.error!);
                  } else if (state.cars.isNotEmpty) {
                    return CarsAvailableSection(
                      cars: state.cars,
                      onViewAllPressed: () {
                        context.push(RouteNames.allCarsScreen);
                      },
                      onCarPressed: () {
                        
                        print('Car pressed');
                      },
                    );
                  } else {
                    return LoadingSection(title: 'Cars Available Now');
                  }
                },
              );
          }
        }
        
        // Otherwise show content based on bottom navigation
        switch (homeState.currentIndex) {
          case 1: // Services
            return BlocBuilder<ServiceCubit, ServiceState>(
              buildWhen: (previous, current) =>
                  previous.services != current.services ||
                  previous.isLoading != current.isLoading ||
                  previous.error != current.error,
              builder: (context, state) {
                if (state.isLoading) {
                  return LoadingSection(title: 'Nearby Car Services');
                } else if (state.error != null) {
                  return ErrorSection(title: 'Nearby Car Services', message: state.error!);
                } else if (state.services.isNotEmpty) {
                  return ServicesSection(services: state.services);
                } else {
                  return LoadingSection(title: 'Nearby Car Services');
                }
              },
            );
          case 2: // Reels
            return BlocBuilder<ReelCubit, ReelState>(
              buildWhen: (previous, current) =>
                  previous.reels != current.reels ||
                  previous.isLoading != current.isLoading ||
                  previous.error != current.error,
              builder: (context, state) {
                if (state.isLoading) {
                  return LoadingSection(title: 'Market Reels');
                } else if (state.error != null) {
                  return ErrorSection(title: 'Market Reels', message: state.error!);
                } else if (state.reels.isNotEmpty) {
                  return ReelsSection(reels: state.reels);
                } else {
                  return LoadingSection(title: 'Market Reels');
                }
              },
            );
          case 3: // Messages
            return const MessagesSection();
          case 4: // Account
            return const AccountSection();
          default:
            return BlocBuilder<CarCubit, CarState>(
              buildWhen: (previous, current) =>
                  previous.cars != current.cars ||
                  previous.isLoading != current.isLoading ||
                  previous.error != current.error,
              builder: (context, state) {
                if (state.isLoading) {
                  return LoadingSection(title: 'Cars Available Now');
                } else if (state.error != null) {
                  return ErrorSection(title: 'Cars Available Now', message: state.error!);
                } else if (state.cars.isNotEmpty) {
                  return CarsAvailableSection(
                    cars: state.cars,
                    onViewAllPressed: () {
                      context.push(RouteNames.allCarsScreen);
                    },
                    onCarPressed: () {
                      // Navigate to car details
                      context.push('/car-details/${state.cars.first.id}');
                    },
                  );
                } else {
                  return LoadingSection(title: 'Cars Available Now');
                }
              },
            );
        }
      },
    );
  }
}
