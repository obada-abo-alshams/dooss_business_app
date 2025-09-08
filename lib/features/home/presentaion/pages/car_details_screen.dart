import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/routes/route_names.dart';
import '../../../../core/services/locator_service.dart' as di;
import '../../../../core/services/location_service.dart';
import '../manager/car_cubit.dart';
import '../manager/car_state.dart';
import '../widgets/car_image_section.dart';
import '../widgets/car_overview_section.dart';
import '../widgets/car_specifications_section.dart';
import '../widgets/seller_notes_section.dart';
import '../widgets/seller_info_section.dart';


class CarDetailsScreen extends StatefulWidget {
  final int carId;

  const CarDetailsScreen({
    super.key,
    required this.carId,
  });

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Position? _userLocation;
  bool _isLoadingRoute = false;
  LatLng? _carCoordinates;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    print('🗺️ CarDetails: Initializing map...');
    final userLocation = await LocationService.getCurrentLocation();
    if (userLocation != null) {
      print('✅ CarDetails: User location obtained: ${userLocation.latitude}, ${userLocation.longitude}');
      setState(() {
        _userLocation = userLocation;
      });
    } else {
      print('❌ CarDetails: Failed to get user location');
    }
  }

  Future<void> _loadCarCoordinates(String location) async {
    if (location.isNotEmpty) {
      final coords = await _getCarCoordinates(location);
      setState(() {
        _carCoordinates = coords;
      });
    }
  }

  Future<LatLng> _getCarCoordinates(String location) async {
    if (location.isEmpty) {
      print('⚠️ CarDetails: Empty location, using Dubai fallback');
      return const LatLng(25.2048, 55.2708);
    }

    try {
      const apiKey = 'AIzaSyCvFo9bVexv1f4O4lzdYqjPH7b-yf62k_c';
      final encodedLocation = Uri.encodeComponent(location);
      final url = 'https://maps.googleapis.com/maps/api/geocode/json?address=$encodedLocation&key=$apiKey';
      
      print('🌐 CarDetails: Geocoding location: $location');
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'] != null && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final geometry = result['geometry'];
          final location = geometry['location'];
          final lat = location['lat'].toDouble();
          final lng = location['lng'].toDouble();
          
          print('✅ CarDetails: Geocoded coordinates: $lat, $lng');
          return LatLng(lat, lng);
        }
      }
      
      print('⚠️ CarDetails: Geocoding failed, using Dubai fallback');
      return const LatLng(25.2048, 55.2708);
    } catch (e) {
      print('❌ CarDetails: Geocoding error: $e');
      return const LatLng(25.2048, 55.2708);
    }
  }

  Future<void> _loadRoute(double carLat, double carLon) async {
    if (_userLocation == null) {
      print('❌ CarDetails: Cannot load route - user location is null');
      return;
    }

    print('🔄 CarDetails: Loading route...');
    setState(() {
      _isLoadingRoute = true;
    });

    try {
      final markers = <Marker>{
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_userLocation!.latitude, _userLocation!.longitude),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
        Marker(
          markerId: const MarkerId('car_location'),
          position: LatLng(carLat, carLon),
          infoWindow: const InfoWindow(title: 'Car Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      };

      print('✅ CarDetails: Markers created');

      final polyline = await _getRoutePolyline(carLat, carLon);
      
      setState(() {
        _markers = markers;
        if (polyline != null) {
          _polylines = {polyline};
          print('✅ CarDetails: Polyline added to map');
        } else {
          print('⚠️ CarDetails: No polyline received, adding fallback');
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: [
                LatLng(_userLocation!.latitude, _userLocation!.longitude),
                LatLng(carLat, carLon),
              ],
              color: Colors.blue,
              width: 4,
              geodesic: true,
            ),
          };
        }
        _isLoadingRoute = false;
      });
    } catch (e) {
      print('❌ CarDetails: Error loading route: $e');
      setState(() {
        _isLoadingRoute = false;
      });
    }
  }

  Future<Polyline?> _getRoutePolyline(double carLat, double carLon) async {
    if (_userLocation == null) {
      print('❌ CarDetails: Cannot get polyline - user location is null');
      return null;
    }

    try {
      const apiKey = 'AIzaSyCvFo9bVexv1f4O4lzdYqjPH7b-yf62k_c';
      final url = 'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=${_userLocation!.latitude},${_userLocation!.longitude}&'
          'destination=$carLat,$carLon&'
          'mode=driving&'
          'key=$apiKey';

      print('🌐 CarDetails: Requesting route from Google Directions API...');
      print('📍 CarDetails: Origin: ${_userLocation!.latitude},${_userLocation!.longitude}');
      print('📍 CarDetails: Destination: $carLat,$carLon');
      print('🌐 CarDetails: URL: $url');
      
      final response = await http.get(Uri.parse(url));
      
      print('📊 CarDetails: API Response status: ${response.statusCode}');
      print('📊 CarDetails: API Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 CarDetails: API Response status: ${data['status']}');
        
        if (data['status'] == 'OK' && data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final polylineEncoded = route['overview_polyline']['points'];
          
          print('✅ CarDetails: Route found, decoding polyline...');
          final points = _decodePolyline(polylineEncoded);
          print('✅ CarDetails: Polyline decoded with ${points.length} points');
          
          if (points.isNotEmpty) {
            return Polyline(
              polylineId: const PolylineId('route'),
              points: points,
              color: Colors.blue,
              width: 8,
              geodesic: true,
              patterns: [PatternItem.dot, PatternItem.gap(10)],
              visible: true,
            );
          } else {
            print('⚠️ CarDetails: No points in polyline');
          }
        } else {
          print('⚠️ CarDetails: API Response error: ${data['status']}');
          if (data['error_message'] != null) {
            print('💬 CarDetails: Error message: ${data['error_message']}');
          }
        }
      } else {
        print('❌ CarDetails: HTTP error: ${response.statusCode}');
        print('💬 CarDetails: Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ CarDetails: Error getting route polyline: $e');
    }
    
    return null;
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      final p = LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<CarCubit>()..loadCarDetails(widget.carId),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: BlocBuilder<CarCubit, CarState>(
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
                      'Error loading car details',
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

            if (state.selectedCar == null) {
              return const Center(
                child: Text('Car not found'),
              );
            }

            final car = state.selectedCar!;

            if (_carCoordinates == null && car.location.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadCarCoordinates(car.location);
              });
            }

            return Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CarImageSection(
                        imageUrl: car.imageUrl,
                        carName: car.name,
                      ),
                      
                      CarOverviewSection(
                        carName: car.name,
                        price: car.price,
                        isNew: car.isNew,
                        location: car.location,
                        mileage: car.mileage,
                      ),
                      
                      CarSpecificationsSection(
                        year: car.year,
                        transmission: car.transmission,
                        engine: car.engine,
                        fuelType: car.fuelType,
                        color: car.color,
                        doors: car.doors,
                      ),
                      
                      SellerNotesSection(
                        notes: car.sellerNotes,
                      ),
                      
                      SellerInfoSection(
                        sellerName: car.sellerName,
                        sellerType: car.sellerType,
                        sellerImage: car.sellerImage,
                        onCallPressed: () {
                          print('Call seller');
                        },
                        onMessagePressed: () {
                          final dealerId = car.dealerId;
                          context.go('${RouteNames.chatConversationScreen}/$dealerId', extra: widget.carId);
                        },
                      ),
                      
                      Container(
                        padding: EdgeInsets.all(16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.location_on, color: AppColors.gray, size: 20.sp),
                                SizedBox(width: 8.w),
                                Text('Car Location', style: AppTextStyles.blackS16W600),
                                const Spacer(),
                                if (_isLoadingRoute)
                                  SizedBox(
                                    width: 16.w,
                                    height: 16.w,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                GestureDetector(
                                  onTap: () async {
                                    final coords = await _getCarCoordinates(car.location);
                                    _loadRoute(coords.latitude, coords.longitude);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16.r),
                                      border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.map, color: AppColors.primary, size: 16.sp),
                                        SizedBox(width: 4.w),
                                        Text(
                                          'View Route',
                                          style: AppTextStyles.s12w400.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Container(
                              height: 200.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: AppColors.gray.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: _carCoordinates ?? const LatLng(25.2048, 55.2708),
                                    zoom: 15.0,
                                  ),
                                  markers: _markers,
                                  polylines: _polylines,
                                  myLocationEnabled: true,
                                  myLocationButtonEnabled: false,
                                  zoomControlsEnabled: false,
                                  mapToolbarEnabled: false,
                                  compassEnabled: true,
                                  liteModeEnabled: true,
                                  onMapCreated: (GoogleMapController controller) {
                                    print('🗺️ CarDetails: Map controller created');
                                  },
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              car.location.isNotEmpty ? car.location : 'Dubai, UAE',
                              style: AppTextStyles.s14w400.copyWith(color: AppColors.gray),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
                
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8.h,
                  left: 8.w,
                  child: Container(
                    margin: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppColors.black,
                        size: 20.sp,
                      ),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
