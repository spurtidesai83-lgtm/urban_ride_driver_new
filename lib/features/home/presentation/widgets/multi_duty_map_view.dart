import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/duty_model.dart';
import '../../../../shared/services/directions_service.dart';

class MultiDutyMapView extends StatefulWidget {
  final List<DutyModel> duties;
  final Position? driverPosition;
  final VoidCallback? onMapReady;
  final Function(DutyModel)? onDutyTapped;

  const MultiDutyMapView({
    Key? key,
    required this.duties,
    this.driverPosition,
    this.onMapReady,
    this.onDutyTapped,
  }) : super(key: key);

  @override
  State<MultiDutyMapView> createState() => _MultiDutyMapViewState();
}

class _MultiDutyMapViewState extends State<MultiDutyMapView> {
  late GoogleMapController mapController;
  final Set<Marker> markers = {};
  final Set<Polyline> polylines = {};
  bool mapInitialized = false;
  final DirectionsService _directionsService = DirectionsService();

  bool _isValidLatLng(double lat, double lng) {
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  @override
  void initState() {
    super.initState();
    _initializeMarkersAndRoutes();
  }

  Future<void> _initializeMarkersAndRoutes() async {
    markers.clear();
    polylines.clear();

    const defaultLat = 19.0876;
    const defaultLng = 72.8691;

    // Add driver's current location marker
    if (widget.driverPosition != null) {
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

    // Add markers and routes for each duty
    for (int dutyIndex = 0; dutyIndex < widget.duties.length; dutyIndex++) {
      final duty = widget.duties[dutyIndex];

      // Color variation for different duties
      final colors = [
        BitmapDescriptor.hueGreen,
        BitmapDescriptor.hueOrange,
        BitmapDescriptor.hueCyan,
        BitmapDescriptor.hueRose,
      ];
      final hue = colors[dutyIndex % colors.length];

      final routeStops = <LatLng>[];
      final routeStopLabels = <String>[];

      for (final stop in duty.stops) {
        if (_isValidLatLng(stop.latitude, stop.longitude)) {
          routeStops.add(LatLng(stop.latitude, stop.longitude));
          routeStopLabels.add(stop.location);
        }
      }

      if (routeStops.isEmpty &&
          _isValidLatLng(duty.pickupLatitude, duty.pickupLongitude)) {
        routeStops.add(LatLng(duty.pickupLatitude, duty.pickupLongitude));
        routeStopLabels.add(duty.from);
      }

      if (_isValidLatLng(duty.dropLatitude, duty.dropLongitude)) {
        final dropPoint = LatLng(duty.dropLatitude, duty.dropLongitude);
        if (routeStops.isEmpty ||
            routeStops.last.latitude != dropPoint.latitude ||
            routeStops.last.longitude != dropPoint.longitude) {
          routeStops.add(dropPoint);
          routeStopLabels.add(duty.to);
        }
      }

      for (int stopIndex = 0; stopIndex < routeStops.length; stopIndex++) {
        final stopPoint = routeStops[stopIndex];
        final isFirstStop = stopIndex == 0;
        final isLastStop = stopIndex == routeStops.length - 1;

        markers.add(
          Marker(
            markerId: MarkerId('duty_${duty.dutyNo}_stop_$stopIndex'),
            position: stopPoint,
            infoWindow: InfoWindow(
              title: '${routeStopLabels[stopIndex]} - ${duty.dutyNo}',
              snippet: isFirstStop
                  ? 'Pickup'
                  : isLastStop
                      ? 'Drop'
                      : 'Stop ${stopIndex + 1}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isFirstStop
                  ? hue
                  : isLastStop
                      ? BitmapDescriptor.hueRed
                      : BitmapDescriptor.hueOrange,
            ),
            onTap: () => widget.onDutyTapped?.call(duty),
          ),
        );
      }

      // Add pickup marker fallback
      if (routeStops.isEmpty &&
          _isValidLatLng(duty.pickupLatitude, duty.pickupLongitude)) {
        markers.add(
          Marker(
            markerId: MarkerId('pickup_${duty.dutyNo}'),
            position: LatLng(duty.pickupLatitude, duty.pickupLongitude),
            infoWindow: InfoWindow(
              title: 'Pickup - ${duty.dutyNo}',
              snippet: duty.from,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(hue),
            onTap: () => widget.onDutyTapped?.call(duty),
          ),
        );

        // Add drop marker fallback
        if (_isValidLatLng(duty.dropLatitude, duty.dropLongitude)) {
          markers.add(
            Marker(
              markerId: MarkerId('drop_${duty.dutyNo}'),
              position: LatLng(duty.dropLatitude, duty.dropLongitude),
              infoWindow: InfoWindow(
                title: 'Drop - ${duty.dutyNo}',
                snippet: duty.to,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
              onTap: () => widget.onDutyTapped?.call(duty),
            ),
          );

        }
      }

      // Fetch and add full route for this duty
      if (routeStops.length >= 2) {
        try {
          final chainedRoute = <LatLng>[];

          for (int segmentIndex = 0;
              segmentIndex < routeStops.length - 1;
              segmentIndex++) {
            final origin = routeStops[segmentIndex];
            final destination = routeStops[segmentIndex + 1];

            final segmentPoints = await _directionsService.getDirections(
              originLat: origin.latitude,
              originLng: origin.longitude,
              destLat: destination.latitude,
              destLng: destination.longitude,
            );

            if (segmentPoints.isEmpty) {
              continue;
            }

            if (chainedRoute.isEmpty) {
              chainedRoute.addAll(segmentPoints);
            } else {
              chainedRoute.addAll(segmentPoints.skip(1));
            }
          }

          if (chainedRoute.isNotEmpty && mounted) {
            polylines.add(
              Polyline(
                polylineId: PolylineId('route_${duty.dutyNo}'),
                points: chainedRoute,
                color: hue == BitmapDescriptor.hueGreen
                    ? Colors.green
                    : hue == BitmapDescriptor.hueOrange
                        ? Colors.orange
                        : hue == BitmapDescriptor.hueCyan
                            ? Colors.cyan
                            : Colors.pink,
                width: 4,
                geodesic: true,
              ),
            );
          }
        } catch (e) {
          debugPrint('Error loading route for duty ${duty.dutyNo}: $e');
        }
      } else if (_isValidLatLng(duty.pickupLatitude, duty.pickupLongitude) &&
          _isValidLatLng(duty.dropLatitude, duty.dropLongitude)) {
        try {
          final routePoints = await _directionsService.getDirections(
            originLat: duty.pickupLatitude,
            originLng: duty.pickupLongitude,
            destLat: duty.dropLatitude,
            destLng: duty.dropLongitude,
          );

          if (routePoints.isNotEmpty && mounted) {
            polylines.add(
              Polyline(
                polylineId: PolylineId('route_${duty.dutyNo}'),
                points: routePoints,
                color: hue == BitmapDescriptor.hueGreen
                    ? Colors.green
                    : hue == BitmapDescriptor.hueOrange
                        ? Colors.orange
                        : hue == BitmapDescriptor.hueCyan
                            ? Colors.cyan
                            : Colors.pink,
                width: 4,
                geodesic: true,
              ),
            );
          }
        } catch (e) {
          debugPrint('Error loading route for duty ${duty.dutyNo}: $e');
        }
      }
    }

    if (mounted) {
      setState(() {});
      if (mapInitialized) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _moveToShowAllMarkers();
          }
        });
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    if (!mapInitialized) {
      mapController = controller;
      setState(() {
        mapInitialized = true;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _moveToShowAllMarkers();
        }
      });
    }
    widget.onMapReady?.call();
  }

  void _moveToShowAllMarkers() {
    if (markers.isEmpty) return;

    if (markers.length == 1) {
      final marker = markers.first;
      mapController.animateCamera(
        CameraUpdate.newLatLng(marker.position),
      );
    } else {
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
        debugPrint('Error animating camera: $e');
      }
    }
  }

  @override
  void didUpdateWidget(MultiDutyMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duties.length != widget.duties.length ||
        oldWidget.driverPosition != widget.driverPosition) {
      _initializeMarkersAndRoutes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: _onMapCreated,
      markers: markers,
      polylines: polylines,
      initialCameraPosition: CameraPosition(
        target: widget.driverPosition != null
            ? LatLng(
                widget.driverPosition!.latitude,
                widget.driverPosition!.longitude,
              )
            : const LatLng(19.0876, 72.8691),
        zoom: 12,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      compassEnabled: true,
      scrollGesturesEnabled: true,
      zoomGesturesEnabled: true,
      tiltGesturesEnabled: true,
      rotateGesturesEnabled: true,
    );
  }

  @override
  void dispose() {
    if (mapInitialized) {
      try {
        mapController.dispose();
      } catch (e) {
        debugPrint('Map controller disposal error (safe to ignore): $e');
      }
    }
    super.dispose();
  }
}
