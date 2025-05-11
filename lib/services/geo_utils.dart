import 'dart:typed_data';
import 'package:convert/convert.dart';

class GeoUtils {
  /// Improved PostGIS point parser
  static Map<String, double> parsePoint(dynamic pointData) {
    try {
      if (pointData == null) return {'latitude': 0.0, 'longitude': 0.0};
      
      final String pointStr = pointData.toString();
      
      // Handle HEX-encoded EWKB (common in PostGIS)
      if (pointStr.startsWith('01010000')) {
        final hexString = pointStr.substring(8);
        final bytes = Uint8List.fromList(hex.decode(hexString));
        final byteData = ByteData.view(bytes.buffer);
        
        // EWKB format: byte order (1 byte) + type (4 bytes) + X (8 bytes) + Y (8 bytes)
        final x = byteData.getFloat64(5, Endian.little);
        final y = byteData.getFloat64(13, Endian.little);
        return {'longitude': x, 'latitude': y};
      }

      // Handle text format POINT(lon lat)
      final pointPattern = RegExp(r'POINT\(([-\d\.]+) ([-\d\.]+)\)');
      final match = pointPattern.firstMatch(pointStr);
      if (match != null) {
        return {
          'longitude': double.parse(match.group(1)!),
          'latitude': double.parse(match.group(2)!)
        };
      }

      // Fallback to comma-separated values
      final coords = pointStr.split(',');
      if (coords.length == 2) {
        return {
          'longitude': double.parse(coords[0]),
          'latitude': double.parse(coords[1])
        };
      }

      throw FormatException('Unsupported point format');
    } catch (e) {
      print('Error parsing point: $e');
      return {'latitude': 0.0, 'longitude': 0.0};
    }
  }

  /// Converts latitude and longitude to a string representation
  static String pointToString(double latitude, double longitude) {
    return 'POINT($longitude $latitude)';
  }
}