import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/duty_model.dart';
import '../../data/models/driving_data_model.dart';
import '../../data/repositories/home_repository.dart';
import '../../../profile/data/models/profile_model.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class HomeState {
  final int currentDateIndex;
  final bool isDistanceView;
  final int lastClickedArrow;
  final bool isClockedIn;
  final bool clockInManuallySet; // Flag to prevent dashboard from overriding
  final DateTime? lockedOutDate;
  final List<DrivingDataModel> drivingData;
  final List<DutyModel> duties;
  final int currentDutyIndex;
  final List<DutyModel> allDuties; // All duties across all dates
  final bool allDutiesCompleted; // Flag for when all duties of the day are completed
  final bool isLoading;
  final bool isClockActionLoading; // Loading state for clock in/out
  final String? errorMessage;
  final String driverName;
  final int totalTrips;
  final String totalSteeringTime;
  final int totalKms;
  final Position? driverPosition; // Driver's current location
  final bool isMapView; // Toggle between list and map view

  HomeState({
    required this.currentDateIndex,
    required this.isDistanceView,
    required this.lastClickedArrow,
    required this.isClockedIn,
    this.clockInManuallySet = false,
    this.lockedOutDate,
    required this.drivingData,
    required this.duties,
    this.currentDutyIndex = 0,
    this.allDuties = const [],
    this.allDutiesCompleted = false,
    this.isLoading = false,
    this.isClockActionLoading = false,
    this.errorMessage,
    this.driverName = '',
    this.totalTrips = 0,
    this.totalSteeringTime = '',
    this.totalKms = 0,
    this.driverPosition,
    this.isMapView = false,
  });

  HomeState copyWith({
    int? currentDateIndex,
    bool? isDistanceView,
    int? lastClickedArrow,
    bool? isClockedIn,
    bool? clockInManuallySet,
    DateTime? lockedOutDate,
    List<DrivingDataModel>? drivingData,
    List<DutyModel>? duties,
    int? currentDutyIndex,
    List<DutyModel>? allDuties,
    bool? allDutiesCompleted,
    bool? isLoading,
    bool? isClockActionLoading,
    String? errorMessage,
    String? driverName,
    int? totalTrips,
    String? totalSteeringTime,
    int? totalKms,
    Position? driverPosition,
    bool? isMapView,
  }) {
    return HomeState(
      currentDateIndex: currentDateIndex ?? this.currentDateIndex,
      isDistanceView: isDistanceView ?? this.isDistanceView,
      lastClickedArrow: lastClickedArrow ?? this.lastClickedArrow,
      isClockedIn: isClockedIn ?? this.isClockedIn,
      clockInManuallySet: clockInManuallySet ?? this.clockInManuallySet,
      lockedOutDate: lockedOutDate ?? this.lockedOutDate,
      drivingData: drivingData ?? this.drivingData,
      duties: duties ?? this.duties,
      currentDutyIndex: currentDutyIndex ?? this.currentDutyIndex,
      allDuties: allDuties ?? this.allDuties,
      allDutiesCompleted: allDutiesCompleted ?? this.allDutiesCompleted,
      isLoading: isLoading ?? this.isLoading,
      isClockActionLoading: isClockActionLoading ?? this.isClockActionLoading,
      errorMessage: errorMessage,
      driverName: driverName ?? this.driverName,
      totalTrips: totalTrips ?? this.totalTrips,
      totalSteeringTime: totalSteeringTime ?? this.totalSteeringTime,
      totalKms: totalKms ?? this.totalKms,
      driverPosition: driverPosition ?? this.driverPosition,
      isMapView: isMapView ?? this.isMapView,
    );
  }

  bool get isLockedOutForToday {
    if (lockedOutDate == null) return false;
    final now = DateTime.now();
    return lockedOutDate!.year == now.year &&
        lockedOutDate!.month == now.month &&
        lockedOutDate!.day == now.day;
  }

  DutyModel? get currentDuty {
    if (duties.isEmpty || currentDutyIndex >= duties.length) return null;
    return duties[currentDutyIndex];
  }

  DutyModel? get nextDuty {
    if (duties.isEmpty || currentDutyIndex + 1 >= duties.length) return null;
    return duties[currentDutyIndex + 1];
  }

  List<DutyModel> get tomorrowDuties {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
    
    return allDuties.where((duty) => 
        duty.date.year == tomorrow.year &&
        duty.date.month == tomorrow.month &&
        duty.date.day == tomorrow.day
    ).toList();
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  final HomeRepository _repository;
  final Ref _ref;

  HomeNotifier(this._repository, this._ref) : super(HomeState(
    currentDateIndex: 0,
    isDistanceView: true,
    lastClickedArrow: 0,
    isClockedIn: false,
    duties: [],
    allDuties: [],
    drivingData: [], // Will be loaded from API
    totalTrips: 0,
    totalSteeringTime: '--',
    totalKms: 0,
  )) {
    _listenProfileName();

    // Load dashboard data from API (no mock data fallback)
    fetchDashboard();
  }

  void _listenProfileName() {
    _ref.listen<AsyncValue<ProfileModel>>(profileProvider, (previous, next) {
      next.whenData((profile) {
        if (profile.name.isNotEmpty && state.driverName != profile.name) {
          state = state.copyWith(driverName: profile.name);
        }
      });
    });
  }

  // Fetch dashboard data from API
  Future<void> fetchDashboard() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final dashboard = await _repository.getDashboard();
      final data = dashboard.data;
      print('📊 Dashboard fetched: isClockedIn=${data.isClockedIn}, schedule=${data.schedule.length} items');
      
      // Update state with dashboard data
      final today = DateTime.now();
      final todayDuties = _repository.convertScheduleToDuties(data.schedule, today);
      print('📋 Converted ${todayDuties.length} duties from schedule');
      
      // If clock-in was manually set, don't override it from dashboard
      final newClockedInState = state.clockInManuallySet ? state.isClockedIn : data.isClockedIn;
      
      // Use API duties only - no mock fallback
      final finalDuties = todayDuties;
      print('📋 Loaded ${finalDuties.length} duties from API');
      
      state = state.copyWith(
        isLoading: false,
        isClockedIn: newClockedInState,
        totalTrips: data.noOfTrips,
        totalSteeringTime: data.steeringTime,
        totalKms: data.totalKms,
        duties: finalDuties,
        allDuties: finalDuties,
        currentDutyIndex: 0,
        allDutiesCompleted: finalDuties.isEmpty,
        errorMessage: null,
      );
      print('🏠 [HomeProvider] Updated state with ${finalDuties.length} duties');
      
      // Fetch weekly schedule in the background
      fetchWeeklySchedule();
    } catch (e) {
      // Show error to user - no mock data fallback
      print('❌ Dashboard fetch failed: $e');
      
      // Determine error type for better message
      String errorMsg = 'Failed to load dashboard';
      if (e.toString().contains('SocketException') || e.toString().contains('Network')) {
        errorMsg = 'Network error - Backend server not responding';
      } else if (e.toString().contains('TimeoutException')) {
        errorMsg = 'Request timeout - Backend server is slow or offline';
      } else if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        errorMsg = 'Authentication failed - Token may be expired';
      } else if (e.toString().contains('404') || e.toString().contains('not found')) {
        errorMsg = 'API endpoint not found - Backend config issue';
      } else {
        errorMsg = 'Backend Error: ${e.toString()}';
      }
      
      state = state.copyWith(
        isLoading: false,
        duties: [],
        allDuties: [],
        errorMessage: errorMsg,
      );
    }
  }

  // Fetch today's schedule from API
  Future<void> fetchTodaySchedule() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final scheduleResponse = await _repository.getTodaySchedule();
      final today = DateTime.now();
      final todayDuties = _repository.convertScheduleToDuties(scheduleResponse.data, today);
      
      state = state.copyWith(
        isLoading: false,
        duties: todayDuties,
        allDuties: [...todayDuties, ...state.allDuties.where((d) => !_isSameDay(d.date, today))],
        currentDutyIndex: 0,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Fetch weekly/tomorrow's schedule from API
  Future<void> fetchWeeklySchedule() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final scheduleResponse = await _repository.getWeeklySchedule();
      final weeklyDuties = _repository.convertWeeklyScheduleToDuties(scheduleResponse.data);
      
      // Replace all duties for the next week, keep today's duties
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final todayDuties = state.duties.where((d) => _isSameDay(d.date, today)).toList();
      
      state = state.copyWith(
        isLoading: false,
        allDuties: [...todayDuties, ...weeklyDuties],
        errorMessage: null,
      );
      print('📅 [HomeProvider] Weekly schedule fetched and merged. Total duties: ${state.allDuties.length}');
    } catch (e) {
      print('❌ [HomeProvider] Weekly schedule fetch failed: $e');
      String errorMsg = 'Failed to load weekly schedule';
      if (e.toString().contains('SocketException') || e.toString().contains('Network')) {
        errorMsg = 'Network error while loading schedule';
      } else if (e.toString().contains('TimeoutException')) {
        errorMsg = 'Schedule load timeout';
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMsg,
      );
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  void loadDutiesForDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    
    final dateDuties = state.allDuties
        .where((duty) => 
            duty.date.year == targetDate.year &&
            duty.date.month == targetDate.month &&
            duty.date.day == targetDate.day)
        .toList();
    
    state = state.copyWith(
      duties: dateDuties,
      currentDutyIndex: 0,
      allDutiesCompleted: false,
    );
  }

  void navigateDate(int direction) {
    state = state.copyWith(
      currentDateIndex: (state.currentDateIndex + direction).clamp(0, state.drivingData.length - 1),
      lastClickedArrow: direction == 1 ? 1 : 2,
    );
  }

  void toggleView(bool showDistance) {
    state = state.copyWith(isDistanceView: showDistance);
  }

  // Get current location
  Future<Position?> _getCurrentLocation() async {
    try {
      // Check permission
      final permission = await Permission.location.status;
      if (!permission.isGranted) {
        final result = await Permission.location.request();
        if (!result.isGranted) {
          return null;
        }
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  Future<ClockActionResult> toggleClockStatus() async {
    print('🟢 toggleClockStatus called, isClockedIn=${state.isClockedIn}');
    
    // Set loading state
    state = state.copyWith(isClockActionLoading: true);
    
    if (!state.isClockedIn) {
      // Clock In
      if (state.isLockedOutForToday) {
        print('🔴 Locked out for today');
        state = state.copyWith(isClockActionLoading: false);
        return const ClockActionResult(
          success: false,
          message: 'You are locked out for today',
        );
      }

      try {
        print('🟢 Getting current location...');
        // Get current location
        final position = await _getCurrentLocation();
        print('🟢 Location: ${position?.latitude}, ${position?.longitude}');
        if (position == null) {
          print('🔴 Location is null');
          state = state.copyWith(isClockActionLoading: false);
          return const ClockActionResult(
            success: false,
            message: 'Location is required to clock in',
          );
        }

        print('🟢 Calling clock in API...');
        print('🟢 Current duty: route="${state.currentDuty?.route}", routeCode="${state.currentDuty?.routeCode}"');
        
        // Use vehicle number if available, else fallback to a known test value
        // Get route code from current duty (R-45A format), fallback to route name
        final routeIdentifier = state.currentDuty?.routeCode ?? state.currentDuty?.route;
        
        print('🟢 Clock In - Using: $routeIdentifier (routeCode=${state.currentDuty?.routeCode}, route=${state.currentDuty?.route})');
        
        if (routeIdentifier == null || routeIdentifier.isEmpty) {
          print('🔴 Route identifier is required for clock in');
          state = state.copyWith(isClockActionLoading: false);
          return const ClockActionResult(
            success: false,
            message: 'Route identifier is required to clock in',
          );
        }

        // Call clock in API
        final response = await _repository.clockIn(
          position.latitude,
          position.longitude,
          routeIdentifier,
        );
        print('🟢 API Response: success=${response.success}, message=${response.message}');

        if (response.success) {
          print('✅ Clock in successful!');
          state = state.copyWith(
            isClockedIn: true,
            clockInManuallySet: false, // Reset flag since it's from API
            isClockActionLoading: false,
          );
          return const ClockActionResult(
            success: true,
            message: 'Clocked in successfully',
          );
        } else {
          print('❌ Clock in failed: ${response.message}');
          state = state.copyWith(isClockActionLoading: false);
          return ClockActionResult(
            success: false,
            message: response.message.isNotEmpty
                ? response.message
                : 'Clock in failed',
          );
        }
      } catch (e) {
        print('❌ Exception during clock in: $e');
        final errorMsg = e.toString().toLowerCase();
        
        // Check if already clocked in - sync state
        if (errorMsg.contains('already clocked in')) {
          print('🔄 Already clocked in - syncing state');
          state = state.copyWith(
            isClockedIn: true,
            clockInManuallySet: true, // Prevent dashboard from overriding
            isClockActionLoading: false,
          );
          return const ClockActionResult(
            success: true,
            message: 'You are already clocked in for today',
          );
        }
        
        // Extract clean error message
        String cleanMsg = e.toString();
        if (cleanMsg.contains('Exception:')) {
          // Extract the last exception message
          final parts = cleanMsg.split('Exception:');
          cleanMsg = parts.last.trim();
        }
        
        state = state.copyWith(isClockActionLoading: false);
        return ClockActionResult(
          success: false,
          message: cleanMsg,
        );
      }
    }

    // Clock Out
    if (state.allDutiesCompleted) {
      try {
        // Get current location
        final position = await _getCurrentLocation();
        if (position == null) {
          state = state.copyWith(isClockActionLoading: false);
          return const ClockActionResult(
            success: false,
            message: 'Location is required to clock out',
          );
        }

        // Get route identifier from current duty (R-45A format), fallback to route name
        print('🟢 Current duty: route="${state.currentDuty?.route}", routeCode="${state.currentDuty?.routeCode}"');
        final routeIdentifier = state.currentDuty?.routeCode ?? state.currentDuty?.route;
        
        print('🟢 Clock Out - Using: $routeIdentifier (routeCode=${state.currentDuty?.routeCode}, route=${state.currentDuty?.route})');
        
        if (routeIdentifier == null || routeIdentifier.isEmpty) {
          print('🔴 Route identifier is required for clock out');
          state = state.copyWith(isClockActionLoading: false);
          return const ClockActionResult(
            success: false,
            message: 'Route identifier is required to clock out',
          );
        }

        // Call clock out API
        final response = await _repository.clockOut(
          position.latitude,
          position.longitude,
          routeIdentifier,
        );

        if (response.success) {
          state = state.copyWith(
            isClockedIn: false,
            lockedOutDate: DateTime.now(),
            clockInManuallySet: false,
            isClockActionLoading: false,
          );
          return const ClockActionResult(
            success: true,
            message: 'Clocked out successfully',
          );
        } else {
          state = state.copyWith(isClockActionLoading: false);
          return ClockActionResult(
            success: false,
            message: response.message.isNotEmpty
                ? response.message
                : 'Clock out failed',
          );
        }
      } catch (e) {
        final errorMsg = e.toString().toLowerCase();
        
        // Check if already clocked out - sync state
        if (errorMsg.contains('already clocked out') || errorMsg.contains('not clocked in')) {
          state = state.copyWith(
            isClockedIn: false,
            clockInManuallySet: true,
            isClockActionLoading: false,
          );
          fetchDashboard();
          return const ClockActionResult(
            success: true,
            message: 'Already clocked out',
          );
        }
        
        // Extract clean error message
        String cleanMsg = e.toString();
        if (cleanMsg.contains('Exception:')) {
          final parts = cleanMsg.split('Exception:');
          cleanMsg = parts.last.trim();
        }
        
        state = state.copyWith(isClockActionLoading: false);
        return ClockActionResult(
          success: false,
          message: cleanMsg,
        );
      }
    }

    try {
      // Get current location
      final position = await _getCurrentLocation();
      if (position == null) {
        state = state.copyWith(isClockActionLoading: false);
        return const ClockActionResult(
          success: false,
          message: 'Location is required to clock out',
        );
      }

      // Get route identifier from current duty (R-45A format), fallback to route name
      final routeIdentifier = state.currentDuty?.routeCode ?? state.currentDuty?.route;
      
      print('🟢 Clock Out (Sync) - Route: ${state.currentDuty?.route}, RouteCode: ${state.currentDuty?.routeCode}, Using: $routeIdentifier');
      
      if (routeIdentifier == null || routeIdentifier.isEmpty) {
        print('🔴 Route identifier is required for clock out');
        state = state.copyWith(isClockActionLoading: false);
        return const ClockActionResult(
          success: false,
          message: 'Route identifier is required to clock out',
        );
      }

      // Call clock out API
      final response = await _repository.clockOut(
        position.latitude,
        position.longitude,
        routeIdentifier,
      );

      if (response.success) {
        state = state.copyWith(
          isClockedIn: false,
          clockInManuallySet: false,
          isClockActionLoading: false,
        );
        return const ClockActionResult(
          success: true,
          message: 'Clocked out successfully',
        );
      } else {
        state = state.copyWith(isClockActionLoading: false);
        return ClockActionResult(
          success: false,
          message: response.message.isNotEmpty
              ? response.message
              : 'Clock out failed',
        );
      }
    } catch (e) {
      final errorMsg = e.toString().toLowerCase();
      
      // Check if already clocked out - sync state
      if (errorMsg.contains('already clocked out') || errorMsg.contains('not clocked in')) {
        state = state.copyWith(
          isClockedIn: false,
          clockInManuallySet: true,
          isClockActionLoading: false,
        );
        fetchDashboard();
        return const ClockActionResult(
          success: true,
          message: 'Already clocked out',
        );
      }
      
      // Extract clean error message
      String cleanMsg = e.toString();
      if (cleanMsg.contains('Exception:')) {
        final parts = cleanMsg.split('Exception:');
        cleanMsg = parts.last.trim();
      }
      
      state = state.copyWith(isClockActionLoading: false);
      return ClockActionResult(
        success: false,
        message: cleanMsg,
      );
    }
  }

  void completeCurrentDuty() {
    if (state.currentDutyIndex < state.duties.length - 1) {
      // Move to next duty
      state = state.copyWith(
        currentDutyIndex: state.currentDutyIndex + 1,
      );
    } else {
      // Last duty completed - set flag
      state = state.copyWith(
        allDutiesCompleted: true,
      );
    }
  }

  // Toggle between map and list view
  void toggleMapView(bool showMap) {
    state = state.copyWith(isMapView: showMap);
    if (showMap) {
      print('🗺️ Map view enabled - updating location');
      updateDriverLocation();
    }
  }

  // Update driver's current location
  Future<void> updateDriverLocation() async {
    try {
      final position = await _getCurrentLocation();
      if (position != null) {
        state = state.copyWith(driverPosition: position);
        
        // Send location update to backend (background)
        _sendLocationToBackend(position);
      }
    } catch (e) {
      print('Error updating driver location: $e');
    }
  }

  // Send location update to backend
  Future<void> _sendLocationToBackend(Position position) async {
    try {
      // Call backend API to update location
      await _repository.updateDriverLocation(
        position.latitude,
        position.longitude,
      );
    } catch (e) {
      print('Error sending location to backend: $e');
    }
  }

  // Load map-related duty data
  Future<void> loadMapData() async {
    try {
      // First get current location
      await updateDriverLocation();
      
      // Load duty data with coordinates from repository if available
      // This would typically come from the API
      print('📍 Map data loaded with driver position');
    } catch (e) {
      print('Error loading map data: $e');
    }
  }
}

class ClockActionResult {
  final bool success;
  final String message;

  const ClockActionResult({
    required this.success,
    required this.message,
  });
}

final homeRepositoryProvider = Provider((ref) => HomeRepository());

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return HomeNotifier(repository, ref);
});
