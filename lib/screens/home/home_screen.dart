import 'package:flutter/material.dart';
import '../dashboard/user_dashboard_screen.dart';
import '../device/device_details_screen.dart';
import '../sos/sos_history_screen.dart';
import '../profile/profile_screen.dart';
import '../../utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    UserDashboardScreen(),
    DeviceDetailsScreen(),
    SosHistoryScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        backgroundColor: AppConstants.surfaceColor,
        indicatorColor: AppConstants.primaryColor.withValues(alpha: 0.25),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppConstants.primaryColor),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.router_outlined),
            selectedIcon: Icon(Icons.router, color: AppConstants.primaryColor),
            label: 'Device',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history, color: AppConstants.primaryColor),
            label: 'Timeline',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppConstants.primaryColor),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
