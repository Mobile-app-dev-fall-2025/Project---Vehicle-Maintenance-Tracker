
// lib/screens/home_dashboard.dart
import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../vehicle_detail_page.dart';

class HomeDashboardPage extends StatefulWidget {
  const HomeDashboardPage({super.key});
  @override State<HomeDashboardPage> createState() => _HomeDashboardPageState();
}

class _HomeDashboardPageState extends State<HomeDashboardPage> {
  final _db = DBHelper();
  List<Map<String, dynamic>> _vehicles = [];
  DateTime _focusedMonth = DateTime.now();
  int? _selectedDay;

  @override void initState(){super.initState(); _loadVehicles();}
  Future<void> _loadVehicles() async {
    try { final db = await _db.database; final rows = await db.query('vehicles'); if (mounted) setState(()=>_vehicles=rows); }
    catch (_) { if (mounted) setState(()=>_vehicles=[]); }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const CircleAvatar(radius: 16, child: Icon(Icons.person, size: 18))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text('Welcome back, Aidan', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        _VehicleInfoCard(vehicles: _vehicles, onTapFirst: () {
          if (_vehicles.isEmpty) return;
          Navigator.push(context, MaterialPageRoute(builder: (_) => VehicleDetailPage(vehicle: _vehicles.first)));
        }),
        const SizedBox(height: 16),
        _MonthHeader(month: _focusedMonth,
          onPrev: ()=>setState(()=>_focusedMonth=DateTime(_focusedMonth.year,_focusedMonth.month-1,1)),
          onNext: ()=>setState(()=>_focusedMonth=DateTime(_focusedMonth.year,_focusedMonth.month+1,1))),
        const SizedBox(height: 8),
        _CalendarGrid(month:_focusedMonth, selected:_selectedDay, onSelect:(d)=>setState(()=>_selectedDay=d)),
      ]),
    );
  }
}

class _VehicleInfoCard extends StatelessWidget {
  final List<Map<String, dynamic>> vehicles; final VoidCallback? onTapFirst;
  const _VehicleInfoCard({required this.vehicles, this.onTapFirst});
  @override Widget build(BuildContext context) {
    final cs=Theme.of(context).colorScheme; final t=Theme.of(context).textTheme; final v=vehicles.isNotEmpty?vehicles.first:null;
    return Card(child: InkWell(borderRadius: BorderRadius.circular(16), onTap: onTapFirst, child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      Container(width:96, height:96, decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(12)), child: Icon(Icons.directions_car_rounded, color: cs.onPrimaryContainer, size:32)),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children:[
        Text('Vehicle information', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height:6),
        Text(v==null?'No vehicles yet':'${v['year'] ?? ''} ${v['make'] ?? ''} ${v['model'] ?? ''}', style: t.bodyLarge),
        if(v!=null)...[const SizedBox(height:4), Text('Mileage: ${v['mileage'] ?? '-'}', style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant))],
      ])),
    ]))));
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime month; final VoidCallback onPrev; final VoidCallback onNext;
  const _MonthHeader({required this.month, required this.onPrev, required this.onNext});
  @override Widget build(BuildContext context) {
    final t=Theme.of(context).textTheme;
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(onPressed:onPrev, icon: const Icon(Icons.chevron_left)),
      Text('${_name(month)} ${month.year}', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
      IconButton(onPressed:onNext, icon: const Icon(Icons.chevron_right)),
    ]);
  }
  String _name(DateTime d){const n=['JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE','JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER']; return n[d.month-1];}
}

class _CalendarGrid extends StatelessWidget {
  final DateTime month; final int? selected; final ValueChanged<int> onSelect;
  const _CalendarGrid({required this.month, required this.selected, required this.onSelect});
  @override Widget build(BuildContext context) {
    final cs=Theme.of(context).colorScheme; final t=Theme.of(context).textTheme;
    final first=DateTime(month.year,month.month,1);
    final firstWeekday=(first.weekday)%7; // Monday=1..Sunday=7 -> 0..6 (Su last)
    final days=DateTime(month.year,month.month+1,0).day;
    final labels=['M','T','W','Th','F','S','Su'];
    final weekLabels=[for(final d in labels) Center(child: Text(d, style: t.labelMedium?.copyWith(color: cs.onSurfaceVariant)))];
    final cells=<Widget>[];
    for(int i=0;i<firstWeekday;i++){cells.add(const SizedBox());}
    for(int d=1; d<=days; d++){
      final sel = selected==d;
      cells.add(GestureDetector(onTap:()=>onSelect(d), child: Container(alignment: Alignment.center, height:40,
        decoration: BoxDecoration(color: sel? cs.onSurface : cs.surfaceVariant, borderRadius: BorderRadius.circular(8)),
        child: Text('$d', style: TextStyle(color: sel? cs.surface : cs.onSurface)),
      )));
    }
    return Column(children: [
      GridView.count(crossAxisCount:7, shrinkWrap:true, physics: const NeverScrollableScrollPhysics(), children: weekLabels),
      const SizedBox(height:8),
      GridView.count(crossAxisCount:7, shrinkWrap:true, physics: const NeverScrollableScrollPhysics(), children: cells),
    ]);
  }
}
