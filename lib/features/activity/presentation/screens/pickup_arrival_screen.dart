import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbandriver/shared/utils/responsive_utils.dart';
import '../providers/pickup_provider.dart';
import 'package:urbandriver/features/home/presentation/providers/home_provider.dart';
import 'pickup_navigation_screen.dart';
import '../../../home/presentation/screens/driver_main_screen.dart';

class PickupArrivalScreen extends ConsumerStatefulWidget {
  const PickupArrivalScreen({super.key});

  @override
  ConsumerState<PickupArrivalScreen> createState() => _PickupArrivalScreenState();
}

class _PickupArrivalScreenState extends ConsumerState<PickupArrivalScreen> {
  bool _showPassengerNotArrived = false;

  @override
  Widget build(BuildContext context) {
    final pickupState = ref.watch(pickupProvider);
    final currentStop = pickupState.currentStop;

    if (currentStop == null) {
      return const Scaffold(
        body: Center(child: Text('No pickup stops available')),
      );
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
                    
                    // Trip Live Status with Timer
                    Padding(
                      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20),
                      child: _buildTripLiveStatus(context),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.padding(context, 16)),
                    
                    // Current Pickup Card
                    Padding(
                      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20),
                      child: _buildCurrentPickupCard(context),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.padding(context, 20)),
                    
