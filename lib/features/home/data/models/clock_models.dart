// Clock In Request Model
class ClockInRequest {
  final double latitude;
  final double longitude;
  final String routeNo;

  ClockInRequest({
    required this.latitude,
    required this.longitude,
    required this.routeNo,
  });

  Map<String, dynamic> toJson() {
    final json = {
      'latitude': latitude,
      'longitude': longitude,
      'routeNo': routeNo,
    };
    print('🔵 [ClockInRequest] Sending: $json');
    return json;
  }
}

// Clock Out Request Model
class ClockOutRequest {
  final double latitude;
  final double longitude;
  final String routeNo;

  ClockOutRequest({
    required this.latitude,
    required this.longitude,
    required this.routeNo,
  });

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'routeNo': routeNo,
    };
  }
}

// Clock Response Model (for both clock in and clock out)
class ClockResponse {
  final bool success;
  final dynamic data;
  final String message;

  ClockResponse({
    required this.success,
    this.data,
    required this.message,
  });

  factory ClockResponse.fromJson(Map<String, dynamic> json) {
    return ClockResponse(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data,
      'message': message,
    };
  }
}
