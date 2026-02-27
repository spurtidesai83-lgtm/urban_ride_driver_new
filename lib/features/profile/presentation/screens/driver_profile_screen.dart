import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:urbandriver/shared/utils/responsive_utils.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../auth/providers/registration_provider.dart';
import '../../../home/presentation/providers/home_provider.dart';
import '../../../activity/presentation/providers/activity_provider.dart';
import '../../../activity/presentation/providers/pickup_provider.dart';
import '../../../wallet/providers/wallet_provider.dart';
import '../../../leave/providers/leave_provider.dart';
import '../../../notifications/providers/notification_provider.dart';
import '../../data/models/profile_model.dart';
import '../providers/profile_provider.dart';
import '../providers/trip_history_provider.dart';
import '../providers/vehicle_provider.dart';
import '../../../auth/screens/login.dart';
import 'vehicle_documents_screen.dart';
import 'ride_history_screen.dart';
import 'vehicle_details_screen.dart';

class DriverProfileScreen extends ConsumerStatefulWidget {
  final String phoneOrEmail;
  final VoidCallback? onMenuTap;

  const DriverProfileScreen({
    super.key,
    required this.phoneOrEmail,
    this.onMenuTap,
  });

  @override
  ConsumerState<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends ConsumerState<DriverProfileScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploadingProfilePicture = false;

  String _profileInitials(String name) {
    final normalized = name.trim();
    if (normalized.isEmpty || normalized == '-') {
      return '-';
    }

    final parts = normalized
        .split(RegExp(r'[\s._-]+'))
        .where((part) => part.trim().isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '-';
    }

    final first = parts.first.substring(0, 1).toUpperCase();
    final second = parts.length > 1
      ? parts.last.substring(0, 1).toUpperCase()
        : '';

    return second.isEmpty ? first : '$first $second';
  }

