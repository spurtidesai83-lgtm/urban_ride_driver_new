import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/home_provider.dart';
import '../widgets/map_view.dart';

/// Example of how to integrate MapView into your home screen
class MapIntegrationExample extends ConsumerWidget {
  const MapIntegrationExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Integration Example'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  homeNotifier.toggleMapView(!homeState.isMapView);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        homeState.isMapView ? Icons.list : Icons.map,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        homeState.isMapView ? 'List View' : 'Map View',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: homeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : homeState.isMapView
              ? _buildMapView(homeState)
              : _buildListView(homeState),
    );
  }

  Widget _buildMapView(HomeState homeState) {
    return Stack(
      children: [
        // Map takes full width/height
        MapView(
          currentDuty: homeState.currentDuty,
          driverPosition: homeState.driverPosition,
        ),
        // Duty info overlay at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildDutyInfoCard(homeState),
        ),
      ],
    );
  }

  Widget _buildDutyInfoCard(HomeState homeState) {
    final duty = homeState.currentDuty;
    if (duty == null) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text('No duty selected'),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
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
                  color: Colors.blue.withOpacity(0.1),
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
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  duty.from,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.flag, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  duty.to,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoChip(Icons.access_time, duty.joiningTime, 'Start'),
              _buildInfoChip(Icons.schedule, duty.closeTime, 'End'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String value, String label) {
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

  Widget _buildListView(HomeState homeState) {
    if (homeState.duties.isEmpty) {
      return const Center(
        child: Text('No duties assigned'),
      );
    }

    return ListView.builder(
      itemCount: homeState.duties.length,
      itemBuilder: (context, index) {
        final duty = homeState.duties[index];
        final isSelected = index == homeState.currentDutyIndex;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: isSelected ? 8 : 2,
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            title: Text(
              duty.route,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${duty.from} → ${duty.to}'),
            trailing: duty.isCompleted
                ? const Icon(Icons.check_circle, color: Colors.green)
                : null,
          ),
        );
      },
    );
  }
}
