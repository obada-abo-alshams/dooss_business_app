import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/app_config.dart';

class LocationService {
  static Future<bool> requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('❌ LocationService: Location services are disabled');
        return false;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        print('🔍 LocationService: Requesting permission...');
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ LocationService: Permission denied');
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ LocationService: Permission denied forever');
        return false;
      }

      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        print('✅ LocationService: Permission granted');
        return true;
      }

      return false;
    } catch (e) {
      print('❌ LocationService Error requesting permission: $e');
      return false;
    }
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      print('🔍 LocationService: Requesting location permission...');
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        print('❌ LocationService: Permission denied');
        return null;
      }

      print('✅ LocationService: Permission granted, getting current position...');
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium, // Use medium accuracy for faster response
        timeLimit: Duration(seconds: 5), // Reduce timeout
      );

      print('📍 LocationService: Position obtained - lat: ${position.latitude}, lon: ${position.longitude}');
      return position;
    } catch (e) {
      print('❌ LocationService Error getting location: $e');
      
      // Handle specific plugin errors
      if (e.toString().contains('MissingPluginException')) {
        print('❌ LocationService: Plugin not properly configured');
      } else if (e.toString().contains('PermissionDenied')) {
        print('❌ LocationService: Permission denied by user');
      } else if (e.toString().contains('LocationServiceDisabled')) {
        print('❌ LocationService: Location service is disabled');
      }
      
      return null;
    }
  }

  static Future<double> calculateDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) async {
    try {
      // First try to get route distance using Google Directions API
      final routeDistance = await _getRouteDistance(
        startLatitude: startLatitude,
        startLongitude: startLongitude,
        endLatitude: endLatitude,
        endLongitude: endLongitude,
      );
      
      if (routeDistance > 0) {
        return routeDistance;
      }
      
      // Fallback to straight line distance
      double distanceInMeters = Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );

      return distanceInMeters;
    } catch (e) {
      print('Error calculating distance: $e');
      return 0.0;
    }
  }

  // Get route distance using Google Directions API
  static Future<double> _getRouteDistance({
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) async {
    try {
      // Use Google Directions API to get real road distance
      final url = 'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=$startLatitude,$startLongitude&'
          'destination=$endLatitude,$endLongitude&'
          'key=${AppConfig.googleMapsApiKey}';
      
      print('🗺️ Requesting route from Google Directions API...');
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final legs = route['legs'];
          
          if (legs.isNotEmpty) {
            final distance = legs[0]['distance']['value']; // Distance in meters
            print('✅ Real road distance: ${distance}m');
            return distance.toDouble();
          }
        } else {
          print('⚠️ Google Directions API error: ${data['status']}');
        }
      } else {
        print('❌ HTTP error: ${response.statusCode}');
      }
      
      // Fallback to approximated road distance
      double straightLineDistance = Geolocator.distanceBetween(
        startLatitude,
        startLongitude,
        endLatitude,
        endLongitude,
      );
      
      // Apply a factor to approximate road distance
      double roadDistance = straightLineDistance * 1.3;
      print('📍 Fallback: Approximated road distance: ${roadDistance.toStringAsFixed(0)}m');
      return roadDistance;
    } catch (e) {
      print('Error getting route distance: $e');
      return 0.0;
    }
  }

  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      double distanceInKm = distanceInMeters / 1000;
      return '${distanceInKm.toStringAsFixed(1)} km';
    }
  }

  // Fallback location for UAE (Dubai coordinates)
  static Position getDefaultLocation() {
    return Position(
      longitude: 55.2708,
      latitude: 25.2048,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      headingAccuracy: 0,
    );
  }

  // Get location with fallback
  static Future<Position> getLocationWithFallback() async {
    try {
      final position = await getCurrentLocation();
      if (position != null) {
        return position;
      } else {
        print('🔄 LocationService: Using fallback location (Dubai)');
        return getDefaultLocation();
      }
    } catch (e) {
      print('🔄 LocationService: Error occurred, using fallback location (Dubai)');
      return getDefaultLocation();
    }
  }
}
