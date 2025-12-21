import 'package:flutter/material.dart';
import '../services/market_price_service.dart';
import '../services/profile_service.dart';

class CropMandiListScreen extends StatefulWidget {
  final String crop;

  const CropMandiListScreen({super.key, required this.crop});

  @override
  State<CropMandiListScreen> createState() => _CropMandiListScreenState();
}

class _CropMandiListScreenState extends State<CropMandiListScreen> {
  late Future _future;
  String locationText = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final location = await ProfileService.getLocation();

    setState(() {
      locationText =
          '${location['district'] ?? ''}, ${location['state'] ?? ''}';
    });

    _future = MarketPriceService.fetchPrices(crops: [widget.crop]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.crop.toUpperCase()} Prices')),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final response = snapshot.data;
          final cropData = response.data.first;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 📍 Location header
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Location: $locationText',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),

              if (cropData.mandis.isEmpty)
                const Expanded(
                  child: Center(child: Text('No nearby mandis found')),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: cropData.mandis.length,
                    itemBuilder: (context, index) {
                      final mandi = cropData.mandis[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          title: Text(mandi['mandi_name'] ?? 'Mandi'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Min: ₹${mandi['min_price'] ?? '--'}'),
                              Text('Max: ₹${mandi['max_price'] ?? '--'}'),
                              Text('Modal: ₹${mandi['modal_price'] ?? '--'}'),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
