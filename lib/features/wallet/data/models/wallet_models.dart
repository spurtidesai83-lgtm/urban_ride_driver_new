// Wallet Balance Model
class WalletModel {
  final String driverIamUuid;
  final double currentBalance;
  final int srNo;

  WalletModel({
    required this.driverIamUuid,
    required this.currentBalance,
    required this.srNo,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      driverIamUuid: json['driverIamUuid'] as String,
      currentBalance: (json['currentBalance'] as num).toDouble(),
      srNo: json['srNo'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driverIamUuid': driverIamUuid,
      'currentBalance': currentBalance,
      'srNo': srNo,
    };
  }
}

// Wallet Response Model (for both GET wallet and daily update)
class WalletResponse {
  final bool success;
  final WalletModel data;
  final String message;

  WalletResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory WalletResponse.fromJson(Map<String, dynamic> json) {
    return WalletResponse(
      success: json['success'] as bool,
      data: WalletModel.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] as String,
    );
  }
}

// Daily Log Model
class DailyLogModel {
  final int id;
  final String driverId;
  final String date;
  final String kilometersDriven;
  final double calculatedEarnings;

  DailyLogModel({
    required this.id,
    required this.driverId,
    required this.date,
    required this.kilometersDriven,
    required this.calculatedEarnings,
  });

  factory DailyLogModel.fromJson(Map<String, dynamic> json) {
    return DailyLogModel(
      id: json['id'] as int,
      driverId: json['driverId'] as String,
      date: json['date'] as String,
      kilometersDriven: json['kilometersDriven'] as String,
      calculatedEarnings: (json['calculatedEarnings'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'date': date,
      'kilometersDriven': kilometersDriven,
      'calculatedEarnings': calculatedEarnings,
    };
  }
}

// Daily Logs Response Model
class DailyLogsResponse {
  final bool success;
  final List<DailyLogModel> data;
  final String message;

  DailyLogsResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory DailyLogsResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List;
    final logs = dataList.map((item) => DailyLogModel.fromJson(item as Map<String, dynamic>)).toList();
    
    return DailyLogsResponse(
      success: json['success'] as bool,
      data: logs,
      message: json['message'] as String,
    );
  }
}

// Monthly Statement Model
class MonthlyStatementModel {
  final String driverId;
  final int month;
  final int year;
  final double totalMonthlyEarnings;

  MonthlyStatementModel({
    required this.driverId,
    required this.month,
    required this.year,
    required this.totalMonthlyEarnings,
  });

  factory MonthlyStatementModel.fromJson(Map<String, dynamic> json) {
    return MonthlyStatementModel(
      driverId: json['driverId'] as String,
      month: json['month'] as int,
      year: json['year'] as int,
      totalMonthlyEarnings: (json['totalMonthlyEarnings'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'driverId': driverId,
      'month': month,
      'year': year,
      'totalMonthlyEarnings': totalMonthlyEarnings,
    };
  }

  String get monthYear {
    final monthNames = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${monthNames[month]} $year';
  }
}

// Monthly Statements Response Model
class MonthlyStatementsResponse {
  final bool success;
  final List<MonthlyStatementModel> data;
  final String message;

  MonthlyStatementsResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory MonthlyStatementsResponse.fromJson(Map<String, dynamic> json) {
    print('📋 [MonthlyStatements] Parsing response: success=${json['success']}, dataType=${json['data'].runtimeType}, message=${json['message']}');
    
    final dataList = json['data'] as List?;
    
    if (dataList == null) {
      print('⚠️  [MonthlyStatements] Data is null, returning empty list');
      return MonthlyStatementsResponse(
        success: json['success'] as bool? ?? false,
        data: [],
        message: json['message'] as String? ?? '',
      );
    }
    
    print('📋 [MonthlyStatements] Parsing ${dataList.length} statements');
    final statements = dataList
        .map((item) {
          print('📋 [MonthlyStatements]   - Month: ${item['month']}, Year: ${item['year']}, Earnings: ${item['totalMonthlyEarnings']}');
          return MonthlyStatementModel.fromJson(item as Map<String, dynamic>);
        })
        .toList();
    
    print('✅ [MonthlyStatements] Successfully parsed ${statements.length} statements');
    return MonthlyStatementsResponse(
      success: json['success'] as bool? ?? false,
      data: statements,
      message: json['message'] as String? ?? '',
    );
  }
}
