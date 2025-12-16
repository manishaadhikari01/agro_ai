import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/config.dart';

const String _apiUrl = "http://10.0.2.2:8000/ml/crop-recommendation/predict";

class CropRecommendationScreen extends StatefulWidget {
  const CropRecommendationScreen({super.key});

  @override
  State<CropRecommendationScreen> createState() =>
      _CropRecommendationScreenState();
}

class _CropRecommendationScreenState extends State<CropRecommendationScreen> {
  // Form controllers
  String? _selectedDistrict = 'Dehradun';
  String? _selectedSeason = 'Kharif';
  String? _selectedSoilType = 'Loamy';
  String? _selectedAltitudeZone = 'High-Hills';
  String? _selectedIrrigationType = 'Rainfed';
  // Top K is always 3 internally (not exposed to user)
  final int _topK = 3;

  // Recommendations data
  List<CropRecommendation>? _recommendations;
  int? _selectedCropIndex;
  bool _isLoading = false;

  // Dropdown options
  final List<String> _districts = [
    'Dehradun',
    'Haridwar',
    'Nainital',
    'Almora',
    'Pauri Garhwal',
    'Tehri Garhwal',
    'Chamoli',
    'Rudraprayag',
    'Uttarkashi',
    'Pithoragarh',
    'Bageshwar',
    'Champawat',
  ];

  final List<String> _seasons = ['Kharif', 'Rabi', 'Zaid'];

  final List<String> _soilTypes = ['Loamy', 'Clay', 'Silty', 'Sandy'];

  final List<String> _altitudeZones = ['High-Hills', 'Mid-Hills', 'Terai'];

  final List<String> _irrigationTypes = ['Rainfed', 'Canal', 'Tube Well'];

