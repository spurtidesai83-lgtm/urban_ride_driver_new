class VehicleModel {
  final String registrationNumber; // Vehicle registration number (plate number)
  final String model; // Vehicle model name
  final String capacity; // Seating capacity
  final String fuelType; // Fuel type (PETROL, DIESEL, etc.)
  final String color; // Vehicle color
  final String yearOfManufacture; // Year and month of manufacture
  final String chassisNumber; // Chassis number (partially masked)
  final String engineNumber; // Engine number (partially masked)
  final String insuranceExpiry; // Insurance expiry date
  final bool isActive; // Whether vehicle is active/verified

  VehicleModel({
    required this.registrationNumber,
    required this.model,
    required this.capacity,
    required this.fuelType,
    required this.color,
    required this.yearOfManufacture,
    required this.chassisNumber,
    required this.engineNumber,
    required this.insuranceExpiry,
    this.isActive = true,
  });

  // Extract year from yearOfManufacture (e.g., "11/2015" -> "2015")
  String get manufacturingYear {
    List<String> parts = yearOfManufacture.split('/');
    return parts.length > 1 ? parts[1] : yearOfManufacture;
  }

  // Check if insurance is expired
  bool get isInsuranceExpired {
    try {
      DateTime expiryDate = DateTime.parse(insuranceExpiry);
      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      return false;
    }
  }

  // Get insurance status
  String get insuranceStatus {
    return isInsuranceExpired ? 'Expired' : 'Active';
  }

  VehicleModel copyWith({
    String? registrationNumber,
    String? model,
    String? capacity,
    String? fuelType,
    String? color,
    String? yearOfManufacture,
    String? chassisNumber,
    String? engineNumber,
    String? insuranceExpiry,
    bool? isActive,
  }) {
    return VehicleModel(
      registrationNumber: registrationNumber ?? this.registrationNumber,
      model: model ?? this.model,
      capacity: capacity ?? this.capacity,
      fuelType: fuelType ?? this.fuelType,
      color: color ?? this.color,
      yearOfManufacture: yearOfManufacture ?? this.yearOfManufacture,
      chassisNumber: chassisNumber ?? this.chassisNumber,
      engineNumber: engineNumber ?? this.engineNumber,
      insuranceExpiry: insuranceExpiry ?? this.insuranceExpiry,
      isActive: isActive ?? this.isActive,
    );
  }
}
