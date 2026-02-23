import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';
import '../../features/profile/data/models/api_trip_history_model.dart';

class TripHistoryApiService {
  /// Fetch all trip history for the driver
  Future<ApiTripHistoryResponse> getAllTripHistory() async {
    try {
      final token = await StorageService.getToken();
      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.allTripHistoryEndpoint));

      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(token: token),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ApiTripHistoryResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch trip history');
      }
    } catch (e) {
      throw Exception('Failed to get trip history: $e');
    }
  }
}
