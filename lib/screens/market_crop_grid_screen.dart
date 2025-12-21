import 'package:flutter/material.dart';
import '../screens/crop_mandi_list_screen.dart';

class MarketCropGridScreen extends StatefulWidget {
  const MarketCropGridScreen({super.key});

  @override
  State<MarketCropGridScreen> createState() => _MarketCropGridScreenState();
}

class _MarketCropGridScreenState extends State<MarketCropGridScreen> {
  String searchQuery = '';

  static const List<String> cropList = [
    'tomato',
    'potato',
    'onion',
    'wheat',
    'rice',
    'maize',
    'soybean',
    'cotton',
    'chilli',
    'banana',
    'apple',
  ];

  @override
  Widget build(BuildContext context) {
    final filteredCrops =
        cropList
            .where((crop) => crop.contains(searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Select Crop')),
      body: Column(
        children: [
          // 🔍 Search bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search crops...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
            ),
          ),

          // 🟩 Crop grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredCrops.length,
              itemBuilder: (context, index) {
                final crop = filteredCrops[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CropMandiListScreen(crop: crop),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Image.asset(
                              'lib/assets/$crop.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) {
                                return const Icon(Icons.image, size: 40);
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            crop.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
