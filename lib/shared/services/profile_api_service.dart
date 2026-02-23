import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
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

  Future<ApiProfileData> uploadProfilePicture(XFile imageFile) async {
    try {
      final token = await StorageService.getToken();
      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.profileEndpoint));

      final request = http.MultipartRequest('PATCH', url)
        ..headers.addAll({
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        });

      final imageBytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'profilePicture',
          imageBytes,
          filename: imageFile.name.isNotEmpty ? imageFile.name : 'profile_picture.jpg',
        ),
      );

      final streamedResponse = await request.send().timeout(ApiConfig.connectTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final jsonData = jsonDecode(response.body);
        final data = jsonData['data'];

        if (data is Map<String, dynamic>) {
          return ApiProfileData.fromJson(data);
        }

        throw Exception('Invalid profile response received after upload');
      }

      Map<String, dynamic>? errorData;
      try {
        errorData = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        errorData = null;
      }

      throw Exception(errorData?['message'] ?? 'Failed to upload profile picture');
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }
}
