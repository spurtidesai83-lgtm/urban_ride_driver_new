import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/trip_model.dart';
import '../../data/models/live_trip_model.dart';
import '../../data/repositories/activity_repository.dart';
import 'package:urbandriver/features/home/presentation/providers/home_provider.dart';
import 'package:urbandriver/features/home/data/models/duty_model.dart';

class ActivityState {
  final List<TripModel> allTrips;
  final String activeView; // 'trips' | 'overview'
  final String activeTab; // 'all' | 'scheduled' | 'upcoming' | 'ongoing'
  final String timeFilter; // 'Today' | 'This Month' | 'This Year' | 'All Time'
  final bool isLoading;

  ActivityState({
    this.allTrips = const [],
    this.activeView = 'trips',
    this.activeTab = 'ongoing',
    this.timeFilter = 'All Time',
    this.isLoading = false,
  });

  ActivityState copyWith({
    List<TripModel>? allTrips,
    String? activeView,
    String? activeTab,
    String? timeFilter,
    bool? isLoading,
  }) {
    return ActivityState(
      allTrips: allTrips ?? this.allTrips,
      activeView: activeView ?? this.activeView,
      activeTab: activeTab ?? this.activeTab,
      timeFilter: timeFilter ?? this.timeFilter,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  List<TripModel> get filteredTrips {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    bool isSameDate(DateTime a, DateTime b) {
      return a.year == b.year && a.month == b.month && a.day == b.day;
    }
    
    // 1. Filter by tab
    List<TripModel> trips = [];
    switch (activeTab) {
      case 'scheduled':
        // Show all of today's trips that are not yet completed.
        // This includes the live one and any others scheduled for today.
        trips = allTrips.where((t) => isSameDate(t.date, today) && t.status != 'Completed').toList();
        break;
      case 'upcoming':
        // Show trips that are specifically for tomorrow (from tomorrow API)
        final tomorrow = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
        trips = allTrips.where((t) => isSameDate(t.date, tomorrow)).toList();
        break;
      case 'ongoing':
        // Show only the current live trip.
        trips = allTrips.where((t) => t.status == 'Live').toList();
        break;
      case 'all':
      default:
        trips = allTrips;
        break;
    }

    // 2. Filter by time
    return trips.where((trip) {
      final tripDate = DateTime(trip.date.year, trip.date.month, trip.date.day);
      if (timeFilter == 'Today') {
        return tripDate.isAtSameMomentAs(today);
      } else if (timeFilter == 'This Month') {
        return trip.date.month == now.month && trip.date.year == now.year;
      } else if (timeFilter == 'This Year') {
        return trip.date.year == now.year;
      }
      return true;
    }).toList();
  }
}

class ActivityNotifier extends StateNotifier<ActivityState> {
  final ActivityRepository _repository;

  ActivityNotifier(this._repository) : super(ActivityState());

  // Convert DutyModel to TripModel
  TripModel _dutyToTrip(DutyModel duty, {bool isLive = false}) {
    if (duty.dutyNo == 'OFF') {
      return TripModel(
        id: 'OFF_${duty.date.toIso8601String()}',
        status: 'OFF',
        from: '',
        to: '',
        date: duty.date,
        timeDisplay: '',
        startTime: '',
        endTime: '',
        tripType: 'Day Off',
        steeringTime: '00:00',
        buttonText: '',
      );
    }

    final uniqueTripId = duty.tripNo != null
        ? '${duty.dutyNo}_${duty.tripNo}_${duty.date.year}-${duty.date.month}-${duty.date.day}'
        : '${duty.dutyNo}_${duty.joiningTime}_${duty.from}_${duty.to}_${duty.date.year}-${duty.date.month}-${duty.date.day}';

    return TripModel(
      id: uniqueTripId,
      status: isLive ? 'Live' : (duty.isCompleted ? 'Completed' : 'Scheduled'),
      from: duty.from,
      to: duty.to,
      date: duty.date,
      timeDisplay: duty.reportingTime,
      startTime: duty.joiningTime,
      endTime: duty.closeTime,
      tripType: duty.serviceType ?? 'Shared Cab', // From backend or default
      steeringTime: duty.steeringTime ?? duty.joiningTime, // Use steering time or fall back to joining time
      restTime: duty.restTime,
      kms: duty.tripKms,
      buttonText: isLive ? 'View Live' : 'View Details',
    );
  }

  TripModel _liveTripToTrip(LiveTripModel liveTrip) {
    final now = DateTime.now();
    final fallbackDate = DateTime(now.year, now.month, now.day);

    return TripModel(
      id: liveTrip.tripNo.toString(),
      status: 'Live',
      from: liveTrip.fromLocation,
      to: liveTrip.toLocation,
      date: liveTrip.tripDate ?? fallbackDate,
      timeDisplay: liveTrip.reportingTime,
      startTime: liveTrip.startTime,
      endTime: liveTrip.endTime,
      tripType: 'Live Trip',
      steeringTime: liveTrip.steering,
      restTime: liveTrip.rest,
      kms: liveTrip.kms,
      buttonText: 'View Live',
    );
  }

  // Update trips from duties
  Future<void> updateTripsFromDuties(
    List<DutyModel> duties,
    int currentDutyIndex, {
    bool isClockedIn = false,
    bool allDutiesCompleted = false,
  }) async {
    print('📺 [ActivityProvider] Received ${duties.length} duties to process.');

    // 1. Convert all duties to TripModels
    final allTrips = duties.map((duty) => _dutyToTrip(duty)).toList();

    // 2. Sort trips by date and then by joining time
    allTrips.sort((a, b) {
      final dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) {
        return dateComparison;
      }
      // If dates are the same, sort by time
      return a.timeDisplay.compareTo(b.timeDisplay);
    });
    
    print('📺 [ActivityProvider] Sorted ${allTrips.length} trips.');

    // 3. Handle live trip logic
    final processedTrips = List<TripModel>.from(allTrips);
    bool liveTripHandled = false;
    bool liveApiConfirmedNoLiveTrip = false;

    // Attempt to merge live trip from dedicated API endpoint first
    if (isClockedIn) {
      try {
        final liveTrip = await _repository.getLiveTrip();
        if (liveTrip != null && liveTrip.isValidLiveTrip) {
          final normalizedDutyNo = liveTrip.dutyNo.trim().toUpperCase();
          final normalizedTripNo = liveTrip.tripNo.toString().trim().toUpperCase();
          
          // Remove the original version of the live trip
          processedTrips.removeWhere((trip) {
            final tripId = trip.id.trim().toUpperCase();
            return tripId == normalizedTripNo ||
                   tripId == normalizedDutyNo ||
                   tripId.startsWith('${normalizedDutyNo}_');
          });
          
          // Add the detailed live trip to the top
          processedTrips.insert(0, _liveTripToTrip(liveTrip));
          liveTripHandled = true;
          print('📺 [ActivityProvider] Live trip merged from API: ${liveTrip.tripNo}');
        } else {
          liveApiConfirmedNoLiveTrip = true;
          print('📺 [ActivityProvider] Live trip API returned no active trip. Showing no ongoing trip.');
        }
      } catch (e) {
        print('⚠️ [ActivityProvider] Live trip fetch from API failed: $e');
      }
    }

    // If not clocked in or API fails, use fallback to mark a duty as live
    if (isClockedIn && !allDutiesCompleted && !liveTripHandled && !liveApiConfirmedNoLiveTrip) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      // Find today's duties from the full list
      final todayDuties = duties.where((duty) => _isSameDay(duty.date, today)).toList();

      if (todayDuties.isNotEmpty && currentDutyIndex < todayDuties.length) {
        final currentLiveDuty = todayDuties[currentDutyIndex];
        final liveTripId = _dutyToTrip(currentLiveDuty).id;

        // Find the corresponding trip and update its status
        final tripIndex = processedTrips.indexWhere((t) => t.id == liveTripId);
        if (tripIndex != -1) {
          processedTrips[tripIndex] = processedTrips[tripIndex].copyWith(status: 'Live');
          print('📺 [ActivityProvider] Marked duty ${currentLiveDuty.dutyNo} as live using fallback.');
        }
      } else {
        print('📺 [ActivityProvider] Skipping live fallback: no current duty for today.');
      }
    }

    print('📺 [ActivityProvider] Final processed trips: ${processedTrips.length}');
    state = state.copyWith(allTrips: processedTrips);
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  void setView(String view) => state = state.copyWith(activeView: view);
  void setTab(String tab) => state = state.copyWith(activeTab: tab);
  void setTimeFilter(String filter) => state = state.copyWith(timeFilter: filter);

  void updateLiveTripFromDuty(DutyModel duty) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Update the live trip with new duty data
    final List<TripModel> updatedTrips = state.allTrips.map((trip) {
      if (trip.status == 'Live') {
        return TripModel(
          id: trip.id,
          status: 'Live',
          from: duty.from,
          to: duty.to,
          date: today,
          timeDisplay: duty.reportingTime,
          startTime: duty.joiningTime,
          endTime: duty.closeTime,
          tripType: duty.serviceType ?? 'Shared Cab',
          steeringTime: duty.steeringTime ?? duty.joiningTime,
          restTime: duty.restTime,
          kms: duty.tripKms,
          buttonText: 'View Live',
        );
      }
      return trip;
    }).toList();

    state = state.copyWith(allTrips: updatedTrips);
  }
}

final activityRepositoryProvider = Provider((ref) => ActivityRepository());

final activityProvider = StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
  final repository = ref.watch(activityRepositoryProvider);
  final notifier = ActivityNotifier(repository);
  
  // Watch homeProvider to get duties from dashboard API
  final homeState = ref.watch(homeProvider);
  
  // Update trips whenever homeState.allDuties changes
  if (homeState.allDuties.isNotEmpty) {
    print('📺 [ActivityProvider] Watching homeProvider with ${homeState.allDuties.length} duties');
    notifier.updateTripsFromDuties(
      homeState.allDuties,
      homeState.currentDutyIndex,
      isClockedIn: homeState.isClockedIn,
      allDutiesCompleted: homeState.allDutiesCompleted,
    );
  } else {
    print('📺 [ActivityProvider] homeState.allDuties is empty, showing no trips');
    notifier.updateTripsFromDuties(
      [],
      0,
      isClockedIn: homeState.isClockedIn,
      allDutiesCompleted: homeState.allDutiesCompleted,
    );
  }
  
  return notifier;
});
