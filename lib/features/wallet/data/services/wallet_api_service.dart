import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../shared/config/api_config.dart';
import '../../../../shared/services/storage_service.dart';
import '../models/wallet_models.dart';

class WalletApiService {
  // Get wallet balance
  Future<WalletModel> getWallet() async {
    try {
      final token = await StorageService.getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token available');
      }
      
      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.walletEndpoint));
      final headers = ApiConfig.getHeaders(token: token);
      
      final response = await http.get(
        url,
        headers: headers,
      ).timeout(ApiConfig.connectTimeout);

      final jsonData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        final walletResponse = WalletResponse.fromJson(jsonData);
        return walletResponse.data;
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to fetch wallet');
      }
    } catch (e) {
      throw Exception('Failed to get wallet: $e');
    }
  }

  // Update daily wallet with kilometers
  Future<WalletResponse> updateDailyWallet(double kilometers) async {
    try {
      final token = await StorageService.getToken();
      final url = Uri.parse(
        '${ApiConfig.buildUrl(ApiConfig.walletDailyUpdateEndpoint)}?kilometers=$kilometers'
      );
      
      print('💰 [WalletAPI] GET ${url.toString()}');
      
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(token: token),
      ).timeout(ApiConfig.connectTimeout);

      print('💰 [WalletAPI] Daily update response status: ${response.statusCode}');
      final jsonData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        print('💰 [WalletAPI] Daily update response: $jsonData');
        return WalletResponse.fromJson(jsonData);
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to update daily wallet');
      }
    } catch (e) {
      print('❌ [WalletAPI] Daily update error: $e');
      throw Exception('Failed to update daily wallet: $e');
    }
  }

  // Get daily logs for current month
  Future<DailyLogsResponse> getDailyLogs() async {
    try {
      final token = await StorageService.getToken();
      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.walletDailyLogsEndpoint));
      
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(token: token),
      ).timeout(ApiConfig.connectTimeout);

      final jsonData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return DailyLogsResponse.fromJson(jsonData);
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to fetch daily logs');
      }
    } catch (e) {
      throw Exception('Failed to get daily logs: $e');
    }
  }

  // Get all monthly statements
  Future<MonthlyStatementsResponse> getMonthlyStatements() async {
    try {
      final token = await StorageService.getToken();
      final url = Uri.parse(ApiConfig.buildUrl(ApiConfig.walletMonthlyStatementsEndpoint));
      
      print('💰 [WalletAPI] GET ${url.toString()}');
      
      final response = await http.get(
        url,
        headers: ApiConfig.getHeaders(token: token),
      ).timeout(ApiConfig.connectTimeout);

      print('💰 [WalletAPI] Monthly statements response status: ${response.statusCode}');
      final jsonData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        print('💰 [WalletAPI] Monthly statements: $jsonData');
        return MonthlyStatementsResponse.fromJson(jsonData);
      } else {
        throw Exception(jsonData['message'] ?? 'Failed to fetch monthly statements');
      }
    } catch (e) {
      print('❌ [WalletAPI] Monthly statements error: $e');
      throw Exception('Failed to get monthly statements: $e');
    }
  }
}
