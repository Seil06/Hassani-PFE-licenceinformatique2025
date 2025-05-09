class GeoUtils {
  // Parse PostGIS POINT format (e.g., "POINT(2.34 48.85)")
  static Map<String, double> parsePoint(String point) {
    final coords = point.replaceAll('POINT(', '').replaceAll(')', '').split(' ');
    return {
      'longitude': double.parse(coords[0]),
      'latitude': double.parse(coords[1]),
    };
  }
}