import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Donor login / register. Auth is USERNAME-based; email is optional.
class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  final _username = TextEditingController();
  final _name = TextEditingController();
  final _password = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _username.dispose();
    _name.dispose();
    _password.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = null; });
    try {
      if (_isLogin) {
        await ApiClient.login(
          username: _username.text.trim(),
          password: _password.text,
        );
      } else {
        await ApiClient.register(
          username: _username.text.trim(),
          fullName: _name.text.trim(),
          password: _password.text,
          email: _email.text.trim(),
          phone: _phone.text.trim(),
        );
      }
      if (!mounted) return;
      widget.onAuthenticated();
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
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
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.muted),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text('Sahovat', style: AppTheme.serif(size: 30)),
              const SizedBox(height: 4),
              Text(
                _isLogin ? 'Welcome back' : 'Create your account',
                style: text.bodyMedium?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 28),
              if (!_isLogin) ...[
                _field(_name, 'Full name', Icons.person_outline),
                const SizedBox(height: 12),
              ],
              _field(_username, 'Username', Icons.alternate_email),
              const SizedBox(height: 12),
              _field(_password, 'Password', Icons.lock_outline, obscure: true),
              if (!_isLogin) ...[
                const SizedBox(height: 12),
                _field(_email, 'Email (optional)', Icons.mail_outline,
                    keyboard: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _field(_phone, 'Phone (optional)', Icons.phone_outlined,
                    keyboard: TextInputType.phone),
                const SizedBox(height: 8),
                Text(
                  'Username: 3–32 chars, starts with a letter. '
                  'Password: 8+ chars with an uppercase letter and a digit.',
                  style: text.bodySmall,
                ),
              ],
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
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.b1,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(_isLogin ? 'Log in' : 'Create account',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _loading
                      ? null
                      : () => setState(() {
                            _isLogin = !_isLogin;
                            _error = null;
                          }),
                  child: RichText(
                    text: TextSpan(
                      style: text.bodyMedium?.copyWith(color: AppColors.muted),
                      children: [
                        TextSpan(
                            text: _isLogin
                                ? "Don't have an account? "
                                : 'Already have an account? '),
                        TextSpan(
                          text: _isLogin ? 'Register' : 'Log in',
                          style: const TextStyle(
                              color: AppColors.b3, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint, IconData icon,
      {bool obscure = false, TextInputType? keyboard}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      keyboardType: keyboard,
      style: const TextStyle(color: AppColors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.muted2, fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: AppColors.muted),
        filled: true,
        fillColor: AppColors.n3,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.b2),
        ),
      ),
    );
  }
}
