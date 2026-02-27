import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbandriver/shared/utils/responsive_utils.dart';
import '../../../profile/data/models/trip_history_model.dart';
import '../../../profile/presentation/providers/trip_history_provider.dart';

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
    final tripHistoryState = ref.watch(tripHistoryProvider);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              final _ = ref.refresh(tripHistoryProvider);
            },
          ),
        ],
      ),
      body: tripHistoryState.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFFC200))),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (tripHistory) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildSummaryOverview(tripHistory),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: const Text(
                  'Monthly Trip History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              _buildGroupedTripList(context, tripHistory.tripDetails),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryOverview(TripHistoryModel history) {
     return Container(
       padding: const EdgeInsets.all(20),
       decoration: BoxDecoration(
         color: const Color(0xFFFFFBEB),
         borderRadius: BorderRadius.circular(16),
         border: Border.all(color: const Color(0xFFFDE68A).withValues(alpha: 0.3)),
         boxShadow: [
           BoxShadow(
             color: const Color(0xFFD97706).withValues(alpha: 0.05),
             blurRadius: 15,
             offset: const Offset(0, 5),
           ),
         ],
       ),
       child: Column(
         children: [
           Row(
             children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
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
                      history.totalNoOfDuties.toString(),
                      style: const TextStyle(
                         fontSize: 32,
                         fontWeight: FontWeight.bold,
                         color: Color(0xFF451A03),
                         height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Total Duties Completed',
                      style: TextStyle(
                        color: Color(0xFF92400E),
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
             color: const Color(0xFFFDE68A).withValues(alpha: 0.5)
           ),
           const SizedBox(height: 20),
           Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               _buildDetailStat(Icons.speed, '${history.kmsTraveled.toStringAsFixed(0)} km', 'Distance'),
               _buildDetailStat(Icons.schedule, history.steeringHrs, 'Steering'),
               _buildDetailStat(Icons.history_toggle_off, '${history.overTime.toStringAsFixed(1)} h', 'Overtime'),
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

  Widget _buildGroupedTripList(BuildContext context, List<TripDetailModel> trips) {
    if (trips.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No trip history available',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    trips.sort((a, b) => b.tripDate.compareTo(a.tripDate));

    final Map<String, List<TripDetailModel>> groupedTrips = {};

    for (var trip in trips) {
      try {
        final date = DateTime.parse(trip.tripDate);
        final key = _formatMonthYear(date);
        if (!groupedTrips.containsKey(key)) {
          groupedTrips[key] = [];
        }
        groupedTrips[key]!.add(trip);
      } catch (e) {
        const key = 'Unknown Date';
        if (!groupedTrips.containsKey(key)) {
          groupedTrips[key] = [];
        }
        groupedTrips[key]!.add(trip);
      }
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: groupedTrips.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final key = groupedTrips.keys.elementAt(index);
        final monthTrips = groupedTrips[key]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Text(
                key,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
            ...monthTrips.map((trip) => _buildTripItem(context, trip)),
          ],
        );
      },
    );
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  Widget _buildTripItem(BuildContext context, TripDetailModel trip) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                children: [
                  Text(
                    _getDay(trip.tripDate),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB45309),
                    ),
                  ),
                  Text(
                    _getMonthShort(trip.tripDate),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Trip #${trip.tripNo}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            'Steering: ${trip.steeringHrs}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.directions_car, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            '${trip.kms} km',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildStatusIcon(trip.status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    bool isCompleted = status.toLowerCase() == 'completed';
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green[50] : Colors.orange[50],
        shape: BoxShape.circle,
      ),
      child: Icon(
        isCompleted ? Icons.check : Icons.access_time_filled,
        size: 16,
        color: isCompleted ? Colors.green[700] : Colors.orange[700],
      ),
    );
  }

  String _getDay(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return date.day.toString();
    } catch (e) {
      return '';
    }
  }

  String _getMonthShort(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return months[date.month - 1];
    } catch (e) {
      return '';
    }
  }
}
