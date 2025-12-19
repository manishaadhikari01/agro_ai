import 'package:flutter/material.dart';
import '../models/field_model.dart';
import '../services/field_service.dart';
import '../screens/add_field_screen.dart';

class FieldsListScreen extends StatefulWidget {
  const FieldsListScreen({super.key});

  @override
  State<FieldsListScreen> createState() => _FieldsListScreenState();
}

class _FieldsListScreenState extends State<FieldsListScreen> {
  late Future<List<FieldModel>> _fieldsFuture;

  @override
  void initState() {
    super.initState();
    _fieldsFuture = FieldService.getFields();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Fields'),
        backgroundColor: const Color(0xFF0A2216),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A2216),
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddFieldScreen()),
          ).then((_) {
            setState(() {
              _fieldsFuture = FieldService.getFields();
            });
          });
        },
      ),

      body: FutureBuilder<List<FieldModel>>(
        future: _fieldsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final fields = snapshot.data!;

          if (fields.isEmpty) {
            return const Center(child: Text('No fields added yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: fields.length,
            itemBuilder: (context, index) {
              final field = fields[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(field.fieldName),
                  subtitle: Text(
                    'Crop: ${field.cropType}\nArea: ${field.areaHectare} ha',
                  ),
                  trailing: _statusBadge(field.status),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    if (status == 'Healthy') {
      color = Colors.green;
    } else if (status == 'Stressed') {
      color = Colors.red;
    } else {
      color = Colors.orange;
    }

    return Chip(
      label: Text(status),
      backgroundColor: color.withOpacity(0.15),
      labelStyle: TextStyle(color: color),
    );
  }
}
