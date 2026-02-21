import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/trip_model.dart';
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
    
    // 1. Filter by tab
    List<TripModel> trips = [];
    switch (activeTab) {
      case 'scheduled':
        trips = allTrips.where((t) => t.date.isAtSameMomentAs(today) && t.status != 'Live').toList();
        break;
      case 'upcoming':
        trips = allTrips.where((t) => t.date.isAfter(today)).toList();
        break;
      case 'ongoing':
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
    return TripModel(
      id: duty.dutyNo,
      status: isLive ? 'Live' : (duty.isCompleted ? 'Completed' : 'Scheduled'),
      from: duty.from,
      to: duty.to,
      date: duty.date,
      timeDisplay: duty.joiningTime,
      tripType: duty.serviceType ?? 'Shared Cab', // From backend or default
      steeringTime: duty.steeringTime ?? duty.joiningTime, // Use steering time or fall back to joining time
      buttonText: isLive ? 'View Live' : 'View Details',
    );
  }

  // Update trips from duties
  void updateTripsFromDuties(List<DutyModel> duties, int currentDutyIndex) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    print('📺 [ActivityProvider] Received ${duties.length} duties');
    if (duties.isNotEmpty) {
      print('📺 [ActivityProvider] First duty: ${duties[0].dutyNo} from ${duties[0].from} to ${duties[0].to}');
    }

    // Convert duties to trips
    final trips = duties.map((duty) {
      final isLive = duties.indexOf(duty) == currentDutyIndex;
      return _dutyToTrip(duty, isLive: isLive);
    }).toList();

    print('📺 [ActivityProvider] Converted to ${trips.length} trips');
    state = state.copyWith(allTrips: trips);
  }

  void setView(String view) => state = state.copyWith(activeView: view);
  void setTab(String tab) => state = state.copyWith(activeTab: tab);
  void setTimeFilter(String filter) => state = state.copyWith(timeFilter: filter);

  void updateLiveTripFromDuty(DutyModel duty) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Update the live trip with new duty data
    final updatedTrips = state.allTrips.map((trip) {
      if (trip.status == 'Live') {
        return TripModel(
          id: trip.id,
          status: 'Live',
          from: duty.from,
          to: duty.to,
          date: today,
          timeDisplay: duty.joiningTime,
          tripType: duty.serviceType ?? 'Shared Cab',
          steeringTime: duty.steeringTime ?? duty.joiningTime,
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
    notifier.updateTripsFromDuties(homeState.allDuties, homeState.currentDutyIndex);
  } else {
    print('📺 [ActivityProvider] homeState.allDuties is empty, showing no trips');
    notifier.updateTripsFromDuties([], 0);
  }
  
  return notifier;
});
