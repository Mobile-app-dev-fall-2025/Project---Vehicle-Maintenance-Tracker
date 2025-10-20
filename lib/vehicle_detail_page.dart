import 'package:flutter/material.dart';
import './database/db_helper.dart';

class VehicleDetailPage extends StatefulWidget {
  final Map<String, dynamic> vehicle;

  const VehicleDetailPage({super.key, required this.vehicle});

  @override
  State<VehicleDetailPage> createState() => _VehicleDetailPageState();
}

class _VehicleDetailPageState extends State<VehicleDetailPage> {
  final dbHelper = DBHelper();
  List<Map<String, dynamic>> _logs = [];

  @override
  void initState() {
    super.initState();
    _loadMaintenanceLogs();
  }

  Future<void> _loadMaintenanceLogs() async {
    final data = await dbHelper.queryWhere(
      'maintenance_logs',
      'vehicle_id = ?',
      [widget.vehicle['id']],
    );
    setState(() {
      _logs = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vehicle;

    return Scaffold(
      appBar: AppBar(title: Text('${v['make']} ${v['model']}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Make: ${v['make']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Model: ${v['model']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Year: ${v['year']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'License Plate: ${v['license_plate']}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Mileage: ${v['mileage']} mi',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const Text(
              'Maintenance History',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _logs.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'No maintenance records found.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                : Column(
                    children: _logs.map((log) {
                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(log['type']),
                          subtitle: Text(
                            'Date: ${log['date']}  |  Mileage: ${log['mileage']} mi\nNotes: ${log['notes'] ?? ''}',
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // TODO: navigate to add-maintenance page
          // e.g. await Navigator.push(...);
          // then reload logs
          _loadMaintenanceLogs();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
