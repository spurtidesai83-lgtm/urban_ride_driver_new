import '../models/vehicle_model.dart';
import '../../../../shared/services/vehicle_api_service.dart';

class VehicleRepository {
  final VehicleApiService _apiService = VehicleApiService();

  Future<VehicleModel> getVehicleInfo() async {
    try {
      // Fetch vehicle info from API
      final apiResponse = await _apiService.getVehicleInfo();
      final data = apiResponse.data;
      
      // Convert API response to VehicleModel
      return VehicleModel(
        registrationNumber: data.registrationNumber,
        model: data.model,
        capacity: data.capacity,
        fuelType: data.fuelType,
        color: data.color,
        yearOfManufacture: data.yearOfManufacture,
        chassisNumber: data.chassisNumber,
        engineNumber: data.engineNumber,
        insuranceExpiry: data.insuranceExpiry,
        isActive: true,
      );
    } catch (e) {
      // Throw error to be handled by provider
      throw Exception('Failed to get vehicle information: $e');
    }
  }
}
