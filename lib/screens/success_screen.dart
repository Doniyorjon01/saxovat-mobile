import 'package:flutter/material.dart';
import '../models/campaign.dart';
import '../models/donation_receipt.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/money.dart';

class SuccessScreen extends StatelessWidget {
  final DonationReceipt receipt;
  final Campaign campaign;
  const SuccessScreen(
      {super.key, required this.receipt, required this.campaign});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.n1,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 24),
            Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                    color: Color(0x2622C55E), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle,
                    size: 48, color: AppColors.gr1),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text('جزاك الله خيراً',
                  textDirection: TextDirection.rtl,
                  style: AppTheme.serif(size: 26)),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text('May Allah reward you',
                  style: text.bodyMedium?.copyWith(color: AppColors.muted)),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.n3,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _row('Campaign', campaign.displayTitle),
                  const SizedBox(height: 10),
                  _row('Amount', '${formatUzs(receipt.amountTiyin)} UZS'),
                  const SizedBox(height: 10),
                  _row('Tip', '${formatUzs(receipt.tipTiyin)} UZS'),
                  const SizedBox(height: 10),
                  _row('Intention', receipt.intent),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: AppColors.border, height: 1),
                  ),
                  _row('Reference', receipt.externalId),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Status',
                          style: TextStyle(
                              fontSize: 13, color: AppColors.muted)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                            color: const Color(0x2622C55E),
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(receipt.status.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gr1)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context)
                    .popUntil((route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.b1,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Back to home',
                    style:
                        TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 13, color: AppColors.muted)),
        const SizedBox(width: 16),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white)),
        ),
      ],
    );
  }
}
