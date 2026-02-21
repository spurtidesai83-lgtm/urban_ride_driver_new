import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/animated_filter_dropdown.dart';
import 'package:urbandriver/shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/models/trip_model.dart';
import '../providers/activity_provider.dart';
import 'package:urbandriver/features/home/presentation/providers/home_provider.dart';
import 'trip_details_screen.dart';

class ActivityScreen extends ConsumerWidget {
  final String phoneOrEmail;
  final VoidCallback? onMenuTap;

  const ActivityScreen({
    super.key,
    required this.phoneOrEmail,
    this.onMenuTap,
  });

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_isSameDate(date, today)) return 'Today';

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  List<DateTime> _buildDateRangeForFilter(String timeFilter, List<TripModel> trips) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (timeFilter == 'Today') {
      return [today];
    }

    DateTime startDate;
    if (timeFilter == 'This Month') {
      startDate = DateTime(today.year, today.month, 1);
    } else if (timeFilter == 'This Year') {
      startDate = DateTime(today.year, 1, 1);
    } else {
      if (trips.isEmpty) {
        return [today];
      }
      final normalizedTripDates = trips.map((trip) => _normalizeDate(trip.date)).toList();
      normalizedTripDates.sort((a, b) => a.compareTo(b));
      startDate = normalizedTripDates.first;
    }

    final dates = <DateTime>[];
    for (DateTime cursor = startDate;
        !cursor.isAfter(today);
        cursor = cursor.add(const Duration(days: 1))) {
      dates.add(cursor);
    }
    return dates.reversed.toList();
  }

  // Returns a Map where key is the Section Header and value is the list of trips
  Map<String, List<TripModel>> _getGroupedTrips(List<TripModel> filteredTrips) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    Map<String, List<TripModel>> grouped = {};

    for (var trip in filteredTrips) {
      String header;
      if (trip.status == 'Live') {
        header = 'Live'; 
      } else if (trip.date.isAtSameMomentAs(today)) {
        header = 'Today';
      } else {
        // Format: "8 Jan 2026"
        final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final day = trip.date.day;
        final month = months[trip.date.month - 1];
        final year = trip.date.year;
        header = '$day $month $year';
      }

      if (!grouped.containsKey(header)) {
        grouped[header] = [];
      }
      grouped[header]!.add(trip);
    }
    
    return grouped;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityState = ref.watch(activityProvider);
    final activityNotifier = ref.read(activityProvider.notifier);
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _TripsHeader(
            onMenuTap: onMenuTap,
          ),
          _TabBar(
            activeTab: activityState.activeTab,
            onTabChange: activityNotifier.setTab,
            activeTimeFilter: activityState.timeFilter,
            onTimeFilterChange: activityNotifier.setTimeFilter,
          ),
          Expanded(
            child: activityState.isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _buildTripsList(context, activityState, homeState.isClockedIn),
          ),
        ],
      ),
    );
  }

  Widget _buildTripsList(BuildContext context, ActivityState state, bool isClockedIn) {
    final filteredTrips = state.filteredTrips;
    final liveTrips = filteredTrips.where((trip) => trip.status == 'Live').toList();
    final nonLiveTrips = filteredTrips.where((trip) => trip.status != 'Live').toList();

    final tripsByDate = <DateTime, List<TripModel>>{};
    for (final trip in nonLiveTrips) {
      final dateKey = _normalizeDate(trip.date);
      tripsByDate.putIfAbsent(dateKey, () => []);
      tripsByDate[dateKey]!.add(trip);
    }

    final dateSections = _buildDateRangeForFilter(state.timeFilter, nonLiveTrips);

    if (liveTrips.isEmpty && dateSections.isEmpty) {
      return const Center(
        child: Text(
          'No trips found',
          style: TextStyle(color: Color(0xFF6F7277)),
        ),
      );
    }

    return ListView(
      padding: ResponsiveUtils.customPadding(context, top: 10, bottom: 100),
      children: [
        if (liveTrips.isNotEmpty) ...[
          Padding(
            padding: ResponsiveUtils.customPadding(context, left: 24, top: 16, right: 24, bottom: 0),
            child: Text(
              'Live',
              style: TextStyle(
                color: Colors.black,
                fontSize: ResponsiveUtils.fontSize(context, 14),
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
          ),
          ...liveTrips.map(
            (trip) => Padding(
              padding: ResponsiveUtils.symmetricPadding(context, horizontal: 24),
              child: _TripCard(trip: trip, isClockedIn: isClockedIn),
            ),
          ),
        ],
        ...dateSections.map((date) {
          final sectionTrips = tripsByDate[date] ?? const <TripModel>[];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: ResponsiveUtils.customPadding(context, left: 24, top: 16, right: 24, bottom: 0),
                child: Text(
                  _formatDateHeader(date),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: ResponsiveUtils.fontSize(context, 14),
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
              ),
              if (sectionTrips.isEmpty)
                Padding(
                  padding: ResponsiveUtils.symmetricPadding(context, horizontal: 24),
                  child: _DayOffCard(date: date),
                )
              else
                ...sectionTrips.map(
                  (trip) => Padding(
                    padding: ResponsiveUtils.symmetricPadding(context, horizontal: 24),
                    child: _TripCard(trip: trip, isClockedIn: isClockedIn),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }


}

class _DayOffCard extends StatelessWidget {
  final DateTime date;

  const _DayOffCard({required this.date});

  String _formatDate(DateTime value) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${value.day} ${months[value.month - 1]} ${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC200).withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy,
              size: 16,
              color: Color(0xFFFFA100),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Day Off • ${_formatDate(date)}',
              style: TextStyle(
                color: Colors.black87,
                fontSize: ResponsiveUtils.fontSize(context, 14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// COMPONENTS
// -----------------------------------------------------------------------------

class _TripsHeader extends StatelessWidget {
  final VoidCallback? onMenuTap;

  const _TripsHeader({
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: 'Trips History',
      onMenuTap: onMenuTap,
    );
  }
}

class _TabBar extends StatelessWidget {
  final String activeTab;
  final ValueChanged<String> onTabChange;
  final String activeTimeFilter;
  final ValueChanged<String> onTimeFilterChange;

  const _TabBar({
    required this.activeTab,
    required this.onTabChange,
    required this.activeTimeFilter,
    required this.onTimeFilterChange,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'id': 'ongoing', 'label': 'Ongoing'},
      {'id': 'scheduled', 'label': 'Scheduled'},
      {'id': 'upcoming', 'label': 'Upcoming'},
      {'id': 'all', 'label': 'All Trips'},
    ];

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          // Scrollable Tabs Area
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: tabs.map((tab) {
                    final id = tab['id']!;
                    final label = tab['label']!;
                    final isActive = activeTab == id;
                    return GestureDetector(
                      onTap: () => onTabChange(id),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: ResponsiveUtils.symmetricPadding(context, horizontal: 12),
                        decoration: BoxDecoration(
                          border: isActive 
                            ? Border(bottom: BorderSide(color: Color(0xFFFFC200), width: ResponsiveUtils.scale(context, 2)))
                            : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 14),
                            color: isActive ? Colors.black : const Color(0xFF6F7277),
                            fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          
          // Fixed Filter Button
          Container(
            padding: ResponsiveUtils.customPadding(context, right: 20, left: 8, top: 8, bottom: 8),
            decoration: const BoxDecoration(
               color: Colors.white,
            ),
            child: FigmaFilterDropdown(
              activeFilter: activeTimeFilter,
              onFilterChanged: onTimeFilterChange,
              options: const ['Today', 'This Month', 'This Year', 'All Time'],
            ),
          ),
        ],
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final TripModel trip;
  final bool isClockedIn;

  const _TripCard({
    required this.trip,
    required this.isClockedIn,
  });

  void _navigateToDetails(BuildContext context) {
    if (trip.buttonText == 'View Details') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripDetailsScreen(
            tripId: trip.id,
            from: trip.from,
            to: trip.to,
            tripType: trip.tripType,
          ),
        ),
      );
    } else if (trip.buttonText == 'View Live') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripDetailsScreen(
            from: trip.from,
            to: trip.to,
            isLiveTrip: true,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLive = trip.buttonText == 'View Live';
    final actionColor = isLive ? const Color(0xFF27AE60) : Colors.black;

    return GestureDetector(
      onTap: () => _navigateToDetails(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Time & Action Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trip.timeDisplay, 
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 15), 
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                  )
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isLive ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    trip.buttonText,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 11),
                      fontWeight: FontWeight.w600,
                      color: actionColor,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),

            // Route Visualization
            _buildRouteRow(
              context, 
              Icons.circle, 
              Colors.green, 
              trip.from, 
              isFirst: true
            ),
            _buildRouteRow(
              context, 
              Icons.square, 
              Colors.red, 
              trip.to, 
              isLast: true
            ),

            const SizedBox(height: 12),

            // Footer Info
            Row(
              children: [
                _buildInfoBadge(context, Icons.local_taxi_outlined, trip.tripType),
                const Spacer(),
                Text(
                  'Steering: ${trip.steeringTime}',
                  style: TextStyle(
                    color: const Color(0xFF6F7277),
                    fontSize: ResponsiveUtils.fontSize(context, 12),
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteRow(BuildContext context, IconData icon, Color color, String text, {bool isFirst = false, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch to allow line to fill height
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                // Icon
                Icon(icon, size: 12, color: color),
                // Connector Line (only if not last)
                if (!isLast)
                   Expanded(
                    child: Container(
                      width: 1,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.symmetric(vertical: 2),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14),
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBadge(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6B7280)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: const Color(0xFF6B7280),
            fontSize: ResponsiveUtils.fontSize(context, 13),
          ),
        ),
      ],
    );
  }
}
