class WeatherData {
  final CurrentWeather current;
  final List<Forecast> forecast;

  WeatherData({required this.current, required this.forecast});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      current: CurrentWeather.fromJson(json['current']),
      forecast:
          (json['forecast'] as List)
              .map((item) => Forecast.fromJson(item))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current': current.toJson(),
      'forecast': forecast.map((item) => item.toJson()).toList(),
    };
  }
}

class CurrentWeather {
  final double temperature;
  final String condition;
  final int humidity;
  final double rainfall;
  final double windSpeed;
  final String location;

  CurrentWeather({
    required this.temperature,
    required this.condition,
    required this.humidity,
    required this.rainfall,
    required this.windSpeed,
    required this.location,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: json['temperature'].toDouble(),
      condition: json['condition'],
      humidity: json['humidity'],
      rainfall: json['rainfall'].toDouble(),
      windSpeed: json['windSpeed'].toDouble(),
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'condition': condition,
      'humidity': humidity,
      'rainfall': rainfall,
      'windSpeed': windSpeed,
      'location': location,
    };
  }
}

class Forecast {
  final String day;
  final double temperature;
  final String condition;
  final String icon; // Could be a string representing the icon

  Forecast({
    required this.day,
    required this.temperature,
    required this.condition,
    required this.icon,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      day: json['day'],
      temperature: json['temperature'].toDouble(),
      condition: json['condition'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'temperature': temperature,
      'condition': condition,
      'icon': icon,
    };
  }
}
