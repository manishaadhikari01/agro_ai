import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/config.dart';

class ChatbotService {
  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/chat'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
          // 'Authorization': 'Bearer your-token',
        },
        body: jsonEncode({
          "user_id": "demo_user", // ← Added this (OPTION A dummy user)
          "query": message,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['answer'] ?? 'Sorry, I couldn\'t understand that.';
      } else {
        return 'Sorry, I\'m having trouble connecting right now. Please try again later.';
      }
    } catch (e) {
      return 'Sorry, I\'m having trouble connecting right now. Please try again later.';
    }
  }

  // Method to get chat history if your backend supports it
  static Future<List<Map<String, String>>> getChatHistory() async {
    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/chat/history'),
        headers: {
          // Add authentication headers if needed
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['answer'] ?? 'No answer from backend.';
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
