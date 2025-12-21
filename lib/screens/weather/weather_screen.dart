import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'package:agroai/screens/weather/widgets/constant.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:agroai/screens/weather/detail_page.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  final Constants _constants = Constants();

  @override
  void initState() {
    super.initState();
    fetchWeatherData('Dehradun');
  }

  static const String API_KEY = "713ff79d2e664d33a9b151509251412";

  String location = 'Dehradun';
  String weatherIcon = 'assests/heavycloudy.png';
  int temperature = 0;
  int hightemp = 0;
  int lowtemp = 0;
  int windSpeed = 0;
  int cloud = 0;
  int humidity = 0;
  String currentDate = '';
  String currentDay = '';
  String currentTime = '';

  List hourlyWeatherForecast = [];
  List dailyWeatherForecast = [];

  String currentWeatherStatus = '';

  // Weather icon mapping
  String getWeatherIcon(String condition) {
    String lowerCondition = condition.toLowerCase();
    if (lowerCondition.contains('sunny') || lowerCondition.contains('clear')) {
      return 'sunny';
    } else if (lowerCondition.contains('partly cloudy') ||
        lowerCondition.contains('partly')) {
      return 'cloudyandsun';
    } else if (lowerCondition.contains('cloudy') ||
        lowerCondition.contains('overcast')) {
      return 'cloudy';
    } else if (lowerCondition.contains('heavy rain') ||
        lowerCondition.contains('heavy')) {
      return 'rainy';
    } else if (lowerCondition.contains('rain') ||
        lowerCondition.contains('drizzle') ||
        lowerCondition.contains('shower')) {
      return 'rain';
    } else if (lowerCondition.contains('snow') ||
        lowerCondition.contains('blizzard')) {
      return 'snow';
    } else if (lowerCondition.contains('thunder') ||
        lowerCondition.contains('lightning')) {
      return 'thunderstrom';
    } else if (lowerCondition.contains('storm') ||
        lowerCondition.contains('tornado')) {
      return 'strom';
    } else if (lowerCondition.contains('sun and rain') ||
        lowerCondition.contains('sunrain')) {
      return 'sunandrain';
    } else {
      return 'cloudy'; // default
    }
  }

  //api call
  String searchWeatherAPI =
      "https://api.weatherapi.com/v1/forecast.json?key=$API_KEY&days=7&q=";

  void fetchWeatherData(String searchText) async {
    try {
      var searchResult = await http.get(
        Uri.parse(searchWeatherAPI + searchText),
      );

      final weatherData = json.decode(searchResult.body);

      var locationData = weatherData['location'];
      var currentWeather = weatherData['current'];

      setState(() {
        location = getShortLocationName(locationData['name']);

        var parsedDate = DateTime.parse(locationData["localtime"]);
        var newDate = DateFormat('MMMM d').format(parsedDate);
        currentDate = newDate;
        currentDay = DateFormat('EEEE').format(parsedDate);
        currentTime = DateFormat('HH:mm').format(parsedDate);

        //update Weather
        currentWeatherStatus = currentWeather['condition']['text'];
        weatherIcon = currentWeatherStatus.replaceAll(' ', '').toLowerCase();
        temperature = currentWeather['temp_c'].toInt();
        humidity = currentWeather['humidity'].toInt();
        windSpeed = currentWeather['wind_kph'].toInt();
        cloud = currentWeather['cloud'].toInt();

        //hourly weather
        dailyWeatherForecast = weatherData['forecast']['forecastday'];
        hourlyWeatherForecast = dailyWeatherForecast[0]['hour'];
        hightemp = dailyWeatherForecast[0]['day']['maxtemp_c'].toInt();
        lowtemp = dailyWeatherForecast[0]['day']['mintemp_c'].toInt();
        print(dailyWeatherForecast);
      });
    } catch (e) {
      print(e);
    }
  }

  //function to get location name

  static String getShortLocationName(String s) {
    List<String> wordList = s.split(' ');

    if (wordList.isNotEmpty) {
      if (wordList.length > 1) {
        return wordList[0] + ' ' + wordList[1];
      } else {
        return wordList[0];
      }
    } else {
      return " ";
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // Determine background based on temperature (convert F to C)
    String backgroundImage =
        temperature < 20
            ? 'lib/screens/weather/assests/cold.jpeg'
            : 'lib/screens/weather/assests/hot.jpeg';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Header Section
                  const SizedBox(height: 80),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        location,
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w500,
                          color: _constants.primaryTextColor,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          _cityController.clear();
                          showModalBottomSheet(
                            context: context,
                            builder:
                                (context) => SingleChildScrollView(
                                  controller: ModalScrollController.of(context),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        TextField(
                                          onChanged: (searchText) {
                                            fetchWeatherData(
                                              _cityController.text,
                                            );
                                          },
                                          controller: _cityController,
                                          decoration: const InputDecoration(
                                            hintText: 'Enter city name',
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        ElevatedButton(
                                          onPressed: () {
                                            fetchWeatherData(
                                              _cityController.text,
                                            );
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Search'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          );
                        },
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: _constants.blackColor,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),
                  Text(
                    "$currentDay, $currentDate $currentTime",
                    style: TextStyle(
                      fontSize: 16,
                      color: _constants.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 50),
                  Text(
                    currentWeatherStatus,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: _constants.primaryTextColor,
                    ),
                  ),
                  // Main Temperature
                  Text(
                    "${temperature}°C",
                    style: TextStyle(
                      fontSize: 100,
                      fontWeight: FontWeight.w300,
                      color: _constants.primaryTextColor,
                    ),
                  ),

                  Text(
                    'H: ${hightemp}°C  L: ${lowtemp}°C',
                    style: TextStyle(
                      fontSize: 20,
                      color: _constants.secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // Glassmorphism Metrics Card
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          color: _constants.tertiaryColor.withOpacity(0.5),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Precipitation
                            Column(
                              children: [
                                Image.asset(
                                  'lib/screens/weather/assests/rain.png',
                                  width: 40,
                                  height: 40,
                                  color: _constants.primaryTextColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$cloud%',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: _constants.primaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                            // Humidity
                            Column(
                              children: [
                                Image.asset(
                                  'lib/screens/weather/assests/humidity.png',
                                  width: 40,
                                  height: 40,
                                  color: _constants.primaryTextColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "$humidity%",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: _constants.primaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                            // Wind
                            Column(
                              children: [
                                Image.asset(
                                  'lib/screens/weather/assests/wind.png',
                                  width: 40,
                                  height: 40,
                                  color: _constants.primaryTextColor,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "${windSpeed}km/h",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: _constants.primaryTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // daily Forecast Button
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: GestureDetector(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => DetailPage(
                                    dailyForecastWeather: dailyWeatherForecast,
                                    location: location,
                                  ),
                            ),
                          ),
                      child: Text(
                        'Daily forecast',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: _constants.primaryTextColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Hourly Forecast at Bottom
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: hourlyWeatherForecast.length,
                  itemBuilder: (BuildContext context, int index) {
                    DateTime now = DateTime.now();

                    DateTime forecastDateTime = DateTime.parse(
                      hourlyWeatherForecast[index]["time"],
                    );

                    String forecastTime = DateFormat(
                      'HH:mm',
                    ).format(forecastDateTime);

                    bool isCurrentHour = forecastDateTime.hour == now.hour;

                    String forecastWeatherName =
                        hourlyWeatherForecast[index]["condition"]["text"];
                    String forecastWeatherIcon = getWeatherIcon(
                      forecastWeatherName,
                    );

                    String forecastTemperature =
                        hourlyWeatherForecast[index]["temp_c"]
                            .round()
                            .toString();

                    return Container(
                      width: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color:
                            isCurrentHour
                                ? Colors.white.withOpacity(0.3)
                                : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border:
                            isCurrentHour
                                ? Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 2,
                                )
                                : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            forecastTime,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  isCurrentHour
                                      ? _constants.primaryTextColor
                                      : _constants.secondaryTextColor,
                              fontWeight:
                                  isCurrentHour
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Image.asset(
                            'lib/screens/weather/assests/$forecastWeatherIcon.png', // Placeholder icon
                            width: 40,
                            height: 40,
                            color: _constants.primaryTextColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$forecastTemperature°C', // Placeholder temperature
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: _constants.primaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
