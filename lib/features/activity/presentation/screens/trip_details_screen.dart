import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbandriver/shared/utils/responsive_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:urbandriver/features/home/data/models/duty_model.dart';
import 'package:urbandriver/features/home/presentation/widgets/map_view.dart';
import 'pin_entry_screen.dart';
import 'trip_map_screen.dart';
import 'pickup_navigation_screen.dart';
import 'package:urbandriver/features/home/presentation/providers/home_provider.dart';
import '../providers/pickup_provider.dart';

class TripDetailsScreen extends ConsumerWidget {
  final String? tripId;
  final String from;
  final String to;
  final String? tripType;
  final String? reportingTime;
  final String? tripStartTime;
  final String? estimatedEndTime;
  final String? restTime;
  final int? kms;
  final bool isLiveTrip;
  final List<DutyStop>? stops;
  final DutyModel? duty;

  const TripDetailsScreen({
    super.key,
    this.tripId,
    required this.from,
    required this.to,
    this.tripType,
    this.reportingTime,
    this.tripStartTime,
    this.estimatedEndTime,
    this.restTime,
    this.kms,
    this.isLiveTrip = false,
    this.stops,
    this.duty,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('🟢 [TripDetailsScreen] Built with: $from → $to');
    print('🟢 [TripDetailsScreen] Received ${stops?.length ?? 0} stops');
    if (stops != null) {
      for (var i = 0; i < stops!.length; i++) {
        print('  Stop $i: ${stops![i].location} @ ${stops![i].timeWindow}');
      }
    }
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context),
            
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: ResponsiveUtils.padding(context, 16)),
                    
                    // Progress Stepper
                    _buildProgressStepper(context),
                    
                    SizedBox(height: ResponsiveUtils.padding(context, 20)),
                    
