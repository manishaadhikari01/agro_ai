import 'package:flutter/material.dart';
import 'chatbot_screen.dart';
import 'homescreen.dart';
import 'profile.dart';
import 'weather/weather_screen.dart';
import 'user_check_screen.dart';
import '../utils/app_mode.dart';

class MainAppScreen extends StatefulWidget {
  final AppMode mode;

  const MainAppScreen({super.key, required this.mode});

  @override
  _MainAppScreenState createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;

  List<Widget> get _screens {
    final isGuest = widget.mode == AppMode.guest;

    return [
      const DashboardScreen(),
      const WeatherScreen(),
      isGuest ? _GuestBlockedScreen(feature: 'Chatbot') : const ChatbotScreen(),
      isGuest ? _GuestBlockedScreen(feature: 'Profile') : const ProfileScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No app bar - each screen manages its own header
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.wb_sunny), label: 'Weather'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chatbot'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF0A2216),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}

class _GuestBlockedScreen extends StatelessWidget {
  final String feature;

  const _GuestBlockedScreen({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 80),
            const SizedBox(height: 20),
            Text(
              '$feature requires login',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Please login or register to access this feature.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const UserCheckScreen()),
                );
              },
              child: const Text('Login / Register'),
            ),
          ],
        ),
      ),
    );
  }
}
