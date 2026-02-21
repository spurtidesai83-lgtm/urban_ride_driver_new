import '../models/trip_log_models.dart';
import '../services/trip_api_service.dart';

class TripRepository {
  final TripApiService _apiService = TripApiService();

  Future<TripLogResponse> startTrip(TripLogRequest request) async {
    return _apiService.startTrip(request);
  }

  Future<TripLogResponse> logTrip(TripLogRequest request) async {
    return _apiService.logTrip(request);
  }

  Future<TripLogResponse> endTrip(TripLogRequest request) async {
    return _apiService.endTrip(request);
  }
}
