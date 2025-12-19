import 'package:flutter/material.dart';

import '../services/profile_service.dart';
import '../services/token_service.dart';
import 'mandi_prices_screen.dart';

class MarketPricesScreen extends StatefulWidget {
  const MarketPricesScreen({super.key});

  @override
  State<MarketPricesScreen> createState() => _MarketPricesScreenState();
}

class _MarketPricesScreenState extends State<MarketPricesScreen> {
  bool _loadingCrops = true;
  String? _error;

  List<String> _crops = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() {
      _loadingCrops = true;
      _error = null;
    });

    final token = await TokenService.getAccessToken();
    if (token == null) {
      if (!mounted) return;
      setState(() {
        _loadingCrops = false;
        _error = 'Please login to view market prices.';
      });
      return;
    }

    try {
      final profile = await ProfileService.fetchProfile();

      final profileCrops =
          (profile?['crops_grown'] as List<dynamic>?)?.cast<String>() ?? [];

      final crops =
          profileCrops.isNotEmpty
              ? profileCrops
              : <String>['Wheat', 'Rice', 'Maize', 'Cotton', 'Sugarcane'];

      if (!mounted) return;

      setState(() {
        _crops = crops;
        _loadingCrops = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingCrops = false;
        _error = 'Failed to load crops. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF0A2216);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Prices'),
        backgroundColor: themeColor,
        foregroundColor: const Color(0xFFE0E7C8),
      ),
      body: SafeArea(
        child:
            _loadingCrops
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_error != null) ...[
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            _error!,
                            style: TextStyle(
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      const Text(
                        'Select a crop',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child:
                            _crops.isEmpty
                                ? const Center(
                                  child: Text(
                                    'No crops found. Please add crops in your profile.',
                                    style: TextStyle(color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                                : ListView.separated(
                                  itemCount: _crops.length,
                                  separatorBuilder:
                                      (_, __) => const SizedBox(height: 8),
                                  itemBuilder: (context, index) {
                                    final crop = _crops[index];
                                    return Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 2,
                                      child: ListTile(
                                        title: Text(
                                          crop,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        trailing: const Icon(
                                          Icons.chevron_right,
                                          color: Colors.grey,
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => MandiPricesScreen(
                                                    cropName: crop,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
