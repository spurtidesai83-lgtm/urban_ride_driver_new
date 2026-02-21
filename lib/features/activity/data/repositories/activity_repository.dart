import '../models/trip_model.dart';
import '../models/live_trip_model.dart';
import '../../../../shared/services/schedule_api_service.dart';

class ActivityRepository {
  final ScheduleApiService _apiService = ScheduleApiService();

  Future<List<TripModel>> getTrips() async {
    // Don't return mock data - let the provider handle conversion from duties
    return [];
  }

  Future<LiveTripModel?> getLiveTrip() async {
    return _apiService.getLiveTrip();
  }
}
