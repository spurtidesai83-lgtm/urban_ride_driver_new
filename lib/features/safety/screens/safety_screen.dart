import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:urbandriver/shared/utils/responsive_utils.dart';

class SafetyScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const SafetyScreen({
    super.key,
    this.onMenuTap,
  });

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  void _triggerSOS() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: ResponsiveUtils.allPadding(context, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: ResponsiveUtils.padding(context, 20)),
            const Text(
              'Emergency Assistance',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: ResponsiveUtils.padding(context, 10)),
            const Text(
              'Who do you want to contact?',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: ResponsiveUtils.padding(context, 24)),
            Row(
              children: [
                Expanded(
                  child: _buildEmergencyOption(
                    icon: Icons.local_police,
                    label: 'Police',
                    color: Colors.red[50]!,
                    iconColor: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _launchDialer('100');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildEmergencyOption(
                    icon: Icons.medical_services,
                    label: 'Ambulance',
                    color: Colors.red[50]!,
                    iconColor: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _launchDialer('102');
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.padding(context, 16)),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.black54),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Your location will be shared with the emergency services automatically.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: ResponsiveUtils.padding(context, 10)),
          ],
        ),
      ),
    );
  }

  Future<void> _launchDialer(String number) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: number,
    );
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      }
    } catch (e) {
      debugPrint('Error launching dialer: $e');
    }
  }

  Widget _buildEmergencyOption({
    required IconData icon,
    required String label,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: iconColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          'Safety Center',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: ResponsiveUtils.symmetricPadding(context, horizontal: 20, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: ResponsiveUtils.padding(context, 20)),
              
              // SOS Button Section
              Center(
                child: GestureDetector(
                  onTap: _triggerSOS,
                  child: Container(
                    width: ResponsiveUtils.width(context, 160),
                    height: ResponsiveUtils.width(context, 160),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: ResponsiveUtils.width(context, 120),
                        height: ResponsiveUtils.width(context, 120),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF5252), Color(0xFFD32F2F)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.sos, color: Colors.white, size: 36),
                            const SizedBox(height: 4),
                            Text(
                              'SOS',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.fontSize(context, 24),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Tap for Emergency Assistance',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.padding(context, 40)),

              // Safety Toolkit Section
              Text(
                'Safety Toolkit',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: ResponsiveUtils.padding(context, 16)),
              
              _buildSwitchItem(
                icon: Icons.share_location_outlined,
                title: 'Share Live Location',
                subtitle: 'Your location is being shared automatically',
                value: true,
                onChanged: null,
                isDisabled: true,
              ),
              SizedBox(height: ResponsiveUtils.padding(context, 12)),
              
              _buildToolkitItem(
                icon: Icons.contact_phone_outlined,
                title: 'Trusted Contacts',
                subtitle: 'Call Admin for support',
                onTap: () {
                  _launchDialer('1234567890');
                },
              ),

              SizedBox(height: ResponsiveUtils.padding(context, 30)),

              // Safety Tips Carousel or List
              Text(
                'Safety Tips',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: ResponsiveUtils.padding(context, 16)),
              
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildSafetyTipCard(
                      context,
                      title: 'Verify Rider',
                      description: 'Always verify the rider\'s name and destination before starting.',
                      color: Colors.blue[50]!,
                      iconColor: Colors.blue,
                      icon: Icons.verified_user_outlined,
                    ),
                    const SizedBox(width: 16),
                    _buildSafetyTipCard(
                      context,
                      title: 'Follow Rules',
                      description: 'Adhere to traffic rules and speed limits for a safe journey.',
                      color: Colors.green[50]!,
                      iconColor: Colors.green,
                      icon: Icons.traffic_outlined,
                    ),
                    const SizedBox(width: 16),
                     _buildSafetyTipCard(
                      context,
                      title: 'Stay Alert',
                      description: 'Avoid driving if you feel drowsy or unwell. Take a break.',
                      color: Colors.orange[50]!,
                      iconColor: Colors.orange,
                      icon: Icons.hotel_class_outlined,
                    ),
                  ],
                ),
              ),
              SizedBox(height: ResponsiveUtils.padding(context, 40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool)? onChanged,
    bool isDisabled = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDisabled ? Colors.black54 : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: const Color(0xFFFFC200),
            onChanged: isDisabled ? null : onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildToolkitItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.05),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4CC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.orange[800], size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ),
        trailing: trailing ?? Icon(Icons.chevron_right, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildSafetyTipCard(
    BuildContext context, {
    required String title,
    required String description,
    required Color color,
    required Color iconColor,
    required IconData icon,
  }) {
    return Container(
      width: ResponsiveUtils.width(context, 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: iconColor.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
