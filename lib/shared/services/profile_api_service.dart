import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';
import '../../features/profile/data/models/api_profile_model.dart';

class ProfileApiService {
  // Get driver profile
  Future<ApiProfileResponse> getProfile() async {
    try {
      final token = await StorageService.getToken();
      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.profileEndpoint));
      
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(token: token),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ApiProfileResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      throw Exception('Failed to get profile: $e');
    }
  }
}
