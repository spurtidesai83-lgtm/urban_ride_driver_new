/// API Response models for Trip History (from backend)
class ApiTripHistoryResponse {
  final bool success;
  final ApiTripHistoryData? data;
  final String message;

  ApiTripHistoryResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory ApiTripHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ApiTripHistoryResponse(
      success: json['success'] ?? false,
      data: json['data'] != null
          ? ApiTripHistoryData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      message: json['message'] ?? '',
    );
  }
}

class ApiTripHistoryData {
  final int totalNoOfDuties;
  final double kmsTraveled;
  final String steeringHrs;
  final double overTime;
  final List<ApiTripDetail> tripDetails;

  ApiTripHistoryData({
    required this.totalNoOfDuties,
    required this.kmsTraveled,
    required this.steeringHrs,
    required this.overTime,
    required this.tripDetails,
  });

  factory ApiTripHistoryData.fromJson(Map<String, dynamic> json) {
    final tripDetailsJson = (json['tripDetails'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    
    return ApiTripHistoryData(
      totalNoOfDuties: json['totalNoOfDuties'] ?? 0,
      kmsTraveled: (json['kmsTraveled'] as num?)?.toDouble() ?? 0.0,
      steeringHrs: json['steeringHrs'] ?? '0:00:00',
      overTime: (json['overTime'] as num?)?.toDouble() ?? 0.0,
      tripDetails: tripDetailsJson.map((item) => ApiTripDetail.fromJson(item)).toList(),
    );
  }
}

class ApiTripDetail {
  final int tripNo;
  final String fromLocation;
  final String toLocation;
  final String tripDate;
  final int kms;
  final String steeringHrs;
  final String status;

  ApiTripDetail({
    required this.tripNo,
    required this.fromLocation,
    required this.toLocation,
    required this.tripDate,
    required this.kms,
    required this.steeringHrs,
    required this.status,
  });

  factory ApiTripDetail.fromJson(Map<String, dynamic> json) {
    return ApiTripDetail(
      tripNo: json['tripNo'] ?? 0,
      fromLocation: json['fromLocation'] ?? '',
      toLocation: json['toLocation'] ?? '',
      tripDate: json['tripDate'] ?? '',
      kms: json['kms'] ?? 0,
      steeringHrs: json['steeringHrs'] ?? '0:00:00',
      status: json['status'] ?? 'UNKNOWN',
    );
  }
}
