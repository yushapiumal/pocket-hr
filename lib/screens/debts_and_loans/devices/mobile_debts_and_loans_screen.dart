import 'package:auto_size_text/auto_size_text.dart';
import 'package:cn_pocket_hr/services/debt_service.dart';
import 'package:cn_pocket_hr/helpers/format_utils.dart';
import 'package:cn_pocket_hr/helpers/hr_colors.dart';
// filepath: /home/akesh/Work/new_hr/cn_pocket_hr/lib/Screens/debtsAndLoans/devices/MobileDebtsAndLoansScreen.dart
import 'package:flutter/material.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:cn_pocket_hr/models/hr/debt_model.dart';

class MobileDebtsAndLoansScreen extends StatefulWidget {
  @override
  State<MobileDebtsAndLoansScreen> createState() =>
      _MobileDebtsAndLoansScreenState();
}

class _MobileDebtsAndLoansScreenState extends State<MobileDebtsAndLoansScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  bool _loading = true;
  String? _error;
  List<DebtItem> _items = [];
  String _query = '';

  // Spacing system (8pt grid + golden-ratio-ish steps)
  static const double _g8 = 8;
  static const double _g12 = 12;
  static const double _g16 = 16;
  static const double _g20 = 20;
  static const double _g24 = 24;

  static const Color _pageBg = Colors.white;
  static const Color _surface = Color.fromARGB(255, 248, 250, 252);

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

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final parsed = await DebtService.getDebts();
      parsed.sort((a, b) => b.issuedDate.compareTo(a.issuedDate));
      setState(() {
        _items = parsed;
        _loading = false;
      });
    } catch (e, st) {
      debugPrint('[DEBT][ERROR] $e');
      debugPrint('$st');
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Widget _itemCard(DebtItem item) {
    final isDebt = item.type.toLowerCase() == 'debt';
    final amountColor = Colors.black87;
    final sign = isDebt ? '-' : '+';
    final icon = isDebt ? Icons.trending_down : Icons.trending_up;
    final iconColor = isDebt ? Colors.red.shade700 : Colors.green.shade700;
    // statusText replaced by localized strings in UI
    final title = (item.description != null && item.description!.isNotEmpty)
        ? item.description!
        : (isDebt ? 'Debt' : 'Loan');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _g12, vertical: _g8),
      child: Container(
        padding: const EdgeInsets.all(10),
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: _g12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          title,
                          maxLines: 1,
                          minFontSize: 10,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: _g12),
                      AutoSizeText(
                        '$sign${FormatUtils.money(item.amount)}',
                        maxLines: 1,
                        minFontSize: 10,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: amountColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: _g8),
                  Row(
                    children: [
                      Icon(Icons.calendar_month,
                          size: 14, color: Colors.black54),
                      const SizedBox(width: 6),
                      Expanded(
                        child: AutoSizeText(
                          FormatUtils.dateFromUnixSeconds(item.issuedDate),
                          maxLines: 1,
                          minFontSize: 9,
                          style: const TextStyle(
                              color: Colors.black54, fontSize: 11),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: (item.collected ? Colors.green : Colors.orange)
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: AutoSizeText(
                          item.collected
                              ? AppLocalizations.of(context)!.collectedLabel
                              : AppLocalizations.of(context)!.pendingLabel,
                          maxLines: 1,
                          minFontSize: 9,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: item.collected
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allItems = _items;
    final debts = _items.where((e) => e.type.toLowerCase() == 'debt').toList();
    final loans = _items.where((e) => e.type.toLowerCase() == 'loan').toList();
    List<DebtItem> filter(List<DebtItem> list) {
      if (_query.isEmpty) return list;
      final q = _query.toLowerCase();
      return list
          .where((e) => ((e.description ?? (e.type == 'debt' ? 'Debt' : 'Loan'))
              .toLowerCase()
              .contains(q)))
          .toList();
    }

    final filteredAll = filter(allItems);
    final filteredDebts = filter(debts);
    final filteredLoans = filter(loans);
    Widget tabBody;
    if (_loading) {
      tabBody = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      tabBody = Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AutoSizeText(_error!,
                  textAlign: TextAlign.center, maxLines: 4, minFontSize: 10),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _load,
                child: AutoSizeText(
                  AppLocalizations.of(context)!.retryLabel,
                  maxLines: 1,
                  minFontSize: 10,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      tabBody = TabBarView(
        controller: _tab,
        children: [
          RefreshIndicator(
            onRefresh: _load,
            child: filteredAll.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 60),
                      Center(
                        child: AutoSizeText(
                          AppLocalizations.of(context)!.noRecords,
                          maxLines: 2,
                          minFontSize: 10,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 30),
                    itemCount: filteredAll.length,
                    itemBuilder: (_, i) => _itemCard(filteredAll[i]),
                  ),
          ),
          RefreshIndicator(
            onRefresh: _load,
            child: filteredDebts.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 60),
                      Center(
                        child: AutoSizeText(
                          AppLocalizations.of(context)!.noDebtsFound,
                          maxLines: 2,
                          minFontSize: 10,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      )
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 30),
                    itemCount: filteredDebts.length,
                    itemBuilder: (_, i) => _itemCard(filteredDebts[i]),
                  ),
          ),
          RefreshIndicator(
            onRefresh: _load,
            child: filteredLoans.isEmpty
                ? ListView(
                    children: [
                      const SizedBox(height: 60),
                      Center(
                        child: AutoSizeText(
                          AppLocalizations.of(context)!.noLoansFound,
                          maxLines: 2,
                          minFontSize: 10,
                          style: const TextStyle(color: Colors.black54),
                        ),
                      )
                    ],
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 30),
                    itemCount: filteredLoans.length,
                    itemBuilder: (_, i) => _itemCard(filteredLoans[i]),
                  ),
          ),
        ],
      );
    }
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: null,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(_g12, _g16, _g12, _g8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(40),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color:
                            HRColors.flavorIconBackgroundColor ?? Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        border:
                            Border.all(color: Colors.black.withOpacity(0.06)),
                      ),
                      child: Icon(Icons.navigate_before,
                          color: HRColors.flavorIconColor),
                    ),
                  ),
                  const SizedBox(width: _g12),
                  Expanded(
                    child: AutoSizeText(
                      AppLocalizations.of(context)!.debtsLabel +
                          ' & ' +
                          AppLocalizations.of(context)!.loansLabel,
                      maxLines: 1,
                      minFontSize: 16,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: _g20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: _g12),
              child: Container(
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
                    color: const Color(0xFF791b27),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  labelColor: const Color(0xFFeed06e),
                  unselectedLabelColor: Colors.black54,
                  tabs: [
                    Tab(
                      child: AutoSizeText(
                        AppLocalizations.of(context)!.allLabel,
                        maxLines: 1,
                        minFontSize: 10,
                      ),
                    ),
                    Tab(
                      child: AutoSizeText(
                        AppLocalizations.of(context)!.debtsLabel,
                        maxLines: 1,
                        minFontSize: 10,
                      ),
                    ),
                    Tab(
                      child: AutoSizeText(
                        AppLocalizations.of(context)!.loansLabel,
                        maxLines: 1,
                        minFontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: _g24),
            Expanded(child: tabBody),
          ],
        ),
      ),
    );
  }
}
