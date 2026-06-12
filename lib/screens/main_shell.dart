import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'causes_screen.dart';
import 'dashboard_screen.dart';
import 'zakat_screen.dart';
import 'profile_screen.dart';

/// The 5-tab application shell (mockup nav): Home · Causes · Dashboard ·
/// Zakat · Profile. Each tab owns its own header; the shell only provides the
/// Scaffold and the bottom navigation. IndexedStack keeps each tab's state
/// alive when switching.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  // Rebuilt each switch only for Profile/Dashboard would be ideal, but
  // IndexedStack needs stable children; these are cheap and self-refreshing.
  final List<Widget> _tabs = const [
    HomeScreen(),
    CausesScreen(),
    DashboardScreen(),
    ZakatScreen(),
    ProfileScreen(),
  ];

  static const _items = <_NavItem>[
    _NavItem('Home', Icons.home_outlined, Icons.home),
    _NavItem('Causes', Icons.favorite_outline, Icons.favorite),
    _NavItem('Dashboard', Icons.bar_chart_outlined, Icons.bar_chart),
    _NavItem('Zakat', Icons.calculate_outlined, Icons.calculate),
    _NavItem('Profile', Icons.person_outline, Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.n1,
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.n0,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int i = 0; i < _items.length; i++)
                  _navButton(i),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navButton(int i) {
    final item = _items[i];
    final selected = i == _index;
    final color = selected ? AppColors.b3 : AppColors.muted2;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _index = i),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? item.activeIcon : item.icon,
                size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  const _NavItem(this.label, this.icon, this.activeIcon);
}
