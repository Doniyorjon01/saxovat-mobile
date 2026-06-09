import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../theme/app_colors.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  String _status = 'Not connected yet';
  bool _ok = false;
  bool _loading = false;

  Future<void> _check() async {
    setState(() { _loading = true; _status = 'Connecting...'; });
    try {
      final data = await ApiClient.checkHealth();
      setState(() {
        _ok = true;
        _status = 'Connected!\n${data['app']} v${data['version']} '
            '(${data['env']})\nPartner: ${data['partner']}';
      });
    } catch (e) {
      setState(() {
        _ok = false;
        _status = 'Could not reach backend:\n$e';
      });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Sahovat', style: text.displayLarge),
                const SizedBox(height: 4),
                Text(
                  'Xayriya platformasi',
                  style: text.bodyMedium?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 32),

                // Status card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _ok ? Icons.check_circle : Icons.cloud_off,
                        size: 40,
                        color: _ok ? AppColors.emerald : AppColors.muted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _status,
                        textAlign: TextAlign.center,
                        style: text.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Primary emerald button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _check,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20, width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white,
                            ),
                          )
                        : const Text('Check backend connection'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}