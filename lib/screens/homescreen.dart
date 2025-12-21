import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'disease_detection.dart';
import 'chatbot_screen.dart';
import 'gov_schemes_screen.dart';
import 'crop_recommendation.dart';
import 'market_crop_grid_screen.dart';
import 'voice_chat_screen.dart';
import '../services/profile_service.dart';
import 'package:video_player/video_player.dart';
import '../screens/fields_list_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = 'Farmer'; // Default name
  String currentDate = '';

  // Weather data
  String location = 'Dehradun';
  int temperature = 0;
  int humidity = 0;
  int windSpeed = 0;
  double precipitation = 0.0;
  String sunrise = '';
  String sunset = '';
  DateTime? sunriseTime;
  DateTime? sunsetTime;
  bool isLoadingWeather = true;

  // Video player
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  static const String API_KEY = "713ff79d2e664d33a9b151509251412";

  @override
  void initState() {
    super.initState();
    _loadUserName();
    _loadCurrentDate();
    _fetchWeatherData('Dehradun');
    _initializeVideo();
  }

  Future<void> _loadUserName() async {
    try {
      final profile = await ProfileService.fetchProfile();
      if (profile != null && profile['name'] != null) {
        setState(() {
          userName = profile['name'];
        });
      } else {
        // Fallback to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          userName = prefs.getString('userName') ?? 'Farmer';
        });
      }
    } catch (e) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        userName = prefs.getString('userName') ?? 'Farmer';
      });
    }
  }

  void _loadCurrentDate() {
    final now = DateTime.now();
    setState(() {
      currentDate = DateFormat('MMMM d, yyyy').format(now);
    });
  }

  Future<void> _fetchWeatherData(String searchText) async {
    setState(() {
      isLoadingWeather = true;
    });

    try {
      String searchWeatherAPI =
          "https://api.weatherapi.com/v1/forecast.json?key=$API_KEY&days=1&q=";

      var searchResult = await http.get(
        Uri.parse(searchWeatherAPI + searchText),
      );

      final weatherData = json.decode(searchResult.body);
      var locationData = weatherData['location'];
      var currentWeather = weatherData['current'];
      var forecastDay = weatherData['forecast']['forecastday'][0];
      var astro = forecastDay['astro'];

      // Parse sunrise and sunset times
      DateTime now = DateTime.now();
      DateTime? parsedSunrise;
      DateTime? parsedSunset;

      try {
        if (astro['sunrise'] != null) {
          sunrise = astro['sunrise'];
          List<String> sunriseParts = sunrise.split(':');
          int sunriseHour = int.parse(sunriseParts[0]);
          int sunriseMin = int.parse(sunriseParts[1].split(' ')[0]);
          if (sunrise.contains('PM') && sunriseHour != 12) sunriseHour += 12;
          if (sunrise.contains('AM') && sunriseHour == 12) sunriseHour = 0;
          parsedSunrise = DateTime(
            now.year,
            now.month,
            now.day,
            sunriseHour,
            sunriseMin,
          );
        }

        if (astro['sunset'] != null) {
          sunset = astro['sunset'];
          List<String> sunsetParts = sunset.split(':');
          int sunsetHour = int.parse(sunsetParts[0]);
          int sunsetMin = int.parse(sunsetParts[1].split(' ')[0]);
          if (sunset.contains('PM') && sunsetHour != 12) sunsetHour += 12;
          if (sunset.contains('AM') && sunsetHour == 12) sunsetHour = 0;
          parsedSunset = DateTime(
            now.year,
            now.month,
            now.day,
            sunsetHour,
            sunsetMin,
          );
        }
      } catch (e) {
        print('Error parsing sunrise/sunset: $e');
      }

      setState(() {
        location = locationData['name'] ?? searchText;
        temperature = currentWeather['temp_c']?.toInt() ?? 0;
        humidity = currentWeather['humidity']?.toInt() ?? 0;
        windSpeed = currentWeather['wind_kph']?.toInt() ?? 0;
        precipitation = forecastDay['day']['totalprecip_mm']?.toDouble() ?? 0.0;
        sunriseTime = parsedSunrise;
        sunsetTime = parsedSunset;
        isLoadingWeather = false;
      });
    } catch (e) {
      print('Error fetching weather: $e');
      setState(() {
        isLoadingWeather = false;
      });
    }
  }

  void _initializeVideo() {
    // Local video file from assets
    _videoController = VideoPlayerController.asset('lib/assets/tutorial.mp4')
      ..initialize()
          .then((_) {
            setState(() {
              _isVideoInitialized = true;
            });
          })
          .catchError((error) {
            print('Error initializing video: $error');
            // If video fails to load, we'll show a placeholder
          });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Dark green header with rounded bottom corners and background image
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: Stack(
                    children: [
                      // Background image with increased opacity
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.95,
                          child: Image.asset(
                            'lib/assets/home.jpg',
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color.fromARGB(152, 43, 87, 25),
                              );
                            },
                          ),
                        ),
                      ),
                      // Green tint overlay (reduced opacity to show more of the image)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A2216).withOpacity(0.5),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 30, 20, 120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // DeepShiva title
                            const Text(
                              'DeepShiva',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hello, $userName',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currentDate,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Weather card that overlaps the header
              Transform.translate(
                offset: const Offset(0, -20),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Background image based on time
                        Positioned.fill(
                          child: Image.asset(
                            _getWeatherBackgroundImage(),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(color: const Color(0xFF0A2216));
                            },
                          ),
                        ),
                        // Dark overlay for better text readability
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.3),
                                  Colors.black.withOpacity(0.5),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child:
                              isLoadingWeather
                                  ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(20.0),
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                  : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            color: Colors.white,
                                            size: 28,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            location,
                                            style: const TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          _buildWeatherItem(
                                            Icons.thermostat,
                                            '$temperature°C',
                                            'Temperature',
                                          ),
                                          _buildWeatherItem(
                                            Icons.water_drop,
                                            '$humidity%',
                                            'Humidity',
                                          ),
                                          _buildWeatherItem(
                                            Icons.air,
                                            '$windSpeed km/h',
                                            'Wind',
                                          ),
                                          _buildWeatherItem(
                                            Icons.cloud,
                                            '${precipitation.toStringAsFixed(1)} mm',
                                            'Precipitation',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Feature Cards Grid (3 columns)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.85,
                  children: [
                    _buildFeatureCard(
                      'Disease Detection',
                      Icons.camera_alt,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const DiseaseDetectionScreen(),
                          ),
                        );
                      },
                    ),
                    _buildFeatureCard('Crop Recommendation', Icons.eco, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => const CropRecommendationScreen(),
                        ),
                      );
                    }),
                    _buildFeatureCard('AI Chatbot', Icons.chat, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatbotScreen(),
                        ),
                      );
                    }),
                    _buildFeatureCard(
                      'Government Schemes',
                      Icons.account_balance,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GovSchemesScreen(),
                          ),
                        );
                      },
                    ),
                    _buildFeatureCard('Market Prices', Icons.trending_up, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MarketCropGridScreen(),
                        ),
                      );
                    }),
                    _buildFeatureCard('Voice Chat', Icons.mic, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const VoiceChatScreen(),
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Video Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child:
                        _isVideoInitialized && _videoController != null
                            ? Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox.expand(
                                  child: FittedBox(
                                    fit: BoxFit.cover,
                                    child: SizedBox(
                                      width: _videoController!.value.size.width,
                                      height:
                                          _videoController!.value.size.height,
                                      child: VideoPlayer(_videoController!),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 10,
                                  left: 10,
                                  right: 10,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'How to use DeepShiva',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            _videoController!.value.isPlaying
                                                ? Icons.pause
                                                : Icons.play_arrow,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              if (_videoController!
                                                  .value
                                                  .isPlaying) {
                                                _videoController!.pause();
                                              } else {
                                                _videoController!.play();
                                              }
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                            : Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.video_library,
                                      size: 48,
                                      color: Color(0xFF0A2216),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'How to use DeepShiva',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0A2216),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // My Fields Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FieldsListScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            'lib/assets/fieldhealth.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF0A2216),
                                child: const Center(
                                  child: Icon(
                                    Icons.agriculture,
                                    size: 64,
                                    color: Color(0xFFE0E7C8),
                                  ),
                                ),
                              );
                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                          const Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Text(
                              'Field Health',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  String _getWeatherBackgroundImage() {
    if (sunriseTime == null || sunsetTime == null) {
      return 'lib/assets/sunny.jpg';
    }

    DateTime now = DateTime.now();
    DateTime currentTime = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute,
    );

    // Check if it's before sunrise (night)
    if (currentTime.isBefore(sunriseTime!)) {
      return 'lib/assets/cold.jpg'; // Night
    }
    // Check if it's after sunset (night)
    else if (currentTime.isAfter(sunsetTime!)) {
      return 'lib/assets/cold.jpg'; // Night
    }
    // Check if it's within 1 hour of sunrise (sunrise time)
    else if (currentTime.difference(sunriseTime!).inMinutes <= 60) {
      return 'lib/assets/hot.jpg'; // Sunrise
    }
    // Check if it's within 1 hour of sunset (sunset time)
    else if (sunsetTime!.difference(currentTime).inMinutes <= 60) {
      return 'lib/assets/hot.jpg'; // Sunset
    }
    // Daytime
    else {
      return 'lib/assets/sunny.jpg'; // Day
    }
  }

  Widget _buildWeatherItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.white70),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36, color: const Color(0xFF0A2216)),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0A2216),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