  Future<void> _getRecommendations() async {
    if (_selectedDistrict == null ||
        _selectedSeason == null ||
        _selectedSoilType == null ||
        _selectedAltitudeZone == null ||
        _selectedIrrigationType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _selectedCropIndex = null;
      _recommendations = null;
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "district": _selectedDistrict,
          "season": _selectedSeason,
          "soil_type": _selectedSoilType,
          "altitude_zone": _selectedAltitudeZone,
          "irrigation": _selectedIrrigationType,
          "top_k": _topK,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception("Backend error ${response.statusCode}");
      }

      final decoded = jsonDecode(response.body);
      final List<dynamic> results = decoded["final_recommendations"];

      final List<CropRecommendation> parsed =
          results.map((item) {
            return CropRecommendation(
              cropName: item["crop"],
              confidence: (item["score"] as num).toDouble(),
              matchReason: (item["reasons"] as List).join(", "),
              fertilizerAdvice:
                  item["fertilizer"] ?? "No fertilizer data available",
              irrigationGuidance:
                  item["irrigation"] ?? "No irrigation data available",
              emoji: item["emoji"] ?? "🌱",
            );
          }).toList();

      setState(() {
        _recommendations = parsed;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to fetch recommendations"),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF9),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Header Image Section
              _buildHeader(),
              const SizedBox(height: 28),

              // Input Form Card
              _buildInputFormCard(),

              const SizedBox(height: 28),

              // Recommendations Section
              if (_recommendations != null && _recommendations!.isNotEmpty)
                _buildRecommendationsSection(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      children: [
        // Full-width image with rounded bottom corners
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(32),
            bottomRight: Radius.circular(32),
          ),
          child: Image.asset(
            'lib/assets/croprecommend.jpeg',
            width: double.infinity,
            height: 400,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                ),
              );
            },
          ),
        ),
        // Back arrow button
        Positioned(
          top: 16,
          left: 16,
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.grey.shade800,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(),
              ),
            ),
          ),
        ),
        // Translucent green card overlay at the bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.green.shade50.withOpacity(0.85),
                      Colors.green.shade100.withOpacity(0.9),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Crop Recommendation System',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  color: Colors.grey.shade900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'AI-powered crop insights based on your farm conditions',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.1,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputFormCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // District Dropdown
          _buildDropdown(
            label: 'District',
            value: _selectedDistrict,
            items: _districts,
            onChanged: (value) {
              setState(() {
                _selectedDistrict = value;
              });
            },
            icon: Icons.location_on,
          ),

          const SizedBox(height: 16),

          // Season Dropdown
          _buildDropdown(
            label: 'Season',
            value: _selectedSeason,
            items: _seasons,
            onChanged: (value) {
              setState(() {
                _selectedSeason = value;
              });
            },
            icon: Icons.calendar_today,
          ),

          const SizedBox(height: 16),

          // Soil Type Dropdown
          _buildDropdown(
            label: 'Soil Type',
            value: _selectedSoilType,
            items: _soilTypes,
            onChanged: (value) {
              setState(() {
                _selectedSoilType = value;
              });
            },
            icon: Icons.landscape,
          ),

          const SizedBox(height: 16),

          // Altitude Zone Dropdown
          _buildDropdown(
            label: 'Altitude Zone',
            value: _selectedAltitudeZone,
            items: _altitudeZones,
            onChanged: (value) {
              setState(() {
                _selectedAltitudeZone = value;
              });
            },
            icon: Icons.terrain,
          ),

          const SizedBox(height: 16),

          // Irrigation Type Dropdown
          _buildDropdown(
            label: 'Irrigation Type',
            value: _selectedIrrigationType,
            items: _irrigationTypes,
            onChanged: (value) {
              setState(() {
                _selectedIrrigationType = value;
              });
            },
            icon: Icons.water_drop,
          ),

          const SizedBox(height: 20),

          // Submit Button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _getRecommendations,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: _isLoading ? 2 : 6,
                shadowColor: Colors.green.withOpacity(0.4),
              ),
              child:
                  _isLoading
                      ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                      : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.insights, size: 22),
                          const SizedBox(width: 8),
                          const Text(
                            'Get Recommendations',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, color: Colors.green.shade700, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.green.shade700,
                size: 24,
              ),
              items:
                  items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                          letterSpacing: 0.1,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: onChanged,
              hint: Text(
                'Select $label',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 15),
              ),
              dropdownColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: Colors.green.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top 3 Recommendations',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Based on your farm conditions',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Horizontal Scrollable Crop Cards
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _recommendations!.length,
            itemBuilder: (context, index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: _buildCropCard(_recommendations![index], index),
              );
            },
          ),
        ),

        const SizedBox(height: 20),

        // Expanded Details Section
        if (_selectedCropIndex != null)
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            child: _buildExpandedDetails(
              _recommendations![_selectedCropIndex!],
            ),
          ),
      ],
    );
  }

  Widget _buildCropCard(CropRecommendation crop, int index) {
    final isSelected = _selectedCropIndex == index;
    final isBestMatch = index == 0; // First recommendation is the best match
    final cropImagePath = 'lib/assets/crop/${crop.cropName.toLowerCase()}.png';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCropIndex = isSelected ? null : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: isBestMatch ? 220 : 200,
        margin: EdgeInsets.only(right: 16, top: isBestMatch ? 0 : 0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isBestMatch
                    ? [Colors.green.shade50, Colors.white]
                    : [Colors.white, Colors.grey.shade50],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color:
                isSelected
                    ? Colors.green.shade400
                    : isBestMatch
                    ? Colors.green.shade200
                    : Colors.green.shade100,
            width:
                isSelected
                    ? 2.5
                    : isBestMatch
                    ? 2
                    : 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? Colors.green.withOpacity(0.25)
                      : isBestMatch
                      ? Colors.green.withOpacity(0.15)
                      : Colors.grey.withOpacity(0.1),
              blurRadius:
                  isSelected
                      ? 16
                      : isBestMatch
                      ? 12
                      : 8,
              offset: Offset(0, isBestMatch ? 6 : 4),
              spreadRadius: isBestMatch ? 1 : 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Best Match Badge
            if (isBestMatch)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 6,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade600, Colors.green.shade700],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified, size: 14, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      'Best Match',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

            // Crop Image
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isBestMatch ? 0 : 24),
                topRight: Radius.circular(isBestMatch ? 0 : 24),
                bottomLeft: const Radius.circular(0),
                bottomRight: const Radius.circular(0),
              ),
              child: Stack(
                children: [
                  Image.asset(
                    cropImagePath,
                    width: double.infinity,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.green.shade100,
                              Colors.green.shade200,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            crop.emoji,
                            style: const TextStyle(fontSize: 64),
                          ),
                        ),
                      );
                    },
                  ),
                  // Confidence Badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            size: 14,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(crop.confidence * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Crop Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          crop.cropName,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                            color: Colors.grey.shade900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),

                        // Confidence Progress Bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Match Score',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                Text(
                                  '${(crop.confidence * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: crop.confidence,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.green.shade500,
                                ),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedDetails(CropRecommendation crop) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade50, Colors.green.shade100],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.insights_rounded,
                  color: Colors.green.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detailed Insights',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Comprehensive analysis for ${crop.cropName}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Match Reason
          _buildDetailItem(
            icon: Icons.psychology_rounded,
            title: 'Why This Crop?',
            content: crop.matchReason,
            color: const Color(0xFF3B82F6), // Blue
          ),

          const SizedBox(height: 16),

          // Fertilizer Advice
          _buildDetailItem(
            icon: Icons.eco_rounded,
            title: 'Fertilizer Advice',
            content: crop.fertilizerAdvice,
            color: const Color(0xFFF59E0B), // Amber/Orange
          ),

          const SizedBox(height: 16),

          // Irrigation Guidance
          _buildDetailItem(
            icon: Icons.water_drop_rounded,
            title: 'Irrigation Guidance',
            content: crop.irrigationGuidance,
            color: const Color(0xFF06B6D4), // Cyan
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.08), color.withOpacity(0.04)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.2), color.withOpacity(0.15)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: Color.fromRGBO(
                      (color.red * 0.75).round().clamp(0, 255),
                      (color.green * 0.75).round().clamp(0, 255),
                      (color.blue * 0.75).round().clamp(0, 255),
                      1.0,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade700,
                    height: 1.6,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Crop Recommendation Model
class CropRecommendation {
  final String cropName;
  final double confidence;
  final String matchReason;
  final String fertilizerAdvice;
  final String irrigationGuidance;
  final String emoji;

  CropRecommendation({
    required this.cropName,
    required this.confidence,
    required this.matchReason,
    required this.fertilizerAdvice,
    required this.irrigationGuidance,
    required this.emoji,
  });
}
