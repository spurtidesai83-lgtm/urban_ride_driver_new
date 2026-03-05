import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/duty_model.dart';
import '../../data/models/driving_data_model.dart';
import '../../data/models/clock_models.dart';
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
  final String? lastClockRouteIdentifier;

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
    this.lastClockRouteIdentifier,
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
    String? lastClockRouteIdentifier,
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
      lastClockRouteIdentifier:
          lastClockRouteIdentifier ?? this.lastClockRouteIdentifier,
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
  static const String _lastClockRouteKey = 'home_last_clock_route';

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
    _restoreLastClockRoute();

    // Load dashboard data from API (no mock data fallback)
    fetchDashboard();
  }

  Future<void> _restoreLastClockRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final route = prefs.getString(_lastClockRouteKey)?.trim();
      if (route != null && route.isNotEmpty && state.lastClockRouteIdentifier != route) {
        state = state.copyWith(lastClockRouteIdentifier: route);
      }
    } catch (_) {}
  }

  Future<void> _persistLastClockRoute(String routeIdentifier) async {
    final route = routeIdentifier.trim();
    if (route.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastClockRouteKey, route);
    } catch (_) {}
  }

  String? _bestRouteIdentifierFromDuty(DutyModel? duty) {
    final routeCode = duty?.routeCode?.trim();
    if (routeCode != null && routeCode.isNotEmpty) return routeCode;

    final route = duty?.route.trim();
    if (route != null && route.isNotEmpty) return route;

    return null;
  }

  String? _resolveRouteIdentifierForClockOut() {
    final currentDutyRoute = _bestRouteIdentifierFromDuty(state.currentDuty);
    if (currentDutyRoute != null) return currentDutyRoute;

    if (state.duties.isNotEmpty) {
      final todayDutyRoute = _bestRouteIdentifierFromDuty(state.duties.first);
      if (todayDutyRoute != null) return todayDutyRoute;
    }

    if (state.allDuties.isNotEmpty) {
      final anyDutyRoute = _bestRouteIdentifierFromDuty(state.allDuties.first);
      if (anyDutyRoute != null) return anyDutyRoute;
    }

    return state.lastClockRouteIdentifier;
  }

  List<String> _clockOutRouteCandidates() {
    final candidates = <String>[];

    void addCandidate(String? value) {
      final candidate = value?.trim();
      if (candidate == null || candidate.isEmpty) return;
      if (!candidates.contains(candidate)) {
        candidates.add(candidate);
      }
    }

    addCandidate(_resolveRouteIdentifierForClockOut());
    addCandidate(state.currentDuty?.dutyNo);
    addCandidate(state.currentDuty?.route);

    final today = DateTime.now();
    final todayDuty = state.allDuties.where((duty) {
      return duty.date.year == today.year &&
          duty.date.month == today.month &&
          duty.date.day == today.day;
    }).toList();

    if (todayDuty.isNotEmpty) {
      final fallbackDuty = todayDuty.last;
      addCandidate(fallbackDuty.routeCode);
      addCandidate(fallbackDuty.route);
      addCandidate(fallbackDuty.dutyNo);
    }

    addCandidate(state.lastClockRouteIdentifier);
    return candidates;
  }

  List<String> _clockInRouteCandidates() {
    final candidates = <String>[];

    void addCandidate(String? value) {
      final candidate = value?.trim();
      if (candidate == null || candidate.isEmpty) return;
      if (!candidates.contains(candidate)) {
        candidates.add(candidate);
      }
    }

    addCandidate(_bestRouteIdentifierFromDuty(state.currentDuty));
    addCandidate(state.currentDuty?.route);
    addCandidate(state.currentDuty?.dutyNo);

    final today = DateTime.now();
    final todayDuty = state.allDuties.where((duty) {
      return duty.date.year == today.year &&
          duty.date.month == today.month &&
          duty.date.day == today.day;
    }).toList();

    if (todayDuty.isNotEmpty) {
      final fallbackDuty = todayDuty.first;
      addCandidate(fallbackDuty.routeCode);
      addCandidate(fallbackDuty.route);
      addCandidate(fallbackDuty.dutyNo);
    }

    addCandidate(state.lastClockRouteIdentifier);
    return candidates;
  }

  bool _isRetryableClockInError(String message) {
    final error = message.toLowerCase();
    if (error.contains('401') || error.contains('unauthorized') || error.contains('token')) {
      return false;
    }

    return error.contains('400') ||
        error.contains('bad request') ||
        error.contains('route') ||
        error.contains('identifier') ||
        error.contains('invalid') ||
        error.contains('not found') ||
        error.contains('500') ||
        error.contains('internal server error');
  }

  Future<(ClockResponse, String)> _clockInWithFallback(
    double latitude,
    double longitude,
  ) async {
    final identifiers = _clockInRouteCandidates();
    if (identifiers.isEmpty) {
      throw Exception('Route identifier is required to clock in');
    }

    Exception? lastException;

    for (final identifier in identifiers) {
      try {
        print('🟢 Clock In - Trying identifier: $identifier');
        final response = await _repository.clockIn(latitude, longitude, identifier);
        return (response, identifier);
      } catch (e) {
        if (_isRetryableClockInError(e.toString())) {
          lastException = Exception(e.toString());
          continue;
        }
        rethrow;
      }
    }

    if (lastException != null) {
      throw lastException;
    }

    throw Exception('Clock in failed');
  }

  bool _isRetryableClockOutError(String message) {
    final error = message.toLowerCase();
    return error.contains('500') ||
        error.contains('internal server error') ||
        error.contains('get-coordinates') ||
        error.contains('external service error');
  }

  Future<ClockResponse> _clockOutWithFallback(double latitude, double longitude) async {
    final identifiers = _clockOutRouteCandidates();
    if (identifiers.isEmpty) {
      throw Exception('Route identifier is required to clock out');
    }

    Exception? lastException;

    for (final identifier in identifiers) {
      try {
        print('🟢 Clock Out - Trying identifier: $identifier');
        final response = await _repository.clockOut(latitude, longitude, identifier);
        if (response.success) {
          return response;
        }

        if (_isRetryableClockOutError(response.message)) {
          lastException = Exception(response.message);
          continue;
        }

        return response;
      } catch (e) {
        if (_isRetryableClockOutError(e.toString())) {
          lastException = Exception(e.toString());
          continue;
        }
        rethrow;
      }
    }

    if (lastException != null) {
      throw lastException;
    }

    throw Exception('Clock out failed');
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
    state = state.copyWith(isLoading: true, errorMessage: null);

    bool isClockedIn = state.isClockedIn;
    int totalTrips = 0;
    String totalSteeringTime = '--';
    int totalKms = 0;
    String? errorMsg;

    try {
      final dashboard = await _repository.getDashboard();
      final data = dashboard.data;

      isClockedIn = state.clockInManuallySet ? state.isClockedIn : data.isClockedIn;
      totalTrips = data.noOfTrips;
      totalSteeringTime = data.steeringTime;
      totalKms = data.totalKms;
    } catch (e) {
      print('⚠️ Dashboard stats fetch failed: $e');
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        errorMsg = 'Authentication failed - Please re-login';
      }
    }

    List<DutyModel> finalDuties = [];
    List<DutyModel> weeklyDuties = [];
    List<DutyModel> tomorrowDuties = [];

    try {
      try {
        final todaySchedule = await _repository.getTodaySchedule();
        finalDuties = _repository.convertTodayScheduleToDuties(todaySchedule);
        print('📋 Today schedule loaded ${finalDuties.length} duties');
      } catch (e) {
        print('⚠️ Today schedule fetch failed: $e');
        if (errorMsg == null) errorMsg = 'Failed to load today\'s schedule';
      }

      weeklyDuties = await _fetchWeeklyScheduleInBackground();

      tomorrowDuties = await _fetchTomorrowSchedule(weeklyFallbackDuties: weeklyDuties);

      var allDutiesCombined = _mergeAndDeduplicateDuties(finalDuties, weeklyDuties);
      allDutiesCombined = _mergeAndDeduplicateDuties(allDutiesCombined, tomorrowDuties);

      final hasFreshScheduleData = finalDuties.isNotEmpty || allDutiesCombined.isNotEmpty;
      final shouldKeepExistingSchedules = !hasFreshScheduleData && state.allDuties.isNotEmpty;

      final dutiesToApply = shouldKeepExistingSchedules ? state.duties : finalDuties;
      final allDutiesToApply = shouldKeepExistingSchedules ? state.allDuties : allDutiesCombined;

        final preservedDutyIndex = dutiesToApply.isEmpty
          ? 0
          : state.currentDutyIndex.clamp(0, dutiesToApply.length - 1);
        final resolvedAllDutiesCompleted = state.allDutiesCompleted
          ? dutiesToApply.isEmpty || preservedDutyIndex >= dutiesToApply.length - 1
          : dutiesToApply.isEmpty && errorMsg == null;

      if (shouldKeepExistingSchedules) {
        print('⚠️ [HomeProvider] Schedule APIs unavailable, keeping last synced duties.');
      }

      state = state.copyWith(
        isLoading: false,
        isClockedIn: isClockedIn,
        totalTrips: totalTrips,
        totalSteeringTime: totalSteeringTime,
        totalKms: totalKms,
        duties: dutiesToApply,
        allDuties: allDutiesToApply,
        currentDutyIndex: preservedDutyIndex,
        allDutiesCompleted: resolvedAllDutiesCompleted,
        errorMessage: dutiesToApply.isEmpty && allDutiesToApply.isEmpty ? errorMsg : null,
        lastClockRouteIdentifier: state.lastClockRouteIdentifier ??
            _bestRouteIdentifierFromDuty(dutiesToApply.isNotEmpty ? dutiesToApply.first : null),
      );

      final routeToPersist = state.lastClockRouteIdentifier;
      if (routeToPersist != null && routeToPersist.isNotEmpty) {
        _persistLastClockRoute(routeToPersist);
      }

      print('🏠 [HomeProvider] Dashboard loaded. Today\'s duties: ${finalDuties.length}, Total unique duties: ${allDutiesCombined.length}');

    } catch (e) {
      print('❌ Critical Dashboard fetch failed: $e');

      state = state.copyWith(
        isLoading: false,
        duties: [],
        allDuties: [],
        errorMessage: 'Failed to load data: $e',
      );
    }
  }

  /// Merges two lists of duties and removes duplicates based on dutyNo, tripNo AND date.
  List<DutyModel> _mergeAndDeduplicateDuties(List<DutyModel> list1, List<DutyModel> list2) {
    final combined = [...list1, ...list2];
    final uniqueKeys = <String>{};
    final uniqueDuties = <DutyModel>[];
    for (final duty in combined) {
      // Use a combination of dutyNo, tripNo and Date to identify unique trips
      // Including date is crucial for recurring weekly schedules
      final dateStr = '${duty.date.year}-${duty.date.month}-${duty.date.day}';
      final key = '${duty.dutyNo}_${duty.tripNo}_$dateStr';
      
      if (uniqueKeys.add(key)) {
        uniqueDuties.add(duty);
      }
    }
    return uniqueDuties;
  }

  /// Fetches the weekly schedule without altering the main loading state.
  Future<List<DutyModel>> _fetchWeeklyScheduleInBackground() async {
    try {
      final scheduleResponse = await _repository.getWeeklySchedule();
      final weeklyDuties = _repository.convertWeeklyScheduleToDuties(scheduleResponse);
      print('📅 [HomeProvider] Weekly schedule fetched in background. Found ${weeklyDuties.length} duties.');
      return weeklyDuties;
    } catch (e) {
      print('❌ [HomeProvider] Weekly schedule fetch failed: $e');
      // Return an empty list on failure, don't block the UI or show an error
      return [];
    }
  }

  /// Fetches tomorrow's schedule explicitly.
  /// If the tomorrow endpoint fails (for example HTTP 500),
  /// fallback to duties for tomorrow derived from weekly data.
  Future<List<DutyModel>> _fetchTomorrowSchedule({
    List<DutyModel> weeklyFallbackDuties = const [],
  }) async {
    try {
      final scheduleResponse = await _repository.getTomorrowSchedule();
      final tomorrowDuties = _repository.convertTomorrowScheduleToDuties(scheduleResponse); // Uses same response type
      print('📅 [HomeProvider] Tomorrow schedule fetched. Found ${tomorrowDuties.length} duties.');
      return tomorrowDuties;
    } catch (e) {
      print('⚠️ [HomeProvider] Tomorrow endpoint failed: $e');

      if (weeklyFallbackDuties.isNotEmpty) {
        final now = DateTime.now();
        final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));

        final fallbackTomorrowDuties = weeklyFallbackDuties
            .where((duty) => _isSameDay(duty.date, tomorrow))
            .toList();

        print('📅 [HomeProvider] Using weekly fallback for tomorrow. Found ${fallbackTomorrowDuties.length} duties.');
        return fallbackTomorrowDuties;
      }

      return [];
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
      allDutiesCompleted: dateDuties.isEmpty, // Set completed if no duties for date
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
        
        final routeCandidates = _clockInRouteCandidates();
        print('🟢 Clock In - Candidates: $routeCandidates (routeCode=${state.currentDuty?.routeCode}, route=${state.currentDuty?.route}, dutyNo=${state.currentDuty?.dutyNo})');

        if (routeCandidates.isEmpty) {
          print('🔴 Route identifier is required for clock in');
          state = state.copyWith(isClockActionLoading: false);
          return const ClockActionResult(
            success: false,
            message: 'Route identifier is required to clock in',
          );
        }

        // Call clock in API with route identifier fallbacks
        final (response, usedRouteIdentifier) = await _clockInWithFallback(
          position.latitude,
          position.longitude,
        );
        print('🟢 API Response: success=${response.success}, message=${response.message}');

        if (response.success) {
          print('✅ Clock in successful!');
          await _persistLastClockRoute(usedRouteIdentifier);
          state = state.copyWith(
            isClockedIn: true,
            clockInManuallySet: false, // Reset flag since it's from API
            isClockActionLoading: false,
            lastClockRouteIdentifier: usedRouteIdentifier,
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
        final routeIdentifier = _resolveRouteIdentifierForClockOut();
        
        print('🟢 Clock Out - Using: $routeIdentifier (routeCode=${state.currentDuty?.routeCode}, route=${state.currentDuty?.route})');
        
        if (routeIdentifier == null || routeIdentifier.isEmpty) {
          print('🔴 Route identifier is required for clock out');
          state = state.copyWith(isClockActionLoading: false);
          return const ClockActionResult(
            success: false,
            message: 'Route identifier is required to clock out',
          );
        }

        // Call clock out API with fallbacks for backend route lookup failures
        final response = await _clockOutWithFallback(
          position.latitude,
          position.longitude,
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
      final routeIdentifier = _resolveRouteIdentifierForClockOut();
      
      print('🟢 Clock Out (Sync) - Route: ${state.currentDuty?.route}, RouteCode: ${state.currentDuty?.routeCode}, Using: $routeIdentifier');
      
      if (routeIdentifier == null || routeIdentifier.isEmpty) {
        print('🔴 Route identifier is required for clock out');
        state = state.copyWith(isClockActionLoading: false);
        return const ClockActionResult(
          success: false,
          message: 'Route identifier is required to clock out',
        );
      }

      // Call clock out API with fallbacks for backend route lookup failures
      final response = await _clockOutWithFallback(
        position.latitude,
        position.longitude,
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
    if (state.duties.isEmpty) {
      state = state.copyWith(allDutiesCompleted: true, currentDutyIndex: 0);
      return;
    }

    final activeDuties = List<DutyModel>.from(state.duties);
    final removeIndex = state.currentDutyIndex.clamp(0, activeDuties.length - 1);
    activeDuties.removeAt(removeIndex);

    if (activeDuties.isEmpty) {
      state = state.copyWith(
        duties: activeDuties,
        currentDutyIndex: 0,
        allDutiesCompleted: true,
      );
      return;
    }

    final nextIndex = removeIndex.clamp(0, activeDuties.length - 1);
    state = state.copyWith(
      duties: activeDuties,
      currentDutyIndex: nextIndex,
      allDutiesCompleted: false,
    );
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
