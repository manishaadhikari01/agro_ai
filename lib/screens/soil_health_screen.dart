import 'package:flutter/material.dart';

class SoilHealthScreen extends StatelessWidget {
  const SoilHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Soil Health'),
        backgroundColor: const Color(0xFF0A2216),
        foregroundColor: const Color(0xFFE0E7C8),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Soil Health Management',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2216),
              ),
            ),
            const SizedBox(height: 16),
            _buildHealthCard(
              'Soil Testing',
              'Regular soil testing helps determine nutrient levels and pH balance.',
              Icons.science,
            ),
            _buildHealthCard(
              'Nutrient Management',
              'Maintain proper NPK levels for healthy crop growth.',
              Icons.grass,
            ),
            _buildHealthCard(
              'Organic Matter',
              'Add compost and organic matter to improve soil structure.',
              Icons.eco,
            ),
            _buildHealthCard(
              'Water Management',
              'Proper irrigation prevents soil erosion and maintains moisture.',
              Icons.water_drop,
            ),
            const SizedBox(height: 20),
            const Text(
              'Soil Health Tips',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2216),
              ),
            ),
            const SizedBox(height: 10),
            _buildTipCard('Test your soil every 2-3 years to monitor changes.'),
            _buildTipCard('Use crop rotation to prevent nutrient depletion.'),
            _buildTipCard('Avoid over-tilling to preserve soil structure.'),
            _buildTipCard('Apply lime if soil pH is too acidic.'),
            _buildTipCard(
              'Use cover crops to prevent erosion and add organic matter.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCard(String title, String description, IconData icon) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 48, color: Colors.green.shade700),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A2216),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String tip) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.lightbulb, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(child: Text(tip, style: const TextStyle(fontSize: 14))),
          ],
        ),
      ),
    );
  }
}
