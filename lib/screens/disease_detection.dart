import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/config.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  _DiseaseDetectionScreenState createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  Map<String, dynamic>? _result;
  bool _isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      await _analyzeImage();
    }
  }

  //void _analyzeImage() {
  // Placeholder for AI analysis
  // setState(() {
  //   _result = 'Severe: Late Blight';
  // });
  //}

  Future<void> _analyzeImage() async {
    if (_image == null) return;

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Config.baseUrl}/ml/plant-disease/predict'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('file', _image!.path),
      );

      var response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        setState(() {
          _result = jsonDecode(responseBody);
        });
      } else {
        throw Exception('Prediction failed');
      }
    } catch (e) {
      setState(() {
        _result = {
          "class": [],
          "confidence": [],
          "remedy": "Could not analyze image. Please try again.",
          "note": "Error analyzing image.",
        };
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Analyze Your Crop\'s Health'),
        backgroundColor: Colors.green.shade700,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Upload or take a photo of your crop to detect diseases and get treatment recommendations.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 30),

              // Image display
              if (_image != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: FileImage(_image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image, size: 64, color: Colors.grey),
                ),

              const SizedBox(height: 30),

              // Buttons
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Upload Photo',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => _pickImage(ImageSource.camera),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.green.shade700),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Take Photo',
                  style: TextStyle(fontSize: 16, color: Colors.green.shade700),
                ),
              ),

              if (_isLoading) ...[
                const SizedBox(height: 30),
                const CircularProgressIndicator(),
              ],

              // Result
              if (_result != null && !_isLoading) ...[
                const SizedBox(height: 30),
                Builder(
                  builder: (context) {
                    final List classes = _result!['class'] ?? [];
                    final List confidences = _result!['confidence'] ?? [];

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // -------- Top prediction --------
                            Text(
                              "Most Likely: ${classes.isNotEmpty ? classes[0] : 'Unknown'}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),

                            if (confidences.isNotEmpty)
                              Text(
                                "Confidence: ${(confidences[0] * 100).toStringAsFixed(1)}%",
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),

                            const SizedBox(height: 12),

                            // -------- Other possibilities --------
                            if (classes.length > 1) ...[
                              const Text(
                                "Other possibilities:",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 6),
                              for (int i = 1; i < classes.length; i++)
                                Text(
                                  "• ${classes[i]} "
                                  "(${(confidences[i] * 100).toStringAsFixed(1)}%)",
                                ),
                            ],

                            const SizedBox(height: 12),

                            // -------- Remedy --------
                            const Text(
                              "Recommended Remedy:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(_result!['remedy']),

                            // -------- Note --------
                            if (_result!['note'] != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green.shade700,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _result!['note'],
                                        style: TextStyle(
                                          color: Colors.green.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
