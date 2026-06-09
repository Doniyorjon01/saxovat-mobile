import 'dart:convert';
import 'package:http/http.dart' as http;

/// Talks to the Saxovat FastAPI backend.
class ApiClient {
  // Flutter WEB in Chrome on the same machine reaches the backend directly.
  //
  // (When we move to an Android emulator later this becomes
  //  http://10.0.2.2:8000 , and a physical phone uses your PC's LAN IP.
  //  We'll handle that in the Android step — leave this as-is for now.)
  static const String baseUrl = 'http://localhost:8000';

  /// Calls GET /health and returns the parsed JSON.
  static Future<Map<String, dynamic>> checkHealth() async {
    final response = await http.get(Uri.parse('$baseUrl/health'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception('Backend returned status ${response.statusCode}');
  }
}