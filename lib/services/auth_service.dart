import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/config.dart';
import 'token_service.dart';

class AuthService {
  /// 📩 SEND OTP
  static Future<bool> sendOtp({required String phone}) async {
    try {
      final response = await http.post(
        Uri.parse("${Config.baseUrl}/auth/send-otp"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Send OTP failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Send OTP error: $e");
      return false;
    }
  }

  /// ✅ VERIFY OTP
  static Future<bool> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${Config.baseUrl}/auth/verify-otp"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone': phone, 'otp': otp}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Verify OTP failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Verify OTP error: $e");
      return false;
    }
  }

  /// 🔐 LOGIN
  static Future<bool> login({
    String? email,
    String? phone,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${Config.baseUrl}/auth/login"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await TokenService.saveTokens(
          data['access_token'],
          data['refresh_token'],
        );
        return true;
      } else {
        print("Login failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }

  /// 📝 REGISTER
  static Future<bool> register({
    required String name,
    required String phone,
    required String district,
    String? email,
    String? state,

    String? crops,
    String? farmerType,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("${Config.baseUrl}/auth/register"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'phone': phone,
          'email': email,
          'state': state,
          'district': district ?? 'unknown',
          'crops': crops,
          'farmerType': farmerType,
          'password': password,
          'confirm_password': password,
        }),
      );

      print("REGISTER STATUS: ${response.statusCode}");
      print("REGISTER BODY: ${response.body}");
      print("DISTRICT SENT TO API => '$district'");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        await TokenService.saveTokens(
          data['access_token'],
          data['refresh_token'],
        );

        return true;
      } else {
        print("Registration failed: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Registration error: $e");
      return false;
    }
  }

  /// ✅ CHECK LOGIN
  static Future<bool> isLoggedIn() async {
    final token = await TokenService.getAccessToken();
    return token != null;
  }

  /// 🚪 LOGOUT
  static Future<void> logout() async {
    await TokenService.clear();
  }
}
