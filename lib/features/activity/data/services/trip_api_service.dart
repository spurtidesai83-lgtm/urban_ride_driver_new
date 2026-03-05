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

      final jsonData = _decodeBody(response.body);
      final message = _extractMessage(jsonData, fallback: response.body);

      if (response.statusCode == 200) {
        if (jsonData is Map<String, dynamic>) {
          return TripLogResponse.fromJson(jsonData);
        }

        return TripLogResponse(
          success: true,
          message: message.isNotEmpty ? message : 'Trip event logged successfully',
        );
      }

      if (response.statusCode == 409) {
        final isLogTripEndpoint = endpoint == ApiConfig.logTripEndpoint;
        if (isLogTripEndpoint || _isIdempotentConflict(message)) {
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
        message: message.isNotEmpty
            ? message
            : 'Trip log request failed (${response.statusCode})',
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
        text.contains('processed') ||
        text.contains('conflict') ||
        text.contains('same checkpoint') ||
        text.contains('already logged');
  }

  dynamic _decodeBody(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String _extractMessage(dynamic jsonData, {String fallback = ''}) {
    if (jsonData is Map<String, dynamic>) {
      final message = jsonData['message'] ?? jsonData['error'] ?? jsonData['details'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString().trim();
      }
    }

    return fallback.trim();
  }
}
