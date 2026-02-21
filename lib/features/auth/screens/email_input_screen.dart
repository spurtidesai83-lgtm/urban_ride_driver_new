import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/registration_provider.dart';
import 'city_selection_screen.dart';

class EmailInputScreen extends ConsumerStatefulWidget {
  final String phoneOrEmail;

  const EmailInputScreen({
    super.key,
    required this.phoneOrEmail,
  });

  @override
  ConsumerState<EmailInputScreen> createState() => _EmailInputScreenState();
}

class _EmailInputScreenState extends ConsumerState<EmailInputScreen> {
  @override
  void initState() {
    super.initState();
    // Clear email state when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(registrationProvider.notifier).setEmailAddress('');
    });
  }

  void _handleContinue(BuildContext context) {
    final registrationState = ref.read(registrationProvider);
    final email = registrationState.emailAddress?.trim() ?? '';

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!registrationState.isEmailValid) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Navigate to city selection screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CitySelectionScreen(
          phoneOrEmail: widget.phoneOrEmail,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final registrationState = ref.watch(registrationProvider);
    final registrationNotifier = ref.read(registrationProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
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
                              onTap: () {
                                Navigator.pop(context);
                              },
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
                        RichText(
                          text: const TextSpan(
                            text: 'Sign-in ',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFFC107), // Yellow "Sign-in"
                            ),
                            children: [
                              TextSpan(
                                text: 'Detail Required',
                                style: TextStyle(
                                  color: Colors.black87, // Black "Detail Required"
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // --- Subtitle ---
                        const Text(
                          "To set up your driver account, we need to collect your email address",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 30),
                        // --- Label ---
                        const Text(
                          "Email Address",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // --- Input Field ---
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            onChanged: registrationNotifier.setEmailAddress,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF575454),
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              suffixIcon: (registrationState.isEmailValid && 
                                           registrationState.emailAddress != null && 
                                           registrationState.emailAddress!.isNotEmpty)
                                  ? const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Icon(
                                        Icons.check_circle,
                                        color: Color(0xFFFFC107),
                                        size: 24,
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        const Spacer(),
                        // --- Continue Button ---
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => _handleContinue(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFC107),
                              disabledBackgroundColor: const Color(0xFFFFE082),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                            ),
                            child: const Text(
                              "Continue",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 34), // Bottom padding
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

