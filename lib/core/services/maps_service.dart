import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../constants/app_config.dart';
import '../network/failure.dart';
import 'location_service.dart';

class MapsService {
  static final Dio _dio = Dio();

  /// Get coordinates from address using Google Geocoding API
  static Future<Either<Failure, LatLng>> getCoordinatesFromAddress(String address) async {
    try {
      final encodedAddress = Uri.encodeComponent(address);
      final url = '${AppConfig.googleMapsGeocodeUrl}?address=$encodedAddress&key=${AppConfig.googleMapsApiKey}';
      
      print('🗺️ MapsService: Getting coordinates for address: $address');
      
      final response = await _dio.get(url);
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          final lat = location['lat'] as double;
          final lng = location['lng'] as double;
          
          print('✅ MapsService: Got coordinates: $lat, $lng');
          return Right(LatLng(lat, lng));
        } else {
          print('❌ MapsService: No results found for address: $address');
          return Left(Failure('No location found for the given address'));
        }
      } else {
        print('❌ MapsService: Geocoding API error: ${response.statusCode}');
        return Left(Failure('Failed to get location coordinates'));
      }
    } catch (e) {
      print('❌ MapsService: Exception in getCoordinatesFromAddress: $e');
      return Left(Failure('Error getting location coordinates: $e'));
    }
  }

  /// Get route between two points using Google Directions API
  static Future<Either<Failure, Map<String, dynamic>>> getRoute({
    required LatLng origin,
    required LatLng destination,
    String travelMode = 'driving',
  }) async {
    try {
      final url = '${AppConfig.googleMapsDirectionsUrl}?'
          'origin=${origin.latitude},${origin.longitude}&'
          'destination=${destination.latitude},${destination.longitude}&'
          'mode=$travelMode&'
          'key=${AppConfig.googleMapsApiKey}';
      
      print('🗺️ MapsService: Getting route from ${origin.latitude},${origin.longitude} to ${destination.latitude},${destination.longitude}');
      
      final response = await _dio.get(url);
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final leg = route['legs'][0];
          
          final routeInfo = {
            'distance': leg['distance']['text'],
            'duration': leg['duration']['text'],
            'steps': leg['steps'],
            'polyline': route['overview_polyline']['points'],
            'bounds': route['bounds'],
          };
          
          print('✅ MapsService: Route found - Distance: ${routeInfo['distance']}, Duration: ${routeInfo['duration']}');
          return Right(routeInfo);
        } else {
          print('❌ MapsService: No route found. Status: ${data['status']}');
          return Left(Failure('No route found between the locations'));
        }
      } else {
        print('❌ MapsService: Directions API error: ${response.statusCode}');
        return Left(Failure('Failed to get route information'));
      }
    } catch (e) {
      print('❌ MapsService: Exception in getRoute: $e');
      return Left(Failure('Error getting route information: $e'));
    }
  }

  /// Get route to nearest service from current location
  static Future<Either<Failure, Map<String, dynamic>>> getRouteToNearestService({
    required String serviceAddress,
    String travelMode = 'driving',
  }) async {
    try {
      // Get current location
      final currentLocationResult = await LocationService.getLocationWithFallback();
      final currentLocation = LatLng(currentLocationResult.latitude, currentLocationResult.longitude);
      
      // Get service coordinates
      final serviceCoordinatesResult = await getCoordinatesFromAddress(serviceAddress);
      
      return serviceCoordinatesResult.fold(
        (failure) => Left(failure),
        (serviceLocation) async {
          // Get route between current location and service
          return await getRoute(
            origin: currentLocation,
            destination: serviceLocation,
            travelMode: travelMode,
          );
        },
      );
    } catch (e) {
      print('❌ MapsService: Exception in getRouteToNearestService: $e');
      return Left(Failure('Error getting route to service: $e'));
    }
  }

  /// Generate static map URL
  static String generateStaticMapUrl({
    required LatLng center,
    double zoom = 15,
    int size = 400,
    List<LatLng> markers = const [],
  }) {
    var url = '${AppConfig.googleMapsStaticMapUrl}?'
        'center=${center.latitude},${center.longitude}&'
        'zoom=${zoom.toInt()}&'
        'size=${size}x${size}&'
        'key=${AppConfig.googleMapsApiKey}';
    
    // Add markers
    for (int i = 0; i < markers.length; i++) {
      final marker = markers[i];
      final label = String.fromCharCode(65 + i); // A, B, C, etc.
      url += '&markers=color:red%7Clabel:$label%7C${marker.latitude},${marker.longitude}';
    }
    
    return url;
  }

  /// Calculate distance between two points
  static double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  /// Format distance for display
  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toInt()} m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  /// Check if Google Maps API key is valid
  static Future<bool> validateApiKey() async {
    try {
      final url = '${AppConfig.googleMapsGeocodeUrl}?address=Dubai&key=${AppConfig.googleMapsApiKey}';
      final response = await _dio.get(url);
      
      if (response.statusCode == 200) {
        final data = response.data;
        return data['status'] == 'OK';
      }
      return false;
    } catch (e) {
      print('❌ MapsService: API key validation failed: $e');
      return false;
    }
  }
}