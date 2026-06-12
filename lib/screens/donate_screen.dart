import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../models/campaign.dart';
import '../theme/app_colors.dart';
import '../widgets/money.dart';
import 'success_screen.dart';

class DonateScreen extends StatefulWidget {
  final Campaign campaign;
  final int? initialAmountUzs;
  const DonateScreen({super.key, required this.campaign, this.initialAmountUzs});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  static const _amounts = [50000, 100000, 250000, 500000];
  late int _amountUzs;

  static const _intents = [
    ('sadaqah', 'Sadaqah'),
    ('zakat', 'Zakat'),
    ('fitrana', 'Fitrana'),
    ('lillah', 'Lillah'),
  ];
  String _intent = 'sadaqah';

  double _tipPercent = 0;

  int? _balanceTiyin;
  bool _loadingBalance = true;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _amountUzs = widget.initialAmountUzs ?? 100000;
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    try {
      final b = await ApiClient.fetchWalletBalance();
      if (mounted) setState(() { _balanceTiyin = b; _loadingBalance = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingBalance = false);
    }
  }

  int get _amountTiyin => _amountUzs * 100;
  int get _tipTiyin => (_amountTiyin * _tipPercent / 100).round();
  int get _totalTiyin => _amountTiyin + _tipTiyin;

  Future<void> _confirm() async {
    setState(() { _submitting = true; _error = null; });
    try {
      final receipt = await ApiClient.donate(
        campaignId: widget.campaign.id,
        amountTiyin: _amountTiyin,
        tipTiyin: _tipTiyin,
        intent: _intent,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) =>
            SuccessScreen(receipt: receipt, campaign: widget.campaign),
      ));
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.n1,
      appBar: AppBar(
        backgroundColor: AppColors.n2,
        elevation: 0,
        title: const Text('Make a donation',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(widget.campaign.displayTitle,
              style: text.titleMedium?.copyWith(height: 1.3)),
          const SizedBox(height: 20),
          Text('Amount', style: text.bodySmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _amounts.map((a) {
              final on = a == _amountUzs;
              return GestureDetector(
                onTap: () => setState(() => _amountUzs = a),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: on ? AppColors.b1 : const Color(0x1A2563EB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: on ? AppColors.b1 : AppColors.border),
                  ),
                  child: Text('${formatUzs(a * 100)} UZS',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: on ? Colors.white : AppColors.b3)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text('Intention', style: text.bodySmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _intents.map((i) {
              final on = i.$1 == _intent;
              return GestureDetector(
                onTap: () => setState(() => _intent = i.$1),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: on ? AppColors.b1 : const Color(0x1A2563EB),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: on ? AppColors.b1 : AppColors.border),
                  ),
                  child: Text(i.$2,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: on ? Colors.white : AppColors.b3)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Support the platform', style: text.bodySmall),
              Text('${_tipPercent.round()}%',
                  style: text.bodySmall?.copyWith(
                      color: AppColors.g0, fontWeight: FontWeight.w600)),
            ],
          ),
          Slider(
            value: _tipPercent,
            min: 0,
            max: 15,
            divisions: 15,
            activeColor: AppColors.g0,
            inactiveColor: const Color(0x33D4A843),
            onChanged: (v) => setState(() => _tipPercent = v),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.n3,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _summaryRow('Donation', '${formatUzs(_amountTiyin)} UZS'),
                const SizedBox(height: 6),
                _summaryRow('Tip', '${formatUzs(_tipTiyin)} UZS'),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: AppColors.border, height: 1),
                ),
                _summaryRow('Total', '${formatUzs(_totalTiyin)} UZS',
                    bold: true),
                const SizedBox(height: 10),
                _summaryRow(
                  'Wallet balance',
                  _loadingBalance
                      ? '...'
                      : (_balanceTiyin == null
                          ? '—'
                          : '${formatUzs(_balanceTiyin!)} UZS'),
                  muted: true,
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0x1FDC2626),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0x3DDC2626)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      size: 16, color: Color(0xFFFCA5A5)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_error!,
                        style: const TextStyle(
                            color: Color(0xFFFCA5A5), fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _submitting ? null : _confirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.b1,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text('Confirm — ${formatUzs(_totalTiyin)} UZS',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value,
      {bool bold = false, bool muted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: muted ? AppColors.muted : AppColors.white)),
        Text(value,
            style: TextStyle(
                fontSize: bold ? 15 : 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: bold ? AppColors.b3 : AppColors.white)),
      ],
    );
  }
}
