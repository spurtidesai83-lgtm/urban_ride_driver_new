import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbandriver/shared/utils/responsive_utils.dart';
import '../../data/models/report_record_model.dart';
import '../providers/report_provider.dart';

class DriverReportsScreen extends ConsumerWidget {
  final String phoneOrEmail;
  final VoidCallback? onMenuTap;

  const DriverReportsScreen({
    super.key,
    required this.phoneOrEmail,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportState = ref.watch(reportProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
            size: ResponsiveUtils.iconSize(context, 24),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Driver Reports',
          style: TextStyle(
            color: Colors.black,
            fontSize: ResponsiveUtils.fontSize(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: reportState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFC200)))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Summary Widget (Replaces Earnings Header with original data)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSummaryOverview(reportState),
                  ),
                  const SizedBox(height: 24),

                  // Monthly Records Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: const Text(
                      'Monthly Records',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ),
                  
                  // Records List
                  ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 40),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: reportState.records.length,
                    itemBuilder: (context, index) {
                       return _buildRecordItem(context, reportState.records[index]);
                    }
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSummaryOverview(ReportState state) {
     return Container(
       padding: const EdgeInsets.all(20),
       decoration: BoxDecoration(
         color: const Color(0xFFFFFBEB), // Light yellow tint
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: const Color(0xFFFDE68A).withValues(alpha: 0.3)),
         boxShadow: [
           BoxShadow(
             color: const Color(0xFFD97706).withValues(alpha: 0.05), // Warm shadow
             blurRadius: 15,
             offset: const Offset(0, 5),
           ),
         ],
       ),
       child: Column(
         children: [
           // Top Row: Total Duties (Hero Stat)
           Row(
             children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white, // White bg for icon to pop
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFF4CC)),
                  ),
                  child: const Icon(Icons.work_outline, color: Color(0xFFB45309), size: 28),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.totalDuties.toString(),
                      style: const TextStyle(
                         fontSize: 32,
                         fontWeight: FontWeight.bold,
                         color: Color(0xFF451A03), // Darker brown/black for contrast
                         height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Total Duties Completed',
                      style: TextStyle(
                        color: Color(0xFF92400E), // Warm dark grey/brown
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
             ],
           ),
           const SizedBox(height: 24),
           Container(
             height: 1, 
             color: const Color(0xFFFDE68A).withValues(alpha: 0.5) // Subtle yellow divider
           ), 
           const SizedBox(height: 20),
           // Bottom Row: Secondary Stats
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               _buildDetailStat(Icons.speed, '${state.totalKm.toStringAsFixed(0)} km', 'Distance'),
               _buildDetailStat(Icons.schedule, '${state.totalSteeringHours.toStringAsFixed(1)} h', 'Steering'),
               _buildDetailStat(Icons.history_toggle_off, '${state.totalOvertime.toStringAsFixed(1)} h', 'Overtime'),
             ],
           ),
         ],
       ),
     );
  }

  Widget _buildDetailStat(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
               Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
               const SizedBox(width: 6),
               Flexible(
                 child: Text(
                   label, 
                   maxLines: 1,
                   overflow: TextOverflow.ellipsis,
                   style: const TextStyle(
                     fontSize: 12, 
                     color: Color(0xFF6B7280),
                     fontWeight: FontWeight.w500,
                   ),
                 ),
               ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildRecordItem(BuildContext context, ReportRecord record) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.description_outlined, size: 20, color: Color(0xFF4B5563)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        record.route,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(record.status),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Duty #${record.dutyNo}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.circle, size: 4, color: Color(0xFFD1D5DB)),
                    ),
                    Text(
                      record.date,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                 Text(
                   '${record.km.toStringAsFixed(1)} KM • ${record.steeringTime.toStringAsFixed(1)} Hrs Steering',
                   style: const TextStyle(
                     fontSize: 12,
                     color: Color(0xFF9CA3AF),
                   ),
                 ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isCompleted = status == 'Completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isCompleted ? const Color(0xFFDEF7EC) : const Color(0xFFFFF4CC),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isCompleted ? const Color(0xFF03543F) : const Color(0xFF92400E),
        ),
      ),
    );
  }
}
