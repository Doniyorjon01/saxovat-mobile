import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/auth_store.dart';
import '../api/require_auth.dart';
import '../models/donation_history_item.dart';
import '../models/notification_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/money.dart';
import '../widgets/relative_time.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Future<({List<DonationHistoryItem> donations, List<NotificationItem> notifs})>?
      _future;

  @override
  void initState() {
    super.initState();
    if (AuthStore.instance.isLoggedIn) _load();
  }

  void _load() {
    _future = _fetch();
  }

  Future<({List<DonationHistoryItem> donations, List<NotificationItem> notifs})>
      _fetch() async {
    // Awaited separately to keep each future's static type (Future.wait would
    // widen them to a common supertype and force fragile runtime casts).
    final donations = await ApiClient.fetchDonationHistory(limit: 100);
    final notifResult = await ApiClient.fetchNotifications(limit: 50);
    return (
      donations: donations,
      notifs: notifResult.items,
    );
  }

  Future<void> _reload() async {
    setState(_load);
    await _future;
  }

  Future<void> _login() async {
    final ok = await ensureLoggedIn(context);
    if (ok && mounted) setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthStore.instance.isLoggedIn) {
      return _LoggedOut(onLogin: _login);
    }
    return RefreshIndicator(
      onRefresh: _reload,
      color: AppColors.b2,
      backgroundColor: AppColors.n2,
      child: FutureBuilder<
          ({List<DonationHistoryItem> donations, List<NotificationItem> notifs})>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.b2));
          }
          if (snapshot.hasError) {
            return ListView(children: [
              const SizedBox(height: 100),
              const Icon(Icons.cloud_off, size: 44, color: AppColors.muted),
              const SizedBox(height: 10),
              Center(
                child: Text(
                    snapshot.error
                        .toString()
                        .replaceFirst('Exception: ', ''),
                    style: const TextStyle(color: AppColors.muted)),
              ),
            ]);
          }
          final data = snapshot.data!;
          final completed = data.donations
              .where((d) => d.status == 'completed')
              .toList();
          final totalDonated =
              completed.fold<int>(0, (s, d) => s + d.amountTiyin);
          final peopleHelped =
              completed.map((d) => d.campaignId).toSet().length;
          final donationCount = completed.length;

          return ListView(
            padding: EdgeInsets.zero,
            children: [
              _header(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Your impact',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _statCard('Total donated',
                            '${formatUzs(totalDonated)} UZS', AppColors.b3,
                            Icons.favorite_outline),
                        const SizedBox(width: 10),
                        _statCard('People helped', '$peopleHelped',
                            AppColors.gr1, Icons.groups_outlined),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _statCard('Donations made', '$donationCount',
                        AppColors.g0, Icons.receipt_long_outlined,
                        wide: true),
                    const SizedBox(height: 22),
                    Text('Impact feed',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    _impactFeed(data.notifs),
                    const SizedBox(height: 22),
                    Text('My guardianships',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 10),
                    _guardianshipComingSoon(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _header() {
    final donor = AuthStore.instance.donor;
    final name = donor?.fullName ?? 'Donor';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'D';
    final since = monthYear(donor?.createdAt);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.n2,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
                color: AppColors.b1, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(initial,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.serif(size: 20)),
                if (since.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('Member since $since',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.muted)),
                ],
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: const Color(0x26D4A843),
                borderRadius: BorderRadius.circular(20)),
            child: const Text('Donor',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.g0)),
          ),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, Color color, IconData icon,
      {bool wide = false}) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.n3,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        ],
      ),
    );
    return wide ? SizedBox(width: double.infinity, child: card) : Expanded(child: card);
  }

  Widget _impactFeed(List<NotificationItem> notifs) {
    if (notifs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.n3,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          children: [
            Icon(Icons.notifications_none, size: 20, color: AppColors.muted),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No updates yet. When a campaign you supported is paid out, '
                'it will appear here.',
                style: TextStyle(
                    fontSize: 12, color: AppColors.muted, height: 1.5),
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      children: notifs.map((n) {
        final isPayout = n.type == 'payout_received';
        final color = isPayout ? AppColors.gr1 : AppColors.b3;
        final icon = isPayout
            ? Icons.account_balance_wallet_outlined
            : Icons.volunteer_activism_outlined;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.n3,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: n.isRead ? AppColors.border : AppColors.border2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11)),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n.title,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white)),
                    const SizedBox(height: 3),
                    Text(n.body,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                            height: 1.5)),
                    const SizedBox(height: 6),
                    Text(relativeTime(n.createdAt),
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.muted2)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _guardianshipComingSoon() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x0FD4A843),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x2ED4A843)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: const Color(0x26D4A843),
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.event_repeat_outlined,
                size: 20, color: AppColors.g0),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monthly guardianship',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white)),
                SizedBox(height: 2),
                Text('Sponsor a family every month — coming soon',
                    style: TextStyle(fontSize: 11, color: AppColors.muted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoggedOut extends StatelessWidget {
  final VoidCallback onLogin;
  const _LoggedOut({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: const Color(0x142563EB),
                  borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.insights_outlined,
                  size: 30, color: AppColors.b3),
            ),
            const SizedBox(height: 16),
            Text('Track your impact', style: AppTheme.serif(size: 20)),
            const SizedBox(height: 6),
            const Text(
              'Log in to see your total giving, the people you have helped, '
              'and updates when your donations are delivered.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.b1,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Log in or register',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
