import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:urbandriver/features/home/data/models/duty_model.dart';
import '../../data/models/trip_log_models.dart';
import '../../data/repositories/trip_repository.dart';

class PickupStop {
  final String stopNumber;
  final String location;
  final String passengers;
  final String timeWindow;
  final String scheduledTime;
  final String uqId;
  final double latitude;
  final double longitude;
  final String distance;
  final bool isArrived;
  final bool isPickedUp;

  PickupStop({
    required this.stopNumber,
    required this.location,
    required this.passengers,
    required this.timeWindow,
    required this.scheduledTime,
    this.uqId = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    required this.distance,
    this.isArrived = false,
    this.isPickedUp = false,
  });

  PickupStop copyWith({
    String? stopNumber,
    String? location,
    String? passengers,
    String? timeWindow,
    String? scheduledTime,
    String? uqId,
    double? latitude,
    double? longitude,
    String? distance,
    bool? isArrived,
    bool? isPickedUp,
  }) {
    return PickupStop(
      stopNumber: stopNumber ?? this.stopNumber,
      location: location ?? this.location,
      passengers: passengers ?? this.passengers,
      timeWindow: timeWindow ?? this.timeWindow,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      uqId: uqId ?? this.uqId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distance: distance ?? this.distance,
      isArrived: isArrived ?? this.isArrived,
      isPickedUp: isPickedUp ?? this.isPickedUp,
    );
  }
}

class PickupState {
  final List<PickupStop> stops;
  final int currentStopIndex;
  final String progressKey;
  final String dutyNo;
  final String tripStartTime;
  final bool hasStartedTrip;
  final int tripNo;
  final String startCheckpointName;
  final String startCheckpointUqId;
  final double startLatitude;
  final double startLongitude;
  final String startScheduledTime;
  final String endCheckpointName;
  final String endCheckpointUqId;
  final double endLatitude;
  final double endLongitude;
  final String endScheduledTime;
  final Set<String> loggedCheckpointUqIds;
  final bool hasEndedTrip;
  final bool isStartingTrip;
  final bool isEndingTrip;
  final bool startTripFailed;

  PickupState({
    required this.stops,
    this.currentStopIndex = 0,
    this.progressKey = '',
    this.dutyNo = '',
    this.tripStartTime = '',
    this.hasStartedTrip = false,
    this.tripNo = 0,
    this.startCheckpointName = '',
    this.startCheckpointUqId = '',
    this.startLatitude = 0.0,
    this.startLongitude = 0.0,
    this.startScheduledTime = '',
    this.endCheckpointName = '',
    this.endCheckpointUqId = '',
    this.endLatitude = 0.0,
    this.endLongitude = 0.0,
    this.endScheduledTime = '',
    this.loggedCheckpointUqIds = const <String>{},
    this.hasEndedTrip = false,
    this.isStartingTrip = false,
    this.isEndingTrip = false,
    this.startTripFailed = false,
  });

