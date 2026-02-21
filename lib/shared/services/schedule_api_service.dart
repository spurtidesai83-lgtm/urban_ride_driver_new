import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';
import '../../features/home/data/models/dashboard_models.dart';
import '../../features/home/data/models/schedule_models.dart';
import '../../features/home/data/models/clock_models.dart';

class ScheduleApiService {
  // Get dashboard data
  Future<DashboardResponse> getDashboard() async {
    try {
      final token = await StorageService.getToken();
      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.dashboardEndpoint));
      
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(token: token),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return DashboardResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch dashboard');
      }
    } catch (e) {
      throw Exception('Failed to get dashboard: $e');
    }
  }

  // Get today's schedule
  Future<ScheduleResponse> getTodaySchedule() async {
    try {
      final token = await StorageService.getToken();
      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.todayScheduleEndpoint));
      
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(token: token),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ScheduleResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch today\'s schedule');
      }
    } catch (e) {
      throw Exception('Failed to get today\'s schedule: $e');
    }
  }

  // Get weekly/tomorrow's schedule
  Future<WeeklyScheduleResponse> getWeeklySchedule() async {
    try {
      final token = await StorageService.getToken();
      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.weeklyScheduleEndpoint));
      
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(token: token),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return WeeklyScheduleResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch weekly schedule');
      }
    } catch (e) {
      throw Exception('Failed to get weekly schedule: $e');
    }
  }

  // Clock In
  Future<ClockResponse> clockIn(ClockInRequest request) async {
    try {
      final token = await StorageService.getToken();
      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.clockInEndpoint));
      final body = request.toJson();
      
      print('🚀 [ClockInAPI] URL: $url');
      print('🚀 [ClockInAPI] Body: $body');
      
      final response = await http.post(
        url,
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode(body),
      ).timeout(ApiConfig.connectTimeout);

      final jsonData = jsonDecode(response.body);
      print('🚀 [ClockInAPI] Response: $jsonData');
      
      if (response.statusCode == 200) {
        return ClockResponse.fromJson(jsonData);
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to clock in');
      }
    } catch (e) {
      throw Exception('Failed to clock in: $e');
    }
  }

  // Clock Out
  Future<ClockResponse> clockOut(ClockOutRequest request) async {
    try {
      final token = await StorageService.getToken();
      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.clockOutEndpoint));
      
      final response = await http.post(
        url,
        headers: ApiConfig.getHeaders(token: token),
        body: jsonEncode(request.toJson()),
      ).timeout(ApiConfig.connectTimeout);

      final jsonData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return ClockResponse.fromJson(jsonData);
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to clock out');
      }
    } catch (e) {
      throw Exception('Failed to clock out: $e');
    }
  }
}
