class DutyStop {
  final String stopNumber;
  final String location;
  final String passengers;
  final String timeWindow;
  final String distance;
  final double latitude;
  final double longitude;

  DutyStop({
    required this.stopNumber,
    required this.location,
    required this.passengers,
    required this.timeWindow,
    required this.distance,
    this.latitude = 0.0,
    this.longitude = 0.0,
  });
}

class DutyModel {
  final String dutyNo;
  final String route;
  final String? routeCode; // Backend API identifier (R-45A format)
  final String from;
  final String to;
  final String joiningTime;
  final String closeTime;
  final bool isCompleted;
  final DateTime date;
  final List<DutyStop> stops;
  final double pickupLatitude;
  final double pickupLongitude;
  final double dropLatitude;
  final double dropLongitude;
  final String? pickupAddress;
  final String? dropAddress;
  final String? serviceType; // From backend schedule (e.g., "ordinary", "shared cab")
  final String? steeringTime; // First trip's steering time

  DutyModel({
    required this.dutyNo,
    required this.route,
    this.routeCode,
    required this.from,
    required this.to,
    required this.joiningTime,
    required this.closeTime,
    this.isCompleted = false,
    required this.date,
    this.stops = const [],
    this.pickupLatitude = 0.0,
    this.pickupLongitude = 0.0,
    this.dropLatitude = 0.0,
    this.dropLongitude = 0.0,
    this.pickupAddress,
    this.dropAddress,
    this.serviceType,
    this.steeringTime,
  });

  DutyModel copyWith({
    String? dutyNo,
    String? route,
    String? routeCode,
    String? from,
    String? to,
    String? joiningTime,
    String? closeTime,
    bool? isCompleted,
    DateTime? date,
    List<DutyStop>? stops,
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropLatitude,
    double? dropLongitude,
    String? pickupAddress,
    String? dropAddress,
    String? serviceType,
    String? steeringTime,
  }) {
    return DutyModel(
      dutyNo: dutyNo ?? this.dutyNo,
      route: route ?? this.route,
      routeCode: routeCode ?? this.routeCode,
      from: from ?? this.from,
      to: to ?? this.to,
      joiningTime: joiningTime ?? this.joiningTime,
      closeTime: closeTime ?? this.closeTime,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      stops: stops ?? this.stops,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      dropLatitude: dropLatitude ?? this.dropLatitude,
      dropLongitude: dropLongitude ?? this.dropLongitude,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropAddress: dropAddress ?? this.dropAddress,
      serviceType: serviceType ?? this.serviceType,
      steeringTime: steeringTime ?? this.steeringTime,
    );
  }
}
