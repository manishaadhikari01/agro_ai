import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/config.dart';
import 'token_service.dart';

class GovtDataService {
  /// Fetch live mandi prices for a single crop for the logged‑in user.
  ///
  /// Backend: POST /govt/live-mandi
  /// Body: { "crops": [crop], "limit_mandis": limitMandis }
  /// Returns the decoded JSON map on success, or null on failure/unauthenticated.
  static Future<Map<String, dynamic>?> fetchLiveMandiForCrop(
    String crop, {
    int limitMandis = 5,
  }) async {
    try {
      final token = await TokenService.getAccessToken();
      if (token == null) return null;

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/govt/live-mandi'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'crops': [crop],
          'limit_mandis': limitMandis,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }

      // Optionally log for debugging
      // ignore: avoid_print
      print(
        'Live mandi request failed: ${response.statusCode} ${response.body}',
      );
      return null;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching live mandi prices: $e');
      return null;
    }
  }
}
