// API Vehicle Response Model - matches backend structure
class ApiVehicleResponse {
  final bool success;
  final ApiVehicleData data;
  final String message;

  ApiVehicleResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory ApiVehicleResponse.fromJson(Map<String, dynamic> json) {
    return ApiVehicleResponse(
      success: json['success'] ?? false,
      data: ApiVehicleData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class ApiVehicleData {
  final String registrationNumber;
  final String model;
  final String capacity;
  final String fuelType;
  final String color;
  final String yearOfManufacture;
  final String chassisNumber;
  final String engineNumber;
  final String insuranceExpiry;

  ApiVehicleData({
    required this.registrationNumber,
    required this.model,
    required this.capacity,
    required this.fuelType,
    required this.color,
    required this.yearOfManufacture,
    required this.chassisNumber,
    required this.engineNumber,
    required this.insuranceExpiry,
  });

  factory ApiVehicleData.fromJson(Map<String, dynamic> json) {
    return ApiVehicleData(
      registrationNumber: json['registrationNumber'] ?? '',
      model: json['model'] ?? '',
      capacity: json['capacity'] ?? '',
      fuelType: json['fuelType'] ?? '',
      color: json['color'] ?? '',
      yearOfManufacture: json['yearOfManufacture'] ?? '',
      chassisNumber: json['chassisNumber'] ?? '',
      engineNumber: json['engineNumber'] ?? '',
      insuranceExpiry: json['insuranceExpiry'] ?? '',
    );
  }
}
