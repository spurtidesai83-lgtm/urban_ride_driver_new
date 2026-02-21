import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/registration_provider.dart';
import 'language_selection_screen.dart';

class CitySelectionScreen extends ConsumerWidget {
  final String phoneOrEmail;

  const CitySelectionScreen({
    super.key,
    required this.phoneOrEmail,
  });

  // Major cities in Maharashtra
  static const List<String> _maharashtraCities = [
    'Pune',
    'Mumbai',
    'Nagpur',
    'Nashik',
    'Aurangabad',
    'Solapur',
    'Amravati',
    'Kolhapur',
    'Sangli',
    'Nanded',
    'Jalgaon',
    'Akola',
    'Latur',
    'Dhule',
    'Ahmednagar',
    'Chandrapur',
    'Parbhani',
    'Ichalkaranji',
    'Jalna',
    'Bhusawal',
    'Panvel',
    'Satara',
    'Beed',
    'Yavatmal',
    'Kamptee',
    'Gondia',
    'Barshi',
    'Achalpur',
    'Osmanabad',
    'Nandurbar',
  ];

  void _showCityPicker(BuildContext context, WidgetRef ref) {
    final registrationState = ref.read(registrationProvider);
    final registrationNotifier = ref.read(registrationProvider.notifier);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
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
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Select City',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              // City List
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _maharashtraCities.length,
                  itemBuilder: (context, index) {
                    final city = _maharashtraCities[index];
                    final isSelected = city == registrationState.selectedCity;
                    return ListTile(
                      title: Text(
                        city,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? const Color(0xFFFFC200) : Colors.black,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Color(0xFFFFC200),
                            )
                          : null,
                      onTap: () {
                        registrationNotifier.setCity(city);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom),
            ],
          ),
        );
      },
    );
  }

  void _handleContinue(BuildContext context, WidgetRef ref) {
    final selectedCity = ref.read(registrationProvider).selectedCity;

    if (selectedCity == null || selectedCity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a city')),
      );
      return;
    }

    // Navigate to Language Selection Screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LanguageSelectionScreen(
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
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
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(top: 10.0),
                                child: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
                              ),
                            ),
                            // Logo Placeholder
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
                                        'URBAN\\nRIDE',
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

                        const SizedBox(height: 20),
                        // --- Title ---
                        RichText(
                          text: const TextSpan(
                            text: 'Start Earning with Urban',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 24,
                              color: Colors.black,
                            ),
                            children: [
                              TextSpan(
                                text: 'Ride',
                                style: TextStyle(
                                  color: Color(0xFFFFC200),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // --- Subtitle ---
                        const Text(
                          "Which city do want to ride ?",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // --- Input Field with Dropdown ---
                        GestureDetector(
                          onTap: () => _showCityPicker(context, ref),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: registrationState.selectedCity != null
                                    ? const Color(0xFFFFC200)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                                    child: Text(
                                      registrationState.selectedCity ?? 'Select your city',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(right: 12.0),
                                  child: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.black,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // City suggestions (quick select chips)
                        const Text(
                          'Popular Cities',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['Pune', 'Mumbai', 'Nagpur', 'Nashik']
                              .map((city) => GestureDetector(
                                    onTap: () {
                                      registrationNotifier.setCity(city);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: registrationState.selectedCity == city
                                            ? const Color(0xFFFFC200)
                                            : Colors.grey[200],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        city,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: registrationState.selectedCity == city
                                              ? Colors.black
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ))
                              .toList(),
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
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
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
            },
          ),
        ),
      ),
    );
  }
}

