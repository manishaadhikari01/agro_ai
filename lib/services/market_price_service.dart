import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/market_price_model.dart';
import 'token_service.dart';
import '../utils/config.dart';

class MarketPriceService {
  static Future<MarketPriceResponse> fetchPrices({
    required List<String> crops,
    int limitMandis = 5,
  }) async {
    final token = await TokenService.getAccessToken();

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/govt/live-mandi'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'crops': crops, 'limit_mandis': limitMandis}),
    );

    if (response.statusCode == 200) {
      return MarketPriceResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('API Error ${response.statusCode}: ${response.body}');
    }
  }
}
