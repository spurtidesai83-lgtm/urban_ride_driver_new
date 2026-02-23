import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository.dart';

class ProfileNotifier extends StateNotifier<AsyncValue<ProfileModel>> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.getProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void updateName(String newName) {
    state.whenData((profile) {
      state = AsyncValue.data(profile.copyWith(name: newName));
    });
  }

  Future<void> uploadProfilePicture(XFile imageFile) async {
    final currentProfile = state.valueOrNull;

    try {
      final updatedProfile = await _repository.uploadProfilePicture(imageFile);

      if (currentProfile == null) {
        state = AsyncValue.data(updatedProfile);
        return;
      }

      state = AsyncValue.data(updatedProfile.copyWith(
        totalRides: currentProfile.totalRides,
        dutiesDone: currentProfile.dutiesDone,
        daysOfDuty: currentProfile.daysOfDuty,
        kmCovered: currentProfile.kmCovered,
        overtimeRate: currentProfile.overtimeRate,
        vehicleNumber: currentProfile.vehicleNumber,
        vehicleModel: currentProfile.vehicleModel,
      ));
    } catch (e) {
      if (currentProfile != null) {
        state = AsyncValue.data(currentProfile);
      }
      rethrow;
    }
  }

  // Fetch statistics for a specific month
  Future<void> fetchMonthStats(String month) async {
    state.whenData((profile) async {
      try {
        final data = await _repository.getMonthStats(month);
        state = AsyncValue.data(profile.copyWith(
          dutiesDone: data['dutiesDone'] as int,
          daysOfDuty: data['daysOfDuty'] as int,
          kmCovered: data['kmCovered'] as double,
        ));
      } catch (e) {
        // Handle error
      }
    });
  }
}

final profileRepositoryProvider = Provider((ref) => ProfileRepository());

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<ProfileModel>>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository);
});
