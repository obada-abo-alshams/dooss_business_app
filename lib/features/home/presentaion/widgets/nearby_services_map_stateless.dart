import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../data/models/service_model.dart';
import '../manager/maps_cubit.dart';
import '../manager/maps_state.dart';

class NearbyServicesMapStateless extends StatelessWidget {
  final List<ServiceModel> services;

  const NearbyServicesMapStateless({
    super.key,
    required this.services,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapsCubit()..initializeMap(services),
      child: Container(
        height: 200.h,
        margin: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: AppColors.gray.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: BlocBuilder<MapsCubit, MapsState>(
            buildWhen: (previous, current) =>
                previous.isLoading != current.isLoading ||
                previous.error != current.error ||
                previous.userLocation != current.userLocation ||
                previous.markers != current.markers,
            builder: (context, state) {
              if (state.isLoading) {
                return Container(
                  color: AppColors.gray.withOpacity(0.1),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                );
              }

              if (state.error != null) {
                return Container(
                  color: AppColors.gray.withOpacity(0.1),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          color: AppColors.gray,
                          size: 48.sp,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Map unavailable',
                          style: TextStyle(
                            color: AppColors.gray,
                            fontSize: 14.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        TextButton(
                          onPressed: () => context.read<MapsCubit>().refreshMap(),
                          child: Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  context.read<MapsCubit>().setMapController(controller);
                },
                initialCameraPosition: CameraPosition(
                  target: state.userLocation != null
                      ? LatLng(state.userLocation!.latitude, state.userLocation!.longitude)
                      : const LatLng(AppConfig.defaultLatitude, AppConfig.defaultLongitude),
                  zoom: AppConfig.defaultZoom,
                ),
                markers: state.markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                mapType: MapType.normal,
              );
            },
          ),
        ),
      ),
    );
  }
}