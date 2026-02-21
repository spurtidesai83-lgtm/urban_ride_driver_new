class TripLogRequest {
  final String dutyNo;
  final int tripNo;
  final String checkpointName;
  final String scheduledTime;
  final String loggedTime;
  final String uqId;
  final double latitude;
  final double longitude;

  TripLogRequest({
    required this.dutyNo,
    required this.tripNo,
    required this.checkpointName,
    required this.scheduledTime,
    required this.loggedTime,
    required this.uqId,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'dutyNo': dutyNo,
      'tripNo': tripNo,
      'checkpointName': checkpointName,
      'scheduledTime': scheduledTime,
      'loggedTime': loggedTime,
      'uqId': uqId,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class TripLogResponse {
  final bool success;
  final String message;

  TripLogResponse({
    required this.success,
    required this.message,
  });

  factory TripLogResponse.fromJson(Map<String, dynamic> json) {
    return TripLogResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
