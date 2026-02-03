// filepath: /home/akesh/Work/new_hr/cn_pocket_hr/lib/Screens/allowancesDeductions/AllowancesDeductionsScreen.dart
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:cn_pocket_hr/api/apiService.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';
import 'package:cn_pocket_hr/model/hr/VariableModel.dart';

class TabletAllowancesDeductionsScreen extends StatefulWidget {
  

  @override
  State<TabletAllowancesDeductionsScreen> createState() => _TabletAllowancesDeductionsScreenState();
}

class _TabletAllowancesDeductionsScreenState extends State<TabletAllowancesDeductionsScreen>
    with SingleTickerProviderStateMixin {
  final _api = APIService();
  final _storage = LocalStorage('pocketHR');

  late final TabController _tab;
  bool _loading = true;
  String? _error;
  List<VariableItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _storage.ready;
      final uid = _storage.getItem('uid')?.toString();
      if (uid == null || uid.isEmpty) {
        throw Exception('Missing user id');
      }

      final raw = await _api.fetchVariablesForUser(uid);
      final parsed = raw
          .whereType<Map>()
          .map((e) => VariableItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      parsed.sort((a, b) => b.issuedDate.compareTo(a.issuedDate));

      setState(() {
        _items = parsed;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _money(num v) {
    // Simple formatting without intl dependency
    return v.toStringAsFixed(2);
  }

  String _dateFromUnixSeconds(int seconds) {
    if (seconds <= 0) return '-';
    final dt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Widget _chip(String text, {Color? bg, Color? fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg ?? Colors.black12,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: fg ?? Colors.black87),
      ),
    );
  }

  Widget _row(VariableItem item) {
    final isAllowance = item.type.toLowerCase() == 'allowance';
    final amountColor = isAllowance ? Colors.green.shade800 : Colors.red.shade800;
    final sign = isAllowance ? '+' : '-';

    return Card(
      color: Colors.white.withOpacity(0.85),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.allowance,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  '$sign${_money(item.amount)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: amountColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _chip(_dateFromUnixSeconds(item.issuedDate), bg: Colors.black12),
                const SizedBox(width: 8),
                _chip(item.processed ? 'Processed' : 'Pending',
                    bg: item.processed ? Colors.green.withOpacity(0.15) : Colors.orange.withOpacity(0.15),
                    fg: item.processed ? Colors.green.shade800 : Colors.orange.shade800),
                if (item.processedOn != null) ...[
                  const SizedBox(width: 8),
                  _chip('On ${item.processedOn}', bg: Colors.blue.withOpacity(0.12), fg: Colors.blue.shade800),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allowances = _items.where((e) => e.type.toLowerCase() == 'allowance').toList();
    final deductions = _items.where((e) => e.type.toLowerCase() == 'deduction').toList();

    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    } else {
      body = TabBarView(
        controller: _tab,
        children: [
          ListView.builder(
            itemCount: allowances.length,
            itemBuilder: (_, i) => _row(allowances[i]),
          ),
          ListView.builder(
            itemCount: deductions.length,
            itemBuilder: (_, i) => _row(deductions[i]),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: HRColors.black.withOpacity(0.2),
        elevation: 0,
        title: const Text('Allowances & Deductions'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Allowances'),
            Tab(text: 'Deductions'),
          ],
        ),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.grey.withOpacity(0.15),
              Colors.white.withOpacity(0.2),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: body,
      ),
    );
  }
}
