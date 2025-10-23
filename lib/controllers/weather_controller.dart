import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

class WeatherController extends ChangeNotifier {
  WeatherData? _weatherData;
  List<String>? _weatherAlerts;
  Map<String, dynamic>? _cropRecommendations;
  bool _isLoading = false;
  String? _errorMessage;

  WeatherData? get weatherData => _weatherData;
  List<String>? get weatherAlerts => _weatherAlerts;
  Map<String, dynamic>? get cropRecommendations => _cropRecommendations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch weather data by location
  Future<bool> fetchWeatherByLocation(String location) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await WeatherService.fetchWeatherByLocation(location);
      if (data != null) {
        _weatherData = data;
        return true;
      } else {
        _errorMessage = 'Failed to fetch weather data';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch weather data by coordinates
  Future<bool> fetchWeatherByCoordinates(
    double latitude,
    double longitude,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await WeatherService.fetchWeatherByCoordinates(
        latitude,
        longitude,
      );
      if (data != null) {
        _weatherData = data;
        return true;
      } else {
        _errorMessage = 'Failed to fetch weather data';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch weather alerts
  Future<bool> fetchWeatherAlerts(String location) async {
    try {
      final alerts = await WeatherService.fetchWeatherAlerts(location);
      if (alerts != null) {
        _weatherAlerts = alerts;
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error fetching alerts: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Fetch crop-specific weather recommendations
  Future<bool> fetchCropRecommendations(String cropType) async {
    if (_weatherData == null) {
      _errorMessage = 'Weather data not available';
      return false;
    }

    try {
      final recommendations =
          await WeatherService.fetchCropWeatherRecommendations(
            cropType,
            _weatherData!,
          );
      if (recommendations != null) {
        _cropRecommendations = recommendations;
        return true;
      } else {
        _errorMessage = 'Failed to fetch recommendations';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error fetching recommendations: $e';
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Refresh weather data
  Future<bool> refreshWeather() async {
    if (_weatherData == null) return false;

    return fetchWeatherByLocation(_weatherData!.current.location);
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Get weather icon based on condition
  IconData getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Icons.wb_sunny;
      case 'partly cloudy':
      case 'cloudy':
        return Icons.cloud;
      case 'rainy':
      case 'rain':
        return Icons.grain;
      case 'stormy':
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snowy':
      case 'snow':
        return Icons.ac_unit;
      default:
        return Icons.wb_cloudy;
    }
  }

  // Format temperature
  String formatTemperature(double temperature) {
    return '${temperature.round()}°C';
  }

  // Get weather condition color
  Color getWeatherConditionColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return Colors.orange;
      case 'partly cloudy':
        return Colors.blueGrey;
      case 'cloudy':
        return Colors.grey;
      case 'rainy':
      case 'rain':
        return Colors.blue;
      case 'stormy':
      case 'thunderstorm':
        return Colors.purple;
      case 'snowy':
      case 'snow':
        return Colors.lightBlue;
      default:
        return Colors.grey;
    }
  }
}
