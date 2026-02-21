import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';
import '../../features/leave/data/models/api_leave_model.dart';
import '../../features/leave/data/models/leave_model.dart';

class LeaveApiService {
  // Apply for leave
  Future<ApiLeaveApplicationResponse> applyLeave(LeaveApplication application) async {
    try {
      final token = await StorageService.getToken();
      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.applyLeaveEndpoint));
      
      final response = await http.post(
        url,
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode(application.toJson()),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ApiLeaveApplicationResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to apply leave');
      }
    } catch (e) {
      throw Exception('Failed to apply leave: $e');
    }
  }

  // Get leave history
  Future<ApiLeaveHistoryResponse> getLeaveHistory() async {
    try {
      final token = await StorageService.getToken();
      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.leaveHistoryEndpoint));
      
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(token: token),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ApiLeaveHistoryResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch leave history');
      }
    } catch (e) {
      throw Exception('Failed to get leave history: $e');
    }
  }
}
