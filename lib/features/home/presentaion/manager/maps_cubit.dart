import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/cubits/optimized_cubit.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/maps_service.dart';
import '../../data/models/service_model.dart';
import 'maps_state.dart';

class MapsCubit extends OptimizedCubit<MapsState> {
  MapsCubit() : super(MapsState.initial());

  void initializeMap(List<ServiceModel> services) async {
    safeEmit(state.copyWith(isLoading: true, services: services));
    
    try {
      // Get user location
      final position = await LocationService.getLocationWithFallback();
      
      // Create markers
      final markers = <Marker>{};
      
      // User location marker
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: LatLng(position.latitude, position.longitude),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Current device location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );

      // Service markers (limit to first 6 for better visibility)
      for (int i = 0; i < services.length && i < 6; i++) {
        final service = services[i];
        final isMechanic = service.type.toLowerCase().contains('mechanic') ||
                          service.name.toLowerCase().contains('garage') ||
                          service.name.toLowerCase().contains('repair');

        markers.add(
          Marker(
            markerId: MarkerId('service_${service.id}'),
            position: LatLng(service.lat, service.lon),
            infoWindow: InfoWindow(
              title: service.name,
              snippet: '${service.address}\n${MapsService.formatDistance(service.distance ?? 0)}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isMechanic ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen
            ),
          ),
        );
      }
      
      safeEmit(state.copyWith(
        userLocation: position,
        markers: markers,
        isLoading: false,
        error: null,
      ));
      
      print('✅ MapsCubit: Map initialized with ${markers.length} markers');
    } catch (e) {
      print('❌ MapsCubit: Error initializing map: $e');
      safeEmit(state.copyWith(
        isLoading: false,
        error: 'Failed to load map: $e',
      ));
    }
  }

  void setMapController(GoogleMapController controller) {
    safeEmit(state.copyWith(mapController: controller));
  }

  void clearError() {
    safeEmit(state.copyWith(error: null));
  }

  void refreshMap() {
    if (state.services.isNotEmpty) {
      initializeMap(state.services);
    }
  }
}