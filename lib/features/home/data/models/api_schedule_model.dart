import 'package:flutter/foundation.dart';
import 'package:urbandriver/features/home/data/models/schedule_models.dart';

// Main response for Today's Schedule API (/api/driver/schdule/today)
class ApiTodayScheduleResponse {
  final bool success;
  final Map<String, List<ApiDuty>> data;
  final String message;

  ApiTodayScheduleResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ApiTodayScheduleResponse.fromJson(Map<String, dynamic> json) {
    Map<String, List<ApiDuty>> parsedData = {};
    if (json['data'] is Map<String, dynamic>) {
      (json['data'] as Map<String, dynamic>).forEach((key, value) {
        if (value is List) {
          parsedData[key] = value.map((e) => ApiDuty.fromJson(e)).toList();
        }
      });
    }
    return ApiTodayScheduleResponse(
      success: json['success'] ?? false,
      data: parsedData,
      message: json['message'] ?? '',
    );
  }
}

// Main response for Weekly Schedule API (/api/driver/schdule/weekly)
class ApiWeeklyScheduleResponse {
  final bool success;
  final List<Map<String, Map<String, List<ApiDuty>>>> data;
  final String message;

  ApiWeeklyScheduleResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ApiWeeklyScheduleResponse.fromJson(Map<String, dynamic> json) {
    List<Map<String, Map<String, List<ApiDuty>>>> parsedData = [];
    if (json['data'] is List) {
      for (var dayMap in (json['data'] as List)) {
        if (dayMap is Map<String, dynamic>) {
          Map<String, Map<String, List<ApiDuty>>> daySchedule = {};
          dayMap.forEach((date, scheduleMap) {
            if (scheduleMap is Map<String, dynamic>) {
              Map<String, List<ApiDuty>> duties = {};
              scheduleMap.forEach((dutyKey, dutyList) {
                if (dutyList is List) {
                  duties[dutyKey] =
                      dutyList.map((d) => ApiDuty.fromJson(d)).toList();
                }
              });
              daySchedule[date] = duties;
            }
          });
          parsedData.add(daySchedule);
        }
      }
    }

    return ApiWeeklyScheduleResponse(
      success: json['success'] ?? false,
      data: parsedData,
      message: json['message'] ?? '',
    );
  }
}

// Represents a single duty, which contains schedule details and trips
class ApiDuty {
  final int id;
  final String dutyDate;
  final ApiScheduleDetails? scheduleDetails;

  ApiDuty({
    required this.id,
    required this.dutyDate,
    this.scheduleDetails,
  });

  factory ApiDuty.fromJson(Map<String, dynamic> json) {
    return ApiDuty(
      id: json['id'] ?? 0,
      dutyDate: json['dutyDate'] ?? '',
      scheduleDetails: json['scheduleDetails'] != null
          ? ApiScheduleDetails.fromJson(json['scheduleDetails'])
          : null,
    );
  }
}

// Contains the details of a schedule, like route and trips
class ApiScheduleDetails {
  final int id;
  final String scheduleDutyNo;
  final String serviceType;
  final String routeNo;
  final List<ApiTrip> trips;

  ApiScheduleDetails({
    required this.id,
    required this.scheduleDutyNo,
    required this.serviceType,
    required this.routeNo,
    required this.trips,
  });

  factory ApiScheduleDetails.fromJson(Map<String, dynamic> json) {
    var tripsList = <ApiTrip>[];
    if (json['trips'] is List) {
      tripsList = (json['trips'] as List)
          .map((trip) => ApiTrip.fromJson(trip))
          .toList();
    }
    return ApiScheduleDetails(
      id: json['id'] ?? 0,
      scheduleDutyNo: json['scheduleDutyNo'] ?? '',
      serviceType: json['serviceType'] ?? 'N/A',
      routeNo: json['routeNo'] ?? '',
      trips: tripsList,
    );
  }
}

// Represents a single trip within a duty
class ApiTrip {
  final int id;
  final String fromLocation;
  final String toLocation;
  final String kms;
  final String startTime;
  final String endTime;
  final String steering;
  final String rest;
  final List<StopModel> stops;

  ApiTrip({
    required this.id,
    required this.fromLocation,
    required this.toLocation,
    required this.kms,
    required this.startTime,
    required this.endTime,
    required this.steering,
    required this.rest,
    this.stops = const [],
  });

  factory ApiTrip.fromJson(Map<String, dynamic> json) {
    return ApiTrip(
      id: json['id'] ?? 0,
      fromLocation: json['fromLocation'] ?? '',
      toLocation: json['toLocation'] ?? '',
      kms: json['kms']?.toString() ?? '0',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      steering: json['steering'] ?? '00:00',
      rest: json['rest'] ?? '00:00',
      stops: (json['stops'] as List<dynamic>?)
              ?.map((stop) => StopModel.fromJson(stop))
              .toList() ??
          [],
    );
  }
}
