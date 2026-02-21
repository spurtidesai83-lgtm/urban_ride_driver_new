import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbandriver/shared/utils/responsive_utils.dart';
import '../providers/vehicle_provider.dart';

class VehicleDetailsScreen extends ConsumerWidget {
  const VehicleDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicleAsyncValue = ref.watch(vehicleProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Vehicle Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: ResponsiveUtils.fontSize(context, 20),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Refresh button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: () {
                ref.refresh(vehicleProvider);
              },
            ),
          ),
        ],
      ),
      body: vehicleAsyncValue.when(
        loading: () => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              const Color(0xFFFFC200),
            ),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              SizedBox(height: 16),
              Text(
                'Failed to load vehicle details',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 13),
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC200),
                  padding: EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  ref.refresh(vehicleProvider);
                },
                child: Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        data: (vehicle) => SingleChildScrollView(
          padding:
              ResponsiveUtils.symmetricPadding(context, horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Image Card
              _buildVehicleImageCard(context, vehicle.model, vehicle.isActive),
              
              SizedBox(height: ResponsiveUtils.padding(context, 20)),
              
              // Vehicle Information Card
              _buildVehicleInfoCard(context, vehicle),
              
              SizedBox(height: ResponsiveUtils.padding(context, 20)),
              
              // Additional Details Card
              _buildAdditionalDetailsCard(context, vehicle),
              
              SizedBox(height: ResponsiveUtils.padding(context, 20)),
              
              // Insurance and Verification Card
              _buildInsuranceCard(context, vehicle),
              
              SizedBox(height: ResponsiveUtils.padding(context, 30)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleImageCard(
    BuildContext context,
    String modelName,
    bool isActive,
  ) {
    return Container(
      width: double.infinity,
      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Vehicle Image
          Container(
            height: ResponsiveUtils.height(context, 180),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 12)),
            ),
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 12)),
                child: Image.asset(
                  'assets/images/trip_car_image.png',
                  fit: BoxFit.contain,
                  height: ResponsiveUtils.height(context, 150),
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.directions_car,
                      size: ResponsiveUtils.iconSize(context, 80),
                      color: Colors.grey[400],
                    );
                  },
                ),
              ),
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.padding(context, 16)),
          
          // Model Name
          Text(
            modelName,
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: ResponsiveUtils.padding(context, 12)),
          
          // Status Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.padding(context, 16),
              vertical: ResponsiveUtils.padding(context, 8),
            ),
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 20)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isActive ? Icons.check_circle : Icons.cancel,
                  color: isActive ? Colors.green : Colors.red,
                  size: ResponsiveUtils.iconSize(context, 16),
                ),
                SizedBox(width: ResponsiveUtils.padding(context, 6)),
                Text(
                  isActive ? 'Active' : 'Inactive',
                  style: TextStyle(
                    color: isActive ? Colors.green : Colors.red,
                    fontSize: ResponsiveUtils.fontSize(context, 14),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoCard(BuildContext context, dynamic vehicle) {
    return Container(
      width: double.infinity,
      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Basic Information',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.padding(context, 20)),
          
          _buildDetailItem(
            context,
            icon: Icons.directions_car,
            label: 'Vehicle Model',
            value: vehicle.model,
          ),
          
          SizedBox(height: ResponsiveUtils.padding(context, 16)),
          
          _buildDetailItem(
            context,
            icon: Icons.tag,
            label: 'Registration Number',
            value: vehicle.registrationNumber,
          ),
          
          SizedBox(height: ResponsiveUtils.padding(context, 16)),
          
          _buildDetailItem(
            context,
            icon: Icons.color_lens,
            label: 'Color',
            value: vehicle.color,
          ),
          
          SizedBox(height: ResponsiveUtils.padding(context, 16)),
          
          _buildDetailItem(
            context,
            icon: Icons.calendar_today,
            label: 'Year of Manufacture',
            value: vehicle.manufacturingYear,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalDetailsCard(BuildContext context, dynamic vehicle) {
    return Container(
      width: double.infinity,
      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Technical Details',
            style: TextStyle(
              fontSize: ResponsiveUtils.fontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          
          SizedBox(height: ResponsiveUtils.padding(context, 20)),
          
          _buildDetailItem(
            context,
            icon: Icons.event_seat,
            label: 'Seating Capacity',
            value: '${vehicle.capacity} Passengers',
          ),
          
          SizedBox(height: ResponsiveUtils.padding(context, 16)),
          
          _buildDetailItem(
            context,
            icon: Icons.local_gas_station,
            label: 'Fuel Type',
            value: vehicle.fuelType,
          ),
          
          SizedBox(height: ResponsiveUtils.padding(context, 16)),
          
          _buildDetailItem(
            context,
            icon: Icons.vpn_key,
            label: 'Chassis Number',
            value: vehicle.chassisNumber,
          ),
          
          SizedBox(height: ResponsiveUtils.padding(context, 16)),
          
          _buildDetailItem(
            context,
            icon: Icons.settings,
            label: 'Engine Number',
            value: vehicle.engineNumber,
          ),
        ],
      ),
    );
  }

  Widget _buildInsuranceCard(BuildContext context, dynamic vehicle) {
    bool isExpired = vehicle.isInsuranceExpired;
    
    return Container(
      width: double.infinity,
      padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isExpired
              ? Colors.red.withValues(alpha: 0.3)
              : Colors.green.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.verified_user,
                size: ResponsiveUtils.iconSize(context, 24),
                color: isExpired ? Colors.red : Colors.green,
              ),
              SizedBox(width: ResponsiveUtils.padding(context, 12)),
              Text(
                'Insurance Details',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveUtils.padding(context, 20)),
          
          _buildDetailItem(
            context,
            icon: Icons.date_range,
            label: 'Expiry Date',
            value: vehicle.insuranceExpiry,
            valueColor: isExpired ? Colors.red : Colors.green,
          ),
          
          SizedBox(height: ResponsiveUtils.padding(context, 16)),
          
          _buildDetailItem(
            context,
            icon: Icons.info,
            label: 'Status',
            value: vehicle.insuranceStatus,
            valueColor: isExpired ? Colors.red : Colors.green,
          ),
          
          if (isExpired) ...[
            SizedBox(height: ResponsiveUtils.padding(context, 16)),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(ResponsiveUtils.padding(context, 12)),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 8)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: ResponsiveUtils.iconSize(context, 20),
                  ),
                  SizedBox(width: ResponsiveUtils.padding(context, 8)),
                  Expanded(
                    child: Text(
                      'Insurance has expired. Please renew it immediately.',
                      style: TextStyle(
                        fontSize: ResponsiveUtils.fontSize(context, 13),
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveUtils.padding(context, 8)),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC200).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 8)),
          ),
          child: Icon(
            icon,
            size: ResponsiveUtils.iconSize(context, 20),
            color: const Color(0xFFFFC200),
          ),
        ),
        
        SizedBox(width: ResponsiveUtils.padding(context, 12)),
        
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 13),
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: ResponsiveUtils.padding(context, 4)),
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 16),
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
