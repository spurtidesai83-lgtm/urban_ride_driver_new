import '../models/wallet_models.dart';
import '../services/wallet_api_service.dart';

class WalletRepository {
  final WalletApiService _apiService = WalletApiService();

  // Get wallet balance
  Future<WalletModel> getWallet() async {
    try {
      return await _apiService.getWallet();
    } catch (e) {
      rethrow;
    }
  }

  // Update daily wallet
  Future<WalletResponse> updateDailyWallet(double kilometers) async {
    try {
      return await _apiService.updateDailyWallet(kilometers);
    } catch (e) {
      rethrow;
    }
  }

  // Get daily logs for current month
  Future<DailyLogsResponse> getDailyLogs() async {
    try {
      return await _apiService.getDailyLogs();
    } catch (e) {
      rethrow;
    }
  }

  // Get all monthly statements
  Future<MonthlyStatementsResponse> getMonthlyStatements() async {
    try {
      return await _apiService.getMonthlyStatements();
    } catch (e) {
      rethrow;
    }
  }
}
