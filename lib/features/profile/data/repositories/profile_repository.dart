import '../models/profile_model.dart';
import 'package:image_picker/image_picker.dart';
import '../models/api_profile_model.dart';
import '../../../../shared/services/profile_api_service.dart';
import '../../../../shared/services/storage_service.dart';

class ProfileRepository {
  final ProfileApiService _apiService = ProfileApiService();

  ProfileModel _mapApiDataToProfile(ApiProfileData data) {
    return ProfileModel(
      name: data.fullName,
      email: '',
      phone: data.phoneNumber,
      totalRides: 0,
      dutiesDone: 0,
      daysOfDuty: 0,
      kmCovered: 0.0,
      overtimeRate: 50.0,
      isVerified: data.status == 'ACTIVE',
      profileImageUrl: data.profilePicture,
      vehicleNumber: null,
      vehicleModel: null,
    );
  }

  Future<ProfileModel> getProfile() async {
    try {
      // Fetch profile from API
      final apiResponse = await _apiService.getProfile();

      // Convert API response to ProfileModel
      return _mapApiDataToProfile(apiResponse.data);
    } catch (e) {
      print('⚠️ [ProfileRepository] Failed to fetch profile: $e');

      final email = await StorageService.getUserEmail();
      if (email != null && email.isNotEmpty) {
        final name = email.split('@')[0];
        print('✅ [ProfileRepository] Using fallback profile from stored email: $name');
        return ProfileModel(
          name: name,
          email: email,
          phone: '',
          totalRides: 0,
          dutiesDone: 0,
          daysOfDuty: 0,
          kmCovered: 0.0,
          overtimeRate: 0.0,
          isVerified: true,
          profileImageUrl: null,
          vehicleNumber: null,
          vehicleModel: null,
        );
      }

      rethrow;
    }
  }

  Future<ProfileModel> uploadProfilePicture(XFile imageFile) async {
    try {
      final updatedProfileData = await _apiService.uploadProfilePicture(imageFile);
      return _mapApiDataToProfile(updatedProfileData);
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  Future<Map<String, dynamic>> getMonthStats(String month) async {
    // TODO: Implement API call when available
    // For now, return empty stats instead of mock data
    throw Exception('Month stats not available - Backend API not implemented yet');
  }
}
