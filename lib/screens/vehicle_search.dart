// lib/screens/vehicle_search.dart
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../add_vehicle_page.dart';

class VehicleSearchPage extends StatefulWidget {
  const VehicleSearchPage({super.key});
  @override
  State<VehicleSearchPage> createState() => _VehicleSearchPageState();
}

class _VehicleSearchPageState extends State<VehicleSearchPage> {
  final _db = DBHelper();
  List<Map<String, dynamic>> _vehicles = [];
  String? _year;
  String? _make;
  String? _model;
  String? _mileage;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final db = await _db.database;
      final rows = await db.query('vehicles');
      if (mounted) setState(() => _vehicles = rows);
    } catch (_) {
      if (mounted) setState(() => _vehicles = []);
    }
  }

  List<String> _uniq(String key) {
    final s = <String>{};
    for (final v in _vehicles) {
      final val = v[key]?.toString() ?? '';
      if (val.isNotEmpty) s.add(val);
    }
    return s.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const CircleAvatar(
          radius: 16,
          child: Icon(Icons.person, size: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddVehiclePage()),
            ),
            child: Semantics(
              button: true,
              label: 'Add New Vehicle',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.add_circle_outline, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Add New Vehicle',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),
          _Dropdown(
            label: 'Year',
            items: _uniq('year'),
            value: _year,
            onChanged: (v) => setState(() => _year = v),
          ),
          const SizedBox(height: 12),
          _Dropdown(
            label: 'Make',
            items: _uniq('make'),
            value: _make,
            onChanged: (v) => setState(() => _make = v),
          ),
          const SizedBox(height: 12),
          _Dropdown(
            label: 'Model',
            items: _uniq('model'),
            value: _model,
            onChanged: (v) => setState(() => _model = v),
          ),
          const SizedBox(height: 12),
          _Dropdown(
            label: 'Mileage',
            items: _uniq('mileage'),
            value: _mileage,
            onChanged: (v) => setState(() => _mileage = v),
          ),
        ],
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  const _Dropdown({
    required this.label,
    required this.items,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.expand_more),
      ),
    );
  }
}
