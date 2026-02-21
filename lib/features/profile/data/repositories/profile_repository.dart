import '../models/profile_model.dart';
import '../../../../shared/services/profile_api_service.dart';

class ProfileRepository {
  final ProfileApiService _apiService = ProfileApiService();

  Future<ProfileModel> getProfile() async {
    try {
      // Fetch profile from API
      final apiResponse = await _apiService.getProfile();
      final data = apiResponse.data;
      
      // Convert API response to ProfileModel
      return ProfileModel(
        name: data.fullName,
        email: '', // Email not in API response, could be from storage
        phone: data.phoneNumber.toString(),
        totalRides: 0, // Not in current API response
        dutiesDone: 0, // Not in current API response
        daysOfDuty: 0, // Not in current API response
        kmCovered: 0.0, // Not in current API response
        overtimeRate: 50.0, // Default value
        isVerified: data.status == 'ACTIVE',
        profileImageUrl: data.profilePicture,
        vehicleNumber: null, // Not in profile API
        vehicleModel: null, // Not in profile API
      );
    } catch (e) {
      // Throw error instead of returning mock data
      throw Exception('Failed to fetch profile: $e');
    }
  }

  Future<Map<String, dynamic>> getMonthStats(String month) async {
    // TODO: Implement API call when available
    // For now, return empty stats instead of mock data
    throw Exception('Month stats not available - Backend API not implemented yet');
  }
}
