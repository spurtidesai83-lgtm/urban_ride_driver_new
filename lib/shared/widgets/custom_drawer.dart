import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/responsive_utils.dart';
import '../../features/profile/presentation/screens/driver_profile_screen.dart';
import '../../features/reports/presentation/screens/driver_reports_screen.dart';
import '../../features/safety/screens/safety_screen.dart';
import '../../features/support/screens/help_support_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/leave/screens/leave_application_screen.dart';
import '../../features/auth/screens/login.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/home/presentation/providers/home_provider.dart';
import '../../features/activity/presentation/providers/activity_provider.dart';
import '../../features/activity/presentation/providers/pickup_provider.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../../features/profile/presentation/providers/trip_history_provider.dart';
import '../../features/profile/presentation/providers/vehicle_provider.dart';
import '../../features/wallet/providers/wallet_provider.dart';
import '../../features/leave/providers/leave_provider.dart';
import '../../features/notifications/providers/notification_provider.dart';


class CustomDrawer extends StatelessWidget {
  final String? userName;
  final String? phoneNumber;
  final String? profileImageUrl;

  const CustomDrawer({
    super.key,
    this.userName,
    this.phoneNumber,
    this.profileImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: ResponsiveUtils.widthPercent(context, 0.75).clamp(280, 320), // 75% of screen width, max 320
      backgroundColor: const Color(0xFFFFC200),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // --- Header Section ---
            Padding(
              padding: ResponsiveUtils.customPadding(context, left: 26, top: 20, right: 24, bottom: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image
                  Container(
                    width: ResponsiveUtils.width(context, 40),
                    height: ResponsiveUtils.height(context, 40),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 8)),
                      image: DecorationImage(
                        image: AssetImage('assets/images/profile_photo.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.padding(context, 12)),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName ?? "-",
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 16),
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(height: ResponsiveUtils.padding(context, 2)),
                        Text(
                          phoneNumber ?? "-",
                          style: TextStyle(
                            fontSize: ResponsiveUtils.fontSize(context, 12),
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Close Icon
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: ResponsiveUtils.iconSize(context, 24), color: Colors.black),
                  ),
                ],
              ),
            ),

            // --- Menu Items List ---
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: const [
                  DrawerItem(icon: Icons.person_outline, label: "My Profile"),
                  DrawerItem(icon: Icons.assessment_outlined, label: "Reports"),
                  DrawerItem(icon: Icons.verified_user_outlined, label: "Safety"),
                  DrawerItem(icon: Icons.help_outline, label: "Help & Support"),
                  DrawerItem(icon: Icons.mail_outline, label: "Leave Application"),
                  DrawerItem(icon: Icons.settings_outlined, label: "Setting"),
                  DrawerItem(icon: Icons.logout, label: "Logout"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Widget for consistent spacing
class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: ResponsiveUtils.symmetricPadding(context, horizontal: 29, vertical: 0),
      visualDensity: const VisualDensity(vertical: -2),
      leading: Icon(
        icon,
        size: ResponsiveUtils.iconSize(context, 20),
        color: Colors.black,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: ResponsiveUtils.fontSize(context, 16),
          fontWeight: FontWeight.w500,
          color: Colors.black,
        ),
      ),
      onTap: onTap ?? () {
        // Handle navigation logic here
        Navigator.pop(context); // Close drawer first
        
        switch (label) {
          case "My Profile":
            // Navigate to profile screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DriverProfileScreen(
                  phoneOrEmail: "User", // You can pass actual user data here
                ),
              ),
            );
            break;
          case "Reports":
            // Navigate to reports screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DriverReportsScreen(
                  phoneOrEmail: "User", // You can pass actual user data here
                ),
              ),
            );
            break;
          case "Safety":
            // Navigate to safety screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SafetyScreen(),
              ),
            );
            break;
          case "Help & Support":
            // Navigate to help screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HelpSupportScreen(),
              ),
            );
            break;

          case "Setting":
            // Navigate to settings screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
            break;

          case "Leave Application":
            // Navigate to leave application screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LeaveApplicationScreen(),
              ),
            );
            break;

          case "Logout":
            // Handle logout
            _handleLogout(context);
            break;
        }
      },
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 16)),
          ),
          title: Text(
            'Logout',
            style: TextStyle(
              color: Colors.black,
              fontSize: ResponsiveUtils.fontSize(context, 18),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              color: Colors.black87,
              fontSize: ResponsiveUtils.fontSize(context, 14),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: ResponsiveUtils.fontSize(context, 14),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Close drawer

                final container = ProviderScope.containerOf(context);
                await container.read(authProvider.notifier).signOut();
                container.invalidate(homeProvider);
                container.invalidate(activityProvider);
                container.invalidate(pickupProvider);
                container.invalidate(profileProvider);
                container.invalidate(tripHistoryProvider);
                container.invalidate(vehicleProvider);
                container.invalidate(walletProvider);
                container.invalidate(leaveProvider);
                container.invalidate(notificationProvider);

                // Navigate to login screen and clear all previous routes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: ResponsiveUtils.fontSize(context, 14),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

