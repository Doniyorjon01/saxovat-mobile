import 'package:flutter/material.dart';
import '../models/campaign.dart';
import '../theme/app_colors.dart';
import '../widgets/money.dart';
import '../api/require_auth.dart';
import 'donate_screen.dart';

class CampaignDetailScreen extends StatelessWidget {
  final Campaign campaign;
  const CampaignDetailScreen({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final remaining = (campaign.targetAmountTiyin - campaign.raisedAmountTiyin)
        .clamp(0, campaign.targetAmountTiyin);

    return Scaffold(
      backgroundColor: AppColors.n1,
      appBar: AppBar(
        backgroundColor: AppColors.n2,
        elevation: 0,
        title: const Text('Campaign details',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        actions: [
          if (campaign.isUrgent)
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Center(child: _MiniBadge('Urgent', Color(0xFFFCA5A5))),
            ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(child: _MiniBadge('Verified', AppColors.t1)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Beneficiary card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0x0DDC2626),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x2EDC2626)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.n4,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border2, width: 2),
                      ),
                      child: const Icon(Icons.person,
                          size: 28, color: AppColors.muted2),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(campaign.displayTitle,
                          style: text.titleMedium?.copyWith(height: 1.3)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 5,
                  runSpacing: 5,
                  children: const [
                    _MiniBadge('ID Verified', AppColors.g0),
                    _MiniBadge('Docs approved', AppColors.t1),
                    _MiniBadge('MB Certified', AppColors.gr1),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Progress card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.n3,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Goal', style: text.bodySmall),
                        Text('${formatUzs(campaign.targetAmountTiyin)} UZS',
                            style: text.titleLarge),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Raised', style: text.bodySmall),
                        Text('${formatUzs(campaign.raisedAmountTiyin)} UZS',
                            style: text.titleLarge
                                ?.copyWith(color: AppColors.b3)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: campaign.progress,
                    minHeight: 10,
                    backgroundColor: const Color(0x12FFFFFF),
                    valueColor: const AlwaysStoppedAnimation(AppColors.b2),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${campaign.donorCount} donors',
                        style: text.bodySmall),
                    Text('${formatUzs(remaining)} UZS to go',
                        style: text.bodySmall?.copyWith(
                            color: AppColors.gr1, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text('About this campaign', style: text.titleMedium),
          const SizedBox(height: 8),
          Text(campaign.description,
              style: text.bodyMedium?.copyWith(
                  color: AppColors.muted, height: 1.6)),
          const SizedBox(height: 16),

          // Docs placeholder (no backend document storage yet)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0x12169A4A),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x33169A4A)),
            ),
            child: Row(
              children: const [
                Icon(Icons.check_circle_outline,
                    size: 16, color: Color(0xFF86EFAC)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '100% of your donation goes to this campaign. '
                    'No deductions. Verified by the Muslim Board.',
                    style: TextStyle(
                        color: Color(0xFF86EFAC), fontSize: 11, height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Donate button → login if needed → donate flow
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: () async {
                final ok = await ensureLoggedIn(context);
                if (!ok || !context.mounted) return;
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => DonateScreen(campaign: campaign),
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.b1,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Donate now →',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}