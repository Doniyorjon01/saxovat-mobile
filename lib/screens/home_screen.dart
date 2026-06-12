import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../models/campaign.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/campaign_card.dart';
import 'campaign_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _category;
  late Future<List<Campaign>> _future;

  static const _categories = <(String?, String)>[
    (null, 'All'),
    ('medical', 'Medical'),
    ('education', 'Education'),
    ('mosque', 'Mosque'),
    ('family', 'Family'),
  ];

  @override
  void initState() {
    super.initState();
    _future = ApiClient.fetchCampaigns();
  }

  void _selectCategory(String? category) {
    setState(() {
      _category = category;
      _future = ApiClient.fetchCampaigns(category: category);
    });
  }

  Future<void> _reload() async {
    setState(() => _future = ApiClient.fetchCampaigns(category: _category));
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _reload,
      color: AppColors.b2,
      backgroundColor: AppColors.n2,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _hero(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _categoryChips(),
                const SizedBox(height: 16),
                _sectionHeader(),
                const SizedBox(height: 12),
                _campaignList(),
                const SizedBox(height: 16),
                _verseCard(context),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: const BoxDecoration(
        color: AppColors.n2,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SAHOVAT · GENEROSITY',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.8,
                          color: AppColors.muted)),
                  const SizedBox(height: 3),
                  Text('Assalomu alaykum 👋', style: AppTheme.serif(size: 20)),
                ],
              ),
              Row(
                children: [
                  _circleIcon(Icons.notifications_outlined, dot: true),
                  const SizedBox(width: 8),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                        color: AppColors.b1, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: const Text('A',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0x142563EB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.mosque_outlined,
                        size: 13, color: AppColors.g0),
                    const SizedBox(width: 5),
                    Text('Official partner — Muslim Board of Uzbekistan',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.muted)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _stat('Total distributed', '4.2B', unit: ' UZS',
                        color: AppColors.b3),
                    Container(
                        width: 0.5, height: 36, color: AppColors.border),
                    _stat('Lives changed', '12,480', color: AppColors.g0,
                        padLeft: true),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0x1FD4A843), Color(0x142563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x4DD4A843)),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      color: const Color(0x26D4A843),
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.workspace_premium_outlined,
                      size: 22, color: AppColors.g0),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Officially Certified',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.g0)),
                      const SizedBox(height: 1),
                      Text('Muslim Board of Uzbekistan · Reg. №MB-2024-001',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.muted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleIcon(IconData icon, {bool dot = false}) {
    return Stack(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.n4,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 18, color: AppColors.muted),
        ),
        if (dot)
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.r1,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.n2, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _stat(String label, String value,
      {String unit = '', required Color color, bool padLeft = false}) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(left: padLeft ? 12 : 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 11, color: AppColors.muted)),
            const SizedBox(height: 2),
            RichText(
              text: TextSpan(
                text: value,
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w700, color: color),
                children: [
                  TextSpan(
                      text: unit, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((c) {
          final selected = c.$1 == _category;
          return Padding(
            padding: const EdgeInsets.only(right: 7),
            child: GestureDetector(
              onTap: () => _selectCategory(c.$1),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
                decoration: BoxDecoration(
                  color: selected ? AppColors.b1 : const Color(0x1A2563EB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: selected ? AppColors.b1 : AppColors.border),
                ),
                child: Text(c.$2,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: selected ? Colors.white : AppColors.b3)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Urgent cases',
            style: Theme.of(context).textTheme.titleMedium),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
              color: const Color(0x26DC2626),
              borderRadius: BorderRadius.circular(20)),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, size: 9, color: Color(0xFFFCA5A5)),
              SizedBox(width: 3),
              Text('AI sorted',
                  style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFCA5A5))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _campaignList() {
    return FutureBuilder<List<Campaign>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator(color: AppColors.b2)),
          );
        }
        if (snapshot.hasError) {
          return _message(Icons.cloud_off, 'Could not load campaigns',
              snapshot.error.toString());
        }
        final campaigns = snapshot.data ?? [];
        if (campaigns.isEmpty) {
          return _message(Icons.inbox_outlined, 'No live campaigns yet',
              'Pull down to refresh');
        }
        return Column(
          children: campaigns
              .map((c) => CampaignCard(
                    campaign: c,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => CampaignDetailScreen(campaign: c),
                      ));
                    },
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _message(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(icon, size: 44, color: AppColors.muted),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: AppColors.white)),
          const SizedBox(height: 4),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        ],
      ),
    );
  }

  Widget _verseCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x0FD4A843),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x2ED4A843)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.format_quote, size: 14, color: AppColors.g0),
              SizedBox(width: 6),
              Text('Verse of the day',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.g0)),
            ],
          ),
          const SizedBox(height: 10),
          Text('وَمَا تُنفِقُوا مِنْ خَيْرٍ فَلِأَنفُسِكُمْ',
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: AppTheme.serif(size: 16)),
          const SizedBox(height: 8),
          Text(
              '"Whatever good you spend — it is for yourselves." '
              '— Surah Al-Baqarah 2:272',
              style: TextStyle(
                  fontSize: 12, color: AppColors.muted, height: 1.6)),
        ],
      ),
    );
  }
}
