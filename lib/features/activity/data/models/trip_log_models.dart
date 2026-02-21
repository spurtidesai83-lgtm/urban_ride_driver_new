class TripLogRequest {
  final String dutyNo;
  final int tripNo;
  final String checkpointName;
  final String scheduledTime;
  final String loggedTime;

  TripLogRequest({
    required this.dutyNo,
    required this.tripNo,
    required this.checkpointName,
    required this.scheduledTime,
    required this.loggedTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'dutyNo': dutyNo,
      'tripNo': tripNo,
      'checkpointName': checkpointName,
      'scheduledTime': scheduledTime,
      'loggedTime': loggedTime,
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
