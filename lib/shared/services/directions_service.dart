import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsService {
  static const String _apiKey = 'AIzaSyCK77sKlnN0GeBxTekWup4_oFj7xBH6ioI';
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json';

  // Fetch driving directions with road-following polyline
  Future<List<LatLng>> getDirections({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    if (kIsWeb) {
      print('🌐 Web detected: skipping Directions REST call to avoid CORS; using straight-line route');
      return _fallbackStraightLine(originLat, originLng, destLat, destLng);
    }

    try {
      final url = Uri.parse(
        '$_baseUrl?origin=$originLat,$originLng&destination=$destLat,$destLng&mode=driving&key=$_apiKey',
      );

      print('🗺️ Fetching directions from ($originLat, $originLng) to ($destLat, $destLng)');
      
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final polylinePoints = data['routes'][0]['overview_polyline']['points'];
          final decodedPoints = _decodePolyline(polylinePoints);
          
          print('✅ Decoded ${decodedPoints.length} points for route');
          return decodedPoints;
        } else {
          print('❌ Directions API error: ${data['status']}');
          return _fallbackStraightLine(originLat, originLng, destLat, destLng);
        }
      } else {
        print('❌ HTTP error: ${response.statusCode}');
        return _fallbackStraightLine(originLat, originLng, destLat, destLng);
      }
    } catch (e) {
      print('❌ Error fetching directions: $e');
      return _fallbackStraightLine(originLat, originLng, destLat, destLng);
    }
  }

  // Decode Google's encoded polyline format
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
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

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  // Fallback to straight line if API fails
  List<LatLng> _fallbackStraightLine(double lat1, double lng1, double lat2, double lng2) {
    print('⚠️ Using fallback straight line');
    return [
      LatLng(lat1, lng1),
      LatLng(lat2, lng2),
    ];
  }
}
