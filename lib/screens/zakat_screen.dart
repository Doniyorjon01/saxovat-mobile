import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/money.dart';

/// Zakat al-Mal calculator. Fully client-side (no backend).
/// Rule: if net zakatable assets >= nisab, zakat due = 2.5% of net assets.
class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  final _cash = TextEditingController(text: '0');
  final _gold = TextEditingController(text: '0');
  final _business = TextEditingController(text: '0');
  final _other = TextEditingController(text: '0');
  final _debts = TextEditingController(text: '0');
  final _nisab = TextEditingController(text: '5400000');

  @override
  void dispose() {
    _cash.dispose();
    _gold.dispose();
    _business.dispose();
    _other.dispose();
    _debts.dispose();
    _nisab.dispose();
    super.dispose();
  }

  int _val(TextEditingController c) {
    final cleaned = c.text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  int get _assets =>
      _val(_cash) + _val(_gold) + _val(_business) + _val(_other);
  int get _net => (_assets - _val(_debts)).clamp(0, 1 << 62);
  int get _nisabValue => _val(_nisab);
  bool get _meetsNisab => _net >= _nisabValue && _nisabValue > 0;
  int get _zakatDue => _meetsNisab ? (_net * 25 ~/ 1000) : 0;

  String _uzs(int wholeUzs) => formatUzs(wholeUzs * 100);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          decoration: const BoxDecoration(
            color: AppColors.n2,
            border: Border(
                bottom: BorderSide(color: AppColors.border, width: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                    color: const Color(0x26D4A843),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.calculate_outlined,
                    size: 20, color: AppColors.g0),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Zakat calculator', style: AppTheme.serif(size: 20)),
                  const SizedBox(height: 2),
                  const Text('Zakat al-Mal · 2.5% on net wealth',
                      style:
                          TextStyle(fontSize: 12, color: AppColors.muted)),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionLabel('Your assets (UZS)'),
              const SizedBox(height: 10),
              _field(_cash, 'Cash & bank savings', Icons.savings_outlined),
              const SizedBox(height: 10),
              _field(_gold, 'Gold & silver value', Icons.diamond_outlined),
              const SizedBox(height: 10),
              _field(_business, 'Business assets / inventory',
                  Icons.store_outlined),
              const SizedBox(height: 10),
              _field(_other, 'Other zakatable assets',
                  Icons.account_balance_wallet_outlined),
              const SizedBox(height: 18),
              _sectionLabel('Deductions (UZS)'),
              const SizedBox(height: 10),
              _field(_debts, 'Debts you owe', Icons.remove_circle_outline),
              const SizedBox(height: 18),
              _sectionLabel('Nisab threshold (UZS)'),
              const SizedBox(height: 6),
              const Text(
                  'Nisab tracks the gold/silver price and changes over time. '
                  'Update it to the current value from a trusted source.',
                  style: TextStyle(
                      fontSize: 11, color: AppColors.muted, height: 1.5)),
              const SizedBox(height: 10),
              _field(_nisab, 'Nisab value', Icons.trending_up),
              const SizedBox(height: 20),
              _resultCard(text),
              const SizedBox(height: 14),
              const Text(
                'This is an estimate to help you plan. For rulings on your '
                'specific situation, please consult a qualified scholar.',
                style: TextStyle(
                    fontSize: 11, color: AppColors.muted2, height: 1.5),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _resultCard(TextTheme text) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x1FD4A843), Color(0x142563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x4DD4A843)),
      ),
      child: Column(
        children: [
          _resultRow('Total assets', '${_uzs(_assets)} UZS'),
          const SizedBox(height: 8),
          _resultRow('Less debts', '− ${_uzs(_val(_debts))} UZS'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.border, height: 1),
          ),
          _resultRow('Net zakatable wealth', '${_uzs(_net)} UZS', bold: true),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _meetsNisab
                  ? const Color(0x12169A4A)
                  : const Color(0x14000000),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _meetsNisab
                      ? const Color(0x33169A4A)
                      : AppColors.border),
            ),
            child: Row(
              children: [
                Icon(
                    _meetsNisab
                        ? Icons.check_circle_outline
                        : Icons.info_outline,
                    size: 16,
                    color: _meetsNisab
                        ? const Color(0xFF86EFAC)
                        : AppColors.muted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _meetsNisab
                        ? 'Your wealth meets nisab — zakat is due.'
                        : 'Your wealth is below nisab — no zakat is due.',
                    style: TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color: _meetsNisab
                            ? const Color(0xFF86EFAC)
                            : AppColors.muted),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Column(
            children: [
              const Text('Zakat due (2.5%)',
                  style: TextStyle(fontSize: 12, color: AppColors.muted)),
              const SizedBox(height: 4),
              Text('${_uzs(_zakatDue)} UZS',
                  style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: AppColors.g0)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
                color: AppColors.white)),
        Text(value,
            style: TextStyle(
                fontSize: bold ? 15 : 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: bold ? AppColors.b3 : AppColors.white)),
      ],
    );
  }

  Widget _sectionLabel(String s) {
    return Text(s,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.b3,
            letterSpacing: 0.3));
  }

  Widget _field(TextEditingController c, String hint, IconData icon) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      onChanged: (_) => setState(() {}),
      style: const TextStyle(color: AppColors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.muted2, fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: AppColors.muted),
        filled: true,
        fillColor: AppColors.n3,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.g0),
        ),
      ),
    );
  }
}
