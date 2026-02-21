import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbandriver/shared/utils/responsive_utils.dart';
import 'package:urbandriver/features/home/presentation/providers/home_provider.dart';
import '../providers/pickup_provider.dart';
import 'pickup_navigation_screen.dart';

class VehicleInspectionScreen extends ConsumerStatefulWidget {
  final String vehicleNumber;
  final String vehicleModel;

  const VehicleInspectionScreen({
    super.key,
    required this.vehicleNumber,
    required this.vehicleModel,
  });

  @override
  ConsumerState<VehicleInspectionScreen> createState() => _VehicleInspectionScreenState();
}

class _VehicleInspectionScreenState extends ConsumerState<VehicleInspectionScreen> {
  final Map<String, bool> _checklistItems = {
    'Tyre condition': false,
    'Oil condition': false,
    'Brake check': false,
    'Vehicle cleanliness': false,
    'Fuel level': false,
  };

  final TextEditingController _issueController = TextEditingController();

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  bool get _allChecked => _checklistItems.values.every((checked) => checked);

  Future<void> _completeInspection() async {
    if (_allChecked) {
      // Load stops from current duty
      final homeState = ref.read(homeProvider);
      final currentDuty = homeState.currentDuty;
      
      print('🟢 [VehicleInspectionScreen] Loading stops for: ${currentDuty?.from} → ${currentDuty?.to}');
      print('   Duty has ${currentDuty?.stops.length ?? 0} stops');
      if (currentDuty?.stops != null) {
        for (var i = 0; i < currentDuty!.stops.length; i++) {
          print('     Stop $i: ${currentDuty.stops[i].location} @ ${currentDuty.stops[i].timeWindow}');
        }
      }
      
      // Load the current duty's stops into the pickup provider
      ref.read(pickupProvider.notifier).loadStopsFromDuty(currentDuty);
      await ref.read(pickupProvider.notifier).startTripIfNeeded();
      
      // Verify stops were loaded
      final pickupState = ref.read(pickupProvider);
      print('🟢 [VehicleInspectionScreen] Pickup provider now has ${pickupState.stops.length} stops');
      
      // Navigate to pickup navigation screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const PickupNavigationScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all inspection items'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                child: Padding(
                  padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: ResponsiveUtils.padding(context, 16)),
                      
                      // Progress Stepper
                      _buildProgressStepper(context),
                      
                      SizedBox(height: ResponsiveUtils.padding(context, 24)),
                      
                      // Vehicle Card
                      _buildVehicleCard(context),
                      
                      SizedBox(height: ResponsiveUtils.padding(context, 20)),
                      
                      // Inspection Title
                      Text(
                        'Vehicle Inspection Required',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 16),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      
                      SizedBox(height: ResponsiveUtils.padding(context, 8)),
                      
                      Text(
                        'Complete all checks to proceed to pickups',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 13),
                          color: Colors.grey[600],
                        ),
                      ),
                      
                      SizedBox(height: ResponsiveUtils.padding(context, 20)),
                      
                      // Checklist Items
                      ..._checklistItems.entries.map((entry) {
                        return _buildChecklistItem(context, entry.key, entry.value);
                      }),
                      
                      SizedBox(height: ResponsiveUtils.padding(context, 20)),
                      
                      // Found an issue section
                      Text(
                        'Found an issue?',
                        style: TextStyle(
                          fontSize: ResponsiveUtils.fontSize(context, 14),
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      
                      SizedBox(height: ResponsiveUtils.padding(context, 12)),
                      
                      TextField(
                        controller: _issueController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Report Vehicle Issue (example...)\nLow tyre pressure\nOil leakage\nBrake noise\nCleaning required\nLow fuel',
                          hintStyle: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 12),
                            color: Colors.grey[400],
                            height: 1.5,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 8)),
                            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 8)),
                            borderSide: BorderSide(color: Colors.grey[200]!, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 8)),
                            borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                          ),
                          contentPadding: ResponsiveUtils.symmetricPadding(context, horizontal: 16, vertical: 12),
                        ),
                      ),
                      
                      SizedBox(height: ResponsiveUtils.padding(context, 16)),
                      
                      // Photo Proof (Optional) with Upload Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Photo Proof (Optional)',
                            style: TextStyle(
                              fontSize: ResponsiveUtils.fontSize(context, 14),
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // TODO: Open camera for photo proof
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: ResponsiveUtils.symmetricPadding(context, horizontal: 24, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 8)),
                              ),
                            ),
                            child: Text(
                              'Upload',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.fontSize(context, 14),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: ResponsiveUtils.padding(context, 100)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom Buttons
      bottomSheet: _buildBottomButtons(context),
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
        _buildStepperItem(context, 'Inspection', true, false),
        Expanded(child: _buildStepperLine(context, false)),
        _buildStepperItem(context, 'Pickups', false, false),
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

  Widget _buildVehicleCard(BuildContext context) {
    return Container(
      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 12)),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Vehicle Icon
          Container(
            width: ResponsiveUtils.scale(context, 60),
            height: ResponsiveUtils.scale(context, 60),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 8)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 8)),
              child: Image.asset(
                'assets/images/trip_car_image.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          SizedBox(width: ResponsiveUtils.padding(context, 16)),
          
          // Vehicle Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.vehicleNumber,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 16),
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: ResponsiveUtils.padding(context, 4)),
                Text(
                  widget.vehicleModel,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.fontSize(context, 13),
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Yellow indicator
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
    );
  }

  Widget _buildChecklistItem(BuildContext context, String label, bool isChecked) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _checklistItems[label] = !isChecked;
        });
      },
      child: Container(
        margin: ResponsiveUtils.symmetricPadding(context, vertical: 6),
        padding: ResponsiveUtils.symmetricPadding(context, horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isChecked ? const Color(0xFFFFF9E6) : Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 12)),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              width: ResponsiveUtils.scale(context, 24),
              height: ResponsiveUtils.scale(context, 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isChecked ? const Color(0xFFFFC200) : Colors.grey[400]!,
                  width: 2,
                ),
                color: isChecked ? const Color(0xFFFFC200) : Colors.transparent,
              ),
              child: isChecked
                  ? Icon(
                      Icons.check,
                      size: ResponsiveUtils.iconSize(context, 18),
                      color: Colors.white,
                    )
                  : null,
            ),
            SizedBox(width: ResponsiveUtils.padding(context, 12)),
            Text(
              label,
              style: TextStyle(
                fontSize: ResponsiveUtils.fontSize(context, 14),
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
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
          onPressed: _completeInspection,
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
            'Inspection Complete',
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
