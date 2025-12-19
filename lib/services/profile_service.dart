import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/config.dart';
import 'token_service.dart';

class ProfileService {
  static Future<Map<String, dynamic>?> fetchProfile() async {
    try {
      final token = await TokenService.getAccessToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/users/me'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      if (response.statusCode == 401) {
        await TokenService.clear();
        return null;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateProfile({
    required Map<String, dynamic> data,
  }) async {
    try {
      final token = await TokenService.getAccessToken();
      if (token == null) return false;

      final response = await http.put(
        Uri.parse('${Config.baseUrl}/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
