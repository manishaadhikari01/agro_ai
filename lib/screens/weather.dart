import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/weather_controller.dart';
import '../controllers/auth_controller.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _locationController = TextEditingController();
  bool _isLocationSet = false;

  @override
  void initState() {
    super.initState();
    _initializeWeather();
  }

  Future<void> _initializeWeather() async {
    final weatherController = Provider.of<WeatherController>(
      context,
      listen: false,
    );
    final authController = Provider.of<AuthController>(context, listen: false);

    // Try to get user's location from profile or use default
    String location = 'Delhi'; // Default location

    if (authController.currentUser?.state != null) {
      location = authController.currentUser!.state!;
    }

    _locationController.text = location;
    await weatherController.fetchWeatherByLocation(location);
    setState(() {
      _isLocationSet = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final weatherController = Provider.of<WeatherController>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Weather'),
        backgroundColor: const Color(0xFF0A2216),
        foregroundColor: const Color(0xFFE0E7C8),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: weatherController.isLoading ? null : _refreshWeather,
          ),
        ],
      ),
      body: SafeArea(
        child:
            weatherController.isLoading && !_isLocationSet
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location Input
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Location',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _locationController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter location',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed:
                                        weatherController.isLoading
                                            ? null
                                            : _fetchWeatherByLocation,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0A2216),
                                      foregroundColor: const Color(0xFFE0E7C8),
                                    ),
                                    child:
                                        weatherController.isLoading
                                            ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : const Text('Get Weather'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Error Message
                      if (weatherController.errorMessage != null)
                        Card(
                          color: Colors.red.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.red),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    weatherController.errorMessage!,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: weatherController.clearError,
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Current Weather Card
                      if (weatherController.weatherData != null) ...[
                        Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Current Weather',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      weatherController.getWeatherIcon(
                                        weatherController
                                            .weatherData!
                                            .current
                                            .condition,
                                      ),
                                      size: 32,
                                      color: weatherController
                                          .getWeatherConditionColor(
                                            weatherController
                                                .weatherData!
                                                .current
                                                .condition,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${weatherController.formatTemperature(weatherController.weatherData!.current.temperature)}, ${weatherController.weatherData!.current.condition}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Location: ${weatherController.weatherData!.current.location}',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Humidity: ${weatherController.weatherData!.current.humidity}%',
                                    ),
                                    Text(
                                      'Rainfall: ${weatherController.weatherData!.current.rainfall}mm',
                                    ),
                                    Text(
                                      'Wind: ${weatherController.weatherData!.current.windSpeed} km/h',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Weather Alerts
                        if (weatherController.weatherAlerts != null &&
                            weatherController.weatherAlerts!.isNotEmpty) ...[
                          Card(
                            color: Colors.orange.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.warning, color: Colors.orange),
                                      SizedBox(width: 8),
                                      Text(
                                        'Weather Alerts',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ...weatherController.weatherAlerts!.map(
                                    (alert) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 4.0,
                                      ),
                                      child: Text(
                                        '• $alert',
                                        style: const TextStyle(
                                          color: Colors.orange,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Forecast
                        const Text(
                          '3-Day Forecast',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount:
                              weatherController.weatherData!.forecast.length,
                          itemBuilder: (context, index) {
                            final forecast =
                                weatherController.weatherData!.forecast[index];
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ListTile(
                                leading: Icon(
                                  weatherController.getWeatherIcon(
                                    forecast.condition,
                                  ),
                                  color: weatherController
                                      .getWeatherConditionColor(
                                        forecast.condition,
                                      ),
                                ),
                                title: Text(forecast.day),
                                subtitle: Text(forecast.condition),
                                trailing: Text(
                                  weatherController.formatTemperature(
                                    forecast.temperature,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),

                        // Crop Recommendations
                        if (weatherController.cropRecommendations != null) ...[
                          const SizedBox(height: 20),
                          const Text(
                            'Crop Recommendations',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Based on current weather: ${weatherController.cropRecommendations!['recommendation'] ?? 'No specific recommendations'}',
                                  ),
                                  if (weatherController
                                          .cropRecommendations!['actions'] !=
                                      null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Suggested actions: ${weatherController.cropRecommendations!['actions']}',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
      ),
    );
  }

  Future<void> _fetchWeatherByLocation() async {
    final location = _locationController.text.trim();
    if (location.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a location')));
      return;
    }

    final weatherController = Provider.of<WeatherController>(
      context,
      listen: false,
    );
    final success = await weatherController.fetchWeatherByLocation(location);

    if (success) {
      // Also fetch alerts and recommendations
      await weatherController.fetchWeatherAlerts(location);

      // Fetch recommendations if user has crops
      final authController = Provider.of<AuthController>(
        context,
        listen: false,
      );
      if (authController.currentUser?.crops != null) {
        await weatherController.fetchCropRecommendations(
          authController.currentUser!.crops!,
        );
      }
    }
  }

  Future<void> _refreshWeather() async {
    final weatherController = Provider.of<WeatherController>(
      context,
      listen: false,
    );
    await weatherController.refreshWeather();
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }
}
