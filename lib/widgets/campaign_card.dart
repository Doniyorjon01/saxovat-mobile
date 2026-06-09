import 'package:flutter/material.dart';
import '../models/campaign.dart';
import '../theme/app_colors.dart';

/// Compact campaign card: square thumb on the left, content on the right —
/// badges, title, progress bar, raised/left row. Matches the mockup.
class CampaignCard extends StatelessWidget {
  final Campaign campaign;
  final VoidCallback? onTap;
  const CampaignCard({super.key, required this.campaign, this.onTap});

  /// 50000000 tiyin -> "500 000"
  String _uzs(int tiyin) {
    final s = (tiyin ~/ 100).toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  // Category → (icon, accent color), matching the mockup's category styling.
  (IconData, Color) _categoryStyle(String category) {
    switch (category) {
      case 'medical':
        return (Icons.monitor_heart_outlined, AppColors.r1);
      case 'education':
        return (Icons.school_outlined, AppColors.b3);
      case 'mosque':
        return (Icons.mosque_outlined, AppColors.g0);
      case 'family':
        return (Icons.home_outlined, AppColors.b3);
      case 'disability':
        return (Icons.accessible_outlined, AppColors.t1);
      case 'orphan':
        return (Icons.volunteer_activism_outlined, AppColors.g0);
      default:
        return (Icons.favorite_outline, AppColors.b3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final (icon, accent) = _categoryStyle(campaign.category);
    final remaining = (campaign.targetAmountTiyin - campaign.raisedAmountTiyin)
        .clamp(0, campaign.targetAmountTiyin);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.n3,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumb
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, size: 24, color: accent),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      _badge(campaign.category,
                          bg: const Color(0x1F2563EB), fg: AppColors.b3),
                      _badge('Verified',
                          bg: const Color(0x1A06B6D4),
                          fg: AppColors.t1,
                          icon: Icons.verified_outlined),
                      if (campaign.isUrgent)
                        _badge('Urgent',
                            bg: const Color(0x26DC2626),
                            fg: const Color(0xFFFCA5A5),
                            icon: Icons.priority_high),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Title
                  Text(
                    campaign.displayTitle,
                    style: text.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Progress
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: campaign.progress,
                      minHeight: 6,
                      backgroundColor: const Color(0x12FFFFFF),
                      valueColor: const AlwaysStoppedAnimation(AppColors.b2),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Raised / left
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${_uzs(campaign.raisedAmountTiyin)} UZS raised',
                          style: text.bodySmall),
                      Text('${_uzs(remaining)} left',
                          style: text.bodySmall?.copyWith(
                            color: AppColors.gr1,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String label,
      {required Color bg, required Color fg, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: fg),
            const SizedBox(width: 3),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
        ],
      ),
    );
  }
}