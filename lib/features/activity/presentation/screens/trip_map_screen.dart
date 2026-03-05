import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';
import '../../../home/data/models/duty_model.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../home/presentation/widgets/map_view.dart';
import '../../presentation/providers/pickup_provider.dart';

class TripMapScreen extends ConsumerStatefulWidget {
  final DutyModel duty;
  final Position? driverPosition;
  final VoidCallback? onTripStarted;

  const TripMapScreen({
    super.key,
    required this.duty,
    this.driverPosition,
    this.onTripStarted,
  });

  @override
  ConsumerState<TripMapScreen> createState() => _TripMapScreenState();
}

class _TripMapScreenState extends ConsumerState<TripMapScreen> {
  bool _navigationStarted = false;
  bool _isStarting = false;
  bool _destinationReached = false;
  Position? _liveDriverPosition;
  StreamSubscription<Position>? _positionSubscription;

  bool _isValidLatLng(double lat, double lng) {
    if (lat == 0.0 && lng == 0.0) return false;
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  // Get route stops from duty stops
  List<LatLng> _getRouteStops() {
    final stops = <LatLng>[];
    
    if (widget.duty.stops.isNotEmpty) {
      // Use stops from duty
      for (var stop in widget.duty.stops) {
        if (_isValidLatLng(stop.latitude, stop.longitude)) {
          stops.add(LatLng(stop.latitude, stop.longitude));
        }
      }
    }
    
    return stops;
  }

  // Get route stop labels
  List<String> _getRouteStopLabels() {
    final labels = <String>[];
    
    if (widget.duty.stops.isNotEmpty) {
      for (var stop in widget.duty.stops) {
        labels.add(stop.location);
      }
    }
    
    return labels;
  }

  @override
  void initState() {
    super.initState();
    _liveDriverPosition = widget.driverPosition;
    _startLocationTracking();
    Future.microtask(() {
      ref.read(pickupProvider.notifier).loadStopsFromDuty(widget.duty);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pickupState = ref.watch(pickupProvider);
    final routeStops = _getRouteStops();
    final routeStopLabels = _getRouteStopLabels();
    final currentStop = pickupState.currentStop;
    final completedStops = pickupState.stops.where((s) => s.isPickedUp).toList();
    final nextStop = currentStop;
    
    return Scaffold(
      body: Stack(
        children: [
          // Full Map View
          Positioned.fill(
            child: MapView(
              currentDuty: widget.duty,
              driverPosition: _liveDriverPosition,
              tripStarted: _navigationStarted,
              navigationMode: _navigationStarted,
              routeStops: routeStops,
              routeStopLabels: routeStopLabels,
            ),
          ),

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),

          // Trip Info Card at Bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildTripInfoCard(context, pickupState, nextStop, completedStops),
          ),
        ],
      ),
    );
  }

  Widget _buildTripInfoCard(BuildContext context, PickupState pickupState, PickupStop? nextStop, List<PickupStop> completedStops) {
    final mediaQuery = MediaQuery.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: mediaQuery.size.height * 0.55,
      ),
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          20 + mediaQuery.padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Duty Number & Route
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duty #${widget.duty.dutyNo}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.duty.from} → ${widget.duty.to}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (widget.duty.tripKms != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFC200).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.duty.tripKms} km',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFC200),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Route Details
              _buildDetailRow(
                'From',
                widget.duty.from,
                Icons.location_on,
                Colors.green,
              ),
              const SizedBox(height: 8),
              _buildDetailRow(
                'To',
                widget.duty.to,
                Icons.flag,
                Colors.red,
              ),
              const SizedBox(height: 16),

              // Time Details
              const Divider(thickness: 1),
              const SizedBox(height: 12),

              if (completedStops.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: completedStops.map((stop) => ListTile(
                    leading: const Icon(Icons.check_circle, color: Colors.green),
                    title: Text(stop.location),
                    subtitle: const Text('Completed'),
                  )).toList(),
                ),

              if (nextStop != null)
                Card(
                  color: Colors.yellow[50],
                  child: ListTile(
                    leading: const Icon(Icons.location_on, color: Colors.orange),
                    title: Text(nextStop.location),
                    subtitle: Text('Pickup Window: ${nextStop.timeWindow}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!nextStop.isArrived)
                          ElevatedButton(
                            onPressed: () {
                              final homeState = ref.read(homeProvider);
                              final currentPosition = _liveDriverPosition ?? widget.driverPosition ?? homeState.driverPosition;
                              ref.read(pickupProvider.notifier).markArrived(
                                    latitude: currentPosition?.latitude,
                                    longitude: currentPosition?.longitude,
                                  );
                            },
                            child: const Text('Arrive'),
                          ),
                        if (nextStop.isArrived && !nextStop.isPickedUp)
                          ElevatedButton(
                            onPressed: () {
                              ref.read(pickupProvider.notifier).markPickedUp();
                            },
                            child: const Text('Mark Picked Up'),
                          ),
                        if (nextStop.isPickedUp)
                          const Icon(Icons.check, color: Colors.green),
                      ],
                    ),
                  ),
                ),

              if (pickupState.allStopsCompleted)
                const Center(
                  child: Text('All stops completed!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTimeChip(
                    'Start Time',
                    widget.duty.joiningTime,
                    Icons.access_time,
                  ),
                  _buildTimeChip(
                    'End Time',
                    widget.duty.closeTime,
                    Icons.schedule,
                  ),
                  if (widget.duty.steeringTime != null)
                    _buildTimeChip(
                      'Duration',
                      widget.duty.steeringTime ?? '--',
                      Icons.hourglass_empty,
                    ),
                ],
              ),
              const SizedBox(height: 16),

                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigationStarted
                    ? null
                    : _handleStartTrip,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navigationStarted
                      ? Colors.grey[400]
                      : const Color(0xFFFFC200),
                  disabledBackgroundColor: Colors.grey[400],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: _navigationStarted ? 0 : 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isStarting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _navigationStarted
                                ? Icons.check_circle
                                : Icons.navigation,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _navigationStarted ? 'Navigation Active' : 'Start Navigation',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            if (_navigationStarted && !_destinationReached) ...[
              const SizedBox(height: 8),
              Text(
                'Navigating to destination...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
      ),
    );
  }

  Future<void> _startLocationTracking() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return;
    }

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    ).listen((position) {
      if (!mounted) return;
      setState(() {
        _liveDriverPosition = position;
      });
      _checkDestinationReached(position);
    });
  }

  void _checkDestinationReached(Position position) {
    if (!_navigationStarted) {
      return;
    }

    final targetLat = _navigationStarted
        ? widget.duty.dropLatitude
        : widget.duty.pickupLatitude;
    final targetLng = _navigationStarted
        ? widget.duty.dropLongitude
        : widget.duty.pickupLongitude;

    if (!_isValidLatLng(targetLat, targetLng)) {
      return;
    }

    final distance = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      targetLat,
      targetLng,
    );

    if (_navigationStarted && !_destinationReached && distance <= 80) {
      setState(() {
        _destinationReached = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Destination reached'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleStartTrip() async {
    if (_navigationStarted) {
      return;
    }

    setState(() {
      _isStarting = true;
      _destinationReached = false;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    if (mounted) {
      setState(() {
        _navigationStarted = true;
        _isStarting = false;
      });

      widget.onTripStarted?.call();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Navigation started'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      final position = _liveDriverPosition;
      if (position != null) {
        _checkDestinationReached(position);
      }
    }
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeChip(String label, String time, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(height: 4),
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

}
