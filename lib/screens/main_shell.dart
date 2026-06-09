import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'home_screen.dart';
import 'placeholder_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  // Tab order: 0 Home, 1 Explore, 2 Donate(center), 3 Zakat, 4 Profile
  final _screens = const [
    HomeScreen(),
    PlaceholderScreen(title: 'Explore', icon: Icons.search),
    PlaceholderScreen(title: 'Donate', icon: Icons.favorite_outline),
    PlaceholderScreen(title: 'Zakat', icon: Icons.calculate_outlined),
    PlaceholderScreen(
        title: 'Profile', icon: Icons.person_outline, showLogin: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.n1,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _index, children: _screens),
      ),
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _bottomBar() {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: AppColors.n2,
        border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _navItem(Icons.home_outlined, 'Home', 0),
          _navItem(Icons.search, 'Explore', 1),
          _centerButton(),
          _navItem(Icons.calculate_outlined, 'Zakat', 3),
          _navItem(Icons.person_outline, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final on = _index == index;
    return GestureDetector(
      onTap: () => setState(() => _index = index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: on ? const Color(0x2E2563EB) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: on ? AppColors.b2 : AppColors.muted),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: on ? AppColors.b2 : AppColors.muted)),
          ],
        ),
      ),
    );
  }

  Widget _centerButton() {
    return GestureDetector(
      onTap: () => setState(() => _index = 2),
      child: Transform.translate(
        offset: const Offset(0, -16),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.b1,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.n1, width: 3),
          ),
          child: const Icon(Icons.favorite, size: 24, color: Colors.white),
        ),
      ),
    );
  }
}