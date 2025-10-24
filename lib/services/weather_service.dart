import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../utils/config.dart';

class WeatherService {
  // Fetch current weather and forecast data from backend API
  static Future<WeatherData?> fetchWeatherData({
    String? location,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${Config.weatherEndpoint}/current?location=${location ?? 'Delhi'}',
        ),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
          // 'Authorization': 'Bearer your-token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherData.fromJson(data);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error fetching weather data: $e');
      // Fallback to mock data if API fails
      return _getMockWeatherData(location ?? 'Delhi');
    }
  }

  // Mock weather data for demonstration
  static WeatherData _getMockWeatherData(String location) {
    final now = DateTime.now();

    final current = CurrentWeather(
      temperature:
          28.0 + (now.millisecondsSinceEpoch % 10), // Vary temperature slightly
      condition:
          [
            'Sunny',
            'Cloudy',
            'Partly Cloudy',
            'Rainy',
          ][now.millisecondsSinceEpoch % 4],
      humidity: 60 + (now.millisecondsSinceEpoch % 20), // 60-80%
      rainfall: (now.millisecondsSinceEpoch % 5).toDouble(), // 0-4mm
      windSpeed: 5.0 + (now.millisecondsSinceEpoch % 10), // 5-15 km/h
      location: location,
    );

    final forecast = [
      Forecast(
        day: 'Tomorrow',
        temperature: current.temperature + 2,
        condition: 'Sunny',
        icon: '01d',
      ),
      Forecast(
        day: 'Day 3',
        temperature: current.temperature - 1,
        condition: 'Cloudy',
        icon: '02d',
      ),
      Forecast(
        day: 'Day 4',
        temperature: current.temperature + 1,
        condition: 'Partly Cloudy',
        icon: '03d',
      ),
    ];

    return WeatherData(current: current, forecast: forecast);
  }

  // Fetch weather data for a specific location
  static Future<WeatherData?> fetchWeatherByLocation(String location) async {
    try {
      final response = await http.get(
        Uri.parse('${Config.weatherEndpoint}/current?location=$location'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
          // 'Authorization': 'Bearer your-token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherData.fromJson(data);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error fetching weather by location: $e');
      return _getMockWeatherData(location);
    }
  }

  // Fetch weather data using coordinates
  static Future<WeatherData?> fetchWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${Config.weatherEndpoint}/current?lat=$latitude&lon=$longitude',
        ),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
          // 'Authorization': 'Bearer your-token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeatherData.fromJson(data);
      } else {
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      print('Error fetching weather by coordinates: $e');
      return _getMockWeatherData('Coordinates: $latitude, $longitude');
    }
  }

  // Get weather alerts or warnings from backend API
  static Future<List<String>?> fetchWeatherAlerts(String location) async {
    try {
      final response = await http.get(
        Uri.parse('${Config.weatherEndpoint}/alerts?location=$location'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
          // 'Authorization': 'Bearer your-token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['alerts'] ?? []);
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching weather alerts: $e');
      // Return mock alerts as fallback
      final mockAlerts = [
        'Heavy rainfall expected in the next 24 hours',
        'Strong winds advisory for coastal areas',
        'Heat wave warning - stay hydrated',
      ];

      if (DateTime.now().millisecondsSinceEpoch % 3 == 0) {
        return [
          mockAlerts[DateTime.now().millisecondsSinceEpoch % mockAlerts.length],
        ];
      }

      return [];
    }
  }

  // Get agricultural weather recommendations based on crops from backend API
  static Future<Map<String, dynamic>?> fetchCropWeatherRecommendations(
    String cropType,
    WeatherData weatherData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${Config.weatherEndpoint}/recommendations'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
          // 'Authorization': 'Bearer your-token',
        },
        body: jsonEncode({
          'cropType': cropType,
          'weatherData': weatherData.toJson(),
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to fetch recommendations');
      }
    } catch (e) {
      print('Error fetching crop recommendations: $e');
      // Fallback to mock recommendations
      final recommendations = <String, dynamic>{};

      final temp = weatherData.current.temperature;
      final humidity = weatherData.current.humidity;
      final condition = weatherData.current.condition.toLowerCase();

      if (temp > 35) {
        recommendations['recommendation'] =
            'High temperature detected. Consider irrigation and shade protection for $cropType.';
        recommendations['actions'] =
            'Increase watering frequency, provide shade netting';
      } else if (temp < 10) {
        recommendations['recommendation'] =
            'Low temperature detected. Protect $cropType from frost.';
        recommendations['actions'] =
            'Cover crops, delay harvesting if necessary';
      } else if (condition.contains('rain')) {
        recommendations['recommendation'] =
            'Rainy conditions detected. Monitor soil moisture for $cropType.';
        recommendations['actions'] = 'Check drainage, avoid over-watering';
      } else if (humidity > 80) {
        recommendations['recommendation'] =
            'High humidity detected. Watch for fungal diseases in $cropType.';
        recommendations['actions'] =
            'Apply fungicides if needed, improve air circulation';
      } else {
        recommendations['recommendation'] =
            'Weather conditions are favorable for $cropType growth.';
        recommendations['actions'] =
            'Continue regular maintenance and monitoring';
      }

      return recommendations;
    }
  }
}
