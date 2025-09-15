import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/service_model.dart';

class MapsState {
  final Position? userLocation;
  final Set<Marker> markers;
  final bool isLoading;
  final String? error;
  final GoogleMapController? mapController;
  final List<ServiceModel> services;

  const MapsState({
    this.userLocation,
    this.markers = const {},
    this.isLoading = false,
    this.error,
    this.mapController,
    this.services = const [],
  });

  factory MapsState.initial() {
    return const MapsState();
  }

  MapsState copyWith({
    Position? userLocation,
    Set<Marker>? markers,
    bool? isLoading,
    String? error,
    GoogleMapController? mapController,
    List<ServiceModel>? services,
  }) {
    return MapsState(
      userLocation: userLocation ?? this.userLocation,
      markers: markers ?? this.markers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      mapController: mapController ?? this.mapController,
      services: services ?? this.services,
    );
  }
}