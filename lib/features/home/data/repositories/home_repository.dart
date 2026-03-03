import 'package:urbandriver/features/home/data/models/duty_model.dart';
import '../../../../shared/services/schedule_api_service.dart';
import '../models/dashboard_models.dart';
import '../models/schedule_models.dart';
import '../models/clock_models.dart';
import '../models/api_schedule_model.dart';

class HomeRepository {
  final ScheduleApiService _apiService = ScheduleApiService();

  // Get dashboard data
  Future<DashboardResponse> getDashboard() async {
    try {
      return await _apiService.getDashboard();
    } catch (e) {
      rethrow;
    }
  }

  // Get today's schedule
  Future<ApiTodayScheduleResponse> getTodaySchedule() async {
    try {
      return await _apiService.getTodaySchedule();
    } catch (e) {
      rethrow;
    }
  }

  // Get tomorrow's schedule
  Future<ApiTodayScheduleResponse> getTomorrowSchedule() async {
    try {
      return await _apiService.getTomorrowSchedule();
    } catch (e) {
      rethrow;
    }
  }

  // Get weekly/tomorrow's schedule
  Future<ApiWeeklyScheduleResponse> getWeeklySchedule() async {
    try {
      return await _apiService.getWeeklySchedule();
    } catch (e) {
      rethrow;
    }
  }

  // Clock In
  Future<ClockResponse> clockIn(double latitude, double longitude, String routeNo) async {
    try {
      print('🟡 [HomeRepo] clockIn called: lat=$latitude, lng=$longitude, routeNo=$routeNo');
      final request = ClockInRequest(
        latitude: latitude,
        longitude: longitude,
        routeNo: routeNo,
      );
      print('🟡 [HomeRepo] Creating request with routeNo: $routeNo');
      return await _apiService.clockIn(request);
    } catch (e) {
      rethrow;
    }
  }

  // Clock Out
  Future<ClockResponse> clockOut(double latitude, double longitude, String routeNo) async {
    try {
      final request = ClockOutRequest(
        latitude: latitude,
        longitude: longitude,
        routeNo: routeNo,
      );
      return await _apiService.clockOut(request);
    } catch (e) {
      rethrow;
    }
  }

  // Update driver location (for map tracking)
  Future<bool> updateDriverLocation(double latitude, double longitude) async {
    try {
      // TODO: Implement API call when backend provides endpoint
      // For now, this is a placeholder for location tracking
      print('📍 Location updated: $latitude, $longitude');
      return true;
    } catch (e) {
      print('Error updating location: $e');
      return false;
    }
  }

  // Convert API schedule from TODAY'S endpoint to DutyModel list
  List<DutyModel> convertTodayScheduleToDuties(ApiTodayScheduleResponse todayResponse) {
    final duties = <DutyModel>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    todayResponse.data.forEach((dutyKey, dutyList) {
      if (dutyKey.toUpperCase() == 'OFF') return;

      for (var apiDuty in dutyList) {
        if (apiDuty.scheduleDetails == null) continue;
        final details = apiDuty.scheduleDetails!;

        for (var apiTrip in details.trips) {
          final duty = DutyModel(
            dutyNo: details.scheduleDutyNo,
            route: details.routeNo,
            from: apiTrip.fromLocation,
            to: apiTrip.toLocation,
            joiningTime: apiTrip.startTime,
            closeTime: apiTrip.endTime,
            isCompleted: false,
            date: today, // Today's schedule is always for today
            serviceType: details.serviceType,
            steeringTime: apiTrip.steering,
            restTime: apiTrip.rest,
            tripKms: int.tryParse(apiTrip.kms) ?? 0,
            tripNo: apiTrip.id,
            fromUqId: apiTrip.fromUqId,
            toUqId: apiTrip.toUqId,
            stops: apiTrip.stops.map((s) => DutyStop(
              stopNumber: '',
              location: s.name,
              uqId: s.toUqId,
              passengers: '',
              timeWindow: s.scheduledTime,
              distance: '',
              latitude: s.toLatitude,
              longitude: s.toLongitude,
            )).toList(),
            pickupLatitude: apiTrip.stops.isNotEmpty ? apiTrip.stops.first.fromLatitude : 0.0,
            pickupLongitude: apiTrip.stops.isNotEmpty ? apiTrip.stops.first.fromLongitude : 0.0,
            dropLatitude: apiTrip.stops.isNotEmpty ? apiTrip.stops.last.toLatitude : 0.0,
            dropLongitude: apiTrip.stops.isNotEmpty ? apiTrip.stops.last.toLongitude : 0.0,
          );
          duties.add(duty);
        }
      }
    });
    return duties;
  }

