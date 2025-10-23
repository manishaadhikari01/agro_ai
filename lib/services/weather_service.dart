import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';
import '../utils/config.dart';

class WeatherService {
  // Using mock data for demonstration since API integration might have issues
  // In production, replace with your backend API or OpenWeatherMap

  // Fetch current weather and forecast data
  static Future<WeatherData?> fetchWeatherData({
    String? location,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Return mock data to ensure UI works
      return _getMockWeatherData(location ?? 'Delhi');
    } catch (e) {
      print('Error fetching weather data: $e');
      return null;
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
    return fetchWeatherData(location: location);
  }

  // Fetch weather data using coordinates
  static Future<WeatherData?> fetchWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    return fetchWeatherData(latitude: latitude, longitude: longitude);
  }

  // Get weather alerts or warnings (mock implementation)
  static Future<List<String>?> fetchWeatherAlerts(String location) async {
    // Return alerts randomly for demo
    final mockAlerts = [
      'Heavy rainfall expected in the next 24 hours',
      'Strong winds advisory for coastal areas',
      'Heat wave warning - stay hydrated',
    ];

    // Return alerts randomly for demo
    if (DateTime.now().millisecondsSinceEpoch % 3 == 0) {
      return [
        mockAlerts[DateTime.now().millisecondsSinceEpoch % mockAlerts.length],
      ];
    }

    return [];
  }

  // Get agricultural weather recommendations based on crops
  static Future<Map<String, dynamic>?> fetchCropWeatherRecommendations(
    String cropType,
    WeatherData weatherData,
  ) async {
    // Mock recommendations based on weather conditions
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
      recommendations['actions'] = 'Cover crops, delay harvesting if necessary';
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
