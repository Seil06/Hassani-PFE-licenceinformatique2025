class GeoUtils {
  // Parse PostGIS POINT format (e.g., "POINT(2.34 48.85)")
  static Map<String, double> parsePoint(String point) {
    final coords = point.replaceAll('POINT(', '').replaceAll(')', '').split(' ');
    return {
      'longitude': double.parse(coords[0]),
      'latitude': double.parse(coords[1]),
    };
  }

  // Convert coordinates to PostGIS POINT format
  static String toPostgisPoint(double longitude, double latitude) {
    return 'POINT($longitude $latitude)';
  }

  // Convert coordinates to WKT format
  static String toWkt(double longitude, double latitude) {
    return 'POINT($longitude $latitude)';
  }
}