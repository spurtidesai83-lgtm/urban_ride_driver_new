import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:urbandriver/shared/utils/responsive_utils.dart';

class HelpSupportScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const HelpSupportScreen({
    super.key,
    this.onMenuTap,
  });

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  // Frontend-only FAQ data (No backend needed)
  List<Map<String, dynamic>> faqs = [
    {
      'category': 'Dashboard',
      'question': 'How do I clock in/out for my shift?',
      'answer': 'On the Dashboard, you\'ll see a Clock In/Clock Out button. Tap it to start or end your shift. Make sure to clock in before starting your duties and clock out after completing all trips for the day.',
    },
    {
      'category': 'Dashboard',
      'question': 'Where can I see my vehicle details?',
      'answer': 'Your current vehicle information is displayed on the Dashboard in the "Today\'s Vehicle" card. Tap on it to view complete vehicle details including registration number, type, and documents.',
    },
    {
      'category': 'Trips',
      'question': 'How do I view my assigned duties?',
      'answer': 'Your daily duties are shown on the Dashboard. You can see duty allocation cards with pick-up locations, drop-off points, and scheduled times. Live trips will appear at the top of your activity feed.',
    },
    {
      'category': 'Trips',
      'question': 'How do I start a trip?',
      'answer': 'Tap on your next duty card on the Dashboard to view trip details. Navigate to the pickup location, perform vehicle inspection if required, enter the PIN to start the trip, and follow the in-app navigation to the destination.',
    },
    {
      'category': 'Trips',
      'question': 'Where can I see my trip history?',
      'answer': 'Go to the Activity tab in the bottom navigation. Here you can view all your trips - Live, Today, and historical records. Use the time filter (Day, Week, Month) to view trips from different periods.',
    },
    {
      'category': 'Wallet',
      'question': 'How do I check my incentives?',
      'answer': 'Tap on the Wallet icon in the bottom navigation. You\'ll see your total unpaid incentive summary, monthly performance breakdown with KM driven and rates, and daily incentive logs.',
    },
    {
      'category': 'Wallet',
      'question': 'When will I receive my payment?',
      'answer': 'Your next payout date is shown in the Wallet section. Payments are processed as per the schedule displayed, and funds are credited to your registered bank account.',
    },
    {
      'category': 'Profile',
      'question': 'How do I update my profile information?',
      'answer': 'Go to My Profile from the menu. Here you can view your personal details, contact information, and vehicle details. To update vehicle documents, tap on "Vehicle Documents" option.',
    },
    {
      'category': 'Profile',
      'question': 'How do I upload vehicle documents?',
      'answer': 'Navigate to My Profile > Vehicle Documents. You can upload documents like Insurance, Fitness Certificate, Pollution Certificate, and Permit. Ensure documents are clear and valid.',
    },
    {
      'category': 'Leave',
      'question': 'How do I apply for leave or duty change?',
      'answer': 'Go to the Leave section from the menu. Select your application type (Leave or Duty Change), choose start and end dates, provide a reason, and submit. You can view your application history and pending requests on the same screen.',
    },
    {
      'category': 'Reports',
      'question': 'Where can I see my monthly reports?',
      'answer': 'Access Driver Reports from the menu to view your monthly performance records including trips completed, kilometers driven, incentives earned, and duty compliance.',
    },
    {
      'category': 'Safety',
      'question': 'How do I use the emergency SOS feature?',
      'answer': 'In case of emergency, go to the Safety section from the menu and tap the SOS button. You can quickly contact Police (100) or Ambulance (102). Your location will be automatically shared with emergency services.',
    },
    {
      'category': 'Account',
      'question': 'How do I change my password?',
      'answer': 'Go to Settings from the menu and tap on "Change Password". Enter your current password and the new password. Your password must be at least 6 characters long.',
    },
    {
      'category': 'Notifications',
      'question': 'How do I manage notifications?',
      'answer': 'Go to Settings from the menu to enable or disable push notifications and sound alerts. You can view all your notifications in the Notifications section.',
    },
    {
      'category': 'Support',
      'question': 'How do I contact admin or support?',
      'answer': 'Use this Help & Support screen to browse common questions. For immediate assistance, tap the "Call Admin" button to contact support at +91 1800-123-4567. Support is available 24/7.',
    },
  ];
  
  List<Map<String, dynamic>> filteredFaqs = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // FAQs are loaded from frontend - no API call needed
    filteredFaqs = faqs;
    _searchController.addListener(_filterFaqs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterFaqs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredFaqs = faqs;
      } else {
        filteredFaqs = faqs.where((faq) {
          final question = faq['question'].toString().toLowerCase();
          final answer = faq['answer'].toString().toLowerCase();
          final category = faq['category'].toString().toLowerCase();
          return question.contains(query) || answer.contains(query) || category.contains(query);
        }).toList();
      }
    });
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
          'Help & Support',
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
              
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search help topics...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
              
              SizedBox(height: ResponsiveUtils.padding(context, 30)),

              // Contact Support Card
              Container(
                padding: ResponsiveUtils.allPadding(context, 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFC200), Color(0xFFFFE082)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.borderRadius(context, 16)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Need help with your account?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.padding(context, 8)),
                    const Text(
                      'Our support team is available 24/7 to assist you.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.padding(context, 20)),
                    Center(
                      child: _buildContactOption(
                        icon: Icons.call_outlined,
                        label: 'Call Admin',
                        phoneNumber: '+91 1800-123-4567',
                        onTap: () async {
                          // Launch phone dialer with admin number
                          final Uri phoneUri = Uri(scheme: 'tel', path: '+911800123456');
                          if (await canLaunchUrl(phoneUri)) {
                            await launchUrl(phoneUri);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: ResponsiveUtils.padding(context, 30)),

              // FAQ Section
              Text(
                'Frequently Asked Questions',
                style: TextStyle(
                  fontSize: ResponsiveUtils.fontSize(context, 18),
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: ResponsiveUtils.padding(context, 16)),
              
              isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFC200)))
                  : filteredFaqs.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(40.0),
                            child: Text(
                              _searchController.text.isEmpty
                                  ? 'No FAQs available at the moment'
                                  : 'No results found for "${_searchController.text}"',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredFaqs.length,
                          itemBuilder: (context, index) {
                            return _buildFAQItem(filteredFaqs[index]);
                          },
                        ),
              
              SizedBox(height: ResponsiveUtils.padding(context, 40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String label,
    required String phoneNumber,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFFFC200),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: Colors.black),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  phoneNumber,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq) {
    return Container(
      margin: ResponsiveUtils.customPadding(context, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            faq['question'],
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          children: [
            Text(
              faq['answer'],
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
