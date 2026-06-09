import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/campaign.dart';
import '../models/donor.dart';
import 'auth_store.dart';

/// Talks to the Saxovat FastAPI backend.
class ApiClient {
  static const String baseUrl = 'http://localhost:8000';

  // ── System ────────────────────────────────────────────
  static Future<Map<String, dynamic>> checkHealth() async {
    final response = await http.get(Uri.parse('$baseUrl/health'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Backend returned status ${response.statusCode}');
  }

  // ── Campaigns ─────────────────────────────────────────
  static Future<List<Campaign>> fetchCampaigns({
    String? category,
    int skip = 0,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'skip': '$skip',
      'limit': '$limit',
      if (category != null) 'category': category,
    };
    final uri = Uri.parse('$baseUrl/api/v1/campaigns/public')
        .replace(queryParameters: params);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load campaigns (status ${response.statusCode})');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final items = body['items'] as List<dynamic>;
    return items
        .map((e) => Campaign.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Donor auth ────────────────────────────────────────

  /// Extracts a human-readable message from a FastAPI error response.
  static String _errorMessage(http.Response r, String fallback) {
    try {
      final body = jsonDecode(r.body);
      final detail = body['detail'];
      if (detail is String) return detail;
      if (detail is List && detail.isNotEmpty) {
        // 422 validation errors come as a list of {msg, loc, ...}
        return detail.first['msg']?.toString() ?? fallback;
      }
    } catch (_) {}
    return fallback;
  }

  /// POST /api/v1/donor/auth/register — stores the session on success.
  static Future<void> register({
    required String email,
    required String fullName,
    required String password,
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/donor/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'full_name': fullName,
        'password': password,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      }),
    );
    if (response.statusCode == 200) {
      _saveSession(response.body);
      return;
    }
    throw Exception(_errorMessage(response, 'Registration failed'));
  }

  /// POST /api/v1/donor/auth/login — stores the session on success.
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/donor/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200) {
      _saveSession(response.body);
      return;
    }
    throw Exception(_errorMessage(response, 'Incorrect email or password'));
  }

  /// Parses a DonorTokenResponse body and saves it into AuthStore.
  static void _saveSession(String responseBody) {
    final body = jsonDecode(responseBody) as Map<String, dynamic>;
    AuthStore.instance.setSession(
      access: body['access_token'] as String,
      refresh: body['refresh_token'] as String,
      donorProfile: Donor.fromJson(body['donor'] as Map<String, dynamic>),
    );
  }
}