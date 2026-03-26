class PassengerDetail {
  final String name;
  final String phoneNumber;

  PassengerDetail({
    required this.name,
    required this.phoneNumber,
  });

  factory PassengerDetail.fromJson(Map<String, dynamic> json) {
    return PassengerDetail(
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }
}

class BookingResponse {
  final int passengerCount;
  final List<PassengerDetail> passengerDetails;

  BookingResponse({
    required this.passengerCount,
    required this.passengerDetails,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      passengerCount: json['passengerCount'] ?? 0,
      passengerDetails: (json['passengerDetails'] as List? ?? [])
          .map((i) => PassengerDetail.fromJson(i))
          .toList(),
    );
  }
}

class StopPassengerCount {
  final String stopName;
  final int passengerCount;

  StopPassengerCount({
    required this.stopName,
    required this.passengerCount,
  });

  factory StopPassengerCount.fromJson(Map<String, dynamic> json) {
    return StopPassengerCount(
      stopName: json['stopName'] ?? '',
      passengerCount: json['passengerCount'] ?? 0,
    );
  }
}

class StopCountResponse {
  final String routeNo;
  final int passengerCount;
  final List<StopPassengerCount> stops;

  StopCountResponse({
    required this.routeNo,
    required this.passengerCount,
    required this.stops,
  });

  factory StopCountResponse.fromJson(Map<String, dynamic> json) {
    return StopCountResponse(
      routeNo: json['routeNo'] ?? '',
      passengerCount: json['passengerCount'] ?? 0,
      stops: (json['stops'] as List? ?? [])
          .map((i) => StopPassengerCount.fromJson(i))
          .toList(),
    );
  }
}