  // Convert API schedule from TOMORROW'S endpoint to DutyModel list
  List<DutyModel> convertTomorrowScheduleToDuties(ApiTodayScheduleResponse tomorrowResponse) {
    final duties = <DutyModel>[];
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

    // Check for explicit "OFF" key which means no duties for tomorrow
    if (tomorrowResponse.data.containsKey('OFF')) {
      return duties;
    }

    tomorrowResponse.data.forEach((dutyKey, dutyList) {
      if (dutyKey.toUpperCase() == 'OFF') return;

      for (var apiDuty in dutyList) {
        if (apiDuty.scheduleDetails == null) continue;
        final details = apiDuty.scheduleDetails!;

        for (var apiTrip in details.trips) {
          final duty = DutyModel(
            dutyNo: details.scheduleDutyNo,
            route: details.routeNo,
            from: apiTrip.fromLocation,
            to: apiTrip.toLocation,
            joiningTime: apiTrip.startTime,
            closeTime: apiTrip.endTime,
            isCompleted: false,
            date: tomorrow, // Tomorrow's schedule
            serviceType: details.serviceType,
            steeringTime: apiTrip.steering,
            restTime: apiTrip.rest,
            tripKms: int.tryParse(apiTrip.kms) ?? 0,
            tripNo: apiTrip.id,
            fromUqId: apiTrip.fromUqId,
            toUqId: apiTrip.toUqId,
            stops: apiTrip.stops.map((s) => DutyStop(
              stopNumber: '',
              location: s.name,
              uqId: s.toUqId,
              passengers: '',
              timeWindow: s.scheduledTime,
              distance: '',
              latitude: s.toLatitude,
              longitude: s.toLongitude,
            )).toList(),
            pickupLatitude: apiTrip.stops.isNotEmpty ? apiTrip.stops.first.fromLatitude : 0.0,
            pickupLongitude: apiTrip.stops.isNotEmpty ? apiTrip.stops.first.fromLongitude : 0.0,
            dropLatitude: apiTrip.stops.isNotEmpty ? apiTrip.stops.last.toLatitude : 0.0,
            dropLongitude: apiTrip.stops.isNotEmpty ? apiTrip.stops.last.toLongitude : 0.0,
          );
          duties.add(duty);
        }
      }
    });
    return duties;
  }

  // Convert API schedule from WEEKLY endpoint to DutyModel list
  List<DutyModel> convertWeeklyScheduleToDuties(ApiWeeklyScheduleResponse weeklyResponse) {
    final duties = <DutyModel> [];

    for (var dayData in weeklyResponse.data) {
      dayData.forEach((dateString, scheduleMap) {
        DateTime? scheduleDate;
        try {
          scheduleDate = DateTime.parse(dateString);
        } catch (e) {
          print('Error parsing date: $dateString');
          return; // Skip this entry if date is invalid
        }

        // Explicit OFF day means no duties for this date
        if (scheduleMap.containsKey('OFF')) {
          return;
        }

        scheduleMap.forEach((dutyKey, dutyList) {
          if (dutyKey.toUpperCase() == 'OFF') return;

          for (var apiDuty in dutyList) {
            if (apiDuty.scheduleDetails == null) continue;
            final details = apiDuty.scheduleDetails!;

            for (var apiTrip in details.trips) {
              final duty = DutyModel(
                dutyNo: details.scheduleDutyNo,
                route: details.routeNo,
                from: apiTrip.fromLocation,
                to: apiTrip.toLocation,
                joiningTime: apiTrip.startTime,
                closeTime: apiTrip.endTime,
                isCompleted: false,
                date: scheduleDate!, // Use the date from the weekly schedule
                serviceType: details.serviceType,
                steeringTime: apiTrip.steering,
                restTime: apiTrip.rest,
                tripKms: int.tryParse(apiTrip.kms) ?? 0,
                tripNo: apiTrip.id,
                fromUqId: apiTrip.fromUqId,
                toUqId: apiTrip.toUqId,
                stops: apiTrip.stops.map((s) => DutyStop(
                  stopNumber: '',
                  location: s.name,
                  uqId: s.toUqId,
                  passengers: '',
                  timeWindow: s.scheduledTime,
                  distance: '',
                  latitude: s.toLatitude,
                  longitude: s.toLongitude,
                )).toList(),
                pickupLatitude: apiTrip.stops.isNotEmpty ? apiTrip.stops.first.fromLatitude : 0.0,
                pickupLongitude: apiTrip.stops.isNotEmpty ? apiTrip.stops.first.fromLongitude : 0.0,
                dropLatitude: apiTrip.stops.isNotEmpty ? apiTrip.stops.last.toLatitude : 0.0,
                dropLongitude: apiTrip.stops.isNotEmpty ? apiTrip.stops.last.toLongitude : 0.0,
              );
              duties.add(duty);
            }
          }
        });
      });
    }
    return duties;
  }

}
