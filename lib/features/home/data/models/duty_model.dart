import 'package:intl/intl.dart';

class DutyStop {
  final String stopNumber;
  final String location;
  final String uqId;
  final String passengers;
  final String timeWindow;
  final String distance;
  final double latitude;
  final double longitude;

  DutyStop({
    required this.stopNumber,
    required this.location,
    this.uqId = '',
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
  final String? restTime; // Trip rest duration from backend
  final int? tripKms; // Trip distance from backend
  final int? tripNo; // Backend trip identifier
  final String? fromUqId;
  final String? toUqId;

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
    this.restTime,
    this.tripKms,
    this.tripNo,
    this.fromUqId,
    this.toUqId,
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
    String? restTime,
    int? tripKms,
    int? tripNo,
    String? fromUqId,
    String? toUqId,
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
      restTime: restTime ?? this.restTime,
      tripKms: tripKms ?? this.tripKms,
      tripNo: tripNo ?? this.tripNo,
      fromUqId: fromUqId ?? this.fromUqId,
      toUqId: toUqId ?? this.toUqId,
    );
  }

  String get reportingTime {
    if (joiningTime.isEmpty) return '';
    try {
      String timeStr = joiningTime.trim().toUpperCase();

      final now = DateTime.now();
      DateTime date;

      if (timeStr.contains('AM') || timeStr.contains('PM')) {
        if (timeStr.indexOf(':') == 1) {
           timeStr = '0$timeStr';
        }

        final format = DateFormat('hh:mm a');
        final parsedTime = format.parse(timeStr);
        date = DateTime(now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
      }
      else {
        List<String> parts = timeStr.split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        date = DateTime(now.year, now.month, now.day, hour, minute);
      }

      final reportingDate = date.subtract(const Duration(minutes: 15));

      if (joiningTime.toUpperCase().contains('AM') || joiningTime.toUpperCase().contains('PM')) {
        return DateFormat('h:mm a').format(reportingDate);
      } else {
        return DateFormat('HH:mm').format(reportingDate);
      }
    } catch (e) {
      return joiningTime;
    }
  }
}
