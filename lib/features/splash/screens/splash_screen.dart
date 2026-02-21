import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/screens/login.dart';
import '../../auth/providers/auth_provider.dart';
import '../../home/presentation/screens/driver_main_screen.dart';
import '../../../shared/services/storage_service.dart';

/// Splash screen that shows the Urban Taxi Ride logo then validates token or routes to login.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const Duration _delay = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    Timer(_delay, _checkAuthAndNavigate);
  }

  Future<void> _checkAuthAndNavigate() async {
    if (!mounted) return;

    print('🚀 [SplashScreen] Checking authentication status...');
    
    // Validate stored token
    final isTokenValid = await ref.read(authProvider.notifier).validateToken();
    
    if (!mounted) return;

    if (isTokenValid) {
      print('✅ [SplashScreen] Token valid, navigating to main screen');
      
      // Get stored email
      final email = await StorageService.getUserEmail();
      final phoneOrEmail = email ?? ''; // No fallback - only backend data
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DriverMainScreen(phoneOrEmail: phoneOrEmail),
        ),
      );
    } else {
      print('❌ [SplashScreen] Token invalid/expired, navigating to login');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: Image.asset(
                'assets/images/urban_logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Urban Taxi Ride',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Maharashtra',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black.withOpacity(0.7),
                  ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}
