import 'leave_model.dart';

// API Leave Application Response Model
class ApiLeaveApplicationResponse {
  final bool success;
  final ApiLeaveApplicationData data;
  final String message;

  ApiLeaveApplicationResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ApiLeaveApplicationResponse.fromJson(Map<String, dynamic> json) {
    return ApiLeaveApplicationResponse(
      success: json['success'] ?? false,
      data: ApiLeaveApplicationData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class ApiLeaveApplicationData {
  final String message;
  final String success;

  ApiLeaveApplicationData({
    required this.message,
    required this.success,
  });

  factory ApiLeaveApplicationData.fromJson(Map<String, dynamic> json) {
    return ApiLeaveApplicationData(
      message: json['message'] ?? '',
      success: json['success'] ?? '',
    );
  }
}

// API Leave History Response Model
class ApiLeaveHistoryResponse {
  final bool success;
  final ApiLeaveHistoryData data;
  final String message;

  ApiLeaveHistoryResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ApiLeaveHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ApiLeaveHistoryResponse(
      success: json['success'] ?? false,
      data: ApiLeaveHistoryData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class ApiLeaveHistoryData {
  final List<ApiLeaveRecord> leaveHistoryList;

  ApiLeaveHistoryData({
    required this.leaveHistoryList,
  });

  factory ApiLeaveHistoryData.fromJson(Map<String, dynamic> json) {
    List<ApiLeaveRecord> leaves = [];
    if (json['leaveHistoryList'] != null) {
      leaves = (json['leaveHistoryList'] as List)
          .map((item) => ApiLeaveRecord.fromJson(item))
          .toList();
    }
    return ApiLeaveHistoryData(leaveHistoryList: leaves);
  }

  // Convert to UI models
  List<LeaveRecord> toLeaveRecords() {
    return leaveHistoryList.map((record) => record.toLeaveRecord()).toList();
  }
}

class ApiLeaveRecord {
  final String driverUUID;
  final String driverName;
  final String leaveFrom;
  final String leaveTo;
  final String reason;
  final String status;
  final String? handlerRemark;

  ApiLeaveRecord({
    required this.driverUUID,
    required this.driverName,
    required this.leaveFrom,
    required this.leaveTo,
    required this.reason,
    required this.status,
    this.handlerRemark,
  });

  factory ApiLeaveRecord.fromJson(Map<String, dynamic> json) {
    return ApiLeaveRecord(
      driverUUID: json['driverUUID'] ?? '',
      driverName: json['driverName'] ?? '',
      leaveFrom: json['leaveFrom'] ?? '',
      leaveTo: json['leaveTo'] ?? '',
      reason: json['reason'] ?? '',
      status: json['status'] ?? '',
      handlerRemark: json['handlerRemark'],
    );
  }

  // Convert API model to UI model
  LeaveRecord toLeaveRecord() {
    return LeaveRecord(
      driverUUID: driverUUID,
      driverName: driverName,
      leaveFrom: _parseDate(leaveFrom),
      leaveTo: _parseDate(leaveTo),
      reason: reason,
      status: LeaveStatusExtension.fromString(status),
      handlerRemark: handlerRemark,
    );
  }

  DateTime _parseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return DateTime.now();
    }
  }
}
