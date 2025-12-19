import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/config.dart';
import 'token_service.dart';

class ChatbotService {
  /// 🔹 SEND MESSAGE
  static Future<String> sendMessage(String message) async {
    try {
      final token = await TokenService.getAccessToken();

      // 🔐 Block unauthenticated users
      if (token == null) {
        return '__AUTH_REQUIRED__';
      }

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"query": message}),
      );

      // class ChatbotService {
      //   static Future<String> sendMessage(String message) async {
      //     try {
      //       final response = await http.post(
      //         Uri.parse('${Config.baseUrl}/chat'),
      //         headers: {
      //           'Content-Type': 'application/json',
      //           // Add authentication headers if needed
      //           // 'Authorization': 'Bearer your-token',
      //         },
      //         body: jsonEncode({
      //           "user_id": "demo_user", // ← Added this (OPTION A dummy user)
      //           "query": message,
      //         }),
      //       );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['answer'] ?? 'Sorry, I could not understand that.';
      }

      // 🔒 Token expired / invalid
      if (response.statusCode == 401) {
        await TokenService.clear();
        return '__SESSION_EXPIRED__';
      }

      return 'Something went wrong. Please try again.';
    } catch (e) {
      return 'Network error. Please try again.';
    }
  }

  /// 🔹 CHAT HISTORY (OPTIONAL)
  static Future<List<Map<String, String>>> getChatHistory() async {
    try {
      final token = await TokenService.getAccessToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/chat/history'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, String>>.from(data);
      }

      if (response.statusCode == 401) {
        await TokenService.clear();
        return [];
      }

      return [];
    } catch (e) {
      return [];
    }
  }
}
