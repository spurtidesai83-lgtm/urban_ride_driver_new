import '../models/leave_model.dart';
import '../../../../shared/services/leave_api_service.dart';

class LeaveRepository {
  final LeaveApiService _apiService = LeaveApiService();

  // Apply for leave
  Future<void> applyLeave(LeaveApplication application) async {
    try {
      await _apiService.applyLeave(application);
    } catch (e) {
      throw Exception('Failed to apply leave: $e');
    }
  }

  // Get leave history
  Future<List<LeaveRecord>> getLeaveHistory() async {
    try {
      final apiResponse = await _apiService.getLeaveHistory();
      
      // Convert API response to LeaveRecord list
      return apiResponse.data.leaveHistoryList.map((record) {
        return LeaveRecord(
          driverUUID: record.driverUUID,
          driverName: record.driverName,
          leaveFrom: DateTime.parse(record.leaveFrom),
          leaveTo: DateTime.parse(record.leaveTo),
          reason: record.reason,
          status: LeaveStatusExtension.fromString(record.status),
          handlerRemark: record.handlerRemark,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get leave history: $e');
    }
  }
}
