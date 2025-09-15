import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/locator_service.dart' as di;
import '../manager/car_cubit.dart';
import '../manager/car_state.dart';
import '../widgets/see_all_cars_card.dart';
import '../widgets/brand_selector.dart';
import '../widgets/promotional_banner.dart';
import '../widgets/search_app_bar.dart';
import '../widgets/all_cars_header_widget.dart';

class AllCarsScreen extends StatelessWidget {
  const AllCarsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<CarCubit>()..loadAllCars(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: const SearchAppBar(
          title: 'All Cars',
        ),
        body: BlocBuilder<CarCubit, CarState>(
          buildWhen: (previous, current) =>
              previous.cars != current.cars ||
              previous.filteredCars != current.filteredCars ||
              previous.isLoading != current.isLoading ||
              previous.error != current.error ||
              previous.hasMoreData != current.hasMoreData,
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64.sp,
                      color: AppColors.gray,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Error loading cars',
                      style: AppTextStyles.s16w500.copyWith(color: AppColors.gray),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      state.error!,
                      style: AppTextStyles.s14w400.copyWith(color: AppColors.gray),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  const AllCarsHeaderWidget(),
                  
                  // Brand Selector
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: BrandSelector(
                      selectedBrand: state.selectedBrand,
                      onBrandSelected: (brand) {
                        context.read<CarCubit>().filterByBrand(brand);
                      },
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Cars List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.cars.length + (state.hasMoreCars ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Load More Item
                      if (index == state.cars.length) {
                        return Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Center(
                            child: state.isLoadingMore
                                ? CircularProgressIndicator(color: AppColors.primary)
                                : ElevatedButton(
                                    onPressed: () {
                                      context.read<CarCubit>().loadMoreCars();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: AppColors.white,
                                    ),
                                    child: Text('Load More Cars'),
                                  ),
                          ),
                        );
                      }
                      
                      // Car Item
                      return Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        child: SeeAllCarsCard(
                          car: state.cars[index],
                          onTap: () {
                            // Navigate to car details
                            context.push('/car-details/${state.cars[index].id}');
                          },
                        ),
                      );
                    },
                  ),
                  
                  SizedBox(height: 20.h),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
