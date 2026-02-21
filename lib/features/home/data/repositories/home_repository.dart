import 'package:urbandriver/features/home/data/models/duty_model.dart';
import '../../../../shared/services/schedule_api_service.dart';
import '../models/dashboard_models.dart';
import '../models/schedule_models.dart';
import '../models/clock_models.dart';

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
  Future<ScheduleResponse> getTodaySchedule() async {
    try {
      return await _apiService.getTodaySchedule();
    } catch (e) {
      rethrow;
    }
  }

  // Get weekly/tomorrow's schedule
  Future<WeeklyScheduleResponse> getWeeklySchedule() async {
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

  // Convert API schedule to DutyModel list
  List<DutyModel> convertScheduleToDuties(Map<String, List<ScheduleItemModel>> schedule, DateTime date) {
    final duties = <DutyModel>[];
    
    print('🔄 [HomeRepo] Converting schedule with ${schedule.length} duty entries');
    
    schedule.forEach((dutyNo, scheduleItems) {
      // Skip OFF entries - these represent days off, not actual duties
      if (dutyNo.toUpperCase() == 'OFF') {
        print('🔄 [HomeRepo] Skipping OFF entry for date');
        return;
      }
      
      print('🔄 [HomeRepo] Processing duty: $dutyNo with ${scheduleItems.length} schedule items');
      
      for (var item in scheduleItems) {
        final route = item.routeId;
        // Get serviceType and first trip's steering time
        String? serviceType = route.serviceType.isNotEmpty ? route.serviceType : null;
        String? steeringTime = route.trips.isNotEmpty ? route.trips.first.steering : null;
        print('🔄 [HomeRepo]   Route: routeNo="${route.routeNo}", routeCode="${route.routeCode}", trips=${route.trips.length}');
        
        // Convert trips to duties
        for (var trip in route.trips) {
          print('🔄 [HomeRepo]     Creating DutyModel with routeCode="${route.routeCode}"');
          final duty = DutyModel(
            dutyNo: route.scheduleDutyNo,
            route: route.routeNo,
            routeCode: route.routeCode,
            from: trip.fromLocation,
            to: trip.toLocation,
            joiningTime: trip.startTime,
            closeTime: trip.endTime,
            isCompleted: false,
            date: date,
            serviceType: serviceType,
            steeringTime: steeringTime,
            stops: trip.stops.map((stop) => DutyStop(
              stopNumber: stop.name,
              location: stop.name,
              passengers: '0', // Not in API response
              timeWindow: stop.scheduledTime,
              distance: '0 km', // Not in API response
            )).toList(),
          );
          duties.add(duty);
          print('🔄 [HomeRepo]     ✅ Duty created: ${duty.dutyNo}, Route=${duty.route}, RouteCode=${duty.routeCode}, ServiceType=${duty.serviceType}, Steering=${duty.steeringTime}');
        }
      }
    });
    
    print('🔄 [HomeRepo] Converted to ${duties.length} total duties');
    return duties;
  }

  // Convert weekly schedule to DutyModel list using explicit dates
  List<DutyModel> convertWeeklyScheduleToDuties(Map<String, Map<String, List<ScheduleItemModel>>> weeklyData) {
    final duties = <DutyModel>[];
    
    print('📅 [HomeRepo] Converting weekly schedule for ${weeklyData.length} days');
    
    weeklyData.forEach((dateString, dutyMap) {
      try {
        final dateParts = dateString.split('-');
        if (dateParts.length == 3) {
          final scheduleDate = DateTime(
            int.parse(dateParts[0]),
            int.parse(dateParts[1]),
            int.parse(dateParts[2]),
          );
          
          print('📅 [HomeRepo] Processing date: $dateString with ${dutyMap.length} duty sets');
          
          // Reuse convertScheduleToDuties for each day
          final dailyDuties = convertScheduleToDuties(dutyMap, scheduleDate);
          duties.addAll(dailyDuties);
        }
      } catch (e) {
        print('⚠️ [HomeRepo] Error processing schedule for $dateString: $e');
      }
    });

    // Sort duties by date and joining time
    duties.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      return a.joiningTime.compareTo(b.joiningTime);
    });
    
    print('📅 [HomeRepo] Converted to ${duties.length} total duties from weekly schedule');
    return duties;
  }

  // Get all duties (for backward compatibility with mock data)
  List<DutyModel> getAllDuties() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfter = today.add(const Duration(days: 2));
    
    return [
      DutyModel(
        dutyNo: 'UR-2024-001',
        route: 'Route 101',
        from: 'Mumbai Central',
        to: 'Pune Station',
        joiningTime: '07:30 AM',
        closeTime: '11:00 AM',
        isCompleted: false,
        date: today,
        pickupLatitude: 19.0876,
        pickupLongitude: 72.8691,
        pickupAddress: 'Mumbai Central Station',
        dropLatitude: 18.5204,
        dropLongitude: 73.8567,
        dropAddress: 'Pune Train Station',
        stops: [
          DutyStop(stopNumber: '1', location: 'Mumbai Central', passengers: '12', timeWindow: '07:30 AM', distance: '0 km'),
          DutyStop(stopNumber: '2', location: 'Panvel', passengers: '8', timeWindow: '08:45 AM', distance: '42 km'),
          DutyStop(stopNumber: '3', location: 'Lonavala', passengers: '15', timeWindow: '09:30 AM', distance: '64 km'),
          DutyStop(stopNumber: '4', location: 'Pune Station', passengers: '10', timeWindow: '11:00 AM', distance: '120 km'),
        ],
      ),
      DutyModel(
        dutyNo: 'UR-2024-002',
        route: 'Route 102',
        from: 'Pune Station',
        to: 'Mumbai Central',
        joiningTime: '02:00 PM',
        closeTime: '05:15 PM',
        isCompleted: false,
        date: today,
        pickupLatitude: 18.5204,
        pickupLongitude: 73.8567,
        pickupAddress: 'Pune Train Station',
        dropLatitude: 19.0876,
        dropLongitude: 72.8691,
        dropAddress: 'Mumbai Central Station',
        stops: [
          DutyStop(stopNumber: '1', location: 'Pune Station', passengers: '10', timeWindow: '02:00 PM', distance: '0 km'),
          DutyStop(stopNumber: '2', location: 'Lonavala', passengers: '12', timeWindow: '03:15 PM', distance: '56 km'),
          DutyStop(stopNumber: '3', location: 'Panvel', passengers: '6', timeWindow: '04:00 PM', distance: '78 km'),
          DutyStop(stopNumber: '4', location: 'Mumbai Central', passengers: '10', timeWindow: '05:15 PM', distance: '120 km'),
        ],
      ),
      DutyModel(
        dutyNo: 'UR-2024-003',
        route: 'Route 103',
        from: 'Mumbai Airport T2',
        to: 'Thane Station',
        joiningTime: '06:00 AM',
        closeTime: '07:45 AM',
        isCompleted: false,
        date: tomorrow,
        pickupLatitude: 19.0986,
        pickupLongitude: 72.8194,
        pickupAddress: 'Mumbai Airport Terminal 2',
        dropLatitude: 19.2183,
        dropLongitude: 72.9781,
        dropAddress: 'Thane Railway Station',
        stops: [
          DutyStop(stopNumber: '1', location: 'Mumbai Airport T2', passengers: '5', timeWindow: '06:00 AM', distance: '0 km'),
          DutyStop(stopNumber: '2', location: 'Powai', passengers: '6', timeWindow: '06:30 AM', distance: '8 km'),
          DutyStop(stopNumber: '3', location: 'Ghodbunder Road', passengers: '4', timeWindow: '07:15 AM', distance: '18 km'),
          DutyStop(stopNumber: '4', location: 'Thane Station', passengers: '3', timeWindow: '07:45 AM', distance: '25 km'),
        ],
      ),
      DutyModel(
        dutyNo: 'UR-2024-004',
        route: 'Route 104',
        from: 'Thane Station',
        to: 'Mumbai Airport T2',
        joiningTime: '10:30 AM',
        closeTime: '12:15 PM',
        isCompleted: false,
        date: tomorrow,
        pickupLatitude: 19.2183,
        pickupLongitude: 72.9781,
        pickupAddress: 'Thane Railway Station',
        dropLatitude: 19.0986,
        dropLongitude: 72.8194,
        dropAddress: 'Mumbai Airport Terminal 2',
        stops: [
          DutyStop(stopNumber: '1', location: 'Thane Station', passengers: '7', timeWindow: '10:30 AM', distance: '0 km'),
          DutyStop(stopNumber: '2', location: 'Ghodbunder Road', passengers: '5', timeWindow: '11:00 AM', distance: '7 km'),
          DutyStop(stopNumber: '3', location: 'Powai', passengers: '6', timeWindow: '11:45 AM', distance: '17 km'),
          DutyStop(stopNumber: '4', location: 'Mumbai Airport T2', passengers: '4', timeWindow: '12:15 PM', distance: '25 km'),
        ],
      ),
      DutyModel(
        dutyNo: 'UR-2024-005',
        route: 'Route 105',
        from: 'Mumbai Central',
        to: 'Nashik CBS',
        joiningTime: '08:00 AM',
        closeTime: '12:00 PM',
        isCompleted: false,
        date: dayAfter,
        pickupLatitude: 19.0876,
        pickupLongitude: 72.8691,
        pickupAddress: 'Mumbai Central Station',
        dropLatitude: 19.9975,
        dropLongitude: 73.7898,
        dropAddress: 'Nashik CBS Bus Stand',
        stops: [
          DutyStop(stopNumber: '1', location: 'Mumbai Central', passengers: '15', timeWindow: '08:00 AM', distance: '0 km'),
          DutyStop(stopNumber: '2', location: 'Kalyan', passengers: '10', timeWindow: '09:15 AM', distance: '54 km'),
          DutyStop(stopNumber: '3', location: 'Igatpuri', passengers: '8', timeWindow: '10:30 AM', distance: '120 km'),
          DutyStop(stopNumber: '4', location: 'Nashik CBS', passengers: '9', timeWindow: '12:00 PM', distance: '167 km'),
        ],
      ),
    ];
  }
}
