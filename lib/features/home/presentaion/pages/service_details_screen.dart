import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/location_service.dart';
import '../../data/models/service_model.dart';
// Removed service_photo_card_widget import - no longer needed

class ServiceDetailsScreen extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailsScreen({super.key, required this.service});

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Position? _userLocation;
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    print('🎯 ServiceDetails: Widget initialized with service: ${widget.service.name}');
    print('🎯 ServiceDetails: Service location: ${widget.service.lat}, ${widget.service.lon}');
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    print('🗺️ ServiceDetails: Initializing map...');
    // Get user location
    final userLocation = await LocationService.getCurrentLocation();
    if (userLocation != null) {
      print('✅ ServiceDetails: User location obtained: ${userLocation.latitude}, ${userLocation.longitude}');
      setState(() {
        _userLocation = userLocation;
      });
      // Load route
      await _loadRoute();
    } else {
      print('❌ ServiceDetails: Failed to get user location');
    }
  }

  Future<void> _loadRoute() async {
    if (_userLocation == null) {
      print('❌ ServiceDetails: Cannot load route - user location is null');
      return;
    }

    print('🔄 ServiceDetails: Loading route...');
    setState(() {
      _isLoadingRoute = true;
    });

    try {
      // Create markers
      final markers = <Marker>{
        // User location marker
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(_userLocation!.latitude, _userLocation!.longitude),
          infoWindow: const InfoWindow(title: 'Your Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
        // Service location marker
        Marker(
          markerId: MarkerId('service_${widget.service.id}'),
          position: LatLng(widget.service.lat, widget.service.lon),
          infoWindow: InfoWindow(
            title: widget.service.name,
            snippet: widget.service.address,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            widget.service.type.toLowerCase().contains('mechanic') 
              ? BitmapDescriptor.hueRed 
              : BitmapDescriptor.hueGreen
          ),
        ),
      };

      print('✅ ServiceDetails: Markers created');

      // Get route polyline
      print('🔄 ServiceDetails: Getting route polyline...');
      final polyline = await _getRoutePolyline();
      
      setState(() {
        _markers = markers;
        if (polyline != null) {
          _polylines = {polyline};
          print('✅ ServiceDetails: Polyline added to map');
        } else {
          print('⚠️ ServiceDetails: No polyline received, adding fallback');
          // Add fallback straight line
          _polylines = {
            Polyline(
              polylineId: const PolylineId('route'),
              points: [
                LatLng(_userLocation!.latitude, _userLocation!.longitude),
                LatLng(widget.service.lat, widget.service.lon),
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
      print('❌ ServiceDetails: Error loading route: $e');
      setState(() {
        _isLoadingRoute = false;
      });
    }
  }

  Future<Polyline?> _getRoutePolyline() async {
    if (_userLocation == null) {
      print('❌ ServiceDetails: Cannot get polyline - user location is null');
      return null;
    }

    try {
      const apiKey = 'AIzaSyCvFo9bVexv1f4O4lzdYqjPH7b-yf62k_c';
      final url = 'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=${_userLocation!.latitude},${_userLocation!.longitude}&'
          'destination=${widget.service.lat},${widget.service.lon}&'
          'mode=driving&'
          'key=$apiKey';

      print('🌐 ServiceDetails: Requesting route from Google Directions API...');
      print('📍 ServiceDetails: Origin: ${_userLocation!.latitude},${_userLocation!.longitude}');
      print('📍 ServiceDetails: Destination: ${widget.service.lat},${widget.service.lon}');
      print('🌐 ServiceDetails: URL: $url');
      
      final response = await http.get(Uri.parse(url));
      
      print('📊 ServiceDetails: API Response status: ${response.statusCode}');
      print('📊 ServiceDetails: API Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📊 ServiceDetails: API Response status: ${data['status']}');
        
        if (data['status'] == 'OK' && data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final polylineEncoded = route['overview_polyline']['points'];
          
          print('✅ ServiceDetails: Route found, decoding polyline...');
          final points = _decodePolyline(polylineEncoded);
          print('✅ ServiceDetails: Polyline decoded with ${points.length} points');
          
          if (points.isNotEmpty) {
            return Polyline(
              polylineId: const PolylineId('route'),
              points: points,
              color: Colors.blue,
              width: 8, // Increased width for better visibility
              geodesic: true,
              patterns: [PatternItem.dot, PatternItem.gap(10)],
              visible: true, // Ensure visibility
            );
          } else {
            print('⚠️ ServiceDetails: No points in polyline');
          }
        } else {
          print('⚠️ ServiceDetails: API Response error: ${data['status']}');
          if (data['error_message'] != null) {
            print('💬 ServiceDetails: Error message: ${data['error_message']}');
          }
        }
      } else {
        print('❌ ServiceDetails: HTTP error: ${response.statusCode}');
        print('💬 ServiceDetails: Response body: ${response.body}');
      }
    } catch (e) {
      print('❌ ServiceDetails: Error getting route polyline: $e');
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
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.black, size: 24.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.translate('serviceLocation'),
          style: AppTextStyles.blackS18W700,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: AppColors.black, size: 24.sp),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Header Section
            Container(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.service.name,
                          style: AppTextStyles.blackS18W700,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: widget.service.openNow ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          widget.service.openNow ? 'Open Now' : 'Closed',
                          style: AppTextStyles.secondaryS12W400.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.service.address,
                    style: AppTextStyles.secondaryS14W400.copyWith(color: AppColors.gray),
                  ),
                  SizedBox(height: 8.h),
                  // Removed fake location and verification data - using only real API data
                ],
              ),
            ),

            // Distance Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Icon(Icons.directions_car, color: AppColors.gray, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    widget.service.distance != null 
                      ? '${(widget.service.distance! / 1000).toStringAsFixed(1)} ${AppLocalizations.of(context)!.translate('kmAway')}'
                      : '${AppLocalizations.of(context)!.translate('distanceNotAvailable')}',
                    style: AppTextStyles.secondaryS14W400.copyWith(color: AppColors.gray),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () async {
                      final url = widget.service.mapsUrl;
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.send, color: AppColors.white, size: 14.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Get\nDirections',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.secondaryS12W400.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Working Hours Section
            Container(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: AppColors.gray, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(AppLocalizations.of(context)!.translate('workingHours'), style: AppTextStyles.blackS16W600),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Text(
                        widget.service.open24h 
                          ? '24 Hours' 
                          : widget.service.openingText ?? '${widget.service.openFrom ?? 'N/A'} - ${widget.service.openTo ?? 'N/A'}', 
                        style: AppTextStyles.secondaryS14W400.copyWith(color: AppColors.black, fontWeight: FontWeight.w500)
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Contact Section
            Container(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.translate('contact'), style: AppTextStyles.blackS16W600),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final url = widget.service.callUrl;
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url));
                        }
                      },
                      icon: Icon(Icons.phone, color: AppColors.white, size: 18.sp),
                      label: Text(
                        '${AppLocalizations.of(context)!.translate('callNow')}: ${widget.service.phonePrimary}',
                        style: AppTextStyles.secondaryS14W400.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                  // Removed WhatsApp and Chat buttons as requested
                ],
              ),
            ),

            // Map Section
            Container(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, color: AppColors.gray, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(AppLocalizations.of(context)!.translate('location'), style: AppTextStyles.blackS16W600),
                      const Spacer(),
                      if (_isLoadingRoute)
                        SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to full map view
                          context.push('/service-map', extra: widget.service);
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
                                'View Map',
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
                          target: LatLng(widget.service.lat, widget.service.lon),
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
                          print('🗺️ ServiceDetails: Map controller created');
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.service.address,
                    style: AppTextStyles.s14w400.copyWith(color: AppColors.gray),
                  ),
                ],
              ),
            ),

            // Removed Photos Section as requested - no photos in API response

            // About Section
            Container(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.of(context)!.translate('aboutServiceProvider'), style: AppTextStyles.blackS16W600),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Container(
                        width: 50.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: widget.service.type.toLowerCase().contains('station') ? Colors.blue : Colors.green, 
                          shape: BoxShape.circle
                        ),
                        child: Icon(
                          widget.service.type.toLowerCase().contains('station') ? Icons.local_gas_station : Icons.directions_car, 
                          color: AppColors.white, 
                          size: 24.sp
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.service.name, style: AppTextStyles.blackS16W600),
                            SizedBox(height: 4.h),
                            // Removed rating system as requested - no ratings on platform
                            SizedBox(height: 4.h),
                            // Removed fake statistics - not available in API response
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Services Section - Only show if services are available
            if (widget.service.services.isNotEmpty)
              Container(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.translate('servicesAtLocation'), style: AppTextStyles.blackS16W600),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: widget.service.services.map((serviceName) => Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: AppColors.gray.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: AppColors.gray.withOpacity(0.3), width: 1),
                        ),
                        child: Text(
                          serviceName,
                          style: AppTextStyles.secondaryS12W400.copyWith(color: AppColors.gray, fontWeight: FontWeight.w500),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}

class MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gray.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < size.width; i += 30) {
      canvas.drawLine(Offset(i.toDouble(), 0), Offset(i.toDouble(), size.height), paint);
    }
    
    for (int i = 0; i < size.height; i += 30) {
      canvas.drawLine(Offset(0, i.toDouble()), Offset(size.width, i.toDouble()), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
