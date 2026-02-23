// filepath: /home/akesh/Work/new_hr/cn_pocket_hr/lib/Screens/allowancesDeductions/AllowancesDeductionsScreen.dart
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import 'package:cn_pocket_hr/api/apiService.dart';
import 'package:cn_pocket_hr/model/hr/VariableModel.dart';

class TabletAllowancesDeductionsScreen extends StatefulWidget {
  const TabletAllowancesDeductionsScreen({Key? key}) : super(key: key);

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
  String _query = '';

  // Style aligned with mobile/attendance
  static const Color _pageBg = Colors.white;
  static const Color _surface = Color.fromARGB(255, 248, 250, 252);
  static const double _g8 = 8;
  static const double _g12 = 12;
  static const double _g16 = 16;

  static const FontWeight _wMedium = FontWeight.w500;
  static const FontWeight _wSemi = FontWeight.w600;
  static const FontWeight _wBold = FontWeight.w700;
  static const FontWeight _wBlack = FontWeight.w900;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<String?> _resolveUserId() async {
    await _storage.ready;
    final uid = _storage.getItem('uid')?.toString();
    if (uid != null && uid.isNotEmpty) return uid;

    final jwtUid = await _api.ensureUidFromAccessToken();
    if (jwtUid != null && jwtUid.isNotEmpty) return jwtUid;

    final me = _storage.getItem('me_profile');
    if (me is Map) {
      final m = Map<String, dynamic>.from(me);
      final dataAny = m['data'] ?? m['result'] ?? m['user'];
      if (dataAny is Map) {
        final data = Map<String, dynamic>.from(dataAny);
        final id = (data['_id'] ?? data['id'] ?? data['user_id'] ?? data['sub'] ?? '').toString();
        if (id.isNotEmpty) return id;
      }
    }

    return null;
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uid = await _resolveUserId();
      if (uid == null || uid.isEmpty) throw Exception('Missing user id (uid).');

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
    } catch (e, st) {
      debugPrint('[VAR][ERROR] $e');
      debugPrint('$st');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  String _money(num v) => v.toStringAsFixed(2);

  String _dateFromUnixSeconds(int seconds) {
    if (seconds <= 0) return '-';
    final dt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_g16, _g12, _g16, _g12),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(40),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 18),
            ),
          ),
          const SizedBox(width: _g12),
          const Expanded(
            child: Text(
              'Allowances & Deductions',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 24, fontWeight: _wBlack, color: Colors.black87),
            ),
          ),
          InkWell(
            onTap: _load,
            borderRadius: BorderRadius.circular(40),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: const Icon(Icons.refresh_rounded, color: Colors.black87, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabs() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: TabBar(
        controller: _tab,
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(6),
        indicator: BoxDecoration(
          color: Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        labelColor: Colors.black87,
        unselectedLabelColor: Colors.black54,
        labelStyle: const TextStyle(fontWeight: _wBold),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Allowances'),
          Tab(text: 'Deductions'),
        ],
      ),
    );
  }

  Widget _search() {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        onChanged: (v) => setState(() => _query = v.trim()),
        style: const TextStyle(fontSize: 14, fontWeight: _wSemi),
        decoration: const InputDecoration(
          border: InputBorder.none,
          icon: Icon(Icons.search_rounded, color: Colors.black54),
          hintText: 'Search by name',
        ),
      ),
    );
  }

  Widget _itemCard(VariableItem item) {
    final isAllowance = item.type.toLowerCase() == 'allowance';
    final amountColor = isAllowance ? Colors.green.shade800 : Colors.black87;
    final sign = isAllowance ? '+' : '-';
    final icon = isAllowance ? Icons.add_circle_outline : Icons.remove_circle_outline;
    final iconColor = isAllowance ? Colors.green.shade700 : Colors.red.shade700;
    final statusText = item.processed ? 'Processed' : 'Pending';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: _g12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.allowance,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 15, fontWeight: _wBold, color: Colors.black87),
                      ),
                    ),
                    const SizedBox(width: _g12),
                    Text(
                      '$sign${_money(item.amount)}',
                      style: TextStyle(fontSize: 15, fontWeight: _wBlack, color: amountColor),
                    ),
                  ],
                ),
                const SizedBox(height: _g8),
                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 14, color: Colors.black54),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _dateFromUnixSeconds(item.issuedDate),
                        style: const TextStyle(color: Colors.black54, fontSize: 12, fontWeight: _wMedium),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (item.processed ? Colors.green : Colors.orange).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _wBold,
                          color: item.processed ? Colors.green.shade800 : Colors.orange.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<VariableItem> _applyFilter(List<VariableItem> list) {
    if (_query.isEmpty) return list;
    final q = _query.toLowerCase();
    return list.where((e) => e.allowance.toLowerCase().contains(q)).toList();
  }

  Widget _list(List<VariableItem> list) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
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
    }

    final filtered = _applyFilter(list);
    if (filtered.isEmpty) {
      return const Center(child: Text('No records', style: TextStyle(color: Colors.black54, fontWeight: _wSemi)));
    }

    // Tablet friendly: grid when wide, list when not.
    return LayoutBuilder(
      builder: (context, c) {
        final crossAxisCount = c.maxWidth >= 980 ? 2 : 1;
        return RefreshIndicator(
          onRefresh: _load,
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 30),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: crossAxisCount == 2 ? 3.4 : 3.8,
            ),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _itemCard(filtered[i]),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allowances = _items.where((e) => e.type.toLowerCase() == 'allowance').toList();
    final deductions = _items.where((e) => e.type.toLowerCase() == 'deduction').toList();

    return Scaffold(
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(_g16, 0, _g16, _g16),
                child: Row(
                  children: [
                    // Left pane: tabs + search + summary
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 340),
                      child: Column(
                        children: [
                          _tabs(),
                          const SizedBox(height: _g12),
                          _search(),
                          const SizedBox(height: _g12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.black.withOpacity(0.05)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Summary', style: TextStyle(fontSize: 14, fontWeight: _wBlack, color: Colors.black87)),
                                const SizedBox(height: 10),
                                Text('Total items: ${_items.length}', style: const TextStyle(fontWeight: _wSemi, color: Colors.black54)),
                                const SizedBox(height: 6),
                                Text('Allowances: ${allowances.length}', style: const TextStyle(fontWeight: _wSemi, color: Colors.black54)),
                                const SizedBox(height: 6),
                                Text('Deductions: ${deductions.length}', style: const TextStyle(fontWeight: _wSemi, color: Colors.black54)),
                              ],
                            ),
                          ),
                          const SizedBox(height: _g12),
                          if (_loading)
                            const LinearProgressIndicator(minHeight: 3)
                          else
                            const SizedBox(height: 3),
                        ],
                      ),
                    ),

                    const SizedBox(width: _g16),

                    // Right pane: list
                    Expanded(
                      child: TabBarView(
                        controller: _tab,
                        children: [
                          _list(_items),
                          _list(allowances),
                          _list(deductions),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
