import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/vehicle_model.dart';
import '../../data/repositories/vehicle_repository.dart';

class VehicleNotifier extends StateNotifier<AsyncValue<VehicleModel>> {
  final VehicleRepository _repository;

  VehicleNotifier(this._repository) : super(const AsyncValue.loading()) {
    _fetchVehicleInfo();
  }

  Future<void> _fetchVehicleInfo() async {
    state = const AsyncValue.loading();
    try {
      final vehicle = await _repository.getVehicleInfo();
      state = AsyncValue.data(vehicle);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Refresh vehicle information
  Future<void> refreshVehicleInfo() async {
    await _fetchVehicleInfo();
  }
}

final vehicleRepositoryProvider = Provider((ref) => VehicleRepository());

final vehicleProvider = StateNotifierProvider<VehicleNotifier, AsyncValue<VehicleModel>>((ref) {
  final repository = ref.watch(vehicleRepositoryProvider);
  return VehicleNotifier(repository);
});
