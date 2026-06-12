import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/campaign.dart';
import '../models/donor.dart';
import '../models/donation_receipt.dart';
import '../models/donation_history_item.dart';
import '../models/notification_item.dart';
import 'auth_store.dart';

/// Talks to the Saxovat FastAPI backend. Donor auth is USERNAME-based.
class ApiClient {
  static const String baseUrl = 'http://localhost:8000';

  // ── System ────────────────────────────────────────────
  static Future<Map<String, dynamic>> checkHealth() async {
    final r = await http.get(Uri.parse('$baseUrl/health'));
    if (r.statusCode == 200) return jsonDecode(r.body) as Map<String, dynamic>;
    throw Exception('Backend returned status ${r.statusCode}');
  }

  // ── Headers / error helpers ───────────────────────────
  static Map<String, String> get _authHeaders {
    final token = AuthStore.instance.accessToken;
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static String _errorMessage(http.Response r, String fallback) {
    try {
      final body = jsonDecode(r.body);
      final detail = body['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        return detail.first['msg']?.toString() ?? fallback;
      }
    } catch (_) {}
    return fallback;
  }

  // ── Campaigns (public feed) ───────────────────────────
  static Future<List<Campaign>> fetchCampaigns({
    String? category,
    String? regionId,
    int skip = 0,
    int limit = 50,
  }) async {
    final params = <String, String>{
      'skip': '$skip',
      'limit': '$limit',
      if (category != null) 'category': category,
      if (regionId != null) 'region_id': regionId,
    };
    final uri = Uri.parse('$baseUrl/api/v1/campaigns/public')
        .replace(queryParameters: params);
    final r = await http.get(uri);
    if (r.statusCode != 200) {
      throw Exception('Failed to load campaigns (status ${r.statusCode})');
    }
    final body = jsonDecode(r.body) as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>;
    return items
        .map((e) => Campaign.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Donor auth (USERNAME-based) ───────────────────────
  /// POST /api/v1/donor/auth/register
  static Future<void> register({
    required String username,
    required String fullName,
    required String password,
    String? email,
    String? phone,
  }) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/v1/donor/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'full_name': fullName,
        'password': password,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      }),
    );
    if (r.statusCode == 200) {
      _saveSession(r.body);
      return;
    }
    throw Exception(_errorMessage(r, 'Registration failed'));
  }

  /// POST /api/v1/donor/auth/login
  static Future<void> login({
    required String username,
    required String password,
  }) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/v1/donor/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (r.statusCode == 200) {
      _saveSession(r.body);
      return;
    }
    throw Exception(_errorMessage(r, 'Incorrect username or password'));
  }

  /// POST /api/v1/donor/auth/logout (best-effort; ignores network errors)
  static Future<void> logout() async {
    final refresh = AuthStore.instance.refreshToken;
    if (refresh == null) return;
    try {
      await http.post(
        Uri.parse('$baseUrl/api/v1/donor/auth/logout'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refresh}),
      );
    } catch (_) {/* clearing locally is what matters */}
  }

  static void _saveSession(String responseBody) {
    final body = jsonDecode(responseBody) as Map<String, dynamic>;
    AuthStore.instance.setSession(
      access: body['access_token'] as String,
      refresh: body['refresh_token'] as String,
      donorProfile: Donor.fromJson(body['donor'] as Map<String, dynamic>),
    );
  }

  // ── Profile ───────────────────────────────────────────
  /// GET /api/v1/donor/me
  static Future<Donor> fetchProfile() async {
    final r = await http.get(Uri.parse('$baseUrl/api/v1/donor/me'),
        headers: _authHeaders);
    if (r.statusCode == 200) {
      return Donor.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
    }
    throw Exception(_errorMessage(r, 'Could not load profile'));
  }

  /// PATCH /api/v1/donor/me — update full_name / phone.
  static Future<Donor> updateProfile({String? fullName, String? phone}) async {
    final r = await http.patch(
      Uri.parse('$baseUrl/api/v1/donor/me'),
      headers: _authHeaders,
      body: jsonEncode({
        if (fullName != null) 'full_name': fullName,
        if (phone != null) 'phone': phone,
      }),
    );
    if (r.statusCode == 200) {
      final donor = Donor.fromJson(jsonDecode(r.body) as Map<String, dynamic>);
      // Keep the cached session profile fresh.
      final s = AuthStore.instance;
      if (s.accessToken != null && s.refreshToken != null) {
        s.setSession(
            access: s.accessToken!, refresh: s.refreshToken!, donorProfile: donor);
      }
      return donor;
    }
    throw Exception(_errorMessage(r, 'Could not update profile'));
  }

  /// POST /api/v1/donor/me/change-password
  static Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/v1/donor/me/change-password'),
      headers: _authHeaders,
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );
    if (r.statusCode == 200) return;
    throw Exception(_errorMessage(r, 'Could not change password'));
  }

  /// GET /api/v1/donor/me/donations
  static Future<List<DonationHistoryItem>> fetchDonationHistory({
    int skip = 0,
    int limit = 50,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/donor/me/donations')
        .replace(queryParameters: {'skip': '$skip', 'limit': '$limit'});
    final r = await http.get(uri, headers: _authHeaders);
    if (r.statusCode == 200) {
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      final items = body['items'] as List<dynamic>;
      return items
          .map((e) => DonationHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception(_errorMessage(r, 'Could not load donation history'));
  }

  // ── Notifications ─────────────────────────────────────
  /// GET /api/v1/donor/me/notifications → (items, unread, total)
  static Future<({List<NotificationItem> items, int unread, int total})>
      fetchNotifications({int skip = 0, int limit = 50, bool unreadOnly = false}) async {
    final uri = Uri.parse('$baseUrl/api/v1/donor/me/notifications').replace(
      queryParameters: {
        'skip': '$skip',
        'limit': '$limit',
        'unread_only': '$unreadOnly',
      },
    );
    final r = await http.get(uri, headers: _authHeaders);
    if (r.statusCode == 200) {
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      final items = (body['items'] as List<dynamic>)
          .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return (
        items: items,
        unread: (body['unread'] as num? ?? 0).toInt(),
        total: (body['total'] as num? ?? 0).toInt(),
      );
    }
    throw Exception(_errorMessage(r, 'Could not load notifications'));
  }

  /// POST /api/v1/donor/me/notifications/read-all
  static Future<void> markAllNotificationsRead() async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/v1/donor/me/notifications/read-all'),
      headers: _authHeaders,
    );
    if (r.statusCode == 200) return;
    throw Exception(_errorMessage(r, 'Could not update notifications'));
  }

  /// POST /api/v1/donor/me/notifications/{id}/read
  static Future<void> markNotificationRead(String id) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/v1/donor/me/notifications/$id/read'),
      headers: _authHeaders,
    );
    if (r.statusCode == 200) return;
    throw Exception(_errorMessage(r, 'Could not mark read'));
  }

  // ── Wallet ────────────────────────────────────────────
  /// GET /api/v1/donor/me/wallet → balance in tiyin.
  static Future<int> fetchWalletBalance() async {
    final r = await http.get(Uri.parse('$baseUrl/api/v1/donor/me/wallet'),
        headers: _authHeaders);
    if (r.statusCode == 200) {
      final body = jsonDecode(r.body) as Map<String, dynamic>;
      return (body['balance_tiyin'] as num).toInt();
    }
    throw Exception(_errorMessage(r, 'Could not load wallet balance'));
  }

  // ── Donate (from wallet) ──────────────────────────────
  /// POST /api/v1/donor/me/donate
  static Future<DonationReceipt> donate({
    required String campaignId,
    required int amountTiyin,
    int tipTiyin = 0,
    String intent = 'sadaqah',
    bool isAnonymous = true,
    String? donorName,
    String? message,
  }) async {
    final r = await http.post(
      Uri.parse('$baseUrl/api/v1/donor/me/donate'),
      headers: _authHeaders,
      body: jsonEncode({
        'campaign_id': campaignId,
        'amount_tiyin': amountTiyin,
        'tip_tiyin': tipTiyin,
        'intent': intent,
        'is_anonymous': isAnonymous,
        if (donorName != null && donorName.isNotEmpty) 'donor_name': donorName,
        if (message != null && message.isNotEmpty) 'message': message,
      }),
    );
    if (r.statusCode == 200) {
      return DonationReceipt.fromJson(
          jsonDecode(r.body) as Map<String, dynamic>);
    }
    throw Exception(_errorMessage(r, 'Donation failed'));
  }
}
