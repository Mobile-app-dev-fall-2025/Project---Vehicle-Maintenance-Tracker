import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../add_maintenace_page.dart';

class MaintenanceLogsPage extends StatefulWidget {
  const MaintenanceLogsPage({super.key});
  @override
  State<MaintenanceLogsPage> createState() => _MaintenanceLogsPageState();
}

class _MaintenanceLogsPageState extends State<MaintenanceLogsPage> {
  final _db = DBHelper();
  List<Map<String, dynamic>> _logs = [];
  List<Map<String, dynamic>> _vehicles = [];
  int? _vehicleId;
  int _page = 1;
  static const int _pageSize = 5;
  @override
  void initState() {
    super.initState();
    _loadVehicles().then((_) => _loadLogs());
  }

  Future<void> _loadVehicles() async {
    try {
      final db = await _db.database;
      _vehicles = await db.query('vehicles');
      if (_vehicles.isNotEmpty && _vehicleId == null)
        _vehicleId = _vehicles.first['id'] as int?;
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _loadLogs() async {
    if (_vehicleId == null) return;
    try {
      final db = await _db.database;
      _logs = await db.query(
        'maintenance_logs',
        where: 'vehicle_id = ?',
        whereArgs: [_vehicleId],
        orderBy: 'date_performed DESC',
      );
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() => _logs = []);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final totalPages = (_logs.length / _pageSize).ceil().clamp(1, 999);
    final start = (_page - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, _logs.length);
    final pageItems = _logs.sublist(start, end);
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                Text(
                  'Maintenance Logs',
                  style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: cs.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: _vehicleId == null
                      ? null
                      : () async {
                          final ok = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AddMaintenancePage(vehicleId: _vehicleId!),
                            ),
                          );
                          if (ok == true) _loadLogs();
                        },
                  child: const Text('Create New Log'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (_vehicles.isNotEmpty)
            DropdownButtonFormField<int>(
              value: _vehicleId,
              items: _vehicles
                  .map(
                    (v) => DropdownMenuItem(
                      value: v['id'] as int?,
                      child: Text(
                        '${v['year'] ?? ''} ${v['make'] ?? ''} ${v['model'] ?? ''}',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() {
                _vehicleId = v;
                _page = 1;
                _loadLogs();
              }),
              decoration: const InputDecoration(labelText: 'Vehicle'),
            ),
          const SizedBox(height: 8),
          ...pageItems.map((log) => _LogTile(data: log)),
          const SizedBox(height: 12),
          _Pagination(
            current: _page,
            total: totalPages,
            onPrev: _page > 1 ? () => setState(() => _page -= 1) : null,
            onNext: _page < totalPages
                ? () => setState(() => _page += 1)
                : null,
          ),
        ],
      ),
    );
  }
}

class _LogTile extends StatelessWidget {
  final Map<String, dynamic> data;
  const _LogTile({required this.data});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        title: Text(
          '${data['maintenance_item'] ?? 'Maintenance Item'} / ${data['date_performed'] ?? 'Date'}',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              data['notes']?.toString() ?? 'No notes',
              style: t.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final int current;
  final int total;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  const _Pagination({
    required this.current,
    required this.total,
    this.onPrev,
    this.onNext,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('1', style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(width: 8),
        const Text('...'),
        const SizedBox(width: 8),
        IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
      ],
    );
  }
}
