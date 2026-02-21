import '../models/trip_model.dart';

class ActivityRepository {
  Future<List<TripModel>> getTrips() async {
    // Don't return mock data - let the provider handle conversion from duties
    return [];
  }
}
