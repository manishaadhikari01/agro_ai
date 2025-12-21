import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/config.dart';
import 'token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();

        // SAVE LOCATION FIELDS
        if (data['state'] != null) {
          prefs.setString('state', data['state']);
        }
        if (data['district'] != null) {
          prefs.setString('district', data['district']);
        }
        if (data['address'] != null) {
          prefs.setString('address', data['address']);
        }

        return data;
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

  static Future<Map<String, String?>> getLocation() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'state': prefs.getString('state'),
      'district': prefs.getString('district'),
      'address': prefs.getString('address'),
    };
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
