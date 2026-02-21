enum LeaveStatus {
  pending,
  approved,
  rejected,
  cancelled,
}

extension LeaveStatusExtension on LeaveStatus {
  String toStringValue() {
    return toString().split('.').last.toUpperCase();
  }

  static LeaveStatus fromString(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return LeaveStatus.approved;
      case 'REJECTED':
        return LeaveStatus.rejected;
      case 'CANCELLED':
        return LeaveStatus.cancelled;
      case 'PENDING':
      default:
        return LeaveStatus.pending;
    }
  }
}

class LeaveRecord {
  final String driverUUID;
  final String driverName;
  final DateTime leaveFrom;
  final DateTime leaveTo;
  final String reason;
  final LeaveStatus status;
  final String? handlerRemark;

  LeaveRecord({
    required this.driverUUID,
    required this.driverName,
    required this.leaveFrom,
    required this.leaveTo,
    required this.reason,
    required this.status,
    this.handlerRemark,
  });

  // Get number of leave days (inclusive of both start and end date)
  int get leaveDays {
    return leaveTo.difference(leaveFrom).inDays + 1;
  }

  // Check if leave is in the future
  bool get isFuture {
    return leaveFrom.isAfter(DateTime.now());
  }

  // Check if leave is ongoing
  bool get isOngoing {
    final now = DateTime.now();
    return leaveFrom.isBefore(now) && leaveTo.isAfter(now);
  }

  // Format dates for display
  String get formattedDateRange {
    return '${_formatDate(leaveFrom)} - ${_formatDate(leaveTo)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  LeaveRecord copyWith({
    String? driverUUID,
    String? driverName,
    DateTime? leaveFrom,
    DateTime? leaveTo,
    String? reason,
    LeaveStatus? status,
    String? handlerRemark,
  }) {
    return LeaveRecord(
      driverUUID: driverUUID ?? this.driverUUID,
      driverName: driverName ?? this.driverName,
      leaveFrom: leaveFrom ?? this.leaveFrom,
      leaveTo: leaveTo ?? this.leaveTo,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      handlerRemark: handlerRemark ?? this.handlerRemark,
    );
  }
}

class LeaveApplication {
  final DateTime fromDate;
  final DateTime toDate;
  final String reason;

  LeaveApplication({
    required this.fromDate,
    required this.toDate,
    required this.reason,
  });

  // Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'fromLeaveDate': _formatDateForApi(fromDate),
      'toLeaveDate': _formatDateForApi(toDate),
      'leaveReason': reason,
    };
  }

  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Get number of days
  int get numberOfDays {
    return toDate.difference(fromDate).inDays + 1;
  }
}
