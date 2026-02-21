import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/driver_bottom_nav_bar.dart';
import '../../../../shared/widgets/custom_drawer.dart';
import 'home_screen.dart';
import '../../../activity/presentation/screens/activity_screen.dart';
import '../../../notifications/screens/notifications_screen.dart';
import '../../../wallet/screens/wallet_screen.dart';
import '../providers/home_provider.dart';
import '../../../activity/presentation/providers/activity_provider.dart';
import '../../../profile/presentation/providers/profile_provider.dart';

class DriverMainScreen extends ConsumerStatefulWidget {
  final String phoneOrEmail;

  const DriverMainScreen({
    super.key,
    required this.phoneOrEmail,
  });

  @override
  ConsumerState<DriverMainScreen> createState() => _DriverMainScreenState();
}

class _DriverMainScreenState extends ConsumerState<DriverMainScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDrawerOpen = false;
  DateTime? _lastBackPressTime;

  final List<Widget> _screens = [];

  void _handlePopInvoked(bool didPop, Object? result) {
    if (didPop) {
      return;
    }
    
    if (_isDrawerOpen) {
      _scaffoldKey.currentState?.closeDrawer();
      setState(() => _isDrawerOpen = false);
      return;
    }
    
    if (_selectedIndex != 0) {
      setState(() => _selectedIndex = 0);
      return;
    }
    
    // On home tab - check for double tap to exit
    final now = DateTime.now();
    if (_lastBackPressTime == null || 
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      // First press or too much time passed - show toast
      _lastBackPressTime = now;
      
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Second press within 2 seconds - exit app
    SystemNavigator.pop();
  }

  @override
  void initState() {
    super.initState();
    // Initialize screens
    _screens.addAll([
      HomeScreen(
        phoneOrEmail: widget.phoneOrEmail,
        onMenuTap: () {
          _scaffoldKey.currentState?.openDrawer();
          setState(() => _isDrawerOpen = true);
        },
      ),
      ActivityScreen(
        phoneOrEmail: widget.phoneOrEmail,
        onMenuTap: () {
          _scaffoldKey.currentState?.openDrawer();
          setState(() => _isDrawerOpen = true);
        },
      ),
      NotificationsScreen(
        phoneOrEmail: widget.phoneOrEmail,
        onMenuTap: () {
          _scaffoldKey.currentState?.openDrawer();
          setState(() => _isDrawerOpen = true);
        },
      ),
      WalletScreen(phoneOrEmail: widget.phoneOrEmail),
    ]);
  }

  void _onItemTapped(int index) {
    // Clear any existing SnackBars when switching tabs
    ScaffoldMessenger.of(context).clearSnackBars();

    final homeState = ref.read(homeProvider);
    if (index == 1 && homeState.isLockedOutForToday && !homeState.isClockedIn) {
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
    
    if (index == 0) {
      ref.invalidate(homeProvider);
      ref.invalidate(activityProvider);
      ref.invalidate(profileProvider);
    } else if (index == 1) {
      ref.invalidate(homeProvider);
      ref.invalidate(activityProvider);
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _handlePopInvoked,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        extendBody: true,
        drawer: CustomDrawer(
          userName: profileAsync.maybeWhen(
            data: (profile) => profile?.name,
            orElse: () => null,
          ),
          phoneNumber: profileAsync.maybeWhen(
            data: (profile) => profile?.phone,
            orElse: () => null,
          ),
        ),
        onDrawerChanged: (isOpened) {
          setState(() {
            _isDrawerOpen = isOpened;
          });
        },
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ],
        ),
        bottomNavigationBar: _isDrawerOpen 
            ? null 
            : DriverBottomNavBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
      ),
    );
  }
}