                    // Trip Summary Card
                    Padding(
                      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20),
                      child: _buildTripSummaryCard(context),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.padding(context, 20)),
                    
                    // Timing Breakdown
                    Padding(
                      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20),
                      child: _buildTimingBreakdown(context),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.padding(context, 20)),
                    
                    // Location Section
                    Padding(
                      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20),
                      child: _buildLocationSection(context, ref),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.padding(context, 20)),
                    
                    // Stops/Depot Information
                    Padding(
                      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20),
                      child: _buildStopsSection(context),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.padding(context, 100)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Button
      bottomSheet: _buildBottomButton(context, ref),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios,
              size: ResponsiveUtils.iconSize(context, 20),
              color: Colors.black,
            ),
          ),
          SizedBox(width: ResponsiveUtils.padding(context, 16)),
          Text(
            'Today',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStepper(BuildContext context) {
    return Padding(
      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 40),
      child: Row(
        children: [
          _buildStepperItem(context, 'Trip Setup', true, false),
          Expanded(child: _buildStepperLine(context, false)),
          _buildStepperItem(context, 'Inspection', false, false),
          Expanded(child: _buildStepperLine(context, false)),
          _buildStepperItem(context, 'Pickups', false, true),
        ],
      ),
    );
  }

  Widget _buildStepperItem(BuildContext context, String label, bool isActive, bool isLast) {
    return Column(
      children: [
        Container(
          width: ResponsiveUtils.scale(context, 24),
          height: ResponsiveUtils.scale(context, 24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFFFFC200) : Colors.grey[300],
          ),
          child: isActive
              ? Icon(
                  Icons.check,
                  size: ResponsiveUtils.iconSize(context, 16),
                  color: Colors.white,
                )
              : null,
        ),
        SizedBox(height: ResponsiveUtils.padding(context, 8)),
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, 11),
            color: isActive ? Colors.black : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepperLine(BuildContext context, bool isActive) {
    return Container(
      height: 2,
      margin: EdgeInsets.only(bottom: ResponsiveUtils.padding(context, 28)),
      color: isActive ? const Color(0xFFFFC200) : Colors.grey[300],
    );
  }

  Widget _buildTripSummaryCard(BuildContext context) {
    return Container(
      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Trip Summary',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                padding: ResponsiveUtils.symmetricPadding(context, horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC200),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 12)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isLiveTrip ? Colors.green : Colors.orange,
                      ),
                    ),
                    SizedBox(width: ResponsiveUtils.padding(context, 4)),
                    Text(
                      isLiveTrip ? 'Live Trip' : 'Reporting Pending',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 10),
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.padding(context, 12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Route: $from → $to',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 13),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.padding(context, 4)),
                  if (tripType != null)
                    Text(
                      'Trip Type: $tripType',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 13),
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimingBreakdown(BuildContext context) {
    final actualReportingTime = (reportingTime != null && reportingTime!.isNotEmpty)
      ? reportingTime!
      : '--';
    final actualTripStartTime = (tripStartTime != null && tripStartTime!.isNotEmpty)
      ? tripStartTime!
      : '--';
    final actualRestTime = (restTime != null && restTime!.isNotEmpty)
      ? restTime!
      : '--';
    final actualEstimatedEndTime = (estimatedEndTime != null && estimatedEndTime!.isNotEmpty)
      ? estimatedEndTime!
      : '--';

    return Container(
      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 12)),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timing Breakdown',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 15),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: ResponsiveUtils.padding(context, 12)),
          _buildTimingRow(context, 'Reporting Time', actualReportingTime),
          _buildTimingRow(context, 'Trip Start', actualTripStartTime),
          _buildTimingRow(context, 'Rest Time', actualRestTime),
          _buildTimingRow(context, 'Estimated End', actualEstimatedEndTime),
        ],
      ),
    );
  }

  Widget _buildTimingRow(BuildContext context, String label, String time) {
    return Padding(
      padding: ResponsiveUtils.symmetricPadding(context, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 13),
              color: Colors.grey[700],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 13),
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context, WidgetRef ref) {
    final kmsLabel = kms != null ? '$kms km' : '-- km';

    return Container(
      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFFC200),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.padding(context, 8)),
                  Text(
                    'Your location',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 14),
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              Text(
                '5:25 AM',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 13),
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.padding(context, 12)),
          Padding(
            padding: ResponsiveUtils.customPadding(context, left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kmsLabel,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 13),
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: ResponsiveUtils.padding(context, 16)),
                if (duty != null || (isLiveTrip && ref.read(homeProvider).currentDuty != null))
                  Builder(
                    builder: (context) {
                      final useDuty = duty ?? ref.read(homeProvider).currentDuty!;
                      return Container(
                        height: 200,
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: ResponsiveUtils.padding(context, 12)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: MapView(
                            currentDuty: useDuty,
                            driverPosition: ref.read(homeProvider).driverPosition,
                            tripStarted: isLiveTrip,
                            navigationMode: false,
                            routeStops: useDuty.stops.map((s) => LatLng(s.latitude, s.longitude)).toList(),
                            routeStopLabels: useDuty.stops.map((s) => s.location).toList(),
                          ),
                        ),
                      );
                    }
                  ),
                SizedBox(height: ResponsiveUtils.padding(context, 8)),
                GestureDetector(
                  onTap: () {
                    // Get the current duty from home provider for map display
                    final homeState = ref.read(homeProvider);
                    if (homeState.currentDuty != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TripMapScreen(
                            duty: homeState.currentDuty!,
                            driverPosition: homeState.driverPosition,
                            onTripStarted: () {
                              // Handle trip started if needed
                              debugPrint('Trip started from map screen');
                            },
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: ResponsiveUtils.symmetricPadding(context, horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC200),
                      borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 12)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: ResponsiveUtils.iconSize(context, 14),
                          color: Colors.black,
                        ),
                        SizedBox(width: ResponsiveUtils.padding(context, 4)),
                        Text(
                          'View Maps',
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 12),
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getStopsForRoute() {
    // If stops data is provided from API/backend, use it
    if (stops != null && stops!.isNotEmpty) {
      print('🟢 [TripDetailsScreen] Using ${stops!.length} stops from API');
      return stops!.map((stop) => {
        'name': stop.location,
        'time': stop.timeWindow,
        'description': stop.passengers.isNotEmpty ? '${stop.passengers} Passengers' : '',
        'icon': Icons.location_on,
        'iconColor': const Color(0xFFFFC200),
        'isCompleted': false,
      }).toList();
    }
    
    // No hardcoded data - API data is required
    throw Exception('Trip stops data not available from server');
  }

  Widget _buildStopsSection(BuildContext context) {
    // Stops must come from API - if not available, show error
    try {
      final stops = _getStopsForRoute();
      return Column(
        children: stops.asMap().entries.map((entry) {
          final index = entry.key;
          final stop = entry.value;
          final isLast = index == stops.length - 1;
          final isCompleted = stop['isCompleted'] as bool? ?? false;
          
          return _buildStopItem(
            context,
            stop['name'] as String,
            stop['time'] as String,
            stop['description'] as String,
            stop['icon'] as IconData,
            stop['iconColor'] as Color,
            isLast,
            stop['hasLink'] as bool? ?? false,
            isCompleted,
          );
        }).toList(),
      );
    } catch (e) {
      // Show error message if stops not available
      return Center(
        child: Padding(
          padding: ResponsiveUtils.symmetricPadding(context, vertical: 40),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 40),
              SizedBox(height: ResponsiveUtils.padding(context, 12)),
              Text(
                'Trip stops not available',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildStopItem(
    BuildContext context,
    String name,
    String time,
    String description,
    IconData icon,
    Color iconColor,
    bool isLast,
    bool hasLink,
    bool isCompleted,
  ) {
    final isDestination = isLast;
    final isDepot = icon == Icons.warehouse;
    
    return Padding(
      padding: ResponsiveUtils.symmetricPadding(context, vertical: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Yellow vertical bar timeline with white dots
          Column(
            children: [
              // White dot or yellow icon
              Container(
                width: ResponsiveUtils.scale(context, 24),
                height: ResponsiveUtils.scale(context, 24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDepot ? const Color(0xFFFFC200) : Colors.white,
                  border: isDepot ? null : Border.all(
                    color: const Color(0xFFFFC200),
                    width: 3,
                  ),
                ),
                child: isDepot
                    ? Icon(
                        Icons.directions_car,
                        size: ResponsiveUtils.iconSize(context, 14),
                        color: Colors.white,
                      )
                    : null,
              ),
              // Yellow vertical bar
              if (!isLast)
                Container(
                  width: ResponsiveUtils.scale(context, 10),
                  height: ResponsiveUtils.scale(context, description.isEmpty ? 40 : (hasLink ? 90 : 70)),
                  color: const Color(0xFFFFC200),
                ),
            ],
          ),
          SizedBox(width: ResponsiveUtils.padding(context, 12)),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 15),
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 14),
                        color: isDestination ? Colors.blue[700] : Colors.grey[700],
                        fontWeight: isDestination ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  SizedBox(height: ResponsiveUtils.padding(context, 4)),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, 13),
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
                if (hasLink) ...[
                  SizedBox(height: ResponsiveUtils.padding(context, 4)),
                  GestureDetector(
                    onTap: () {
                      // TODO: Handle link tap
                    },
                    child: Text(
                      'Scheduled break for meals and refreshment',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 13),
                        color: Colors.blue[700],
                        decoration: TextDecoration.underline,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                SizedBox(height: ResponsiveUtils.padding(context, 8)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    // Only show action button for live trips
    if (!isLiveTrip) {
      return Container(
        width: double.infinity,
        padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Container(
          padding: ResponsiveUtils.symmetricPadding(context, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 12)),
            border: Border.all(color: Colors.grey[300]!, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
              const SizedBox(width: 8),
              Text(
                'Preview Only',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          if (homeState.isLockedOutForToday) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You are locked out for today'),
                backgroundColor: Colors.red,
                duration: Duration(milliseconds: 1500),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          if (!homeState.isClockedIn) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Clock in to start duty"),
                backgroundColor: Colors.red,
                duration: Duration(milliseconds: 1500),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          final activeDuty = duty ?? homeState.currentDuty;
          if (activeDuty != null) {
            await ref.read(pickupProvider.notifier).loadStopsFromDuty(activeDuty);
            if (!context.mounted) return;
            final pickupState = ref.read(pickupProvider);
            if (pickupState.hasPersistedDutyProgress) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PickupNavigationScreen(),
                ),
              );
              return;
            }
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PinEntryScreen(
                depotName: from == 'Mumbai' ? 'Mumbai Depot' : 'Wakad Depot',
                isFirstDuty: homeState.currentDutyIndex == 0,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFC200),
          foregroundColor: Colors.black,
          elevation: 0,
          padding: ResponsiveUtils.symmetricPadding(context, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 12)),
          ),
        ),
        child: Text(
          from == 'Mumbai' ? 'Navigate to Mumbai Depot' : 'Navigate to Wakad Depot',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, 15),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