  PickupState copyWith({
    List<PickupStop>? stops,
    int? currentStopIndex,
    String? progressKey,
    String? dutyNo,
    String? tripStartTime,
    bool? hasStartedTrip,
    int? tripNo,
    String? startCheckpointName,
    String? startCheckpointUqId,
    double? startLatitude,
    double? startLongitude,
    String? startScheduledTime,
    String? endCheckpointName,
    String? endCheckpointUqId,
    double? endLatitude,
    double? endLongitude,
    String? endScheduledTime,
    Set<String>? loggedCheckpointUqIds,
    bool? hasEndedTrip,
    bool? isStartingTrip,
    bool? isEndingTrip,
    bool? startTripFailed,
  }) {
    return PickupState(
      stops: stops ?? this.stops,
      currentStopIndex: currentStopIndex ?? this.currentStopIndex,
      progressKey: progressKey ?? this.progressKey,
      dutyNo: dutyNo ?? this.dutyNo,
      tripStartTime: tripStartTime ?? this.tripStartTime,
      hasStartedTrip: hasStartedTrip ?? this.hasStartedTrip,
      tripNo: tripNo ?? this.tripNo,
      startCheckpointName: startCheckpointName ?? this.startCheckpointName,
      startCheckpointUqId: startCheckpointUqId ?? this.startCheckpointUqId,
      startLatitude: startLatitude ?? this.startLatitude,
      startLongitude: startLongitude ?? this.startLongitude,
      startScheduledTime: startScheduledTime ?? this.startScheduledTime,
      endCheckpointName: endCheckpointName ?? this.endCheckpointName,
      endCheckpointUqId: endCheckpointUqId ?? this.endCheckpointUqId,
      endLatitude: endLatitude ?? this.endLatitude,
      endLongitude: endLongitude ?? this.endLongitude,
      endScheduledTime: endScheduledTime ?? this.endScheduledTime,
      loggedCheckpointUqIds: loggedCheckpointUqIds ?? this.loggedCheckpointUqIds,
      hasEndedTrip: hasEndedTrip ?? this.hasEndedTrip,
      isStartingTrip: isStartingTrip ?? this.isStartingTrip,
      isEndingTrip: isEndingTrip ?? this.isEndingTrip,
      startTripFailed: startTripFailed ?? this.startTripFailed,
    );
  }

  PickupStop? get currentStop {
    if (stops.isEmpty || currentStopIndex >= stops.length) return null;
    return stops[currentStopIndex];
  }

  List<PickupStop> get nextStops {
    if (stops.isEmpty || currentStopIndex + 1 >= stops.length) return [];
    return stops.sublist(currentStopIndex + 1);
  }

  bool get allStopsCompleted {
    return stops.every((stop) => stop.isPickedUp);
  }

  int get completedStopsCount {
    return stops.where((stop) => stop.isPickedUp).length;
  }

  bool get hasPersistedDutyProgress {
    return hasStartedTrip ||
        currentStopIndex > 0 ||
        stops.any((stop) => stop.isArrived || stop.isPickedUp);
  }
}

class PickupNotifier extends StateNotifier<PickupState> {
  final TripRepository _repository;
  // Bumping version to v3 to invalidate stale test data
  static const String _progressPrefix = 'pickup_progress_v3_';

  PickupNotifier(this._repository)
      : super(PickupState(
          stops: [],
        ));

  // Load stops from a duty
  Future<void> loadStopsFromDuty(DutyModel? duty) async {
    print('📦 [pickup_provider] loadStopsFromDuty called with: ${duty?.from} → ${duty?.to}');
    if (duty == null) {
      print('❌ [pickup_provider] Duty is null!');
      state = PickupState(stops: []);
      return;
    }

    print('📦 [pickup_provider] Converting ${duty.stops.length} duty stops to pickup stops');
    final pickupStops = duty.stops.map((dutyStop) {
      return PickupStop(
        stopNumber: dutyStop.stopNumber,
        location: dutyStop.location,
        passengers: '${dutyStop.passengers} Passengers',
        timeWindow: 'Pickup Window: ${dutyStop.timeWindow}',
        scheduledTime: dutyStop.timeWindow,
        uqId: dutyStop.uqId,
        latitude: dutyStop.latitude,
        longitude: dutyStop.longitude,
        distance: dutyStop.distance,
      );
    }).toList();

    print('✅ [pickup_provider] Created ${pickupStops.length} pickup stops');
    final progressKey = _buildDutyProgressKey(duty);
    state = PickupState(
      stops: pickupStops,
      currentStopIndex: 0,
      progressKey: progressKey,
      dutyNo: duty.dutyNo,
      tripStartTime: '',
      hasStartedTrip: false,
      tripNo: duty.tripNo ?? 0,
      startCheckpointName: duty.from,
      startCheckpointUqId: duty.fromUqId ?? '',
      startLatitude: duty.pickupLatitude,
      startLongitude: duty.pickupLongitude,
      startScheduledTime: duty.joiningTime,
      endCheckpointName: duty.to,
      endCheckpointUqId: duty.toUqId ?? '',
      endLatitude: duty.dropLatitude,
      endLongitude: duty.dropLongitude,
      endScheduledTime: duty.closeTime,
    );

    await _restoreSavedProgress();
  }

