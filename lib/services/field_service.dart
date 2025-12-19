import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/field_model.dart';
import 'token_service.dart';
import '../utils/config.dart';

class FieldService {
  static Future<List<FieldModel>> getFields() async {
    final token = await TokenService.getAccessToken();

    final response = await http.get(
      Uri.parse('${Config.baseUrl}/fields'),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    print('STATUS CODE => ${response.statusCode}');
    print('RESPONSE BODY => ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => FieldModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load fields');
    }
  }

  static Future<void> createField({
    required String fieldName,
    required List<List<double>> coordinates,
    required String cropType,
    required String season,
  }) async {
    final token = await TokenService.getAccessToken();

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/fields'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "field_name": fieldName,
        "coordinates": coordinates,
        "crop_type": cropType.toLowerCase(),
        "season": season.toLowerCase(),
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create field');
    }
  }
}
