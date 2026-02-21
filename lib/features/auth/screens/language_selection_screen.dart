import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/registration_provider.dart';
import '../../home/presentation/screens/driver_main_screen.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  final String phoneOrEmail;

  const LanguageSelectionScreen({
    super.key,
    required this.phoneOrEmail,
  });

  // Available languages with their display names and codes
  static const List<Map<String, String>> _languages = [
    {'code': 'mr', 'name': 'मराठी', 'englishName': 'Marathi'},
    {'code': 'en', 'name': 'English', 'englishName': 'English'},
    {'code': 'hi', 'name': 'हिन्दी', 'englishName': 'Hindi'},
    {'code': 'ta', 'name': 'தமிழ்', 'englishName': 'Tamil'},
  ];

  String _getDisplayName(String languageCode) {
    final language = _languages.firstWhere(
      (lang) => lang['code'] == languageCode,
      orElse: () => _languages[1], // Default to English
    );
    return language['name'] ?? 'English';
  }

  void _handleContinue(BuildContext context, WidgetRef ref) {
    final selectedLanguage = ref.read(registrationProvider).selectedLanguage;
    if (selectedLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a language')),
      );
      return;
    }

    // Navigate to Driver Main Screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DriverMainScreen(
          phoneOrEmail: phoneOrEmail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrationState = ref.watch(registrationProvider);
    final registrationNotifier = ref.read(registrationProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Header ---
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   // Back Icon
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
                    ),
                  ),
                  // Logo
                  Container(
                    width: 93,
                    height: 93,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      'assets/images/urban_logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC200),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'URBAN\nRIDE',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // --- Title ---
              const Text(
                "Select your language",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 8),

              // --- Subtitle ---
              const Text(
                "You can change your language here or\nat any time through the Help section.",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // --- Language Selection Dropdown ---
              GestureDetector(
                onTap: registrationNotifier.toggleDropdown,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: registrationState.isDropdownOpen
                          ? const Color(0xFFFFC200)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        registrationState.selectedLanguage != null
                            ? _getDisplayName(registrationState.selectedLanguage!)
                            : "Select...",
                        style: TextStyle(
                          fontSize: 16,
                          color: registrationState.selectedLanguage != null
                              ? Colors.black
                              : Colors.grey,
                          fontWeight: registrationState.selectedLanguage != null
                              ? FontWeight.w500
                              : FontWeight.normal,
                        ),
                      ),
                      Icon(
                        registrationState.isDropdownOpen
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),

              // --- Dropdown List (shown when open) ---
              if (registrationState.isDropdownOpen)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: _languages.map((language) {
                      final isSelected = language['code'] == registrationState.selectedLanguage;
                      return _buildLanguageItem(
                        context,
                        registrationNotifier,
                        language['name']!,
                        language['code']!,
                        isSelected: isSelected,
                      );
                    }).toList(),
                  ),
                ),

              const Spacer(),

              // --- Continue Button ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _handleContinue(context, ref),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC200),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 34),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to build list items
  Widget _buildLanguageItem(BuildContext context, RegistrationNotifier notifier, String text, String languageCode, {bool isSelected = false}) {
    return GestureDetector(
      onTap: () => notifier.setLanguage(languageCode),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF3F4F6) : Colors.transparent,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

