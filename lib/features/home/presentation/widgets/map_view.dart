import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/duty_model.dart';
import '../../../../shared/services/directions_service.dart';

class MapView extends StatefulWidget {
  final DutyModel? currentDuty;
  final Position? driverPosition;
  final bool tripStarted;
  final bool navigationMode;
  final List<LatLng> routeStops;
  final List<String> routeStopLabels;
  final VoidCallback? onMapReady;

  const MapView({
    super.key,
    this.currentDuty,
    this.driverPosition,
    this.tripStarted = false,
    this.navigationMode = false,
    this.routeStops = const [],
    this.routeStopLabels = const [],
    this.onMapReady,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late GoogleMapController mapController;
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  bool mapInitialized = false;
  final DirectionsService _directionsService = DirectionsService();
  bool isLoadingRoute = false;
  DateTime? _lastRouteRefreshAt;
  LatLng? _lastRouteRefreshOrigin;

  bool _isValidLatLng(double lat, double lng) {
    if (lat == 0.0 && lng == 0.0) return false;
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  bool get _hasCustomRouteStops => widget.routeStops.length >= 2;

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
    // Load route asynchronously without blocking
    _loadRoute();
  }

  void _initializeMarkers() {
    markers.clear();
    polylines.clear();
    
    // Default location (Mumbai)
    const defaultLat = 19.0876;
    const defaultLng = 72.8691;

    // Add driver's current location marker
    if (widget.driverPosition != null) {
      print('📍 Adding driver marker at ${widget.driverPosition!.latitude}, ${widget.driverPosition!.longitude}');
      markers.add(
        Marker(
          markerId: const MarkerId('driver_location'),
          position: LatLng(
            widget.driverPosition!.latitude,
            widget.driverPosition!.longitude,
          ),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'Current position',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    } else {
      // Add default location if no driver position
      print('📍 No driver position, using default location');
      markers.add(
        Marker(
          markerId: const MarkerId('driver_location'),
          position: const LatLng(defaultLat, defaultLng),
          infoWindow: const InfoWindow(
            title: 'Default Location',
            snippet: 'Mumbai',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    if (_hasCustomRouteStops) {
      for (int index = 0; index < widget.routeStops.length; index++) {
        final stop = widget.routeStops[index];
        if (!_isValidLatLng(stop.latitude, stop.longitude)) {
          continue;
        }

        final isFirst = index == 0;
        final isLast = index == widget.routeStops.length - 1;
        final title = widget.routeStopLabels.length > index
            ? widget.routeStopLabels[index]
            : 'Stop ${index + 1}';

        markers.add(
          Marker(
            markerId: MarkerId('route_stop_$index'),
            position: stop,
            infoWindow: InfoWindow(
              title: title,
              snippet: isFirst
                  ? 'Pickup'
                  : isLast
                      ? 'Drop'
                      : 'Intermediate Stop',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isFirst
                  ? BitmapDescriptor.hueGreen
                  : isLast
                      ? BitmapDescriptor.hueRed
                      : BitmapDescriptor.hueOrange,
            ),
          ),
        );
      }
    } else {
      // Add pickup location marker
      if (widget.currentDuty != null &&
          _isValidLatLng(
            widget.currentDuty!.pickupLatitude,
            widget.currentDuty!.pickupLongitude,
          )) {
        print('🟢 Adding pickup marker at ${widget.currentDuty!.pickupLatitude}, ${widget.currentDuty!.pickupLongitude}');
        markers.add(
          Marker(
            markerId: const MarkerId('pickup_location'),
            position: LatLng(
              widget.currentDuty!.pickupLatitude,
              widget.currentDuty!.pickupLongitude,
            ),
            infoWindow: InfoWindow(
              title: 'Pickup',
              snippet: widget.currentDuty!.pickupAddress ?? widget.currentDuty!.from,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          ),
        );
      }

      // Add drop location marker
      if (widget.currentDuty != null &&
          _isValidLatLng(
            widget.currentDuty!.dropLatitude,
            widget.currentDuty!.dropLongitude,
          )) {
        print('🔴 Adding drop marker at ${widget.currentDuty!.dropLatitude}, ${widget.currentDuty!.dropLongitude}');
        markers.add(
          Marker(
            markerId: const MarkerId('drop_location'),
            position: LatLng(
              widget.currentDuty!.dropLatitude,
              widget.currentDuty!.dropLongitude,
            ),
            infoWindow: InfoWindow(
              title: 'Drop-off',
              snippet: widget.currentDuty!.dropAddress ?? widget.currentDuty!.to,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
    }
    
    print('✅ Markers initialized: ${markers.length} markers');
    if (mounted) setState(() {});
  }

  Future<void> _loadRoute() async {
    if (_hasCustomRouteStops) {
      setState(() => isLoadingRoute = true);
      try {
        final chainedRoute = <LatLng>[];

        for (int index = 0; index < widget.routeStops.length - 1; index++) {
          final origin = widget.routeStops[index];
          final destination = widget.routeStops[index + 1];

          if (!_isValidLatLng(origin.latitude, origin.longitude) ||
              !_isValidLatLng(destination.latitude, destination.longitude)) {
            continue;
          }

          final segment = await _directionsService.getDirections(
            originLat: origin.latitude,
            originLng: origin.longitude,
            destLat: destination.latitude,
            destLng: destination.longitude,
          );

          if (segment.isEmpty) {
            continue;
          }

          if (chainedRoute.isEmpty) {
            chainedRoute.addAll(segment);
          } else {
            chainedRoute.addAll(segment.skip(1));
          }
        }

        if (mounted) {
          polylines.clear();
          if (chainedRoute.isNotEmpty) {
            polylines.add(
              Polyline(
                polylineId: const PolylineId('route_stops_chain'),
                points: chainedRoute,
                color: Colors.blue,
                width: 5,
                geodesic: true,
              ),
            );
          }
          setState(() => isLoadingRoute = false);
        }
      } catch (e) {
        print('❌ Error loading chained route: $e');
        if (mounted) {
          setState(() => isLoadingRoute = false);
        }
      }
      return;
    }

    final duty = widget.currentDuty;
    if (duty == null) {
      print('⚠️ No duty available for route');
      return;
    }

    final hasPickup = _isValidLatLng(duty.pickupLatitude, duty.pickupLongitude);
    final hasDrop = _isValidLatLng(duty.dropLatitude, duty.dropLongitude);

    if (!hasPickup && !hasDrop) {
      print('⚠️ No valid destination coordinates for route');
      return;
    }

    final destinationLat = widget.tripStarted
        ? (hasDrop ? duty.dropLatitude : duty.pickupLatitude)
        : (hasPickup ? duty.pickupLatitude : duty.dropLatitude);
    final destinationLng = widget.tripStarted
        ? (hasDrop ? duty.dropLongitude : duty.pickupLongitude)
        : (hasPickup ? duty.pickupLongitude : duty.dropLongitude);

    final hasDriver = widget.driverPosition != null;
    final originLat = hasDriver
        ? widget.driverPosition!.latitude
        : (hasPickup ? duty.pickupLatitude : duty.dropLatitude);
    final originLng = hasDriver
        ? widget.driverPosition!.longitude
        : (hasPickup ? duty.pickupLongitude : duty.dropLongitude);

    print('🛣️ Fetching road-based route...');
    setState(() => isLoadingRoute = true);
    
    try {
      final routePoints = await _directionsService.getDirections(
        originLat: originLat,
        originLng: originLng,
        destLat: destinationLat,
        destLng: destinationLng,
      );
      
      if (routePoints.isNotEmpty && mounted) {
        polylines.clear();
        polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: routePoints,
            color: Colors.blue,
            width: 5,
            geodesic: true,
          ),
        );
        print('✅ Route polyline created with ${routePoints.length} points');
      }
      
      if (mounted) {
        setState(() => isLoadingRoute = false);
      }
    } catch (e) {
      print('❌ Error loading route: $e');
      if (mounted) {
        setState(() => isLoadingRoute = false);
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    print('🗺️ Map created');
    if (!mapInitialized) {
      mapController = controller;
      setState(() {
        mapInitialized = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          if (widget.navigationMode && widget.driverPosition != null) {
            _followDriverCamera(widget.driverPosition!);
          } else {
            _moveToShowAllMarkers();
          }
        }
      });
    }
    widget.onMapReady?.call();
  }

  void _updateDriverMarkerOnly() {
    final driverPosition = widget.driverPosition;
    if (driverPosition == null) {
      return;
    }

    markers.removeWhere((marker) => marker.markerId.value == 'driver_location');
    markers.add(
      Marker(
        markerId: const MarkerId('driver_location'),
        position: LatLng(driverPosition.latitude, driverPosition.longitude),
        infoWindow: const InfoWindow(
          title: 'Your Location',
          snippet: 'Current position',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
  }

  void _followDriverCamera(Position position) {
    if (!mapInitialized) {
      return;
    }

    final bearing = position.heading.isNaN || position.heading < 0
        ? 0.0
        : position.heading;

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 17,
          tilt: 45,
          bearing: bearing,
        ),
      ),
    );
  }

  bool _shouldRefreshRouteForMovement(Position? oldPosition, Position? newPosition) {
    if (newPosition == null) {
      return false;
    }

    final now = DateTime.now();
    if (_lastRouteRefreshAt != null &&
        now.difference(_lastRouteRefreshAt!).inSeconds < 8) {
      return false;
    }

    final lastOrigin = _lastRouteRefreshOrigin;
    final oldOrigin = oldPosition;

    final baseLat = lastOrigin?.latitude ?? oldOrigin?.latitude;
    final baseLng = lastOrigin?.longitude ?? oldOrigin?.longitude;

    if (baseLat == null || baseLng == null) {
      return true;
    }

    final movedMeters = Geolocator.distanceBetween(
      baseLat,
      baseLng,
      newPosition.latitude,
      newPosition.longitude,
    );

    return movedMeters >= 35;
  }

  void _moveToShowAllMarkers() {
    if (markers.isEmpty) {
      print('⚠️ No markers to show');
      return;
    }

    print('🎯 Moving to show ${markers.length} markers');

    if (markers.length == 1) {
      final marker = markers.first;
      print('📍 Centering on single marker: ${marker.position.latitude}, ${marker.position.longitude}');
      mapController.animateCamera(
        CameraUpdate.newLatLng(marker.position),
      );
    } else {
      // Calculate bounds to show all markers
      double minLat = markers.first.position.latitude;
      double maxLat = markers.first.position.latitude;
      double minLng = markers.first.position.longitude;
      double maxLng = markers.first.position.longitude;

      for (var marker in markers) {
        if (marker.position.latitude < minLat) minLat = marker.position.latitude;
        if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
        if (marker.position.longitude < minLng) minLng = marker.position.longitude;
        if (marker.position.longitude > maxLng) maxLng = marker.position.longitude;
      }

      print('📐 Bounds: lat($minLat, $maxLat), lng($minLng, $maxLng)');

      try {
        mapController.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(minLat, minLng),
              northeast: LatLng(maxLat, maxLng),
            ),
            100,
          ),
        );
      } catch (e) {
        print('❌ Error animating camera: $e');
      }
    }
  }

  @override
  void didUpdateWidget(MapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!mapInitialized) {
      return;
    }

    final routeDataChanged =
        oldWidget.currentDuty != widget.currentDuty ||
        oldWidget.tripStarted != widget.tripStarted ||
        oldWidget.routeStops != widget.routeStops ||
        oldWidget.routeStopLabels != widget.routeStopLabels;

    final driverPositionChanged = oldWidget.driverPosition != widget.driverPosition;
    final navigationModeChanged = oldWidget.navigationMode != widget.navigationMode;

    if (routeDataChanged || navigationModeChanged) {
      print('🔄 Widget updated, refreshing markers and route');
      _initializeMarkers();
      _loadRoute();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && mapInitialized) {
          if (widget.navigationMode && widget.driverPosition != null) {
            _followDriverCamera(widget.driverPosition!);
          } else {
            _moveToShowAllMarkers();
          }
        }
      });
      return;
    }

    if (driverPositionChanged) {
      _updateDriverMarkerOnly();
      setState(() {});

      if (widget.navigationMode && widget.driverPosition != null) {
        _followDriverCamera(widget.driverPosition!);

        if (_shouldRefreshRouteForMovement(oldWidget.driverPosition, widget.driverPosition)) {
          _lastRouteRefreshAt = DateTime.now();
          _lastRouteRefreshOrigin = LatLng(
            widget.driverPosition!.latitude,
            widget.driverPosition!.longitude,
          );
          _loadRoute();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          markers: markers,
          polylines: polylines,
          initialCameraPosition: CameraPosition(
            target: widget.driverPosition != null
                ? LatLng(
                    widget.driverPosition!.latitude,
                    widget.driverPosition!.longitude,
                  )
                : const LatLng(19.0876, 72.8691), // Mumbai default
            zoom: 14,
          ),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          compassEnabled: true,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          tiltGesturesEnabled: true,
          rotateGesturesEnabled: true,
        ),
        // Loading indicator for route
        if (isLoadingRoute)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Loading route...', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        // Error/Loading overlay
        if (!mapInitialized && !isLoadingRoute)
          Container(
            color: Colors.white70,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing Map...'),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    if (mapInitialized) {
      try {
        mapController.dispose();
      } catch (e) {
        // Ignore web-specific disposal errors
        print('⚠️ Map controller disposal error (safe to ignore): $e');
      }
    }
    super.dispose();
  }
}
