import '../models/trip_history_model.dart';
import '../models/api_trip_history_model.dart';
import '../../../../shared/services/trip_history_api_service.dart';

class TripHistoryRepository {
  final TripHistoryApiService _apiService = TripHistoryApiService();

  Future<TripHistoryModel> getAllTripHistory() async {
    try {
      final apiResponse = await _apiService.getAllTripHistory();

      if (apiResponse.data == null) {
        throw Exception('No trip history data returned');
      }

      // Convert API response to domain model
      return _mapApiDataToModel(apiResponse.data!);
    } catch (e) {
      throw Exception('Failed to fetch trip history: $e');
    }
  }

  TripHistoryModel _mapApiDataToModel(ApiTripHistoryData apiData) {
    return TripHistoryModel(
      totalNoOfDuties: apiData.totalNoOfDuties,
      kmsTraveled: apiData.kmsTraveled,
      steeringHrs: apiData.steeringHrs,
      overTime: apiData.overTime,
      tripDetails: apiData.tripDetails
          .map((trip) => TripDetailModel(
                tripNo: trip.tripNo,
                fromLocation: trip.fromLocation,
                toLocation: trip.toLocation,
                tripDate: trip.tripDate,
                kms: trip.kms,
                steeringHrs: trip.steeringHrs,
                status: trip.status,
              ))
          .toList(),
    );
  }
}
