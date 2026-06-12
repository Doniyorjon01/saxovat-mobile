import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../api/auth_store.dart';
import '../api/require_auth.dart';
import '../models/donation_history_item.dart';
import '../models/donor.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/money.dart';
import '../widgets/relative_time.dart';
import 'change_password_screen.dart';

/// Profile tab (mockup Image 6). Shows the donor header, an Account section
/// (notifications toggle = local pref, language = local pref, privacy →
/// change password), giving history, and sign out.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  String? _error;
  Donor? _donor;
  List<DonationHistoryItem> _history = const [];

  // Local-only UI preferences (no backend pref store yet).
  bool _notificationsOn = true;
  String _language = "O'zbekcha";

  @override
  void initState() {
    super.initState();
    if (AuthStore.instance.isLoggedIn) {
      _load();
    } else {
      _loading = false;
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final donor = await ApiClient.fetchProfile();
      final history = await ApiClient.fetchDonationHistory(limit: 50);
      if (!mounted) return;
      setState(() {
        _donor = donor;
        _history = history;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  Future<void> _signIn() async {
    final ok = await ensureLoggedIn(context);
    if (ok && mounted) _load();
  }

  Future<void> _signOut() async {
    await ApiClient.logout();
    AuthStore.instance.clear();
    if (!mounted) return;
    setState(() {
      _donor = null;
      _history = const [];
    });
  }

  Future<void> _editProfile() async {
    final donor = _donor;
    if (donor == null) return;
    final nameCtrl = TextEditingController(text: donor.fullName);
    final phoneCtrl = TextEditingController(text: donor.phone ?? '');

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.n2,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        bool saving = false;
        String? err;
        return StatefulBuilder(
          builder: (ctx, setSheet) {
            Future<void> save() async {
              setSheet(() {
                saving = true;
                err = null;
              });
              try {
                final updated = await ApiClient.updateProfile(
                  fullName: nameCtrl.text.trim(),
                  phone: phoneCtrl.text.trim(),
                );
                if (!mounted) return;
                setState(() => _donor = updated);
                Navigator.of(ctx).pop();
              } catch (e) {
                setSheet(() =>
                    err = e.toString().replaceFirst('Exception: ', ''));
              } finally {
                setSheet(() => saving = false);
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Edit profile',
                      style: Theme.of(ctx).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  _sheetField(nameCtrl, 'Full name', Icons.person_outline),
                  const SizedBox(height: 12),
                  _sheetField(phoneCtrl, 'Phone', Icons.phone_outlined),
                  if (err != null) ...[
                    const SizedBox(height: 12),
                    Text(err!,
                        style: const TextStyle(
                            color: Color(0xFFFCA5A5), fontSize: 12)),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: saving ? null : save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.b1,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Save',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthStore.instance.isLoggedIn && _donor == null) {
      return _loggedOut(context);
    }
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.b2));
    }
    if (_error != null) {
      return _errorState(context);
    }

    final donor = _donor!;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          _header(context, donor),
          const SizedBox(height: 20),
          _badges(),
          const SizedBox(height: 24),
          _accountSection(context),
          const SizedBox(height: 24),
          _givingHistory(context),
          const SizedBox(height: 24),
          _signOutButton(),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────
  Widget _header(BuildContext context, Donor donor) {
    final initials = donor.fullName.trim().isNotEmpty
        ? donor.fullName.trim()[0].toUpperCase()
        : donor.username.isNotEmpty
            ? donor.username[0].toUpperCase()
            : '?';
    return Row(
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.b1, AppColors.t0],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.center,
          child: Text(initials, style: AppTheme.serif(size: 26)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(donor.fullName,
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(
                donor.email ?? '@${donor.username}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.muted),
              ),
              if (donor.createdAt != null) ...[
                const SizedBox(height: 2),
                Text('Member since ${monthYear(donor.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ],
          ),
        ),
        IconButton(
          onPressed: _editProfile,
          icon: const Icon(Icons.edit_outlined,
              size: 20, color: AppColors.b3),
        ),
      ],
    );
  }

  // ── Badges ──────────────────────────────────────────────
  // NOTE: backend has no donor verification / guardian field, so we show a
  // single neutral "Verified account" badge (a registered, authenticated
  // donor). The mockup's "ID verified" / "Guardian donor" need backend work.
  Widget _badges() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _badge('Verified account', Icons.verified_user_outlined, AppColors.b3),
      ],
    );
  }

  Widget _badge(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.n3,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: AppColors.white, fontSize: 12)),
        ],
      ),
    );
  }

  // ── Account section ─────────────────────────────────────
  Widget _accountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Account', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.n2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              SwitchListTile(
                value: _notificationsOn,
                onChanged: (v) => setState(() => _notificationsOn = v),
                activeColor: AppColors.b2,
                secondary: const Icon(Icons.notifications_outlined,
                    color: AppColors.muted, size: 20),
                title: const Text('Notifications',
                    style: TextStyle(color: AppColors.white, fontSize: 13)),
                subtitle: const Text('On this device',
                    style: TextStyle(color: AppColors.muted, fontSize: 11)),
              ),
              _divider(),
              ListTile(
                leading: const Icon(Icons.language_outlined,
                    color: AppColors.muted, size: 20),
                title: const Text('Language',
                    style: TextStyle(color: AppColors.white, fontSize: 13)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_language,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right,
                        color: AppColors.muted, size: 18),
                  ],
                ),
                onTap: _pickLanguage,
              ),
              _divider(),
              ListTile(
                leading: const Icon(Icons.lock_outline,
                    color: AppColors.muted, size: 20),
                title: const Text('Privacy & security',
                    style: TextStyle(color: AppColors.white, fontSize: 13)),
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.muted, size: 18),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen()),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickLanguage() async {
    // Local-only selector. Full translation is future work; this just records
    // the donor's preferred display language label for now.
    const options = ["O'zbekcha", "Русский", "English"];
    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.n2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            for (final o in options)
              ListTile(
                title: Text(o,
                    style: const TextStyle(
                        color: AppColors.white, fontSize: 14)),
                trailing: _language == o
                    ? const Icon(Icons.check, color: AppColors.b3, size: 18)
                    : null,
                onTap: () => Navigator.of(ctx).pop(o),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _language = picked);
  }

  // ── Giving history ──────────────────────────────────────
  Widget _givingHistory(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Giving history', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        if (_history.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.n2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text('No donations yet.',
                style: TextStyle(color: AppColors.muted, fontSize: 13)),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: AppColors.n2,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _history.length; i++) ...[
                  if (i > 0) _divider(),
                  _historyRow(_history[i]),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _historyRow(DonationHistoryItem d) {
    // Backend history carries no campaign title (only campaign_id), so we
    // surface intent + date + amount, which is what the API gives us.
    final intentLabel =
        d.intent.isNotEmpty ? '${d.intent[0].toUpperCase()}${d.intent.substring(1)}' : 'Donation';
    final when = d.completedAt ?? d.createdAt;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: AppColors.n3,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.volunteer_activism_outlined,
                size: 18, color: AppColors.b3),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(intentLabel,
                    style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(relativeTime(when),
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${formatUzs(d.amountTiyin)} UZS',
                  style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              if (d.status != 'completed') ...[
                const SizedBox(height: 2),
                Text(d.status,
                    style: const TextStyle(
                        color: AppColors.muted, fontSize: 10)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Sign out ────────────────────────────────────────────
  Widget _signOutButton() {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: _signOut,
        icon: const Icon(Icons.logout, size: 18, color: Color(0xFFFCA5A5)),
        label: const Text('Sign out',
            style: TextStyle(
                color: Color(0xFFFCA5A5),
                fontWeight: FontWeight.w600,
                fontSize: 14)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0x3DDC2626)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, thickness: 1, color: AppColors.border);

  // ── Logged-out / error states ───────────────────────────
  Widget _loggedOut(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_circle_outlined,
                  size: 56, color: AppColors.muted),
              const SizedBox(height: 16),
              Text('Your profile',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Log in to see your giving history, notifications and account settings.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.muted),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.b1,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Log in or register',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorState(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppColors.muted),
              const SizedBox(height: 16),
              Text(_error ?? 'Something went wrong',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.muted)),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: _load,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetField(
      TextEditingController c, String hint, IconData icon) {
    return TextField(
      controller: c,
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
