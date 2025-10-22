import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
  static const String baseUrl =
      'https://your-backend-api.com'; // Replace with your actual backend URL

  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
          // 'Authorization': 'Bearer your-token',
        },
        body: jsonEncode({
          'message': message,
          // Add any additional parameters your backend expects
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'Sorry, I couldn\'t understand that.';
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
        Uri.parse('$baseUrl/chat/history'),
        headers: {
          // Add authentication headers if needed
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, String>>.from(data['history'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
