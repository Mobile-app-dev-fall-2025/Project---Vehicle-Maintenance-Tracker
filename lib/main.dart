import 'package:flutter/material.dart';
import './database/db_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vehicle Maintenance Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const VehicleListPage(),
    );
  }
}

class VehicleListPage extends StatefulWidget {
  const VehicleListPage({super.key});

  @override
  State<VehicleListPage> createState() => _VehicleListPageState();
}

class _VehicleListPageState extends State<VehicleListPage> {
  final dbHelper = DBHelper();
  List<Map<String, dynamic>> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final data = await dbHelper.queryAll('vehicles');
    setState(() {
      _vehicles = data;
    });
  }

  Future<void> _addDummyVehicle() async {
    // Add a test vehicle (for demo)
    await dbHelper.insert('vehicles', {
      'make': 'Toyota',
      'model': 'Camry',
      'year': 2019,
      'license_plate': 'ABC-1234',
    });
    _loadVehicles(); // refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Vehicles'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addDummyVehicle),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: _vehicles.isEmpty
            ? const Center(
                child: Text(
                  'No vehicles added yet.',
                  style: TextStyle(fontSize: 16),
                ),
              )
            : ListView.builder(
                itemCount: _vehicles.length,
                itemBuilder: (context, index) {
                  final v = _vehicles[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.directions_car,
                        color: Colors.blue,
                      ),
                      title: Text('${v['make']} ${v['model']}'),
                      subtitle: Text(
                        'Year: ${v['year']} • Plate: ${v['license_plate']}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await dbHelper.delete('vehicles', 'id = ?', [
                            v['id'],
                          ]);
                          _loadVehicles();
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
