import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';
import '../../features/home/data/models/dashboard_models.dart';
import '../../features/home/data/models/schedule_models.dart';
import '../../features/home/data/models/clock_models.dart';
import '../../features/activity/data/models/live_trip_model.dart';
import '../../features/home/data/models/api_schedule_model.dart';

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
  Future<ApiTodayScheduleResponse> getTodaySchedule() async {
    try {
      final token = await StorageService.getToken();
      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.todayScheduleEndpoint));
      
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(token: token),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ApiTodayScheduleResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch today\'s schedule');
      }
    } catch (e) {
      throw Exception('Failed to get today\'s schedule: $e');
    }
  }

  // Get tomorrow's schedule
  Future<ApiTodayScheduleResponse> getTomorrowSchedule() async {
    try {
      final token = await StorageService.getToken();
      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.dailyScheduleEndpoint));
      
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(token: token),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ApiTodayScheduleResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch tomorrow\'s schedule');
      }
    } catch (e) {
      throw Exception('Failed to get tomorrow\'s schedule: $e');
    }
  }

  // Get weekly/tomorrow's schedule
  Future<ApiWeeklyScheduleResponse> getWeeklySchedule() async {
    try {
      final token = await StorageService.getToken();
      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.weeklyScheduleEndpoint));
      
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(token: token),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ApiWeeklyScheduleResponse.fromJson(jsonData);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch weekly schedule');
      }
    } catch (e) {
      throw Exception('Failed to get weekly schedule: $e');
    }
  }

  Future<LiveTripModel?> getLiveTrip() async {
    try {
      final token = await StorageService.getToken();
      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.liveTripEndpoint));

      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(token: token),
      ).timeout(ApiConfig.connectTimeout);

      if (response.statusCode == 204) {
        return null;
      }

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);

        if (jsonData is Map<String, dynamic>) {
          final rawData = jsonData['data'];
          if (rawData is Map<String, dynamic>) {
            return LiveTripModel.fromJson(rawData);
          }
          return LiveTripModel.fromJson(jsonData);
        }

        return null;
      }

      if (response.statusCode == 404) {
        return null;
      }

      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to fetch live trip');
    } catch (e) {
      if (e.toString().contains('404')) {
        return null;
      }
      throw Exception('Failed to get live trip: $e');
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
