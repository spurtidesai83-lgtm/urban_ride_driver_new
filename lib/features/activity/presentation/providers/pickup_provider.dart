import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbandriver/features/home/data/models/duty_model.dart';
import '../../data/models/trip_log_models.dart';
import '../../data/repositories/trip_repository.dart';

class PickupStop {
  final String stopNumber;
  final String location;
  final String passengers;
  final String timeWindow;
  final String scheduledTime;
  final String distance;
  final bool isArrived;
  final bool isPickedUp;

  PickupStop({
    required this.stopNumber,
    required this.location,
    required this.passengers,
    required this.timeWindow,
    required this.scheduledTime,
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
      distance: distance ?? this.distance,
      isArrived: isArrived ?? this.isArrived,
      isPickedUp: isPickedUp ?? this.isPickedUp,
    );
  }
}

class PickupState {
  final List<PickupStop> stops;
  final int currentStopIndex;
  final String dutyNo;
  final String tripStartTime;
  final bool hasStartedTrip;

  PickupState({
    required this.stops,
    this.currentStopIndex = 0,
    this.dutyNo = '',
    this.tripStartTime = '',
    this.hasStartedTrip = false,
  });

  PickupState copyWith({
    List<PickupStop>? stops,
    int? currentStopIndex,
    String? dutyNo,
    String? tripStartTime,
    bool? hasStartedTrip,
  }) {
    return PickupState(
      stops: stops ?? this.stops,
      currentStopIndex: currentStopIndex ?? this.currentStopIndex,
      dutyNo: dutyNo ?? this.dutyNo,
      tripStartTime: tripStartTime ?? this.tripStartTime,
      hasStartedTrip: hasStartedTrip ?? this.hasStartedTrip,
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
}

class PickupNotifier extends StateNotifier<PickupState> {
  final TripRepository _repository;

  PickupNotifier(this._repository)
      : super(PickupState(
          stops: [],
        ));

  // Load stops from a duty
  void loadStopsFromDuty(DutyModel? duty) {
    print('📦 [pickup_provider] loadStopsFromDuty called with: ${duty?.from} → ${duty?.to}');
    if (duty == null || duty.stops.isEmpty) {
      print('❌ [pickup_provider] Duty is null or has no stops!');
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
        distance: dutyStop.distance,
      );
    }).toList();

    print('✅ [pickup_provider] Created ${pickupStops.length} pickup stops');
    state = PickupState(
      stops: pickupStops,
      currentStopIndex: 0,
      dutyNo: duty.dutyNo,
      tripStartTime: '',
      hasStartedTrip: false,
    );
  }

  Future<void> startTripIfNeeded() async {
    if (state.hasStartedTrip || state.stops.isEmpty || state.dutyNo.isEmpty) {
      return;
    }

    final currentStop = state.currentStop;
    if (currentStop == null) return;

    final now = DateTime.now();
    final request = TripLogRequest(
      dutyNo: state.dutyNo,
      tripNo: 0,
      checkpointName: currentStop.location,
      scheduledTime: _formatScheduledTime(currentStop.scheduledTime),
      loggedTime: _formatTime24(now),
    );

    print('🚗 [PickupProvider] Starting trip for duty: ${state.dutyNo}');
    final response = await _repository.startTrip(request);
    
    if (response.success) {
      print('✅ [PickupProvider] Trip started successfully');
      state = state.copyWith(
        hasStartedTrip: true,
        tripStartTime: _formatTime24(now),
      );
    } else {
      print('⚠️ [PickupProvider] Trip start failed: ${response.message}');
      // Still mark as started to allow flow to continue
      state = state.copyWith(
        hasStartedTrip: true,
        tripStartTime: _formatTime24(now),
      );
    }
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
      tripNo: state.currentStopIndex + 1,
      checkpointName: stop.location,
      scheduledTime: _formatScheduledTime(stop.scheduledTime),
      loggedTime: formattedLoggedTime,
    );
  }

  Future<void> markArrived() async {
    final currentStop = state.currentStop;
    if (currentStop == null) return;

    await startTripIfNeeded();

    final updatedStops = List<PickupStop>.from(state.stops);
    updatedStops[state.currentStopIndex] = currentStop.copyWith(isArrived: true);
    
    state = state.copyWith(stops: updatedStops);

    if (state.dutyNo.isNotEmpty && state.tripStartTime.isNotEmpty) {
      final loggedTime = DateTime.now().toIso8601String();
      final request = _buildTripLogRequest(currentStop, loggedTime);
      print('🚗 [PickupProvider] Logging trip checkpoint: ${currentStop.location}');
      final response = await _repository.logTrip(request);
      if (response.success) {
        print('✅ [PickupProvider] Trip checkpoint logged');
      } else {
        print('⚠️ [PickupProvider] Trip checkpoint log failed: ${response.message}');
      }
    }
  }

  Future<void> markPickedUp() async {
    final currentStop = state.currentStop;
    if (currentStop == null) return;

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
      print('✅ [pickup_provider] All stops completed!');
    }
  }

  Future<void> markNoShow() async {
    // Mark as picked up (no show) and move to next stop
    await markPickedUp();
  }

  Future<void> endTrip() async {
    final currentStop = state.currentStop;
    if (currentStop == null || state.dutyNo.isEmpty || state.tripStartTime.isEmpty) {
      return;
    }

    final loggedTime = DateTime.now().toIso8601String();
    final request = _buildTripLogRequest(currentStop, loggedTime);
    print('🚗 [PickupProvider] Ending trip for duty: ${state.dutyNo}');
    final response = await _repository.endTrip(request);
    
    if (response.success) {
      print('✅ [PickupProvider] Trip ended successfully');
    } else {
      print('⚠️ [PickupProvider] Trip end failed: ${response.message}');
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
