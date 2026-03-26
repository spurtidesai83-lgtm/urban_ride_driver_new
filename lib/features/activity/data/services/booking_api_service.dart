import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../shared/config/api_config.dart';
import '../../../../shared/services/storage_service.dart';
import '../models/booking_model.dart';

class BookingApiService {
  Future<BookingResponse?> getBookings({
    required String routeNo,
    required String pickup,
    required String from,
    required String to,
    required String travelDate,
  }) async {
    try {
      final token = await StorageService.getToken();
      final queryParameters = {
        'routeNo': routeNo,
        'pickup': pickup,
        'from': from,
        'to': to,
        'travelDate': travelDate,
      };

      final uri = Uri.parse(ApiConfig.buildUrl(ApiConfig.bookingsEndpoint))
          .replace(queryParameters: queryParameters);

      print('🚗 [BookingAPI] GET ${uri.toString()}');

      final response = await http
          .get(
            uri,
            headers: ApiConfig.getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('🚗 [BookingAPI] Response status: ${response.statusCode}');
      print('🚗 [BookingAPI] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return BookingResponse.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      print('❌ [BookingAPI] Error: $e');
      return null;
    }
  }

  Future<StopCountResponse?> getStopPassengerCounts({
    required String routeNo,
    required String from,
    required String to,
    required String travelDate,
  }) async {
    try {
      final token = await StorageService.getToken();
      final queryParameters = {
        'routeNo': routeNo,
        'from': from,
        'to': to,
        'travelDate': travelDate,
      };

      final uri = Uri.parse(ApiConfig.buildUrl(ApiConfig.bookingStopCountEndpoint))
          .replace(queryParameters: queryParameters);

      print('🚗 [BookingAPI] GET Stop Counts: ${uri.toString()}');

      final response = await http
          .get(
            uri,
            headers: ApiConfig.getHeaders(token: token),
          )
          .timeout(ApiConfig.connectTimeout);

      print('🚗 [BookingAPI] Response status: ${response.statusCode}');
      print('🚗 [BookingAPI] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return StopCountResponse.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      print('❌ [BookingAPI] Error: $e');
      return null;
    }
  }
}
