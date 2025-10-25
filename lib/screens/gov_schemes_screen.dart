import 'package:flutter/material.dart';

class GovSchemesScreen extends StatelessWidget {
  const GovSchemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Government Schemes'),
        backgroundColor: const Color(0xFF0A2216),
        foregroundColor: const Color(0xFFE0E7C8),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Agricultural Government Schemes',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A2216),
            ),
          ),
          const SizedBox(height: 16),
          _buildSchemeCard(
            'PM-KISAN',
            'Pradhan Mantri Kisan Samman Nidhi',
            'Provides income support of ₹6,000 per year to farmer families.',
            'https://pmkisan.gov.in/',
          ),
          _buildSchemeCard(
            'Soil Health Card Scheme',
            'Soil Health Management',
            'Provides soil health cards to farmers for better crop management.',
            'https://soilhealth.dac.gov.in/',
          ),
          _buildSchemeCard(
            'Pradhan Mantri Fasal Bima Yojana',
            'Crop Insurance Scheme',
            'Provides financial support to farmers suffering crop loss due to natural calamities.',
            'https://pmfby.gov.in/',
          ),
          _buildSchemeCard(
            'National Agriculture Market (eNAM)',
            'Electronic Trading Platform',
            'Connects farmers directly to markets for better price discovery.',
            'https://enam.gov.in/',
          ),
          _buildSchemeCard(
            'Paramparagat Krishi Vikas Yojana',
            'Organic Farming Promotion',
            'Promotes organic farming practices and sustainable agriculture.',
            'https://pgsindia-ncof.gov.in/',
          ),
        ],
      ),
    );
  }

  Widget _buildSchemeCard(
    String title,
    String subtitle,
    String description,
    String url,
  ) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
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
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // TODO: Open URL or show more details
                },
                child: const Text('Learn More'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
