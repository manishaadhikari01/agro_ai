import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../utils/config.dart';

class AuthService {
  // User Registration
  static Future<bool> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? state,
    String? crops,
    String? farmerType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(Config.registerEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Config.apiKey}', // If API key is required
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'state': state,
          'crops': crops,
          'farmerType': farmerType,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Registration successful
        return true;
      } else {
        // Handle registration failure
        print('Registration failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during registration: $e');
      return false;
    }
  }

  // User Login
  static Future<Map<String, dynamic>?> loginUser(
    String phone,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(Config.loginEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Config.apiKey}', // If API key is required
        },
        body: jsonEncode({'phone': phone, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming the response contains user data and token
        return {'user': User.fromJson(data['user']), 'token': data['token']};
      } else {
        print('Login failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  // Forgot Password
  static Future<bool> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse(Config.forgotPasswordEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Config.apiKey}', // If API key is required
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        // Password reset request successful
        return true;
      } else {
        print('Forgot password failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error during forgot password: $e');
      return false;
    }
  }

  // Fetch User Data
  static Future<User?> fetchUserData(String userId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('${Config.userDataEndpoint}/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      } else {
        print('Failed to fetch user data: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  // Update User Data
  static Future<bool> updateUserData(
    String userId,
    String token,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('${Config.userDataEndpoint}/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(updates),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update user data: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating user data: $e');
      return false;
    }
  }
}
