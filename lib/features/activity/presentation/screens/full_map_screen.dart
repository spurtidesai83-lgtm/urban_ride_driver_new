import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/map_state_provider.dart';
import '../../../home/presentation/widgets/map_view.dart';
import '../../../home/presentation/providers/home_provider.dart';

class FullMapScreen extends ConsumerWidget {
  const FullMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Full Screen Interactive Map
          Positioned.fill(
            child: MapView(
              currentDuty: homeState.currentDuty,
              driverPosition: homeState.driverPosition,
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
        ],
      ),
    );
  }
}