                    // Route Timeline
                    Padding(
                      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20),
                      child: _buildRouteTimeline(context),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.padding(context, 20)),
                    
                    // Next Pickups
                    Padding(
                      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20),
                      child: _buildNextPickups(context),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.padding(context, 20)),
                    
                    // Arrival Confirmation & Actions Card
                    Padding(
                      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20),
                      child: _buildArrivalActionCard(context),
                    ),
                    
                    if (_showPassengerNotArrived) ...[
                      SizedBox(height: ResponsiveUtils.padding(context, 12)),
                      Padding(
                        padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20),
                        child: _buildPassengerNotArrivedCard(context),
                      ),
                    ],
                    
                    SizedBox(height: ResponsiveUtils.padding(context, 100)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Button
      bottomSheet: _buildBottomButton(context),
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
                '02:20',
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

  Widget _buildCurrentPickupCard(BuildContext context) {
    final pickupState = ref.watch(pickupProvider);
    final currentStop = pickupState.currentStop;

    if (currentStop == null) return const SizedBox.shrink();

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

  Widget _buildRouteTimeline(BuildContext context) {
    final pickupState = ref.watch(pickupProvider);
    final currentStopIndex = pickupState.currentStopIndex;
    final stops = pickupState.stops;

    print('🟢 [ArrivalScreen RouteTimeline] Building with currentStopIndex=$currentStopIndex, stops.length=${stops.length}');

    if (stops.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: ResponsiveUtils.symmetricPadding(context, horizontal: 12),
        child: Row(
          children: List.generate(
            stops.length * 2 - 1,
            (index) {
              if (index.isEven) {
                // Stop index
                final stopIndex = index ~/ 2;
                return _buildTimelineStop(
                  context,
                  stops[stopIndex].stopNumber,
                  stops[stopIndex].location,
                  currentStopIndex == stopIndex,
                );
              } else {
                // Line between stops
                final lineIndex = index ~/ 2;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.padding(context, 6)),
                  child: SizedBox(
                    width: ResponsiveUtils.scale(context, 28),
                    child: Center(
                      child: Container(
                        height: ResponsiveUtils.scale(context, 3),
                        decoration: BoxDecoration(
                          color: currentStopIndex > lineIndex ? const Color(0xFFFFC200) : Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStop(BuildContext context, String number, String name, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: ResponsiveUtils.scale(context, 40),
          height: ResponsiveUtils.scale(context, 40),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFFFFC200) : Colors.white,
            border: Border.all(
              color: isActive ? const Color(0xFFFFC200) : Colors.grey[300]!,
              width: 3,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFFFFC200).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 16),
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
        SizedBox(height: ResponsiveUtils.padding(context, 8)),
        SizedBox(
          width: ResponsiveUtils.scale(context, 60),
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 11),
              color: isActive ? Colors.black : Colors.grey[600],
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextPickups(BuildContext context) {
    return Container(
      width: 345,
      height: 159,
      // The parent padding handles the visual "left: 24px" and "top" positioning in the flow,
      // but to be precise with "left: 24px" we might need to adjust the parent or margin here if the parent is different.
      // The parent has symmetric padding 20. If we want 24, we can add margin or change parent.
      // However, fixing width to 345 might cause overflow if the screen is small. 
      // I'll stick to the requested size but use responsive alignment if needed.
      // Since it's a card in a list, "top" is relative. 
      margin: const EdgeInsets.only(left: 4), // Adding 4 to the existing 20 to make it 24 roughly? 
      // Actually typically I should just set the container style.
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB), // Light greyish blue often used as card bg or Colors.grey[50]
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Pickups',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          Spacer(),
          _buildNextPickupItem(context, '2', 'Wakad Tech Park', '1 Passenger • ETA 09:50 AM'),
          SizedBox(height: 12),
          _buildNextPickupItem(context, '3', 'Baner Mahalunge Road', '1 Passenger • ETA 10:05 AM'),
          Spacer(),
        ],
      ),
    );
  }

  Widget _buildNextPickupItem(BuildContext context, String number, String location, String details) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location,
                style: const TextStyle(
                  fontSize: 13, // Slightly smaller to fit
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 2),
              Text(
                details,
                style: TextStyle(
                  fontSize: 11, // Small detail text
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArrivalActionCard(BuildContext context) {
    return Container(
      width: 345,
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Arrival Status
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 20,
                color: const Color(0xFFFFC200),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You have arrived to pickup Vatsal',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Make phone call
                    },
                    icon: Icon(
                      Icons.phone_outlined,
                      size: 16,
                      color: Colors.black87,
                    ),
                    label: Text(
                      'Call',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      final pickupNotifier = ref.read(pickupProvider.notifier);
                      
                      // Mark the current stop as picked up (also updates the index)
                      await pickupNotifier.markPickedUp();
                      
                      // Now read the UPDATED state to check if there are more stops
                      final updatedState = ref.read(pickupProvider);
                      print('🔄 [PickupArrivalScreen] After markPickedUp: currentStopIndex=${updatedState.currentStopIndex}, totalStops=${updatedState.stops.length}, hasMoreStops=${updatedState.currentStopIndex < updatedState.stops.length}');
                      
                      // Check if there are more stops (after index increment)
                      if (updatedState.currentStopIndex < updatedState.stops.length) {
                        // Go back to navigation screen for next pickup
                        print('🔄 [PickupArrivalScreen] Navigating to next pickup...');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PickupNavigationScreen(),
                          ),
                        );
                      } else {
                        print('🔄 [PickupArrivalScreen] All pickups completed!');
                        // If all stops done, button at bottom will show End Duty
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC200),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Mark Picked',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // Passenger Not Arrived Link
          GestureDetector(
            onTap: () {
              setState(() {
                _showPassengerNotArrived = !_showPassengerNotArrived;
              });
            },
            child: Text(
              'Passenger Not Arrived?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.red[400],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerNotArrivedCard(BuildContext context) {
    return Container(
      width: 345,
      height: 134,
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5), // Light red background
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // Center content vertically since height is fixed
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 20,
                color: Colors.red[700],
              ),
              SizedBox(width: 8),
              Text(
                'Passenger not arrived?',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () async {
                      final pickupNotifier = ref.read(pickupProvider.notifier);
                      
                      await pickupNotifier.markNoShow();
                      
                      // Now read the UPDATED state to check if there are more stops
                      final updatedState = ref.read(pickupProvider);
                      print('🔄 [PickupArrivalScreen] After markNoShow: currentStopIndex=${updatedState.currentStopIndex}, totalStops=${updatedState.stops.length}');
                      
                      // Check if there are more stops (after index increment)
                      if (updatedState.currentStopIndex < updatedState.stops.length) {
                        // Go back to navigation screen for next pickup
                        print('🔄 [PickupArrivalScreen] Navigating to next pickup...');
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PickupNavigationScreen(),
                          ),
                        );
                      } else {
                        print('🔄 [PickupArrivalScreen] All pickups completed!');
                        // Close the passenger not arrived card
                        setState(() {
                          _showPassengerNotArrived = false;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F), // Darker red
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Mark No-Shown',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _showPassengerNotArrived = false;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: BorderSide(color: Colors.grey[400]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.white,
                    ),
                    child: Text(
                      'Wait 2 Min',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    final pickupState = ref.watch(pickupProvider);
    final isLastStop = pickupState.currentStopIndex >= pickupState.stops.length - 1;
    final currentStop = pickupState.currentStop;

    if (currentStop == null) return const SizedBox.shrink();

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
            
            if (isLastStop) {
              await pickupNotifier.endTrip();

              // Mark last pickup as picked up
              await pickupNotifier.markPickedUp();
              
              // End duty - complete current duty and go to home
              final homeNotifier = ref.read(homeProvider.notifier);
              homeNotifier.completeCurrentDuty();
              
              // Load next duty's stops
              final homeState = ref.read(homeProvider);
              final nextDuty = homeState.currentDuty;
              pickupNotifier.loadStopsFromDuty(nextDuty);
              
              // Navigate to home screen
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const DriverMainScreen(
                    phoneOrEmail: 'driver@example.com',
                  ),
                ),
                (route) => false,
              );
            } else {
              // Mark current pickup as picked up and go to next
              await pickupNotifier.markPickedUp();
              
              // Navigate to next pickup
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const PickupNavigationScreen(),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isLastStop ? Colors.green : const Color(0xFFFFC200),
            foregroundColor: isLastStop ? Colors.white : Colors.black,
            elevation: 0,
            padding: ResponsiveUtils.symmetricPadding(context, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 24)),
            ),
          ),
          child: Text(
            isLastStop ? 'End Duty' : 'Mark Picked Up',
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
