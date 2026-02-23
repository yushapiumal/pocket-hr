import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:localstorage/localstorage.dart';

import 'package:cn_pocket_hr/api/apiService.dart';
import 'package:cn_pocket_hr/helper/DesignConfig.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:cn_pocket_hr/model/hr/AttendanceModel.dart';
import 'package:cn_pocket_hr/Constant/Slideanimation.dart';
import 'package:cn_pocket_hr/Screens/notifications/Notifications.dart';

class MobileAttendance extends StatefulWidget {
  const MobileAttendance({Key? key}) : super(key: key);

  @override
  State<MobileAttendance> createState() => _MobileAttendanceState();
}

class _MobileAttendanceState extends State<MobileAttendance>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final LocalStorage storage = LocalStorage('pocketHR');
  final APIService apiService = APIService();

  late AnimationController _animationController;
  Future<List<AttendanceModel>>? attendanceFuture;

  String _tabType = 'cur';
  String? _selectedPayroll; // format: M-YYYY (e.g., 1-2026)

  String? _resolvedLocation;
  String? _resolvedUser;

  // Theme aligned with Leave screen
  static const Color _pageBg = Colors.white;
  static const Color _surface = Color.fromARGB(255, 248, 250, 252);
  static const double _g8 = 8;
  static const double _g12 = 12;
  static const double _g16 = 16;

  // Fonts (keep existing sizes; only normalize weights)
  static const FontWeight _wRegular = FontWeight.w400;
  static const FontWeight _wMedium = FontWeight.w500;
  static const FontWeight _wSemi = FontWeight.w600;
  static const FontWeight _wBold = FontWeight.w700;
  static const FontWeight _wBlack = FontWeight.w900;

  TextStyle get _title24 => const TextStyle(fontSize: 24, fontWeight: _wBlack);
  TextStyle get _h16 => const TextStyle(fontSize: 16, fontWeight: _wBold);
  TextStyle get _label14 => const TextStyle(fontSize: 14, fontWeight: _wBold);
  TextStyle get _body12 => const TextStyle(fontSize: 12, fontWeight: _wMedium, color: Color(0xFF6B7280));
  TextStyle get _chip11 => const TextStyle(fontSize: 11, fontWeight: _wBold, color: Colors.black87);
  TextStyle get _valueBold => const TextStyle(fontWeight: _wBold);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _animationController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    // Default: load current month once storage is ready
    _initLoad();
  }

  Future<void> _initLoad() async {
    await storage.ready;
    _loadAttendance('cur');
  }

  void _loadAttendance(String type) {
    _tabType = type;
    setState(() {
      String? payroll = type == 'cur'
          ? storage.getItem('payroll_active_tag')?.toString()
          : (_selectedPayroll ?? storage.getItem('payroll_past_tag')?.toString());

      // If storage does not have a payroll tag for current month, generate a sensible default
      if ((payroll == null || payroll.trim().isEmpty) && type == 'cur') {
        final now = DateTime.now();
        payroll = '${now.month}-${now.year}'; // fallback format expected by backend (M-YYYY)
        print('[UI] fallback payroll tag for current month => $payroll');
      }

      if (payroll == null || payroll.trim().isEmpty) {
        attendanceFuture = Future.value(<AttendanceModel>[]);
        return;
      }

      // Always request fresh data when the tab is tapped
      print('[UI] loading attendance for payroll=$payroll (type=$type)');
      attendanceFuture = apiService.getAttendanceForUserMonth(payroll: payroll).catchError((e, st) {
        print('[UI] getAttendanceForUserMonth ERROR => $e');
        print(st);
        return <AttendanceModel>[];
      });
    });
  }

  Future<void> _pickMonthAndLoad() async {
    final picked = await _showMonthYearPicker();
    if (picked == null) return;
    final mm = picked.month.toString();
    final yyyy = picked.year.toString();
    _selectedPayroll = '$mm-$yyyy';
    _loadAttendance('prv');
  }

  Future<DateTime?> _showMonthYearPicker() async {
    final now = DateTime.now();
    final initialTag = _selectedPayroll;

    int selectedMonth = now.month;
    int selectedYear = now.year;

    if (initialTag != null && initialTag.contains('-')) {
      final parts = initialTag.split('-');
      if (parts.length == 2) {
        final mm = int.tryParse(parts[0]);
        final yy = int.tryParse(parts[1]);
        if (mm != null && mm >= 1 && mm <= 12) selectedMonth = mm;
        if (yy != null) selectedYear = yy;
      }
    }

    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final years = List<int>.generate(11, (i) => now.year - 10 + i);
    final monthController = FixedExtentScrollController(initialItem: selectedMonth - 1);
    final yearController = FixedExtentScrollController(
      initialItem: years.indexOf(selectedYear).clamp(0, years.length - 1),
    );

    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: _g16, vertical: _g12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [BoxShadow(color: Color(0x24000000), blurRadius: 24)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(color: HRColors.orangeColor, shape: BoxShape.circle),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.close, color: Colors.white, size: 18),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 180,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Container(
                          height: 44,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: CupertinoPicker(
                              scrollController: monthController,
                              itemExtent: 40,
                              magnification: 1.05,
                              useMagnifier: true,
                              selectionOverlay: const SizedBox.shrink(),
                              onSelectedItemChanged: (i) => selectedMonth = i + 1,
                              children: months
                                  .map((m) => Center(
                                        child: Text(
                                          m,
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                          Expanded(
                            child: CupertinoPicker(
                              scrollController: yearController,
                              itemExtent: 40,
                              magnification: 1.05,
                              useMagnifier: true,
                              selectionOverlay: const SizedBox.shrink(),
                              onSelectedItemChanged: (i) => selectedYear = years[i],
                              children: years
                                  .map((y) => Center(
                                        child: Text(
                                          y.toString(),
                                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HRColors.orangeColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: () => Navigator.pop(ctx, DateTime(selectedYear, selectedMonth, 1)),
                      child: const Text(
                        'Confirm',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        side: BorderSide(color: Colors.black.withOpacity(0.06)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),
        );
      },
    );
  }

  String _selectedMonthLabel() {
    if (_tabType == 'prv' && _selectedPayroll != null && _selectedPayroll!.isNotEmpty) {
      return _selectedPayroll!;
    }
    return _payrollTag();
  }


  String _payrollTag() {
    return (_tabType == 'cur' ? storage.getItem('payroll_active_tag') : storage.getItem('payroll_past_tag'))?.toString() ?? '';
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  String _formatDurationSeconds(int seconds) {
    final hrs = seconds ~/ 3600;
    final mins = (seconds % 3600) ~/ 60;
    return '${hrs}h ${mins}m';
  }

  // ===== dashboard widgets =====

  Widget _topActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_g16, _g8, _g16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: Center(
                child: SvgPicture.asset(
                  "assets/svg/drawer_icon.svg",
                  colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
                ),
              ),
            ),
          ),

          Text(
            AppLocalizations.of(context)!.attendanceText,
            style: _title24,
          ),

          GestureDetector(
            onTap: () => Navigator.pushNamed(context, HRNotifications.routeName),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: Center(
                child: SvgPicture.asset(
                  "assets/svg/notifications_icon.svg",
                  colorFilter: const ColorFilter.mode(Colors.black87, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthTabs() {
    final thisMonthLabel = storage.getItem('payroll_active_tag')?.toString() ?? 'This Month';
    final pastMonthLabel = storage.getItem('payroll_past_tag')?.toString() ?? 'Past Month';

    return Container(
      margin: const EdgeInsets.only(top: _g12),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _loadAttendance('cur'),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _tabType == 'cur' ? Colors.black.withOpacity(0.06) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    thisMonthLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: _wBold,
                      color: _tabType == 'cur' ? Colors.black87 : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              onTap: _pickMonthAndLoad,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _tabType == 'prv' ? Colors.black.withOpacity(0.06) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    _tabType == 'prv' && _selectedPayroll != null ? _selectedPayroll! : pastMonthLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: _wBold,
                      color: _tabType == 'prv' ? Colors.black87 : Colors.black54,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shiftCard(List<AttendanceModel> items) {
    // Use the latest record for quick stats.
    final latest = items.isNotEmpty ? items.last : null;
    final bp = latest?.boilerPlate ?? <String, dynamic>{};
    final inTime = bp['in_time_only']?.toString() ?? '--:--';
    final outTime = bp['out_time_only']?.toString() ?? '--:--';

    // For the dashboard, show total worked hours for the loaded month.
    int totalSeconds = 0;
    for (final it in items) {
      final b = it.boilerPlate;
      totalSeconds += _toInt(b['workedSeconds'] ?? b['worked_seconds'] ?? b['worked_hours'] ?? 0);
    }
    final totalWorked = totalSeconds > 0
        ? _formatDurationSeconds(totalSeconds)
        : (bp['wrkd_hours_fmtd']?.toString() ?? '0h 0m');

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                child: const Text('GENERAL SHIFT', style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.w700)),
              ),
              // Container(
              //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              //   decoration: BoxDecoration(
              //     color: Colors.black.withOpacity(0.06),
              //     borderRadius: BorderRadius.circular(20),
              //   ),
              //   child: Text(_selectedMonthLabel(), style: _chip11),
              // ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _miniStat('Check In', inTime),
              _miniStat('Check Out', outTime),
              _miniStat('Working Hrs', totalWorked),
            ],
          )
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: _wBold)),
        const SizedBox(height: 4),
        Text(label, style: _body12),
      ],
    );
  }

  Widget _monthSummary(List<AttendanceModel> items) {
    // Simple client-side aggregation placeholder.
    // You can replace these with backend computed values later.
    final total = items.length;
    final absents = 0;
    final late = 0;
    final present = (total - absents).clamp(0, total);

    Widget tile(String label, String value, Color bg, Color fg) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              Text(label, style: TextStyle(color: fg, fontWeight: _wBold, fontSize: 12)),
              const SizedBox(height: 6),
              Text(value, style: TextStyle(color: fg, fontWeight: _wBlack, fontSize: 18)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Attendance for this Month', style: _label14),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            //   decoration: BoxDecoration(
            //     color: Colors.black.withOpacity(0.06),
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   child: Text(_selectedMonthLabel(), style: _chip11),
            // ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            tile('Present', present.toString(), const Color(0xFFEAF7EE), const Color(0xFF2E7D32)),
            const SizedBox(width: 10),
            tile('Absents', absents.toString().padLeft(2, '0'), const Color(0xFFFFEBEE), const Color(0xFFE53935)),
            const SizedBox(width: 10),
            tile('Late in', late.toString().padLeft(2, '0'), const Color(0xFFFFF7E6), const Color(0xFFF59E0B)),
          ],
        ),
      ],
    );
  }

  // ===== list =====

  Widget _attendanceList() {
    return FutureBuilder<List<AttendanceModel>>( 
      future: attendanceFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        var data = snapshot.data!;

        // Resolve header fallback values from the returned data.
        if (data.isNotEmpty) {
          final bp0 = data.first.boilerPlate;
          final loc = bp0['location']?.toString();
          if ((_resolvedLocation == null || _resolvedLocation!.isEmpty) && loc != null && loc.isNotEmpty) {
            _resolvedLocation = loc;
          }
          // fallback user label
          if (_resolvedUser == null || _resolvedUser!.isEmpty) {
            final uid = storage.getItem('uid')?.toString() ?? '';
            _resolvedUser = uid.isNotEmpty ? uid : null;
          }
        }

        // Sort first date -> last date (ascending)
        data = List<AttendanceModel>.from(data)
          ..sort((a, b) {
            final ta = _toInt(a.boilerPlate['firstCheckIn'] ?? a.boilerPlate['time'] ?? 0);
            final tb = _toInt(b.boilerPlate['firstCheckIn'] ?? b.boilerPlate['time'] ?? 0);
            return ta.compareTo(tb);
          });

        if (data.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text('No records')),
          );
        }

        return SlideAnimation(
          position: 4,
          itemCount: 8,
          slideDirection: SlideDirection.fromLeft,
          animationController: _animationController,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.length,
            itemBuilder: (_, index) {
              final record = data[index];
              return _attendanceCard(record);
            },
          ),
        );
      },
    );
  }

  Widget _attendanceCard(AttendanceModel data) {
    final bp = data.boilerPlate;
    final String day = (bp['day'] ?? data.day).toString();
    final String dow = (bp['dow'] ?? data.dow).toString();
    final String inTime = bp['in_time_only']?.toString() ?? ' - ';
    final String outTime = bp['out_time_only']?.toString() ?? ' - ';
    final String wrkd = bp['wrkd_hours_fmtd']?.toString() ?? ' - ';
    final String late = bp['late']?.toString() ?? ' - ';
    final String over = bp['over']?.toString() ?? ' - ';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
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
        child: ExpandableNotifier(
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "$dow $day",
                                style: const TextStyle(fontSize: 15, color: Color(0xff676767), fontWeight: _wMedium),
                              ),
                              Text(
                                data.isOffday ? "DayOff" : "Shift",
                                style: TextStyle(
                                  fontWeight: _wSemi,
                                  color: data.isOffday ? HRColors.dutyOff : HRColors.shift,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const Text("IN : ", style: TextStyle(fontWeight: _wMedium)),
                                Text(inTime, style: _valueBold),
                                SizedBox(width: MediaQuery.of(context).size.width * 0.45),
                                const Text("OUT : ", style: TextStyle(fontWeight: _wMedium)),
                                Text(outTime, style: _valueBold),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(thickness: 1.5),
              ),

              ExpandablePanel(
                header: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("View Details", style: TextStyle(fontWeight: _wBold)),
                ),
                collapsed: const SizedBox.shrink(),
                expanded: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Table(
                    border: TableBorder.symmetric(inside: const BorderSide(width: 1)),
                    children: [
                      _tableRow("WORKED", "LATE", "OVER", header: true),
                      _tableRow(wrkd, late, over),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    ));
    }

    TableRow _tableRow(String a, String b, String c, {bool header = false}) {
      return TableRow(
        decoration: header ? BoxDecoration(color: Colors.grey[350]) : null,
        children: [
          _cell(a, header),
          _cell(b, header),
          _cell(c, header),
        ],
      );
    }

    Widget _cell(String text, bool header) {
      return Padding(
        padding: const EdgeInsets.all(6),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: header ? _wBold : _wRegular),
        ),
      );
    }

    // ===== screen =====

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        key: _scaffoldKey,
        drawer: Drawer(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: DesignConfig.drawerContent(_scaffoldKey, context),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _topActions(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      _monthTabs(),

                      FutureBuilder<List<AttendanceModel>>(
                        future: attendanceFuture,
                        builder: (context, snap) {
                          final list = snap.data ?? const <AttendanceModel>[];
                          return Column(
                            children: [
                              _shiftCard(list),
                              const SizedBox(height: 14),
                              _monthSummary(list),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),

                // History / details
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.attendanceText,
                              style: _label14,
                            ),
                            TextButton(
                              onPressed: () => _loadAttendance(_tabType),
                              child: const Text('Refresh', style: TextStyle(color: Colors.black87, fontWeight: _wBold)),
                            ),
                          ],
                        ),
                      ),
                      _attendanceList(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: _pageBg,
      );
    }
  }
