import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/leave_model.dart';
import '../../../shared/services/leave_api_service.dart';

// State class for leave operations
class LeaveState {
  final List<LeaveRecord> leaveHistory;
  final bool isLoading;
  final bool isApplying;
  final String? errorMessage;
  final String? successMessage;

  LeaveState({
    this.leaveHistory = const [],
    this.isLoading = false,
    this.isApplying = false,
    this.errorMessage,
    this.successMessage,
  });

  LeaveState copyWith({
    List<LeaveRecord>? leaveHistory,
    bool? isLoading,
    bool? isApplying,
    String? errorMessage,
    String? successMessage,
  }) {
    return LeaveState(
      leaveHistory: leaveHistory ?? this.leaveHistory,
      isLoading: isLoading ?? this.isLoading,
      isApplying: isApplying ?? this.isApplying,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

// Leave API Service Provider
final leaveApiServiceProvider = Provider((ref) => LeaveApiService());

// Leave state notifier
class LeaveNotifier extends StateNotifier<LeaveState> {
  final LeaveApiService _leaveApiService;

  LeaveNotifier(this._leaveApiService) : super(LeaveState());

  // Fetch leave history
  Future<void> fetchLeaveHistory() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final response = await _leaveApiService.getLeaveHistory();
      if (response.success) {
        // Get records from API
        final leaveRecords = response.data.toLeaveRecords();
        
        // User requested: "date modified" / "new added once comes on top"
        // Since we don't have a modification date, we rely on the API's insertion order.
        // Assuming API returns [Oldest, ..., Newest], we reverse it to get [Newest, ..., Oldest].
        final reversedRecords = leaveRecords.reversed.toList();
        
        state = state.copyWith(
          leaveHistory: reversedRecords,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: response.message ?? 'Failed to fetch leave history',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  // Apply for leave
  Future<bool> applyLeave(LeaveApplication application) async {
    state = state.copyWith(isApplying: true, errorMessage: null);
    try {
      final response = await _leaveApiService.applyLeave(application);
      if (response.success) {
        state = state.copyWith(
          isApplying: false,
          successMessage: response.message ?? 'Leave applied successfully',
        );
        // Refresh leave history after successful application
        await fetchLeaveHistory();
        return true;
      } else {
        state = state.copyWith(
          isApplying: false,
          errorMessage: response.message ?? 'Failed to apply leave',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isApplying: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  // Clear messages
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

// Leave state provider
final leaveProvider =
    StateNotifierProvider<LeaveNotifier, LeaveState>((ref) {
  final leaveApiService = ref.watch(leaveApiServiceProvider);
  return LeaveNotifier(leaveApiService);
});

// Convenience providers
final leaveHistoryProvider = Provider((ref) {
  return ref.watch(leaveProvider).leaveHistory;
});

final leaveLoadingProvider = Provider((ref) {
  return ref.watch(leaveProvider).isLoading;
});

final leaveApplyingProvider = Provider((ref) {
  return ref.watch(leaveProvider).isApplying;
});

final leaveErrorProvider = Provider((ref) {
  return ref.watch(leaveProvider).errorMessage;
});

final leaveSuccessProvider = Provider((ref) {
  return ref.watch(leaveProvider).successMessage;
});
