import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../models/campaign.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/campaign_card.dart';
import 'campaign_detail_screen.dart';

/// "Causes" — browse every live campaign. Category filter is server-side;
/// the text search is client-side (the public feed has no search param).
class CausesScreen extends StatefulWidget {
  const CausesScreen({super.key});

  @override
  State<CausesScreen> createState() => _CausesScreenState();
}

class _CausesScreenState extends State<CausesScreen> {
  String? _category;
  String _query = '';
  final _search = TextEditingController();
  late Future<List<Campaign>> _future;

  static const _categories = <(String?, String)>[
    (null, 'All'),
    ('medical', 'Medical'),
    ('education', 'Education'),
    ('mosque', 'Mosque'),
    ('family', 'Family'),
    ('disability', 'Disability'),
    ('orphan', 'Orphan'),
    ('other', 'Other'),
  ];

  @override
  void initState() {
    super.initState();
    _future = ApiClient.fetchCampaigns();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
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

  List<Campaign> _filter(List<Campaign> all) {
    if (_query.trim().isEmpty) return all;
    final q = _query.toLowerCase();
    return all.where((c) {
      return c.displayTitle.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          decoration: const BoxDecoration(
            color: AppColors.n2,
            border: Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Causes', style: AppTheme.serif(size: 22)),
              const SizedBox(height: 12),
              TextField(
                controller: _search,
                onChanged: (v) => setState(() => _query = v),
                style: const TextStyle(color: AppColors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Search campaigns',
                  hintStyle:
                      const TextStyle(color: AppColors.muted2, fontSize: 13),
                  prefixIcon: const Icon(Icons.search,
                      size: 18, color: AppColors.muted),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.close,
                              size: 16, color: AppColors.muted),
                          onPressed: () {
                            _search.clear();
                            setState(() => _query = '');
                          },
                        ),
                  filled: true,
                  fillColor: AppColors.n3,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.b2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((c) {
                    final selected = c.$1 == _category;
                    return Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: GestureDetector(
                        onTap: () => _selectCategory(c.$1),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 13, vertical: 7),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.b1
                                : const Color(0x1A2563EB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: selected
                                    ? AppColors.b1
                                    : AppColors.border),
                          ),
                          child: Text(c.$2,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.b3)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _reload,
            color: AppColors.b2,
            backgroundColor: AppColors.n2,
            child: FutureBuilder<List<Campaign>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: AppColors.b2));
                }
                if (snapshot.hasError) {
                  return _message(Icons.cloud_off, 'Could not load campaigns',
                      snapshot.error.toString());
                }
                final filtered = _filter(snapshot.data ?? []);
                if (filtered.isEmpty) {
                  return _message(Icons.inbox_outlined, 'No campaigns found',
                      'Try a different search or category');
                }
                return ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  children: filtered
                      .map((c) => CampaignCard(
                            campaign: c,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    CampaignDetailScreen(campaign: c),
                              ),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _message(IconData icon, String title, String subtitle) {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Icon(icon, size: 44, color: AppColors.muted),
        const SizedBox(height: 10),
        Center(
            child: Text(title, style: const TextStyle(color: AppColors.white))),
        const SizedBox(height: 4),
        Center(
          child: Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        ),
      ],
    );
  }
}
