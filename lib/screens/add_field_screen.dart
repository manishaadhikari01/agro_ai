import 'package:flutter/material.dart';
import '../screens/SelectLocationScreen.dart';
import 'package:latlong2/latlong.dart';
import '../services/field_service.dart';
import '../utils/geo_utils.dart';

class AddFieldScreen extends StatefulWidget {
  const AddFieldScreen({super.key});

  @override
  State<AddFieldScreen> createState() => _AddFieldScreenState();
}

class _AddFieldScreenState extends State<AddFieldScreen> {
  final TextEditingController _fieldNameController = TextEditingController();

  LatLng? _selectedLocation;
  bool _isSubmitting = false;

  String _selectedCrop = 'Wheat';
  String _selectedSeason = 'Rabi';

  Future<void> _createField() async {
    if (_fieldNameController.text.isEmpty || _selectedLocation == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final coordinates = GeoUtils.rectangleFromCenter(_selectedLocation!);

      await FieldService.createField(
        fieldName: _fieldNameController.text.trim(),
        coordinates: coordinates,
        cropType: _selectedCrop,
        season: _selectedSeason,
      );

      if (!mounted) return;

      Navigator.pop(context); // go back to Fields List

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Field created successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to create field')));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  final List<String> crops = ['Wheat', 'Rice', 'Maize', 'Cotton'];
  final List<String> seasons = ['Rabi', 'Kharif', 'Zaid'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Field'),
        backgroundColor: const Color(0xFF0A2216),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Field Name
            TextField(
              controller: _fieldNameController,
              decoration: const InputDecoration(
                labelText: 'Field Name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Crop Dropdown
            DropdownButtonFormField<String>(
              value: _selectedCrop,
              items:
                  crops
                      .map(
                        (crop) =>
                            DropdownMenuItem(value: crop, child: Text(crop)),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCrop = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Crop Type',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Season Dropdown
            DropdownButtonFormField<String>(
              value: _selectedSeason,
              items:
                  seasons
                      .map(
                        (season) => DropdownMenuItem(
                          value: season,
                          child: Text(season),
                        ),
                      )
                      .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSeason = value!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Season',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // Select Location Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SelectLocationScreen(),
                    ),
                  );

                  if (result != null) {
                    setState(() {
                      _selectedLocation = result;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Location selected: '
                          '${result.latitude.toStringAsFixed(4)}, '
                          '${result.longitude.toStringAsFixed(4)}',
                        ),
                      ),
                    );
                  }
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A2216),
                ),
                child: const Text('Select Location'),
              ),
            ),

            //create field
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _createField,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[800],
                ),
                child:
                    _isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Create Field'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
