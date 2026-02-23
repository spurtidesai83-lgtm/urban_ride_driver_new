import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/trip_history_model.dart';
import '../../data/repositories/trip_history_repository.dart';

class TripHistoryNotifier extends StateNotifier<AsyncValue<TripHistoryModel>> {
  final TripHistoryRepository _repository;

  TripHistoryNotifier(this._repository) : super(const AsyncValue.loading()) {
    _fetchTripHistory();
  }

  Future<void> _fetchTripHistory() async {
    state = const AsyncValue.loading();
    try {
      final tripHistory = await _repository.getAllTripHistory();
      state = AsyncValue.data(tripHistory);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await _fetchTripHistory();
  }
}

final tripHistoryRepositoryProvider = Provider((ref) => TripHistoryRepository());

final tripHistoryProvider =
    StateNotifierProvider<TripHistoryNotifier, AsyncValue<TripHistoryModel>>((ref) {
  final repository = ref.watch(tripHistoryRepositoryProvider);
  return TripHistoryNotifier(repository);
});
