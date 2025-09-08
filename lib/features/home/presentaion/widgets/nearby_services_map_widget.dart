import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/services/location_service.dart';
import '../../data/models/service_model.dart';

class NearbyServicesMapWidget extends StatefulWidget {
  final List<ServiceModel> services;

  const NearbyServicesMapWidget({
    super.key,
    required this.services,
  });

  @override
  State<NearbyServicesMapWidget> createState() => _NearbyServicesMapWidgetState();
}

class _NearbyServicesMapWidgetState extends State<NearbyServicesMapWidget> {
  GoogleMapController? _mapController;
  Position? _userLocation;
  Set<Marker> _markers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      // Get user location
      final position = await LocationService.getLocationWithFallback();
      setState(() {
        _userLocation = position;
        _isLoading = false;
      });

      // Add markers
      _addMarkers();
    } catch (e) {
      print('❌ Error initializing map: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _addMarkers() {
    if (_userLocation == null) return;

    // User location marker
    _markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(_userLocation!.latitude, _userLocation!.longitude),
        infoWindow: const InfoWindow(
          title: 'موقعك الحالي',
          snippet: 'موقع الجهاز',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

    // Service markers (limit to first 6 for better visibility)
    for (int i = 0; i < widget.services.length && i < 6; i++) {
      final service = widget.services[i];
      final isMechanic = service.type.toLowerCase().contains('mechanic') ||
                        service.name.toLowerCase().contains('garage') ||
                        service.name.toLowerCase().contains('repair');

      _markers.add(
        Marker(
          markerId: MarkerId('service_${service.id}'),
          position: LatLng(service.lat, service.lon),
          infoWindow: InfoWindow(
            title: service.name,
            snippet: service.address,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isMechanic ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: _isLoading
            ? Container(
                color: AppColors.gray.withOpacity(0.1),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                initialCameraPosition: CameraPosition(
                  target: _userLocation != null
                      ? LatLng(_userLocation!.latitude, _userLocation!.longitude)
                      : const LatLng(25.2048, 55.2708), // Dubai fallback
                  zoom: 12.0,
                ),
                markers: _markers,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                liteModeEnabled: true,
              ),
      ),
    );
  }

  Widget _buildMapBackground() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: CustomPaint(
          painter: MapBackgroundPainter(),
          size: Size.infinite,
        ),
      ),
    );
  }

  Widget _buildUserLocationMarker() {
    return Positioned(
      left: 0.5.sw - 8.w,
      top: 0.5.sh - 8.h,
      child: Column(
        children: [
          // Location dot
          Container(
            width: 16.w,
            height: 16.h,   
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white,
                width: 2,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          // "Your Location" text
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'Your Location',
              style: AppTextStyles.secondaryS12W400.copyWith(
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildServiceMarkers() {
    List<Widget> markers = [];
    
    // Add service markers around user location
    for (int i = 0; i < widget.services.length && i < 6; i++) {
      final service = widget.services[i];
      final isMechanic = service.type.toLowerCase().contains('mechanic') ||
                        service.name.toLowerCase().contains('garage') ||
                        service.name.toLowerCase().contains('repair');
      
      // Position markers around user location
      double angle = (i * 60) * (3.14159 / 180); // Convert to radians
      double distance = 60.w + (i * 10.w); // Vary distance
      
      double left = 0.5.sw + (distance * cos(angle)) - 12.w;
      double top = 0.5.sh + (distance * sin(angle)) - 12.h;
      
      // Ensure markers stay within bounds
      left = left.clamp(16.w, 1.sw - 40.w);
      top = top.clamp(16.h, 200.h - 40.h);
      
      markers.add(
        Positioned(
          left: left,
          top: top,
          child: Container(
            width: 24.w,
            height: 24.h,
            decoration: BoxDecoration(
              color: isMechanic ? Colors.red : Colors.blue,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: AppColors.white,
                width: 2,
              ),
            ),
            child: Icon(
              isMechanic ? Icons.build : Icons.local_gas_station,
              color: AppColors.white,
              size: 14.sp,
            ),
          ),
        ),
      );
    }
    
    return markers;
  }
}

class MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gray.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw grid lines
    for (int i = 0; i < size.width; i += 30) {
      canvas.drawLine(
        Offset(i.toDouble(), 0),
        Offset(i.toDouble(), size.height),
        paint,
      );
    }
    
    for (int i = 0; i < size.height; i += 30) {
      canvas.drawLine(
        Offset(0, i.toDouble()),
        Offset(size.width, i.toDouble()),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
