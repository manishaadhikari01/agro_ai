import 'package:flutter/material.dart';

import '../services/govt_data_service.dart';

class MandiPricesScreen extends StatefulWidget {
  final String cropName;

  const MandiPricesScreen({super.key, required this.cropName});

  @override
  State<MandiPricesScreen> createState() => _MandiPricesScreenState();
}

class _MandiPricesScreenState extends State<MandiPricesScreen> {
  bool _loading = true;
  String? _error;

  // Each mandi record is a raw JSON map from the backend
  List<Map<String, dynamic>> _mandis = [];

  @override
  void initState() {
    super.initState();
    _loadMandis();
  }

  Future<void> _loadMandis() async {
    setState(() {
      _loading = true;
      _error = null;
      _mandis = [];
    });

    final data = await GovtDataService.fetchLiveMandiForCrop(widget.cropName);

    if (!mounted) return;

    if (data == null) {
      setState(() {
        _loading = false;
        _error = 'Could not fetch mandi prices. Please try again.';
      });
      return;
    }

    final List<dynamic> entries = data['data'] as List<dynamic>? ?? [];
    final first =
        entries.isNotEmpty ? entries.first as Map<String, dynamic> : null;
    final List<dynamic> mandisRaw =
        first != null ? (first['mandis'] as List<dynamic>? ?? []) : [];

    setState(() {
      _mandis =
          mandisRaw
              .map(
                (e) => (e as Map).map(
                  (key, value) => MapEntry(key.toString(), value),
                ),
              )
              .cast<Map<String, dynamic>>()
              .toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color(0xFF0A2216);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.cropName} Prices'),
        backgroundColor: themeColor,
        foregroundColor: const Color(0xFFE0E7C8),
      ),
      body: SafeArea(
        child:
            _loading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
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
                      Expanded(child: _buildMandisList(themeColor)),
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _buildMandisList(Color themeColor) {
    if (_mandis.isEmpty && _error == null) {
      return const Center(
        child: Text(
          'No mandi prices found near you for this crop.\nTry again later.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      itemCount: _mandis.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final mandi = _mandis[index];

        final mandiName =
            (mandi['market'] ?? mandi['market_center'] ?? 'Unknown mandi')
                .toString();
        final district = (mandi['district'] ?? '').toString();
        final state = (mandi['state'] ?? '').toString();
        final modalPrice = double.tryParse(
          mandi['modal_price']?.toString() ?? '',
        );
        final minPrice = double.tryParse(mandi['min_price']?.toString() ?? '');
        final maxPrice = double.tryParse(mandi['max_price']?.toString() ?? '');
        final arrivalDate = (mandi['arrival_date'] ?? '').toString();

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        mandiName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (modalPrice != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Modal Price',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${modalPrice.toStringAsFixed(0)}/qtl',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  [district, state].where((s) => s.isNotEmpty).join(', '),
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (minPrice != null)
                      _pricePill(
                        label: 'Min',
                        value: '₹${minPrice.toStringAsFixed(0)}',
                      ),
                    if (maxPrice != null) const SizedBox(width: 8),
                    if (maxPrice != null)
                      _pricePill(
                        label: 'Max',
                        value: '₹${maxPrice.toStringAsFixed(0)}',
                      ),
                    const Spacer(),
                    if (arrivalDate.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            arrivalDate,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pricePill({required String label, required String value}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.grey.shade100,
      ),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
