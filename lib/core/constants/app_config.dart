class AppConfig {
  AppConfig._();
  
  // Google Maps API Configuration
  static const String googleMapsApiKey = 'AIzaSyCvFo9bVexv1f4O4lzdYqjPH7b-yf62k_c';
  
  // Maps URLs
  static const String googleMapsGeocodeUrl = 'https://maps.googleapis.com/maps/api/geocode/json';
  static const String googleMapsDirectionsUrl = 'https://maps.googleapis.com/maps/api/directions/json';
  static const String googleMapsStaticMapUrl = 'https://maps.googleapis.com/maps/api/staticmap';
  
  // Default map location (Dubai)
  static const double defaultLatitude = 25.2048;
  static const double defaultLongitude = 55.2708;
  
  // Map configuration
  static const double defaultZoom = 15.0;
  static const int staticMapSize = 400;
}