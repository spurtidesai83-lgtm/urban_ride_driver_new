int _parseInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _parseDouble(dynamic value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

// Convert route name/number to route code format (e.g., "Route 101" -> "R-101")
String _extractRouteCode(String routeNo) {
  if (routeNo.isEmpty) {
    print('📍 [extractRouteCode] Empty routeNo, returning empty');
    return '';
  }
  
  // If already in R-XXX format, return as is
  if (routeNo.startsWith('R-') || routeNo.startsWith('r-')) {
    print('📍 [extractRouteCode] Already in R- format: $routeNo');
    return routeNo;
  }
  
  // Extract numbers from the route name
  final numbers = routeNo.replaceAll(RegExp(r'[^0-9]'), '');
  if (numbers.isEmpty) {
    print('📍 [extractRouteCode] No numbers found in "$routeNo", returning as-is');
    return routeNo; // Return original if no numbers found
  }
  
  final transformed = 'R-$numbers';
  print('📍 [extractRouteCode] Transformed "$routeNo" → "$transformed"');
  return transformed;
}

// Stop Model (for trip stops)
class StopModel {
  final String name;
  final String fromCheckpoint;
  final String toCheckpoint;
  final String fromUqId;
  final String toUqId;
  final double fromLatitude;
  final double fromLongitude;
  final double toLatitude;
  final double toLongitude;
  final String scheduledTime;
  final String loggedTime;

  StopModel({
    required this.name,
    this.fromCheckpoint = '',
    this.toCheckpoint = '',
    this.fromUqId = '',
    this.toUqId = '',
    this.fromLatitude = 0.0,
    this.fromLongitude = 0.0,
    this.toLatitude = 0.0,
    this.toLongitude = 0.0,
    required this.scheduledTime,
    required this.loggedTime,
  });

  factory StopModel.fromJson(Map<String, dynamic> json) {
    final fromValue = (json['from'] ?? '').toString();
    final toValue = (json['to'] ?? '').toString();
    final toCheckpoint = (json['toCheckpoint'] ?? json['to'] ?? json['name'] ?? '').toString();

    return StopModel(
      name: toCheckpoint,
      fromCheckpoint: fromValue,
      toCheckpoint: toCheckpoint,
      fromUqId: fromValue,
      toUqId: toValue,
      fromLatitude: _parseDouble(json['fromLatitude']),
      fromLongitude: _parseDouble(json['fromLongitude']),
      toLatitude: _parseDouble(json['toLatitude']),
      toLongitude: _parseDouble(json['toLongitude']),
      scheduledTime: json['arrivalTime'] ?? json['scheduledTime'] ?? '',
      loggedTime: json['departureTime'] ?? json['loggedTime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'scheduledTime': scheduledTime,
      'loggedTime': loggedTime,
    };
  }
}

// Trip Model
class ApiTripModel {
  final int id;
  final String fromLocation;
  final String fromUqId;
  final String toLocation;
  final String toUqId;
  final int kms;
  final int stages;
  final double fare;
  final String startTime;
  final String endTime;
  final String steering;
  final String rest;
  final List<StopModel> stops;

  ApiTripModel({
    required this.id,
    required this.fromLocation,
    required this.fromUqId,
    required this.toLocation,
    required this.toUqId,
    required this.kms,
    required this.stages,
    required this.fare,
    required this.startTime,
    required this.endTime,
    required this.steering,
    required this.rest,
    this.stops = const [],
  });

  factory ApiTripModel.fromJson(Map<String, dynamic> json) {
    return ApiTripModel(
      id: json['id'] ?? 0,
      fromLocation: json['fromLocation'] ?? '',
      fromUqId: (json['fromUqId'] ?? '').toString(),
      toLocation: json['toLocation'] ?? '',
      toUqId: (json['toUqId'] ?? '').toString(),
      kms: _parseInt(json['kms']),
      stages: _parseInt(json['stages']),
      fare: _parseDouble(json['fare']),
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      steering: json['steering'] ?? '',
      rest: json['rest'] ?? '',
      stops: (json['stops'] as List<dynamic>?)
              ?.map((stop) => StopModel.fromJson(stop))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fromLocation': fromLocation,
      'fromUqId': fromUqId,
      'toLocation': toLocation,
      'toUqId': toUqId,
      'kms': kms,
      'stages': stages,
      'fare': fare,
      'startTime': startTime,
      'endTime': endTime,
      'steering': steering,
      'rest': rest,
      'stops': stops.map((stop) => stop.toJson()).toList(),
    };
  }
}

// Route Info Model
class RouteInfoModel {
  final int id;
  final String region;
  final String division;
  final String depot;
  final String scheduleDutyNo;
  final String serviceType;
  final String routeNo;
  final String? routeCode; // Backend route identifier (R-45A format)
  final int noOfTrips;
  final String dutyHours;
  final String overtime;
  final String status;
  final List<ApiTripModel> trips;
  final String createdAt;
  final String updatedAt;

  RouteInfoModel({
    required this.id,
    required this.region,
    required this.division,
    required this.depot,
    required this.scheduleDutyNo,
    required this.serviceType,
    required this.routeNo,
    this.routeCode,
    required this.noOfTrips,
    required this.dutyHours,
    required this.overtime,
    required this.status,
    required this.trips,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RouteInfoModel.fromJson(Map<String, dynamic> json) {
    final routeNo = json['routeNo'] ?? '';
    final apiRouteCode = json['routeCode'] ?? json['route_code'] ?? '';
    final routeCode = apiRouteCode.isEmpty 
        ? _extractRouteCode(routeNo)
        : apiRouteCode;
    
    // Handle specific string-to-int conversion for noOfTrips which comes as "2" in string format
    final tripsCount = json['noOfTrips'] is String 
        ? int.tryParse(json['noOfTrips']) ?? 0
        : _parseInt(json['noOfTrips']);
    
    return RouteInfoModel(
      id: json['id'] ?? 0,
      region: json['region'] ?? '',
      division: json['division'] ?? '',
      depot: json['depot'] ?? '',
      scheduleDutyNo: json['scheduleDutyNo'] ?? '',
      serviceType: json['serviceType'] ?? '',
      routeNo: routeNo,
      routeCode: routeCode,
      noOfTrips: tripsCount,
      dutyHours: json['dutyHours'] ?? '',
      overtime: json['overtime'] ?? '',
      status: json['status'] ?? '',
      trips: (json['trips'] as List<dynamic>?)
              ?.map((trip) => ApiTripModel.fromJson(trip))
              .toList() ??
          [],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'region': region,
      'division': division,
      'depot': depot,
      'scheduleDutyNo': scheduleDutyNo,
      'serviceType': serviceType,
      'routeNo': routeNo,
      'routeCode': routeCode,
      'noOfTrips': noOfTrips,
      'dutyHours': dutyHours,
      'overtime': overtime,
      'status': status,
      'trips': trips.map((trip) => trip.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

// Schedule Item Model
class ScheduleItemModel {
  final int id;
  final RouteInfoModel routeId; // Kept as routeId for compatibility, maps to scheduleDetails
  final String dutyDate;
  final String createdAt;
  final String updatedAt;
  final String createdBy;

  ScheduleItemModel({
    required this.id,
    required this.routeId,
    required this.dutyDate,
    this.createdAt = '',
    this.updatedAt = '',
    this.createdBy = '',
  });

  factory ScheduleItemModel.fromJson(Map<String, dynamic> json) {
    return ScheduleItemModel(
      id: json['id'] ?? 0,
      // Map 'scheduleDetails' from JSON to 'routeId' property
      routeId: RouteInfoModel.fromJson(json['scheduleDetails'] ?? json['routeId'] ?? {}),
      dutyDate: json['dutyDate'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      createdBy: json['createdBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scheduleDetails': routeId.toJson(), // Map back to scheduleDetails for consistency if needed
      'dutyDate': dutyDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
    };
  }
}

// Schedule Response Model
class ScheduleResponse {
  final bool success;
  final Map<String, List<ScheduleItemModel>> data;
  final String message;

  ScheduleResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ScheduleResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = <String, List<ScheduleItemModel>>{};
    final data = json['data'] as Map<String, dynamic>? ?? {};
    
    data.forEach((key, value) {
      if (value is List) {
        dataMap[key] = value
            .map((item) => ScheduleItemModel.fromJson(item))
            .toList();
      }
    });

    return ScheduleResponse(
      success: json['success'] ?? false,
      data: dataMap,
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final dataMap = <String, dynamic>{};
    data.forEach((key, value) {
      dataMap[key] = value.map((item) => item.toJson()).toList();
    });

    return {
      'success': success,
      'data': dataMap,
      'message': message,
    };
  }
}

// Weekly Schedule Response Model
class WeeklyScheduleResponse {
  final bool success;
  // Map<Date, Map<DutyNo, List<ScheduleItemModel>>>
  final Map<String, Map<String, List<ScheduleItemModel>>> data;
  final String message;

  WeeklyScheduleResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory WeeklyScheduleResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = <String, Map<String, List<ScheduleItemModel>>>{};
    final dataList = json['data'] as List<dynamic>? ?? [];

    for (var dateMap in dataList) {
      if (dateMap is Map<String, dynamic>) {
        dateMap.forEach((dateKey, dutyMap) {
          if (dutyMap is Map<String, dynamic>) {
             final dutiesForDate = <String, List<ScheduleItemModel>>{};
             dutyMap.forEach((dutyNo, dutyItems) {
               if (dutyItems is List) {
                 dutiesForDate[dutyNo] = dutyItems
                     .map((item) => ScheduleItemModel.fromJson(item))
                     .toList();
               }
             });
             dataMap[dateKey] = dutiesForDate;
          }
        });
      }
    }

    return WeeklyScheduleResponse(
      success: json['success'] ?? false,
      data: dataMap,
      message: json['message'] ?? '',
    );
  }
}
