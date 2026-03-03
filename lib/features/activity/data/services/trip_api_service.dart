import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../shared/config/api_config.dart';
import '../../../../shared/services/storage_service.dart';
import '../models/trip_log_models.dart';

class TripApiService {
  Future<TripLogResponse> startTrip(TripLogRequest request) async {
    return _postTripLog(ApiConfig.startTripEndpoint, request);
  }

  Future<TripLogResponse> logTrip(TripLogRequest request) async {
    return _postTripLog(ApiConfig.logTripEndpoint, request);
  }

  Future<TripLogResponse> endTrip(TripLogRequest request) async {
    return _postTripLog(ApiConfig.endTripEndpoint, request);
  }

  Future<TripLogResponse> _postTripLog(String endpoint, TripLogRequest request) async {
    try {
      final token = await StorageService.getToken();
      final url = Uri.parse(ApiConfig.buildUrl(endpoint));

      print('🚗 [TripAPI] POST $endpoint');
      print('🚗 [TripAPI] Request: ${jsonEncode(request.toJson())}');

      final response = await http
          .post(
            url,
            headers: ApiConfig.getHeaders(token: token),
            body: jsonEncode(request.toJson()),
          )
          .timeout(ApiConfig.connectTimeout);

      print('🚗 [TripAPI] Response status: ${response.statusCode}');
      print('🚗 [TripAPI] Response body: ${response.body}');

      final jsonData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return TripLogResponse.fromJson(jsonData);
      }

      if (response.statusCode == 409) {
        final message = (jsonData['message'] ?? '').toString();
        if (_isIdempotentConflict(message)) {
          return TripLogResponse(
            success: true,
            message: message.isNotEmpty
                ? message
                : 'Trip event already processed',
          );
        }

        return TripLogResponse(
          success: false,
          message: message.isNotEmpty
              ? message
              : 'Trip log request failed (409)',
        );
      }

      // Return error response instead of throwing
      return TripLogResponse(
        success: false,
        message: jsonData['message'] ?? 'Trip log request failed (${response.statusCode})',
      );
    } catch (e) {
      print('❌ [TripAPI] Error: $e');
      // Return error response instead of throwing
      return TripLogResponse(
        success: false,
        message: 'Trip log request failed: $e',
      );
    }
  }

  bool _isIdempotentConflict(String message) {
    final text = message.toLowerCase();
    return text.contains('already') ||
        text.contains('duplicate') ||
        text.contains('exists') ||
        text.contains('processed');
  }
}
