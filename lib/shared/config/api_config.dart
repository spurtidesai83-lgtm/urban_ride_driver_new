class ApiConfig {
  // Base URL
  static const String baseUrl = 'https://truing-multidentate-julio.ngrok-free.dev'; // TODO: Update with actual base URL
  
  // Gateway prefix
  static const String gatewayPrefix = '/workshop';
  
  // Auth endpoints
  static const String loginEndpoint = '$gatewayPrefix/driver/auth/login';
  static const String resetPasswordEndpoint = '$gatewayPrefix/driver/auth/reset-password';
  static const String validateTokenEndpoint = '$gatewayPrefix/driver/auth/validate-token';
  
  // Driver endpoints
  static const String dashboardEndpoint = '$gatewayPrefix/api/driver/dashboard';
  static const String profileEndpoint = '$gatewayPrefix/api/driver/profile';
  static const String vehicleEndpoint = '$gatewayPrefix/api/driver/vehicle';
  static const String todayScheduleEndpoint = '$gatewayPrefix/api/driver/schdule/today';
  static const String dailyScheduleEndpoint = '$gatewayPrefix/api/driver/schdule/tmrow';
  static const String weeklyScheduleEndpoint = '$gatewayPrefix/api/driver/schdule/weekly';
  static const String clockInEndpoint = '$gatewayPrefix/api/driver/clock-in';
  static const String clockOutEndpoint = '$gatewayPrefix/api/driver/clock-out';
  
  // Wallet endpoints
  static const String walletEndpoint = '$gatewayPrefix/api/driver/wallet';
  static const String walletDailyUpdateEndpoint = '$gatewayPrefix/api/driver/wallet/daily-update';
  static const String walletDailyLogsEndpoint = '$gatewayPrefix/api/driver/wallet/daily-logs';
  static const String walletMonthlyStatementsEndpoint = '$gatewayPrefix/api/driver/wallet/statements';

  // Trip logging endpoints
  static const String startTripEndpoint = '$gatewayPrefix/api/driver/trips/start-trip';
  static const String logTripEndpoint = '$gatewayPrefix/api/driver/trips/log-trips';
  static const String endTripEndpoint = '$gatewayPrefix/api/driver/trips';
  static const String liveTripEndpoint = '$gatewayPrefix/api/driver/trips/live-trip';
  
  // Leave endpoints
  static const String applyLeaveEndpoint = '$gatewayPrefix/api/driver/leave/apply';
  static const String leaveHistoryEndpoint = '$gatewayPrefix/api/driver/leave/history';
  
  // Trip history endpoints
  static const String allTripHistoryEndpoint = '$gatewayPrefix/api/driver/trips/all-trip-history';
  
  // Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static Map<String, String> getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': 'true',
    };
    
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
  
  // Build full URL
  static String buildUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}
