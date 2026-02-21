import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:urbandriver/features/home/presentation/providers/home_provider.dart';

class ClockStatusButton extends ConsumerWidget {
  const ClockStatusButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);
    final isClockedIn = homeState.isClockedIn;
    final isLockedOut = homeState.isLockedOutForToday && !homeState.isClockedIn;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: () async {
          if (isLockedOut) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You are locked out for today'),
                backgroundColor: Colors.red,
                duration: Duration(milliseconds: 1500),
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }

          print('🔵 Clock button tapped!');
          final result = await homeNotifier.toggleClockStatus();
          print('🔵 Result: success=${result.success}, message=${result.message}');
          if (context.mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result.message),
                backgroundColor: result.success ? Colors.green : Colors.red,
                duration: const Duration(milliseconds: 1500),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isLockedOut
              ? Colors.grey[400]
              : isClockedIn
                  ? const Color(0xFFFF5252)
                  : const Color(0xFFFFC200),
          foregroundColor: isLockedOut
              ? Colors.white
              : isClockedIn
                  ? Colors.white
                  : Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isLockedOut ? Icons.lock_outline : isClockedIn ? Icons.logout : Icons.login,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              isLockedOut ? 'Shift Locked' : isClockedIn ? 'Clock Out' : 'Clock In',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
