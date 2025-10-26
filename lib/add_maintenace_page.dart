import 'package:flutter/material.dart';
import './database/db_helper.dart';

class AddMaintenancePage extends StatefulWidget {
  final int vehicleId;

  const AddMaintenancePage({super.key, required this.vehicleId});

  @override
  State<AddMaintenancePage> createState() => _AddMaintenancePageState();
}

class _AddMaintenancePageState extends State<AddMaintenancePage> {
  final dbHelper = DBHelper();
  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> _maintenanceTypes = [];
  int? _selectedTypeId;

  final dateController = TextEditingController();
  final mileageController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMaintenanceTypes();
    dateController.text = DateTime.now().toIso8601String().split('T').first;
  }

  Future<void> _loadMaintenanceTypes() async {
    final data = await dbHelper.queryAll('maintenance_types');
    setState(() {
      _maintenanceTypes = data;
      if (_maintenanceTypes.isNotEmpty) {
        _selectedTypeId = _maintenanceTypes[0]['id'];
      }
    });
  }

  Future<void> _saveLog() async {
    if (_formKey.currentState!.validate() && _selectedTypeId != null) {
      final logData = {
        'vehicle_id': widget.vehicleId,
        'maintenance_type_id': _selectedTypeId,
        'date_performed': dateController.text,
        'mileage': int.tryParse(mileageController.text) ?? 0,
        'notes': notesController.text,
      };

      await dbHelper.insert('maintenance_logs', logData);
      if (mounted) Navigator.pop(context, true);
    }
  }

  // Future<void> _saveLog() async {
  //   if (_formKey.currentState!.validate() && _selectedTypeId != null) {
  //     // Prepare the log data
  //     final logData = {
  //       'vehicle_id': widget.vehicleId,
  //       'maintenance_type_id': _selectedTypeId,
  //       'date_performed': dateController.text,
  //       'mileage': int.tryParse(mileageController.text) ?? 0,
  //       'notes': notesController.text,
  //     };

  //     // Create a string showing values and their types
  //     final displayText = logData.entries
  //         .map((e) => '${e.key}: ${e.value} (${e.value.runtimeType})')
  //         .join('\n');

  //     // Show the popup dialog
  //     if (mounted) {
  //       showDialog(
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: const Text('Log Data Preview'),
  //           content: Text(displayText),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text('OK'),
  //             ),
  //           ],
  //         ),
  //       );
  //     }
  //   }
  // }

  @override
  void dispose() {
    dateController.dispose();
    mileageController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Maintenance Log')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _maintenanceTypes.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Maintenance Type Dropdown
                    DropdownButtonFormField<int>(
                      initialValue: _selectedTypeId,
                      items: _maintenanceTypes
                          .map(
                            (type) => DropdownMenuItem<int>(
                              value: type['id'] as int, // cast to int
                              child: Text(type['name'].toString()),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedTypeId = val;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: 'Maintenance Type',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null ? 'Select a maintenance type' : null,
                    ),

                    const SizedBox(height: 12),

                    // Date performed
                    TextFormField(
                      controller: dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date Performed (YYYY-MM-DD)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter a date'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Mileage
                    TextFormField(
                      controller: mileageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Mileage',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter mileage'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Notes
                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    ElevatedButton.icon(
                      onPressed: _saveLog,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Maintenance Log'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
