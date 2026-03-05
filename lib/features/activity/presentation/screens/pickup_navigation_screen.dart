import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbandriver/shared/utils/responsive_utils.dart';
import '../providers/pickup_provider.dart';
import 'pickup_arrival_screen.dart';
import 'full_map_screen.dart';
import '../../../home/presentation/widgets/map_view.dart';
import '../../../home/presentation/providers/home_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickupNavigationScreen extends ConsumerWidget {
  const PickupNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pickupState = ref.watch(pickupProvider);
    print('🟡 [PickupNavigationScreen] Build called with ${pickupState.stops.length} stops');
    if (pickupState.stops.isNotEmpty) {
      for (var i = 0; i < pickupState.stops.length; i++) {
        print('   Stop $i: ${pickupState.stops[i].location} @ ${pickupState.stops[i].timeWindow}');
      }
    } else {
      print('   ❌ NO STOPS LOADED!');
    }
    
    if (pickupState.stops.isNotEmpty && !pickupState.hasStartedTrip) {
      Future.microtask(() => ref.read(pickupProvider.notifier).startTripIfNeeded());
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
                    Padding(
                      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20),
                      child: _buildProgressStepper(context),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.padding(context, 20)),
                    
                    // Trip Live Status
                    Padding(
                      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20),
                      child: _buildTripLiveStatus(context),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.padding(context, 16)),
                    
                    // Current Pickup Card
                    Padding(
                      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20),
                      child: _buildCurrentPickupCard(context, ref),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.padding(context, 20)),
                    
                    // Route Timeline
                    Padding(
                      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20),
                      child: _buildRouteTimeline(context, ref),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.padding(context, 20)),
                    
                    // Next Pickups
                    Padding(
                      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20),
                      child: _buildNextPickups(context, ref),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.padding(context, 20)),
                    
                    // Live Map Preview (Card)
                    Padding(
                      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20),
                      child: _buildMapPreview(context, ref),
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
    return Row(
      children: [
        _buildStepperItem(context, 'Trip Setup', true, true),
        Expanded(child: _buildStepperLine(context, true)),
        _buildStepperItem(context, 'Inspection', true, true),
        Expanded(child: _buildStepperLine(context, true)),
        _buildStepperItem(context, 'Pickups', true, false),
      ],
    );
  }

  Widget _buildStepperItem(BuildContext context, String label, bool isActive, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: ResponsiveUtils.scale(context, 24),
          height: ResponsiveUtils.scale(context, 24),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive || isCompleted ? const Color(0xFFFFC200) : Colors.grey[300],
          ),
          child: isCompleted
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
            color: isActive || isCompleted ? Colors.black : Colors.grey[600],
            fontWeight: isActive || isCompleted ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildTripLiveStatus(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Trip Live • 09:10 AM',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Container(
          padding: ResponsiveUtils.symmetricPadding(context, horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 12)),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: ResponsiveUtils.padding(context, 6)),
              Text(
                'On Schedule',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 12),
                  fontWeight: FontWeight.w600,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentPickupCard(BuildContext context, WidgetRef ref) {
    final pickupState = ref.watch(pickupProvider);
    final currentStop = pickupState.currentStop;
    
    print('🔍 [_buildCurrentPickupCard] currentStopIndex=${pickupState.currentStopIndex}, stops.length=${pickupState.stops.length}, currentStop=$currentStop');
    
    if (currentStop == null) {
      print('   ⚠️ currentStop is null! Returning empty');
      return const SizedBox.shrink();
    }

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
                'Pickup ${currentStop.stopNumber} of ${pickupState.stops.length}',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Container(
                width: ResponsiveUtils.scale(context, 32),
                height: ResponsiveUtils.scale(context, 32),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFC200),
                ),
                child: Icon(
                  Icons.directions_car,
                  size: ResponsiveUtils.iconSize(context, 18),
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.padding(context, 12)),
          _buildPickupDetailRow(context, Icons.location_on, currentStop.location),
          SizedBox(height: ResponsiveUtils.padding(context, 8)),
          _buildPickupDetailRow(context, Icons.person, currentStop.passengers),
          SizedBox(height: ResponsiveUtils.padding(context, 8)),
          _buildPickupDetailRow(context, Icons.access_time, currentStop.timeWindow),
          SizedBox(height: ResponsiveUtils.padding(context, 8)),
          _buildPickupDetailRow(context, Icons.route, currentStop.distance),
          SizedBox(height: ResponsiveUtils.padding(context, 16)),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC200),
                foregroundColor: Colors.black,
                elevation: 0,
                padding: ResponsiveUtils.symmetricPadding(context, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 24)),
                ),
              ),
              child: Text(
                'Navigate to Pickup',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 15),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickupDetailRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: ResponsiveUtils.iconSize(context, 16),
          color: const Color(0xFFFFC200),
        ),
        SizedBox(width: ResponsiveUtils.padding(context, 8)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 13),
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteTimeline(BuildContext context, WidgetRef ref) {
    final pickupState = ref.watch(pickupProvider);
    final currentStopIndex = pickupState.currentStopIndex;
    final stops = pickupState.stops;

    print('🟡 [RouteTimeline] Building with currentStopIndex=$currentStopIndex, stops.length=${stops.length}');

    if (stops.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: ResponsiveUtils.symmetricPadding(context, horizontal: 4, vertical: 12),
        child: Row(
          children: List.generate(
            stops.length * 2 - 1,
            (index) {
              if (index.isEven) {
                // Stop index
                final stopIndex = index ~/ 2;
                final isPassed = currentStopIndex > stopIndex;
                final isCurrent = currentStopIndex == stopIndex;
                return _buildTimelineStop(
                  context,
                  stops[stopIndex].location,
                  isPassed,
                  isCurrent,
                  stopIndex == 0,
                  stopIndex == stops.length - 1,
                );
              } else {
                // Line between stops
                final lineIndex = index ~/ 2;
                final isPassed = currentStopIndex > lineIndex;
                return Container(
                  width: ResponsiveUtils.scale(context, 40),
                  height: ResponsiveUtils.scale(context, 4),
                  margin: EdgeInsets.only(bottom: ResponsiveUtils.padding(context, 32)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPassed 
                        ? [const Color(0xFFFFC200), const Color(0xFFFFC200)]
                        : [Colors.grey[300]!, Colors.grey[300]!],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStop(
    BuildContext context, 
    String name, 
    bool isPassed,
    bool isCurrent,
    bool isFirst,
    bool isLast,
  ) {
    // Get abbreviated name (first 3-4 chars for better fit)
    String displayName = name;
    if (name.length > 5) {
      // Try to abbreviate intelligently
      displayName = name.substring(0, 4);
    }
    
    Color dotColor;
    Color textColor;
    Color borderColor;
    
    if (isCurrent) {
      dotColor = const Color(0xFFFFC200);
      textColor = Colors.black;
      borderColor = const Color(0xFFFFC200);
    } else if (isPassed) {
      dotColor = Colors.green;
      textColor = Colors.green[700]!;
      borderColor = Colors.green;
    } else {
      dotColor = Colors.grey[300]!;
      textColor = Colors.grey[500]!;
      borderColor = Colors.grey[300]!;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Circle indicator
        Container(
          width: ResponsiveUtils.scale(context, 48),
          height: ResponsiveUtils.scale(context, 48),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCurrent ? dotColor : Colors.white,
            border: Border.all(
              color: borderColor,
              width: isCurrent ? 4 : 3,
            ),
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: dotColor.withOpacity(0.4),
                      blurRadius: 12,
                      spreadRadius: 3,
                    )
                  ]
                : isPassed
                  ? [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.2),
                        blurRadius: 6,
                        spreadRadius: 1,
                      )
                    ]
                  : [],
          ),
          child: isPassed && !isCurrent
              ? Icon(
                  Icons.check,
                  size: ResponsiveUtils.iconSize(context, 24),
                  color: Colors.green,
                )
              : Center(
                  child: Text(
                    displayName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.fontSize(context, isCurrent ? 12 : 11),
                      fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                      color: isCurrent ? Colors.white : textColor,
                      height: 1.1,
                    ),
                  ),
                ),
        ),
        SizedBox(height: ResponsiveUtils.padding(context, 8)),
        // Full name below
        Container(
          constraints: BoxConstraints(
            maxWidth: ResponsiveUtils.scale(context, 70),
          ),
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 12),
              color: textColor,
              fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextPickups(BuildContext context, WidgetRef ref) {
    final pickupState = ref.watch(pickupProvider);
    final nextStops = pickupState.nextStops;

    print('🔍 [_buildNextPickups] currentStopIndex=${pickupState.currentStopIndex}, stops.length=${pickupState.stops.length}, nextStops.length=${nextStops.length}');
    if (nextStops.isNotEmpty) {
      for (var i = 0; i < nextStops.length; i++) {
        print('   NextStop $i: ${nextStops[i].location}');
      }
    } else {
      print('   ⚠️ nextStops is empty!');
    }

    if (nextStops.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Next Pickups',
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, 16),
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: ResponsiveUtils.padding(context, 12)),
        Container(
          padding: ResponsiveUtils.symmetricPadding(context, horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 12)),
          ),
          child: Column(
            children: List.generate(
              nextStops.length,
              (index) => Column(
                children: [
                  if (index > 0)
                    Divider(height: ResponsiveUtils.padding(context, 16), color: Colors.grey[300]),
                  _buildNextPickupItem(
                    context,
                    nextStops[index].stopNumber,
                    nextStops[index].location,
                    nextStops[index].passengers,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextPickupItem(BuildContext context, String number, String location, String details) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: TextStyle(
            fontSize: ResponsiveUtils.fontSize(context, 14),
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(width: ResponsiveUtils.padding(context, 12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 14),
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: ResponsiveUtils.padding(context, 4)),
              Text(
                details,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 12),
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMapPreview(BuildContext context, WidgetRef ref) {
    final pickupState = ref.watch(pickupProvider);
    final homeState = ref.watch(homeProvider);
    final routeStops = pickupState.stops
      .where((stop) => stop.latitude >= -90 && stop.latitude <= 90 && stop.longitude >= -180 && stop.longitude <= 180)
      .map((stop) => LatLng(stop.latitude, stop.longitude))
      .toList();
    final routeStopLabels = pickupState.stops
      .where((stop) => stop.latitude >= -90 && stop.latitude <= 90 && stop.longitude >= -180 && stop.longitude <= 180)
      .map((stop) => stop.location)
      .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Live Map Preview',
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 16),
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FullMapScreen()),
                );
              },
              child: Text(
                'View Full Map',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 12),
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFFFC200),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.padding(context, 12)),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FullMapScreen()),
            );
          },
          child: Container(
            height: ResponsiveUtils.scale(context, 250),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 16)),
              color: const Color(0xFFF5F5F5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 16)),
              child: Stack(
                children: [
                  // Actual Google Map
                  Positioned.fill(
                    child: MapView(
                      currentDuty: homeState.currentDuty,
                      driverPosition: homeState.driverPosition,
                      routeStops: routeStops,
                      routeStopLabels: routeStopLabels,
                    ),
                  ),
                  // Clickable overlay hint
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.fullscreen, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text('Expand', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context, WidgetRef ref) {
    return Container(
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
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            final pickupNotifier = ref.read(pickupProvider.notifier);
            final homeState = ref.read(homeProvider);
            await pickupNotifier.markArrived(
              latitude: homeState.driverPosition?.latitude,
              longitude: homeState.driverPosition?.longitude,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PickupArrivalScreen(),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC200),
            foregroundColor: Colors.black,
            elevation: 0,
            padding: ResponsiveUtils.symmetricPadding(context, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 24)),
            ),
          ),
          child: Text(
            'Arrive at Pickup',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
