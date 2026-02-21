import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/report_record_model.dart';
import '../../data/repositories/report_repository.dart';

class ReportState {
  final List<ReportRecord> records;
  final int totalDuties;
  final double totalKm;
  final double totalSteeringHours;
  final double totalOvertime;
  final bool isLoading;

  ReportState({
    required this.records,
    required this.totalDuties,
    required this.totalKm,
    required this.totalSteeringHours,
    required this.totalOvertime,
    this.isLoading = false,
  });

  ReportState copyWith({
    List<ReportRecord>? records,
    int? totalDuties,
    double? totalKm,
    double? totalSteeringHours,
    double? totalOvertime,
    bool? isLoading,
  }) {
    return ReportState(
      records: records ?? this.records,
      totalDuties: totalDuties ?? this.totalDuties,
      totalKm: totalKm ?? this.totalKm,
      totalSteeringHours: totalSteeringHours ?? this.totalSteeringHours,
      totalOvertime: totalOvertime ?? this.totalOvertime,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ReportNotifier extends StateNotifier<ReportState> {
  final ReportRepository _repository;

  ReportNotifier(this._repository) : super(ReportState(
    records: [],
    totalDuties: 0,
    totalKm: 0,
    totalSteeringHours: 0,
    totalOvertime: 0,
    isLoading: true,
  )) {
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final mockRecords = await _repository.getReports();

      // Calculate totals
      final totalDuties = mockRecords.length;
      final totalKm = mockRecords.fold(0.0, (sum, record) => sum + record.km);
      final totalSteeringHours = mockRecords.fold(0.0, (sum, record) => sum + record.steeringTime);
      final totalOvertime = mockRecords.fold(0.0, (sum, record) => sum + record.overtime);

      state = ReportState(
        records: mockRecords,
        totalDuties: totalDuties,
        totalKm: totalKm,
        totalSteeringHours: totalSteeringHours,
        totalOvertime: totalOvertime,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      // Handle error
    }
  }
}

final reportRepositoryProvider = Provider((ref) => ReportRepository());

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  final repository = ref.watch(reportRepositoryProvider);
  return ReportNotifier(repository);
});
