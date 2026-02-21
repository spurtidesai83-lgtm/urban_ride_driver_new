import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/duty_model.dart';
import '../../../../shared/services/directions_service.dart';

class MapView extends StatefulWidget {
  final DutyModel? currentDuty;
  final Position? driverPosition;
  final VoidCallback? onMapReady;

  const MapView({
    Key? key,
    this.currentDuty,
    this.driverPosition,
    this.onMapReady,
  }) : super(key: key);

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

    // Add pickup location marker
    if (widget.currentDuty != null &&
        widget.currentDuty!.pickupLatitude != 0 &&
        widget.currentDuty!.pickupLongitude != 0) {
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
        widget.currentDuty!.dropLatitude != 0 &&
        widget.currentDuty!.dropLongitude != 0) {
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

      // Fetch road-based route from pickup to drop
      // Route will be loaded asynchronously by _loadRoute()
    }
    
    print('✅ Markers initialized: ${markers.length} markers');
    if (mounted) setState(() {});
  }

  Future<void> _loadRoute() async {
    // Check if we have valid coordinates
    if (widget.currentDuty == null ||
        widget.currentDuty!.pickupLatitude == 0 ||
        widget.currentDuty!.pickupLongitude == 0 ||
        widget.currentDuty!.dropLatitude == 0 ||
        widget.currentDuty!.dropLongitude == 0) {
      print('⚠️ No valid coordinates for route');
      return;
    }

    print('🛣️ Fetching road-based route...');
    setState(() => isLoadingRoute = true);
    
    try {
      final routePoints = await _directionsService.getDirections(
        originLat: widget.currentDuty!.pickupLatitude,
        originLng: widget.currentDuty!.pickupLongitude,
        destLat: widget.currentDuty!.dropLatitude,
        destLng: widget.currentDuty!.dropLongitude,
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
          _moveToShowAllMarkers();
        }
      });
    }
    widget.onMapReady?.call();
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
    if (mapInitialized &&
        (oldWidget.driverPosition != widget.driverPosition ||
            oldWidget.currentDuty != widget.currentDuty)) {
      print('🔄 Widget updated, refreshing markers and route');
      _initializeMarkers();
      _loadRoute();
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && mapInitialized) {
          _moveToShowAllMarkers();
        }
      });
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
                      color: Colors.black.withOpacity(0.1),
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
