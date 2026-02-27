import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbandriver/shared/utils/responsive_utils.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../data/models/duty_model.dart';
import '../providers/home_provider.dart';
import '../widgets/draggable_map_button.dart';
import '../widgets/map_view.dart';
import '../widgets/multi_duty_map_view.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../profile/presentation/providers/vehicle_provider.dart';
import 'package:urbandriver/features/profile/data/models/profile_model.dart';
import 'package:urbandriver/features/profile/data/models/vehicle_model.dart';
import '../../../activity/presentation/screens/trip_details_screen.dart';
import '../../../activity/presentation/screens/trip_map_screen.dart';
import '../../../profile/presentation/screens/vehicle_details_screen.dart';

class HomeScreen extends ConsumerWidget {
  final String phoneOrEmail;
  final VoidCallback? onMenuTap;

  const HomeScreen({
    super.key,
    required this.phoneOrEmail,
    this.onMenuTap,
  });

  String _profileInitials(String? fullName) {
    final normalized = (fullName ?? '').trim();
    if (normalized.isEmpty || normalized == '-') return '-';

    final parts = normalized
        .split(RegExp(r'[\s._-]+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) return '-';

    final first = parts.first.substring(0, 1).toUpperCase();
    final second = parts.length > 1
        ? parts.last.substring(0, 1).toUpperCase()
        : '';

    return second.isEmpty ? first : '$first $second';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);
    final profileAsync = ref.watch(profileProvider);
    final vehicleAsync = ref.watch(vehicleProvider);

    return Column(
      children: [
        // Header
        CustomAppBar(
          title: 'Dashboard',
          onMenuTap: onMenuTap,
        ),
        // Body
        Expanded(
          child: homeState.isMapView
              ? _buildMapView(context, homeState, homeNotifier)
              : Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Error Banner (if any error)
                            if (homeState.errorMessage != null)
                              Container(
                                padding: EdgeInsets.all(ResponsiveUtils.padding(context, 12)),
                                margin: EdgeInsets.only(bottom: ResponsiveUtils.padding(context, 16)),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  border: Border.all(color: Colors.red.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.warning_amber, color: Colors.red.shade700, size: 20),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Connection Issue',
                                            style: TextStyle(
                                              fontSize: ResponsiveUtils.fontSize(context, 12),
                                              fontWeight: FontWeight.bold,
                                              color: Colors.red.shade700,
                                            ),
                                          ),
                                          Text(
                                            homeState.errorMessage!,
                                            style: TextStyle(
                                              fontSize: ResponsiveUtils.fontSize(context, 11),
                                              color: Colors.red.shade600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => homeNotifier.fetchDashboard(),
                                      child: Icon(Icons.refresh, color: Colors.red.shade700, size: 20),
                                    ),
                                  ],
                                ),
                              ),
                            // Profile Card
                            profileAsync.when(
                              data: (profile) => _buildProfileCard(context, profile, homeState.isClockedIn),
                              loading: () => _buildProfileCardLoading(context),
                              error: (e, s) => _buildProfileCard(context, null, homeState.isClockedIn),
                            ),
                            SizedBox(height: ResponsiveUtils.padding(context, 20)),

                  // Clock In / Out Button (Shift Control)
                  _buildShiftControlCard(context, homeState, homeNotifier),
                  SizedBox(height: ResponsiveUtils.padding(context, 20)),

                  // No Duty Card - Show when backend has no duties for today
                  if (homeState.duties.isEmpty)
                    _buildNoDutyAllottedCard(context),
                  if (homeState.duties.isEmpty)
                    SizedBox(height: ResponsiveUtils.padding(context, 20)),

                  // Duty Allocation Card - Show when duties are not completed
                  if (!homeState.allDutiesCompleted && homeState.duties.isNotEmpty)
                    _buildDutyAllocationCard(context, homeState),
                  if (!homeState.allDutiesCompleted && homeState.duties.isNotEmpty)
                    SizedBox(height: ResponsiveUtils.padding(context, 20)),

                  // Next Duty Card - Show when there's a next duty
                  if (homeState.nextDuty != null && !homeState.allDutiesCompleted)
                    _buildNextDutyCard(context, homeState),
                  if (homeState.nextDuty != null && !homeState.allDutiesCompleted)
                    SizedBox(height: ResponsiveUtils.padding(context, 20)),

                  // Duty Completed for the Day Card (only when all duties done and clocked in)
                  if (homeState.allDutiesCompleted && homeState.isClockedIn && homeState.duties.isNotEmpty)
                    _buildDutyCompletedCard(context),
                  if (homeState.allDutiesCompleted && homeState.isClockedIn && homeState.duties.isNotEmpty)
                    SizedBox(height: ResponsiveUtils.padding(context, 20)),

                  // Tomorrow's Schedule Card (only when all duties done and clocked out)
                  if (homeState.allDutiesCompleted && !homeState.isClockedIn && homeState.duties.isNotEmpty)
                    _buildTomorrowScheduleCard(context, homeState),
                  if (homeState.allDutiesCompleted && !homeState.isClockedIn && homeState.duties.isNotEmpty)
                    SizedBox(height: ResponsiveUtils.padding(context, 20)),

                  // Activity Section
                  Text(
                    'Activity',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 18),
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.padding(context, 15)),
                  _buildActivityCards(homeState),
                  SizedBox(height: ResponsiveUtils.padding(context, 15)),

                            // Vehicle Details Card - always show, even on OFF/no-duty days
                            vehicleAsync.when(
                              data: (vehicle) => VehicleCard(vehicle: vehicle),
                              loading: () => const VehicleCard(),
                              error: (error, stackTrace) => const VehicleCard(),
                            ),
                            SizedBox(height: ResponsiveUtils.padding(context, 80)),
                              ],
                            ),
                          ),
                        ),
                        // Draggable floating map button
                        DraggableMapButton(
                          onTap: () => homeNotifier.toggleMapView(true),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }

  Widget _buildMapView(
    BuildContext context,
    HomeState homeState,
    HomeNotifier homeNotifier,
  ) {
    return Stack(
      children: [
        // Show all duties for the day with their routes
        homeState.duties.isNotEmpty
            ? MultiDutyMapView(
                duties: homeState.duties,
                driverPosition: homeState.driverPosition,
                onDutyTapped: (duty) {
                  // Optional: Show duty info or navigate to trip screen
                  debugPrint('Tapped duty: ${duty.dutyNo}');
                },
              )
            : MapView(
                currentDuty: homeState.currentDuty,
                driverPosition: homeState.driverPosition,
              ),
        Positioned(
          top: 16,
          right: 16,
          child: SafeArea(
            child: GestureDetector(
              onTap: () => homeNotifier.toggleMapView(false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.list, color: Colors.black87, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'List View',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildMapDutyInfoCard(context, homeState),
        ),
      ],
    );
  }

  Widget _buildMapDutyInfoCard(BuildContext context, HomeState homeState) {
    final duty = homeState.currentDuty;

    if (duty == null) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: const SafeArea(
          top: false,
          child: Center(
            child: Text('No duty selected'),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Duty ${duty.dutyNo}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    duty.route,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildMapDutyInfoItem(Icons.location_on, Colors.green, duty.from),
            const SizedBox(height: 8),
            _buildMapDutyInfoItem(Icons.flag, Colors.red, duty.to),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMapTimeChip(Icons.access_time, duty.joiningTime, 'Start'),
                _buildMapTimeChip(Icons.schedule, duty.closeTime, 'End'),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TripMapScreen(
                        duty: duty,
                        driverPosition: homeState.driverPosition,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC200),
                  foregroundColor: Colors.black,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Navigation',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapDutyInfoItem(IconData icon, Color iconColor, String value) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMapTimeChip(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, ProfileModel? profile, bool isClockedIn) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Picture with ring
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFC200), width: 2),
            ),
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: (profile?.profileImageUrl != null && profile!.profileImageUrl!.trim().isNotEmpty)
                    ? Image.network(
                        profile.profileImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, error, stackTrace) => Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFFF4CC),
                                Color(0xFFFFC200),
                              ],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _profileInitials(profile.name),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFFF4CC),
                              Color(0xFFFFC200),
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _profileInitials(profile?.name),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Name and Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${profile?.name.split(' ')[0] ?? 'Driver'}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Ready to drive?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Simple Status Dot
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isClockedIn ? Colors.green[50] : Colors.grey[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.circle,
              color: isClockedIn ? Colors.green : Colors.grey,
              size: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCardLoading(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 92,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildDutyAllocationCard(BuildContext context, HomeState state) {
    final currentDuty = state.currentDuty;
    if (currentDuty == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: state.isClockedIn ? () {
        print('🟢 [home_screen] Tapping duty: ${currentDuty.from} → ${currentDuty.to}');
        print('🟢 [home_screen] Duty has ${currentDuty.stops.length} stops');
        for (var i = 0; i < currentDuty.stops.length; i++) {
          print('  Stop $i: ${currentDuty.stops[i].location} @ ${currentDuty.stops[i].timeWindow}');
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripDetailsScreen(
              from: currentDuty.from,
              to: currentDuty.to,
              tripType: currentDuty.serviceType,
              reportingTime: currentDuty.reportingTime,
              tripStartTime: currentDuty.joiningTime,
              estimatedEndTime: currentDuty.closeTime,
              restTime: currentDuty.restTime,
              kms: currentDuty.tripKms,
              stops: currentDuty.stops,
              isLiveTrip: true,
              duty: currentDuty,
            ),
          ),
        );
      } : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Left Status Bar
                Container(
                  width: 6,
                  color: state.isClockedIn ? const Color(0xFFFFC200) : Colors.grey[300],
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Duty Allocation',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            if (state.isClockedIn)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC200),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'ON DUTY',
                                  key: ValueKey('status_text'),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // Quick fix for the text literal above inside the Replace call:
                        // I realized I hardcoded 'OFFLINE' where it should be 'ON DUTY' or similar. 
                        // But I can't edit inside the string creation easily. 
                        // I will write the correct code in the block below.
                        const SizedBox(height: 20),
                        
                        // Row 1: Duty No & Route
                        Row(
                          children: [
                            Expanded(child: _buildSimpleInfo('Duty No.', currentDuty.dutyNo)),
                            Expanded(child: _buildSimpleInfo('Route', currentDuty.route)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Row 2: Joining Time & Close Time
                        Row(
                          children: [
                            Expanded(child: _buildSimpleInfo('Join Time', currentDuty.joiningTime)),
                            Expanded(child: _buildSimpleInfo('Close Time', currentDuty.closeTime)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ],
    );
  }

  Widget _buildNextDutyCard(BuildContext context, HomeState state) {
    final nextDuty = state.nextDuty;
    if (nextDuty == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TripDetailsScreen(
              from: nextDuty.from,
              to: nextDuty.to,
              tripType: nextDuty.serviceType,
              reportingTime: nextDuty.reportingTime,
              tripStartTime: nextDuty.joiningTime,
              estimatedEndTime: nextDuty.closeTime,
              restTime: nextDuty.restTime,
              kms: nextDuty.tripKms,
              stops: nextDuty.stops,
              isLiveTrip: false,
              duty: nextDuty,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Left Status Bar for Next Duty (Orange)
                Container(
                  width: 6,
                  color: Colors.orange[300],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Next Duty',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'UPCOMING',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange[800],
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        
                        // Row 1
                        Row(
                          children: [
                            Expanded(child: _buildSimpleInfo('Duty No.', nextDuty.dutyNo)),
                            Expanded(child: _buildSimpleInfo('Route', nextDuty.route)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Row 2
                        Row(
                          children: [
                            Expanded(child: _buildSimpleInfo('Join Time', nextDuty.joiningTime)),
                            Expanded(child: _buildSimpleInfo('Close Time', nextDuty.closeTime)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCards(HomeState homeState) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: _buildActivityCard(
              title: 'No. of Trips',
              time: '${homeState.totalTrips} Trips',
              color: const Color(0xFFEAF2FF), // Light Blue tint
              borderColor: const Color(0xFFBBDEFB),
              iconColor: const Color(0xFF1565C0),
              icon: Icons.directions_bus,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: _buildActivityCard(
              title: 'Steering Time',
              time: homeState.totalSteeringTime.isNotEmpty ? homeState.totalSteeringTime : '0 hr',
              color: const Color(0xFFFFF8E1), // Light Amber tint
              borderColor: const Color(0xFFFFE082),
              iconColor: const Color(0xFFEF6C00),
              icon: Icons.timer,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: _buildActivityCard(
              title: 'Overtime',
              time: '0 hr',
              color: const Color(0xFFFFEBEE), // Light Red tint
              borderColor: const Color(0xFFFFCDD2),
              iconColor: const Color(0xFFC62828),
              icon: Icons.more_time,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: _buildActivityCard(
              title: 'Total KM',
              time: '${homeState.totalKms} km',
              color: const Color(0xFFE8F5E9), // Light Green tint
              borderColor: const Color(0xFFC8E6C9),
              iconColor: const Color(0xFF2E7D32),
              icon: Icons.speed,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required String title,
    required String time,
    required Color color,
    required Color borderColor,
    required Color iconColor,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon ?? Icons.access_time, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: iconColor.withValues(alpha: 0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: iconColor, // Using icon color for text to match theme
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildShiftControlCard(BuildContext context, HomeState homeState, HomeNotifier homeNotifier) {
    return GestureDetector(
      onTap: () async {
        if (homeState.isClockedIn) {
          final shouldClockOut = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 16)),
                ),
                title: Text(
                  'Clock Out',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: ResponsiveUtils.fontSize(context, 18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  'Are you sure you want to end your shift?',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: ResponsiveUtils.fontSize(context, 14),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: ResponsiveUtils.fontSize(context, 14),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(
                      'Clock Out',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: ResponsiveUtils.fontSize(context, 14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
          if (shouldClockOut == true) homeNotifier.toggleClockStatus();
        } else {
          homeNotifier.toggleClockStatus();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: homeState.isClockedIn ? const Color(0xFFFFC200) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: homeState.isClockedIn 
              ? null
              : Border.all(color: Colors.grey[200]!, width: 2),
          boxShadow: [
            BoxShadow(
              color: homeState.isClockedIn 
                  ? const Color(0xFFFFC200).withValues(alpha: 0.4) 
                  : Colors.grey.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: homeState.isClockedIn 
                    ? Colors.white
                    : const Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                homeState.isClockedIn ? Icons.logout : Icons.login,
                color: Colors.black,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    homeState.isClockedIn ? 'YOU ARE ONLINE' : 'YOU ARE OFFLINE',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: homeState.isClockedIn ? Colors.black.withValues(alpha: 0.6) : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    homeState.isClockedIn ? 'Tap to Clock Out' : 'Tap to Start Shift',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: homeState.isClockedIn ? Colors.black54 : Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDutyAllottedCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFC200).withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC200).withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy,
              color: Color(0xFFFFA100),
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No Duty Allotted Today',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDutyCompletedCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF4CC), Color(0xFFFFE082)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFC200).withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFC200).withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Success Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC200).withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 50,
              color: Color(0xFFFFA100),
            ),
          ),
          const SizedBox(height: 20),
          // Title
          const Text(
            'Duty Completed for the Day!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          // Message
          Text(
            'Great job! You have successfully completed all your duties for today. Take a well-deserved rest.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[800],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCompletionStat(
                icon: Icons.route,
                label: 'Routes',
                value: '3',
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.grey[400],
              ),
              _buildCompletionStat(
                icon: Icons.schedule,
                label: 'Hours',
                value: '8+',
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.grey[400],
              ),
              _buildCompletionStat(
                icon: Icons.emoji_events,
                label: 'Status',
                value: 'Done',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFFFFA100),
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildTomorrowScheduleCard(BuildContext context, HomeState homeState) {
    final tomorrowDuties = homeState.tomorrowDuties;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4CC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Color(0xFFFFA100),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tomorrow's Schedule",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Prepare for your next day',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4CC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${tomorrowDuties.length} ${tomorrowDuties.length == 1 ? 'Duty' : 'Duties'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (tomorrowDuties.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(Icons.event_busy, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text(
                      'No duties scheduled for tomorrow',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...tomorrowDuties.asMap().entries.map((entry) {
              final index = entry.key;
              final duty = entry.value;
              final isLast = index == tomorrowDuties.length - 1;
              
              return Column(
                children: [
                  _buildTomorrowDutyItem(duty, index + 1),
                  if (!isLast) const SizedBox(height: 12),
                  if (!isLast) Divider(color: Colors.grey[300], height: 1),
                  if (!isLast) const SizedBox(height: 12),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildTomorrowDutyItem(DutyModel duty, int dutyNumber) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '$dutyNumber',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      duty.dutyNo,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      duty.route,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTomorrowDutyInfo(
                  icon: Icons.location_on_outlined,
                  label: 'From',
                  value: duty.from,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 16, color: Colors.grey[500]),
              const SizedBox(width: 8),
              Expanded(
                child: _buildTomorrowDutyInfo(
                  icon: Icons.location_on,
                  label: 'To',
                  value: duty.to,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildTomorrowDutyInfo(
                  icon: Icons.access_time,
                  label: 'Start',
                  value: duty.joiningTime,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTomorrowDutyInfo(
                  icon: Icons.access_time_filled,
                  label: 'End',
                  value: duty.closeTime,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTomorrowDutyInfo({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFFFA100)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class VehicleCard extends StatelessWidget {
  final VehicleModel? vehicle;
  const VehicleCard({super.key, this.vehicle});

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VehicleDetailsScreen(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFCF0),
              Color(0xFFFFF4CC),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFC200).withValues(alpha: 0.8), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFC200).withValues(alpha: 0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Vehicle",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF7C5A00),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFC200).withValues(alpha: 0.7)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.directions_car, color: Colors.orange[800], size: 14),
                      const SizedBox(width: 4),
                      const Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7C5A00),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFE08A),
                        Color(0xFFFFC200),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFC200).withValues(alpha: 0.9)),
                  ),
                  child: Center(
                    child: const Icon(Icons.local_taxi, color: Color(0xFF4B3A00), size: 24),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayValue(vehicle?.registrationNumber),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _displayValue(vehicle?.model),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
