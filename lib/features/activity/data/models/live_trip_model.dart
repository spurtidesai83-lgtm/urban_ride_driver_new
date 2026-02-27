import 'package:intl/intl.dart';

class LiveTripModel {
  final int tripNo;
  final String dutyNo;
  final String fromLocation;
  final String toLocation;
  final int kms;
  final String status;
  final DateTime? tripDate;
  final String startTime;
  final String endTime;
  final String steering;
  final String rest;

  LiveTripModel({
    required this.tripNo,
    required this.dutyNo,
    required this.fromLocation,
    required this.toLocation,
    required this.kms,
    required this.status,
    required this.tripDate,
    required this.startTime,
    required this.endTime,
    required this.steering,
    required this.rest,
  });

  bool get isInProgress => status.toUpperCase() == 'IN_PROGRESS';

  factory LiveTripModel.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final tripDateRaw = json['tripDate'];
    if (tripDateRaw is String && tripDateRaw.isNotEmpty) {
      parsedDate = DateTime.tryParse(tripDateRaw);
    }

    return LiveTripModel(
      tripNo: _parseInt(json['tripNo']),
      dutyNo: (json['dutyNo'] ?? '').toString(),
      fromLocation: (json['fromLocation'] ?? '').toString(),
      toLocation: (json['toLocation'] ?? '').toString(),
      kms: _parseInt(json['kms']),
      status: (json['status'] ?? '').toString(),
      tripDate: parsedDate,
      startTime: (json['startTime'] ?? '').toString(),
      endTime: (json['endTime'] ?? '').toString(),
      steering: (json['steering'] ?? '').toString(),
      rest: (json['rest'] ?? '').toString(),
    );
  }

  String get reportingTime {
    if (startTime.isEmpty) return '';
    try {
      String timeStr = startTime.trim().toUpperCase();
      final now = DateTime.now();
      DateTime date;

      if (timeStr.contains('AM') || timeStr.contains('PM')) {
        if (timeStr.indexOf(':') == 1) {
           timeStr = '0$timeStr';
        }
        final format = DateFormat('hh:mm a');
        final parsedTime = format.parse(timeStr);
        date = DateTime(now.year, now.month, now.day, parsedTime.hour, parsedTime.minute);
      } else {
        List<String> parts = timeStr.split(':');
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        date = DateTime(now.year, now.month, now.day, hour, minute);
      }

      final reportingDate = date.subtract(const Duration(minutes: 15));

      if (startTime.toUpperCase().contains('AM') || startTime.toUpperCase().contains('PM')) {
        return DateFormat('h:mm a').format(reportingDate);
      } else {
        return DateFormat('HH:mm').format(reportingDate);
      }
    } catch (e) {
      return startTime;
    }
  }
}

int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
