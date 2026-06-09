import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../api/auth_store.dart';
import '../api/require_auth.dart';

class PlaceholderScreen extends StatefulWidget {
  final String title;
  final IconData icon;
  /// If true, shows a login button that demonstrates the auth redirect.
  final bool showLogin;
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    this.showLogin = false,
  });

  @override
  State<PlaceholderScreen> createState() => _PlaceholderScreenState();
}

class _PlaceholderScreenState extends State<PlaceholderScreen> {
  @override
  Widget build(BuildContext context) {
    final loggedIn = AuthStore.instance.isLoggedIn;
    final donor = AuthStore.instance.donor;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, size: 56, color: AppColors.muted2),
          const SizedBox(height: 16),
          Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          if (widget.showLogin && loggedIn) ...[
            const SizedBox(height: 4),
            Text('Logged in as ${donor?.fullName ?? ''}',
                style: const TextStyle(color: AppColors.gr1, fontSize: 13)),
            const SizedBox(height: 4),
            Text(donor?.email ?? '',
                style: const TextStyle(color: AppColors.muted, fontSize: 12)),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                AuthStore.instance.clear();
                setState(() {});
              },
              child: const Text('Log out',
                  style: TextStyle(color: Color(0xFFFCA5A5))),
            ),
          ] else if (widget.showLogin) ...[
            const Text('Not logged in',
                style: TextStyle(color: AppColors.muted, fontSize: 13)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final ok = await ensureLoggedIn(context);
                if (ok && mounted) setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.b1,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              child: const Text('Log in / Register'),
            ),
          ] else
            const Text('Coming soon',
                style: TextStyle(color: AppColors.muted, fontSize: 13)),
        ],
      ),
    );
  }
}
