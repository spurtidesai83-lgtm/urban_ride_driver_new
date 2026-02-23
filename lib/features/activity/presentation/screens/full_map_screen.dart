import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/pickup_provider.dart';
import '../../../home/presentation/widgets/map_view.dart';
import '../../../home/presentation/providers/home_provider.dart';
import 'trip_map_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FullMapScreen extends ConsumerWidget {
  const FullMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final pickupState = ref.watch(pickupProvider);
    final duty = homeState.currentDuty;
    final routeStops = pickupState.stops
        .where((stop) => stop.latitude >= -90 && stop.latitude <= 90 && stop.longitude >= -180 && stop.longitude <= 180)
        .map((stop) => LatLng(stop.latitude, stop.longitude))
        .toList();
    final routeStopLabels = pickupState.stops
        .where((stop) => stop.latitude >= -90 && stop.latitude <= 90 && stop.longitude >= -180 && stop.longitude <= 180)
        .map((stop) => stop.location)
        .toList();

    return Scaffold(
      body: Stack(
        children: [
          // Full Screen Interactive Map
          Positioned.fill(
            child: MapView(
              currentDuty: homeState.currentDuty,
              driverPosition: homeState.driverPosition,
              routeStops: routeStops,
              routeStopLabels: routeStopLabels,
            ),
          ),

          // Top Header Overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: duty == null
                      ? null
                      : () {
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
                    disabledBackgroundColor: Colors.grey[400],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Start Navigation',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