  String _buildDutyProgressKey(DutyModel duty) {
    String clean(String value) {
      return value.trim().toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '_');
    }

    final datePart = '${duty.date.year.toString().padLeft(4, '0')}-'
        '${duty.date.month.toString().padLeft(2, '0')}-'
        '${duty.date.day.toString().padLeft(2, '0')}';
    final tripPart = duty.tripNo?.toString() ?? 'NA';
    final dutyPart = clean(duty.dutyNo);
    final routePart = clean((duty.routeCode ?? duty.route).isNotEmpty ? (duty.routeCode ?? duty.route) : 'NA');
    final joinPart = clean(duty.joiningTime);
    final fromPart = clean((duty.fromUqId ?? duty.from).isNotEmpty ? (duty.fromUqId ?? duty.from) : 'NA');
    final toPart = clean((duty.toUqId ?? duty.to).isNotEmpty ? (duty.toUqId ?? duty.to) : 'NA');

    return '${dutyPart}_${routePart}_${tripPart}_${joinPart}_${fromPart}_${toPart}_$datePart';
  }

  Future<void> _restoreSavedProgress() async {
    if (state.progressKey.isEmpty || state.stops.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_progressPrefix${state.progressKey}');
      if (raw == null || raw.isEmpty) return;

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;

      final savedStops = decoded['stops'];
      final hasStartedTrip = decoded['hasStartedTrip'] == true;
      final tripStartTime = (decoded['tripStartTime'] ?? '').toString();
      final hasEndedTrip = decoded['hasEndedTrip'] == true;
      final loggedCheckpointsRaw = decoded['loggedCheckpointUqIds'];
      final loggedCheckpointUqIds = <String>{};
      if (loggedCheckpointsRaw is List) {
        for (final item in loggedCheckpointsRaw) {
          final value = item?.toString().trim() ?? '';
          if (value.isNotEmpty) {
            loggedCheckpointUqIds.add(value);
          }
        }
      }

      var restoredStops = List<PickupStop>.from(state.stops);

      if (savedStops is List) {
        for (var index = 0; index < restoredStops.length && index < savedStops.length; index++) {
          final stopData = savedStops[index];
          if (stopData is Map<String, dynamic>) {
            restoredStops[index] = restoredStops[index].copyWith(
              isArrived: stopData['isArrived'] == true,
              isPickedUp: stopData['isPickedUp'] == true,
            );
          }
        }
      }

      final nextIndex = restoredStops.indexWhere((stop) => !stop.isPickedUp);

      state = state.copyWith(
        stops: restoredStops,
        currentStopIndex: nextIndex == -1 ? restoredStops.length : nextIndex,
        hasStartedTrip: hasStartedTrip || restoredStops.any((s) => s.isPickedUp || s.isArrived),
        tripStartTime: tripStartTime,
        hasEndedTrip: hasEndedTrip,
        loggedCheckpointUqIds: loggedCheckpointUqIds,
      );

      print('✅ [pickup_provider] Restored progress for ${state.progressKey}. Completed: ${state.completedStopsCount}/${state.stops.length}');
    } catch (e) {
      print('⚠️ [pickup_provider] Failed to restore progress: $e');
    }
  }

  Future<void> _saveProgress() async {
    if (state.progressKey.isEmpty) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final data = {
        'progressKey': state.progressKey,
        'hasStartedTrip': state.hasStartedTrip,
        'hasEndedTrip': state.hasEndedTrip,
        'tripStartTime': state.tripStartTime,
        'currentStopIndex': state.currentStopIndex,
        'loggedCheckpointUqIds': state.loggedCheckpointUqIds.toList(),
        'stops': state.stops
            .map((stop) => {
                  'isArrived': stop.isArrived,
                  'isPickedUp': stop.isPickedUp,
                })
            .toList(),
      };

      await prefs.setString('$_progressPrefix${state.progressKey}', jsonEncode(data));
    } catch (e) {
      print('⚠️ [pickup_provider] Failed to save progress: $e');
    }
  }

  Future<void> startTripIfNeeded() async {
    // Guard: skip if already started, currently starting, failed once, or missing duty
    if (state.hasStartedTrip ||
        state.isStartingTrip ||
        state.startTripFailed ||
        state.dutyNo.isEmpty) {
      return;
    }

    // Always use the duty's starting terminal checkpoint (fromUqId / pickupLatitude)
    // NOT the first passenger stop — backend verifies against the route's terminal coords
    final checkpointName = state.startCheckpointName.trim();
    if (checkpointName.isEmpty) return;

    final scheduledTime = state.startScheduledTime.trim();
    final uqId = state.startCheckpointUqId.trim();
    final latitude = state.startLatitude;
    final longitude = state.startLongitude;

    final now = DateTime.now();
    final request = TripLogRequest(
      dutyNo: state.dutyNo,
      tripNo: state.tripNo,
      checkpointName: checkpointName,
      scheduledTime: _formatScheduledTime(scheduledTime),
      loggedTime: _formatTime24(now),
      uqId: uqId,
      latitude: latitude,
      longitude: longitude,
    );

    state = state.copyWith(isStartingTrip: true);
    print('🚗 [PickupProvider] Starting trip for duty: ${state.dutyNo}, uqId: $uqId, lat: $latitude, lng: $longitude');
    final response = await _repository.startTrip(request);

    if (response.success) {
      print('✅ [PickupProvider] Trip started successfully');
      state = state.copyWith(
        hasStartedTrip: true,
        tripStartTime: _formatTime24(now),
        isStartingTrip: false,
        startTripFailed: false,
      );
    } else {
      print('⚠️ [PickupProvider] Trip start failed: ${response.message}');
      // Set startTripFailed=true so we do NOT retry on every markArrived() call.
      // Still set tripStartTime so log-trip and end-trips can proceed.
      state = state.copyWith(
        hasStartedTrip: false,
        tripStartTime: _formatTime24(now),
        isStartingTrip: false,
        startTripFailed: true,
      );
    }

    await _saveProgress();
  }

  // Format time as HH:mm:ss (24-hour)
  String _formatTime24(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  // Convert scheduled time to HH:mm:ss. Accepts "07:30 AM" or "08:30:00".
  String _formatScheduledTime(String scheduledTime) {
    try {
      if (scheduledTime.contains('AM') || scheduledTime.contains('PM')) {
        final timeParts = scheduledTime.replaceAll(' AM', '').replaceAll(' PM', '').split(':');
        int hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);

        if (scheduledTime.contains('PM') && hour != 12) {
          hour += 12;
        } else if (scheduledTime.contains('AM') && hour == 12) {
          hour = 0;
        }

        return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}:00';
      }

      // If already in HH:mm:ss, return as-is
      if (scheduledTime.length == 8 && scheduledTime.contains(':')) {
        return scheduledTime;
      }

      // If HH:mm, append seconds
      if (scheduledTime.length == 5 && scheduledTime.contains(':')) {
        return '$scheduledTime:00';
      }
    } catch (e) {
      print('⚠️ [PickupProvider] Failed to parse scheduledTime: $e');
    }

    return scheduledTime;
  }

  TripLogRequest _buildTripLogRequest(PickupStop stop, String loggedTime) {
    final formattedLoggedTime = _formatTime24(DateTime.parse(loggedTime));

    return TripLogRequest(
      dutyNo: state.dutyNo,
      tripNo: state.tripNo,
      checkpointName: stop.location,
      scheduledTime: _formatScheduledTime(stop.scheduledTime),
      loggedTime: formattedLoggedTime,
      uqId: stop.uqId,
      latitude: stop.latitude,
      longitude: stop.longitude,
    );
  }

  Future<void> markArrived() async {
    final currentStop = state.currentStop;
    if (currentStop == null) return;
    if (currentStop.isPickedUp || currentStop.isArrived) {
      return;
    }

    await startTripIfNeeded();

    final updatedStops = List<PickupStop>.from(state.stops);
    updatedStops[state.currentStopIndex] = currentStop.copyWith(isArrived: true);
    
    state = state.copyWith(stops: updatedStops);
    await _saveProgress();

    if (state.dutyNo.isNotEmpty &&
        !state.loggedCheckpointUqIds.contains(currentStop.uqId)) {
      final loggedTime = DateTime.now().toIso8601String();
      final request = _buildTripLogRequest(currentStop, loggedTime);
      print('🚗 [PickupProvider] Logging trip checkpoint: ${currentStop.location}');
      final response = await _repository.logTrip(request);
      if (response.success) {
        print('✅ [PickupProvider] Trip checkpoint logged');
        state = state.copyWith(
          loggedCheckpointUqIds: {
            ...state.loggedCheckpointUqIds,
            currentStop.uqId,
          },
        );
        await _saveProgress();
      } else {
        print('⚠️ [PickupProvider] Trip checkpoint log failed: ${response.message}');
      }
    }
  }

  Future<void> markPickedUp() async {
    final currentStop = state.currentStop;
    if (currentStop == null) return;
    if (currentStop.isPickedUp) {
      return;
    }

    print('✅ [pickup_provider] Marking pickup #${state.currentStopIndex + 1} as picked up');

    final updatedStops = List<PickupStop>.from(state.stops);
    updatedStops[state.currentStopIndex] = currentStop.copyWith(
      isArrived: true,
      isPickedUp: true,
    );

    state = state.copyWith(stops: updatedStops);

    // Move to next stop if available
    if (state.currentStopIndex < state.stops.length - 1) {
      state = state.copyWith(currentStopIndex: state.currentStopIndex + 1);
      print('✅ [pickup_provider] Advanced to next stop: #${state.currentStopIndex + 1}');
    } else {
      state = state.copyWith(currentStopIndex: state.stops.length);
      print('✅ [pickup_provider] All stops completed!');
    }

    await _saveProgress();
  }

  Future<void> markNoShow() async {
    // Mark as picked up (no show) and move to next stop
    await markPickedUp();
  }

  Future<void> endTrip() async {
    if (state.dutyNo.isEmpty ||
        state.endCheckpointName.isEmpty ||
        state.hasEndedTrip ||
        state.isEndingTrip) {
      return;
    }

    final now = DateTime.now();
    // Always use the duty's ending terminal checkpoint (toUqId / dropLatitude)
    // NOT the last passenger stop — backend verifies against the route's terminal coords
    final checkpointName = state.endCheckpointName.trim();
    final scheduledTime = state.endScheduledTime.trim();
    final uqId = state.endCheckpointUqId.trim();
    final latitude = state.endLatitude;
    final longitude = state.endLongitude;

    final request = TripLogRequest(
      dutyNo: state.dutyNo,
      tripNo: state.tripNo,
      checkpointName: checkpointName,
      scheduledTime: _formatScheduledTime(scheduledTime),
      loggedTime: _formatTime24(now),
      uqId: uqId,
      latitude: latitude,
      longitude: longitude,
    );
    state = state.copyWith(isEndingTrip: true);
    print('🚗 [PickupProvider] Ending trip for duty: ${state.dutyNo}');
    final response = await _repository.endTrip(request);

    if (response.success) {
      print('✅ [PickupProvider] Trip ended successfully');
      state = state.copyWith(hasEndedTrip: true, isEndingTrip: false);
      await _saveProgress();
    } else {
      print('⚠️ [PickupProvider] Trip end failed: ${response.message}');
      state = state.copyWith(isEndingTrip: false);
    }
  }

  void resetStops() {
    state = PickupState(stops: [], currentStopIndex: 0);
  }
}

final pickupProvider = StateNotifierProvider<PickupNotifier, PickupState>((ref) {
  final repository = ref.watch(tripRepositoryProvider);
  return PickupNotifier(repository);
});

final tripRepositoryProvider = Provider((ref) => TripRepository());