  Widget _buildInitialsAvatar(ProfileModel profile) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF4CC),
            Color(0xFFFFC200),
          ],
        ),
      ),
      child: Center(
        child: Text(
          _profileInitials(profile.name),
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
      ),
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(dialogContext, 16)),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              color: Colors.black,
              fontSize: ResponsiveUtils.fontSize(dialogContext, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: Colors.black87,
              fontSize: ResponsiveUtils.fontSize(dialogContext, 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: ResponsiveUtils.fontSize(dialogContext, 14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop(); // Close dialog
                
                try {
                  // Clear session states
                  await ref.read(authProvider.notifier).signOut();
                  ref.read(registrationProvider.notifier).reset();
                  ref.invalidate(homeProvider);
                  ref.invalidate(activityProvider);
                  ref.invalidate(pickupProvider);
                  ref.invalidate(profileProvider);
                  ref.invalidate(walletProvider);
                  ref.invalidate(leaveProvider);
                  ref.invalidate(tripHistoryProvider);
                  ref.invalidate(vehicleProvider);
                  ref.invalidate(notificationProvider);
                } catch (e) {
                   debugPrint('Error signing out: $e');
                }

                if (context.mounted) {
                   // Navigate to Login Screen and remove all previous routes
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: ResponsiveUtils.fontSize(dialogContext, 14),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutUs(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'About Urban Ride',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Urban Ride is India\'s leading ride-sharing platform, connecting drivers with passengers for safe, affordable, and convenient transportation.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Our Mission',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'To provide reliable and efficient transportation solutions while empowering drivers with flexible earning opportunities.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Version: 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFFFFC200),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showEmergencyContacts(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Emergency Contacts',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEmergencyContactItem(
                context,
                'Booking Management',
                '+91 1800-123-4567',
                Icons.support_agent,
              ),
              const SizedBox(height: 12),
              _buildEmergencyContactItem(
                context,
                'Emergency Helpline',
                '112',
                Icons.local_hospital,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFFFFC200),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndUploadProfilePicture(WidgetRef ref) async {
    if (_isUploadingProfilePicture) {
      return;
    }

    try {
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );

      if (pickedImage == null) {
        return;
      }

      if (mounted) {
        setState(() {
          _isUploadingProfilePicture = true;
        });
      }

      await ref.read(profileProvider.notifier).uploadProfilePicture(pickedImage);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile picture updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload profile picture: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingProfilePicture = false;
        });
      }
    }
  }

  Widget _buildEmergencyContactItem(
    BuildContext context,
    String label,
    String number,
    IconData icon,
  ) {
    return InkWell(
      onTap: () async {
        final Uri phoneUri = Uri(scheme: 'tel', path: number);
        if (await canLaunchUrl(phoneUri)) {
          await launchUrl(phoneUri);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.black, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    number,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.phone, color: Color(0xFFFFC200), size: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _buildProfileWithError(context, err.toString(), ref),
        data: (profile) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Profile Header
              _buildProfileHeader(context, profile, ref),
              const SizedBox(height: 24),

              // Stats Bar with Trip History Data
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildStatsBarWithTripHistory(context, profile, ref),
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 8, color: Color(0xFFF9FAFB)), // Thick separator
              
              // Menu Options
              _buildMenuOptions(context, profile, ref),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileModel profile, WidgetRef ref) {
    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () => _pickAndUploadProfilePicture(ref),
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      (profile.profileImageUrl != null && profile.profileImageUrl!.trim().isNotEmpty)
                          ? Image.network(
                              profile.profileImageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, error, stackTrace) => _buildInitialsAvatar(profile),
                            )
                          : _buildInitialsAvatar(profile),
                      if (_isUploadingProfilePicture)
                        Container(
                          color: Colors.black26,
                          child: const Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: GestureDetector(
                onTap: () => _pickAndUploadProfilePicture(ref),
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC200),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(Icons.camera_alt, size: 12, color: Colors.black87),
                ),
              ),
            ),
            if (profile.isVerified)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.blue, // Verified blue
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          profile.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, size: 14, color: Color(0xFFFFC200)),
              const SizedBox(width: 4),
              const Text(
                "4.9 Rating", 
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBarWithTripHistory(BuildContext context, ProfileModel profile, WidgetRef ref) {
    final tripHistoryAsync = ref.watch(tripHistoryProvider);

    return tripHistoryAsync.when(
      loading: () => _buildStatBarSkeleton(),
      error: (err, stack) => _buildStatsBar(context, profile),
      data: (tripHistory) => Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2)),
          ],
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            _buildStatItem('Duties', tripHistory.totalNoOfDuties.toString()),
            _buildVerticalDivider(),
            _buildStatItem('KM', '${tripHistory.kmsTraveled.toStringAsFixed(1)}k'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBarSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2)),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          _buildStatItem('Duties', '-'),
          _buildVerticalDivider(),
          _buildStatItem('KM', '-'),
        ],
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context, ProfileModel profile) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 2)),
        ],
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          _buildStatItem('Rides', profile.totalRides.toString()),
          _buildVerticalDivider(),
          _buildStatItem('KM', '${(profile.kmCovered / 1000).toStringAsFixed(1)}k'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey[500],
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey[200],
    );
  }

  Widget _buildMenuOptions(BuildContext context, ProfileModel profile, WidgetRef ref) {
    final vehicleAsync = ref.watch(vehicleProvider);
    final profileVehicleModel = (profile.vehicleModel ?? '').trim();
    final vehicleSubtitle = vehicleAsync.maybeWhen(
      data: (vehicle) => vehicle.model.trim().isNotEmpty ? vehicle.model.trim() : 'Vehicle details',
      orElse: () => profileVehicleModel.isNotEmpty ? profileVehicleModel : 'Vehicle details',
    );

    return Column(
      children: [
        _buildListTile(
          context,
          icon: Icons.directions_car,
          title: 'Vehicle Information',
          subtitle: vehicleSubtitle,
          onTap: () => _showVehicleDetails(context, profile),
        ),
        _buildListTile(
          context,
          icon: Icons.folder_shared,
          title: 'Documents',
          subtitle: 'RC, Permit, PUC',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const VehicleDocumentsScreen()),
            );
          },
        ),
        _buildListTile(
          context,
          icon: Icons.history,
          title: 'Trip History',
          onTap: () {
             Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RideHistoryScreen()),
              );
          },
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(thickness: 8, color: Color(0xFFF9FAFB)),
        ),

         _buildListTile(
          context,
          icon: Icons.shield_outlined,
          title: 'Emergency Contacts',
          onTap: () => _showEmergencyContacts(context),
        ),
        _buildListTile(
          context,
          icon: Icons.info_outline,
          title: 'About Urban Ride',
          onTap: () => _showAboutUs(context),
        ),
        const Padding(
           padding: EdgeInsets.symmetric(vertical: 8.0),
           child: Divider(thickness: 8, color: Color(0xFFF9FAFB)),
        ),
        _buildListTile(
          context,
          icon: Icons.logout,
          title: 'Logout',
          textColor: Colors.red,
          iconColor: Colors.red,
          showChevron: false,
          onTap: () => _handleLogout(context, ref),
        ),
      ],
    );
  }

  void _showVehicleDetails(BuildContext context, ProfileModel profile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VehicleDetailsScreen(),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color textColor = const Color(0xFF111827),
    Color iconColor = const Color(0xFF6B7280),
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showChevron)
              Icon(Icons.chevron_right, size: 20, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileWithError(BuildContext context, String errorMessage, WidgetRef ref) {
    // Create empty profile for display
    final emptyProfile = ProfileModel(
      name: '-',
      email: '-',
      phone: '-',
      totalRides: 0,
      dutiesDone: 0,
      daysOfDuty: 0,
      kmCovered: 0.0,
      overtimeRate: 0.0,
      isVerified: false,
      profileImageUrl: null,
      vehicleNumber: null,
      vehicleModel: null,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Error Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              border: Border.all(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Failed to load profile',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      Text(
                        errorMessage,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => ref.refresh(profileProvider),
                  child: Icon(Icons.refresh, color: Colors.red.shade700, size: 20),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Profile Header with empty data
          _buildProfileHeader(context, emptyProfile, ref),
          const SizedBox(height: 24),

          // Stats Bar with empty data
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildStatBarSkeleton(),
          ),
          const SizedBox(height: 24),
          const Divider(thickness: 8, color: Color(0xFFF9FAFB)),
          
          // Menu Options with empty data
          _buildMenuOptions(context, emptyProfile, ref),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
