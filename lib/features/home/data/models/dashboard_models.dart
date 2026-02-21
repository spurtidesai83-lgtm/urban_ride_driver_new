import 'schedule_models.dart';

// Dashboard Response Model
class DashboardResponse {
  final bool success;
  final DashboardData data;
  final String message;

  DashboardResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['success'] ?? false,
      data: DashboardData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
      'message': message,
    };
  }
}

class DashboardData {
  final bool isClockedIn;
  final Map<String, List<ScheduleItemModel>> schedule;
  final int noOfTrips;
  final String steeringTime;
  final int totalKms;

  DashboardData({
    required this.isClockedIn,
    required this.schedule,
    required this.noOfTrips,
    required this.steeringTime,
    required this.totalKms,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final scheduleMap = <String, List<ScheduleItemModel>>{};
    final schedule = json['schedule'] as Map<String, dynamic>? ?? {};
    
    print('📋 [DashboardData] Parsing schedule with ${schedule.length} duty sets');
    
    schedule.forEach((key, value) {
      if (value is List) {
        print('📋 [DashboardData]   Duty "$key": ${value.length} items');
        scheduleMap[key] = value
            .map((item) {
              return ScheduleItemModel.fromJson(item);
            })
            .toList();
      }
    });

    print('📋 [DashboardData] Parsed schedule with ${scheduleMap.length} duty sets');
    return DashboardData(
      isClockedIn: json['isClockedIn'] ?? false,
      schedule: scheduleMap,
      noOfTrips: json['noOfTrips'] ?? 0,
      steeringTime: json['steeringTime'] ?? '',
      totalKms: json['totalKms'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final scheduleMap = <String, dynamic>{};
    schedule.forEach((key, value) {
      scheduleMap[key] = value.map((item) => item.toJson()).toList();
    });

    return {
      'isClockedIn': isClockedIn,
      'schedule': scheduleMap,
      'noOfTrips': noOfTrips,
      'steeringTime': steeringTime,
      'totalKms': totalKms,
    };
  }
}
