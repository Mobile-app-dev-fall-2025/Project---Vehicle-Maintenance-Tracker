import 'package:act10/add_maintenace_page.dart';
import 'package:flutter/material.dart';
import './database/db_helper.dart';
import 'package:intl/intl.dart'; // for date formatting

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
    final db = await dbHelper.database;
    // Join with maintenance_types to get name + interval
    final data = await db.rawQuery(
      '''
      SELECT maintenance_logs.*, 
             maintenance_types.name AS type,
             maintenance_types.recommended_interval_days AS interval_days
      FROM maintenance_logs
      LEFT JOIN maintenance_types 
        ON maintenance_logs.maintenance_type_id = maintenance_types.id
      WHERE maintenance_logs.vehicle_id = ?
      ORDER BY maintenance_logs.date_performed DESC
    ''',
      [widget.vehicle['id']],
    );

    setState(() {
      _logs = data;
    });
  }

  String _calculateNextDate(String? lastDate, int? intervalDays) {
    if (lastDate == null || intervalDays == null) return 'Unknown';
    try {
      final parsedDate = DateTime.parse(lastDate);
      final nextDate = parsedDate.add(Duration(days: intervalDays));
      return DateFormat('yyyy-MM-dd').format(nextDate);
    } catch (_) {
      return 'Unknown';
    }
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
                      final nextRecommendedDate = _calculateNextDate(
                        log['date_performed'] as String?,
                        log['interval_days'] is int
                            ? log['interval_days'] as int
                            : int.tryParse(
                                log['interval_days']?.toString() ?? '',
                              ),
                      );

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text(log['type'] ?? 'Unknown Type'),
                          subtitle: Text(
                            'Date: ${log['date_performed'] ?? 'Unknown'}  |  Mileage: ${log['mileage'] ?? 'N/A'} mi\n'
                            'Notes: ${log['notes'] ?? ''}\n'
                            'Next recommended ${log['type'] ?? 'maintenance'} date: $nextRecommendedDate',
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddMaintenancePage(vehicleId: v['id']),
            ),
          );
          if (result == true) {
            _loadMaintenanceLogs(); // reload logs after adding
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add new maintenance log'),
      ),
    );
  }
}
