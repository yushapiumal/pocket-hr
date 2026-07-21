import 'package:auto_size_text/auto_size_text.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:localstorage/localstorage.dart';

import 'package:cn_pocket_hr/api/api_service.dart';
import 'package:cn_pocket_hr/helpers/design_config.dart';
import 'package:cn_pocket_hr/helpers/hr_colors.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:cn_pocket_hr/models/hr/attendance_model.dart';
import 'package:cn_pocket_hr/constants/slideanimation.dart';
import 'package:cn_pocket_hr/screens/notifications/notifications.dart';

class TabletAttendance extends StatefulWidget {
  const TabletAttendance({Key? key}) : super(key: key);

  @override
  State<TabletAttendance> createState() => _TabletAttendanceState();
}

class _TabletAttendanceState extends State<TabletAttendance>
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
  // TextStyle get _h16 => const TextStyle(fontSize: 16, fontWeight: _wBold);
  TextStyle get _label14 => const TextStyle(fontSize: 14, fontWeight: _wBold);
  // TextStyle get _body12 => const TextStyle(fontSize: 12, fontWeight: _wMedium, color: Color(0xFF6B7280));
  TextStyle get _valueBold => const TextStyle(fontWeight: _wBold);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000));
    // Default: load current month once storage is ready
    _initLoad();
  }

  Future<void> _initLoad() async {
    await storage.ready;
    _loadAttendance('cur');
  }

  void _showTopToast(String msg) {
    // Show top message like home page (using Overlay for true top position)
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: HRColors.darkOrangeColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: AutoSizeText(
                    msg,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 4), () {
      entry.remove();
    });
  }

  String _attendanceErrorMessageFromStatus(int? statusCode) {
    final l = AppLocalizations.of(context)!;
    if (statusCode == 401 || statusCode == 403) return l.sessionExpired;
    if (statusCode == 404) return l.noRecords;
    if (statusCode != null && statusCode >= 500) return l.serverError;
    return l.serverError;
  }

  String _attendanceErrorMessageFromException(Object? err) {
    final l = AppLocalizations.of(context)!;
    if (err == null) return l.serverError;

    if (err is SocketException) return l.noInternetConnection;

    final s = err.toString().toLowerCase();
    if (s.contains('401') || s.contains('403')) return l.sessionExpired;
    if (s.contains('404')) return l.noRecords;
    if (s.contains('socketexception') || s.contains('failed host lookup')) {
      return l.noInternetConnection;
    }
    return l.serverError;
  }

  void _toastAttendanceError(Object? err) {
    final msg = _attendanceErrorMessageFromException(err);
    _showTopToast(msg);
  }

  void _loadAttendance(String type) {
    _tabType = type;
    setState(() {
      String? payroll = type == 'cur'
          ? storage.getItem('payroll_active_tag')?.toString()
          : (_selectedPayroll ??
              storage.getItem('payroll_past_tag')?.toString());

      // If storage does not have a payroll tag for current month, generate a sensible default
      if ((payroll == null || payroll.trim().isEmpty) && type == 'cur') {
        final now = DateTime.now();
        payroll =
            '${now.month}-${now.year}'; // fallback format expected by backend (M-YYYY)
        print('[UI] fallback payroll tag for current month => $payroll');
      }

      if (payroll == null || payroll.trim().isEmpty) {
        attendanceFuture = Future.value(<AttendanceModel>[]);
        return;
      }

      // Always request fresh data when the tab is tapped
      print('[UI] loading attendance for payroll=$payroll (type=$type)');
      attendanceFuture = apiService.getAttendanceForUserMonth(payroll: payroll);
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

    final months = List<String>.generate(12, (i) {
      final dt = DateTime(now.year, i + 1, 1);
      var label = MaterialLocalizations.of(context).formatMonthYear(dt);
      label = label
          .replaceAll(RegExp(r'\b\d{4}\b'), '')
          .replaceAll(RegExp(r',[\s]*'), '')
          .trim();
      return label;
    });

    final years = List<int>.generate(11, (i) => now.year - 10 + i);
    final monthController =
        FixedExtentScrollController(initialItem: selectedMonth - 1);
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
            margin:
                const EdgeInsets.symmetric(horizontal: _g16, vertical: _g12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(color: Color(0x24000000), blurRadius: 24)
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                      color: HRColors.orangeColor, shape: BoxShape.circle),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 18),
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
                              onSelectedItemChanged: (i) =>
                                  selectedMonth = i + 1,
                              children: months
                                  .map((m) => Center(
                                        child: AutoSizeText(
                                          m,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
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
                              onSelectedItemChanged: (i) =>
                                  selectedYear = years[i],
                              children: years
                                  .map((y) => Center(
                                        child: AutoSizeText(
                                          y.toString(),
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: () => Navigator.pop(
                          ctx, DateTime(selectedYear, selectedMonth, 1)),
                      child: AutoSizeText(
                        AppLocalizations.of(context)!.confirmLabel,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w800),
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                        side: BorderSide(color: Colors.black.withOpacity(0.06)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: AutoSizeText(
                        AppLocalizations.of(context)!.cancelLabel,
                        style: TextStyle(
                            color: Colors.black87, fontWeight: FontWeight.w700),
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
                color: HRColors.flavorIconBackgroundColor ?? Colors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: Center(
                child: SvgPicture.asset(
                  "assets/svg/drawer_icon.svg",
                  colorFilter: ColorFilter.mode(
                      HRColors.flavorIconColor, BlendMode.srcIn),
                ),
              ),
            ),
          ),
          AutoSizeText(
            AppLocalizations.of(context)!.attendanceText,
            style: _title24,
          ),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, HRNotifications.routeName),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: HRColors.flavorIconBackgroundColor ?? Colors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: Center(
                child: SvgPicture.asset(
                  "assets/svg/notifications_icon.svg",
                  colorFilter: ColorFilter.mode(
                      HRColors.flavorIconColor, BlendMode.srcIn),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _monthTabs() {
    final thisMonthLabel = storage.getItem('payroll_active_tag')?.toString() ??
        AppLocalizations.of(context)!.thisMonthLabel;
    final pastMonthLabel = storage.getItem('payroll_past_tag')?.toString() ??
        AppLocalizations.of(context)!.pastMonthLabel;

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
                  color: _tabType == 'cur'
                      ? Colors.black.withOpacity(0.06)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: AutoSizeText(
                    thisMonthLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: _wBold,
                      color:
                          _tabType == 'cur' ? Colors.black87 : Colors.black54,
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
                  color: _tabType == 'prv'
                      ? Colors.black.withOpacity(0.06)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: AutoSizeText(
                    _tabType == 'prv' && _selectedPayroll != null
                        ? _selectedPayroll!
                        : pastMonthLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: _wBold,
                      color:
                          _tabType == 'prv' ? Colors.black87 : Colors.black54,
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

  // Widget _shiftCard(List<AttendanceModel> items) {
  //   // Use the latest record for quick stats.
  //   final latest = items.isNotEmpty ? items.last : null;
  //   final bp = latest?.boilerPlate ?? <String, dynamic>{};
  //   final inTime = bp['in_time_only']?.toString() ?? '--:--';
  //   final outTime = bp['out_time_only']?.toString() ?? '--:--';

  //   // For the dashboard, show total worked hours for the loaded month.
  //   int totalSeconds = 0;
  //   for (final it in items) {
  //     final b = it.boilerPlate;
  //     totalSeconds += _toInt(b['workedSeconds'] ?? b['worked_seconds'] ?? b['worked_hours'] ?? 0);
  //   }
  //   final totalWorked = totalSeconds > 0
  //       ? _formatDurationSeconds(totalSeconds)
  //       : (bp['wrkd_hours_fmtd']?.toString() ?? '0h 0m');

  //   return Container(
  //     margin: const EdgeInsets.only(top: 12),
  //     padding: const EdgeInsets.all(14),
  //     decoration: BoxDecoration(
  //       color: _surface,
  //       borderRadius: BorderRadius.circular(14),
  //       border: Border.all(color: Colors.black.withOpacity(0.05)),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.black.withOpacity(0.04),
  //           blurRadius: 10,
  //           offset: const Offset(0, 6),
  //         )
  //       ],
  //     ),
  //     child: Column(
  //       children: [
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //           children: [
  //             Container(
  //               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  //               decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
  //               child:  AutoSizeText(AppLocalizations.of(context)!.generalShift, style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.w700)),
  //             ),
  //             // Container(
  //             //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  //             //   decoration: BoxDecoration(
  //             //     color: Colors.black.withOpacity(0.06),
  //             //     borderRadius: BorderRadius.circular(20),
  //             //   ),
  //             //   child: AutoSizeText(_selectedMonthLabel(), style: _chip11),
  //             // ),
  //           ],
  //         ),
  //         const SizedBox(height: 12),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                children: [
  //             _miniStat(AppLocalizations.of(context)!.checkIn, inTime),
  //             _miniStat(AppLocalizations.of(context)!.checkOut, outTime),
  //             _miniStat(AppLocalizations.of(context)!.workingHrs, totalWorked),
  //           ],
  //         )
  //       ],
  //     ),
  //   );
  // }

  Widget _monthSummary(List<AttendanceModel> items) {
    // Simple client-side aggregation placeholder.
    // You can replace these with backend computed values later.
    final total = items.length;
    final absents = 0;
    final late = 0;
    final present = (total - absents).clamp(0, total);

    int totalSeconds = 0;
    for (final it in items) {
      final b = it.boilerPlate;
      totalSeconds += _toInt(
          b['workedSeconds'] ?? b['worked_seconds'] ?? b['worked_hours'] ?? 0);
    }
    final totalWorked = totalSeconds > 0
        ? _formatDurationSeconds(totalSeconds)
        : (items.isNotEmpty
            ? (items.first.boilerPlate['wrkd_hours_fmtd']?.toString() ??
                '0h 0m')
            : '0h 0m');

    Widget tile(String label, String value, Color bg, Color fg) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration:
              BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              AutoSizeText(label,
                  style:
                      TextStyle(color: fg, fontWeight: _wBold, fontSize: 10)),
              const SizedBox(height: 6),
              AutoSizeText(value,
                  style:
                      TextStyle(color: fg, fontWeight: _wBlack, fontSize: 12)),
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
            //  AutoSizeText(AppLocalizations.of(context)!.attendanceForThisMonth, style: _label14),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            //   decoration: BoxDecoration(
            //     color: Colors.black.withOpacity(0.06),
            //     borderRadius: BorderRadius.circular(20),
            //   ),
            //   child: AutoSizeText(_selectedMonthLabel(), style: _chip11),
            // ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            tile(AppLocalizations.of(context)!.presentLabel, present.toString(),
                const Color(0xFFEAF7EE), const Color(0xFF2E7D32)),
            const SizedBox(width: 10),
            tile(
                AppLocalizations.of(context)!.absentsLabel,
                absents.toString().padLeft(2, '0'),
                const Color(0xFFFFEBEE),
                const Color(0xFFE53935)),
            const SizedBox(width: 10),
            tile(
                AppLocalizations.of(context)!.lateInLabel,
                late.toString().padLeft(2, '0'),
                const Color(0xFFFFF7E6),
                const Color(0xFFF59E0B)),
            const SizedBox(width: 10),
            tile(AppLocalizations.of(context)!.workingHrs, totalWorked,
                const Color(0xFFFFF7E6), const Color(0xFFF59E0B)),
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
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CupertinoActivityIndicator(
                color: HRColors.orangeColor,
                radius: 16.0,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _toastAttendanceError(snapshot.error);
          });
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CupertinoActivityIndicator(
                color: HRColors.orangeColor,
                radius: 16.0,
              ),
            ),
          );
        }

        var data = snapshot.data!;

        int? statusCode;
        if (data.isNotEmpty) {
          try {
            final bp = data.first.boilerPlate;
            final scAny = bp['statusCode'] ?? bp['status'] ?? bp['code'];
            statusCode =
                (scAny is int) ? scAny : int.tryParse(scAny?.toString() ?? '');
          } catch (_) {}
        }

        // 1. If statusCode is 500+, show server error
        if (statusCode != null && statusCode >= 500) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted)
              _showTopToast(AppLocalizations.of(context)!.serverError);
          });
          return const SizedBox.shrink();
        }
        // 2. If statusCode is 401/403/404, show mapped message
        if (statusCode == 401 || statusCode == 403 || statusCode == 404) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted)
              _showTopToast(_attendanceErrorMessageFromStatus(statusCode));
          });
          return const SizedBox.shrink();
        }
        // 3. If statusCode is 200 and data is empty, show no records
        if ((statusCode == 200 || statusCode == null) && data.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _showTopToast(AppLocalizations.of(context)!.noRecords);
          });
          return const SizedBox.shrink();
        }
        // 4. If statusCode is not 200 and not handled above, show generic server error
        if (statusCode != null && statusCode != 200 && data.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted)
              _showTopToast(AppLocalizations.of(context)!.serverError);
          });
          return const SizedBox.shrink();
        }

        // Resolve header fallback values from the returned data.
        if (data.isNotEmpty) {
          final bp0 = data.first.boilerPlate;
          final loc = bp0['location']?.toString();
          if ((_resolvedLocation == null || _resolvedLocation!.isEmpty) &&
              loc != null &&
              loc.isNotEmpty) {
            _resolvedLocation = loc;
          }
          // fallback user label
          if (_resolvedUser == null || _resolvedUser!.isEmpty) {
            final uid = storage.getItem('uid')?.toString() ?? '';
            _resolvedUser = uid.isNotEmpty ? uid : null;
          }
        }

        // Sort latest to oldest (descending)
        data = List<AttendanceModel>.from(data)
          ..sort((a, b) {
            final ta = _toInt(
                a.boilerPlate['firstCheckIn'] ?? a.boilerPlate['time'] ?? 0);
            final tb = _toInt(
                b.boilerPlate['firstCheckIn'] ?? b.boilerPlate['time'] ?? 0);
            return tb.compareTo(ta);
          });

        if (data.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
                child: AutoSizeText(AppLocalizations.of(context)!.noRecords)),
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
                                AutoSizeText(
                                  "$dow $day",
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(0xff676767),
                                      fontWeight: _wMedium),
                                ),
                                 AutoSizeText(
                                  data.isPending
                                      ? AppLocalizations.of(context)!.pendingLabel
                                      : (data.isOffday
                                          ? AppLocalizations.of(context)!.dayOffLabel
                                          : AppLocalizations.of(context)!.shiftLabel),
                                  style: TextStyle(
                                    fontWeight: _wSemi,
                                    color: data.isPending
                                        ? HRColors.orangeColor
                                        : (data.isOffday
                                            ? HRColors.dutyOff
                                            : HRColors.shift),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Flexible(
                                          child: AutoSizeText(
                                            AppLocalizations.of(context)!
                                                .inLabel,
                                            style:
                                                TextStyle(fontWeight: _wMedium),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: AutoSizeText(
                                            inTime,
                                            style: _valueBold,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Flexible(
                                          child: AutoSizeText(
                                            AppLocalizations.of(context)!
                                                .outLabel,
                                            style:
                                                TextStyle(fontWeight: _wMedium),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: AutoSizeText(
                                            outTime,
                                            style: _valueBold,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                  header: Padding(
                    padding: const EdgeInsets.all(8),
                    child: AutoSizeText(
                        AppLocalizations.of(context)!.viewDetails,
                        style: const TextStyle(fontWeight: _wBold)),
                  ),
                  collapsed: const SizedBox.shrink(),
                  expanded: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Table(
                      border: TableBorder.symmetric(
                          inside: const BorderSide(width: 1)),
                      children: [
                        _tableRow(
                            AppLocalizations.of(context)!.workedHeader,
                            AppLocalizations.of(context)!.lateHeader,
                            AppLocalizations.of(context)!.overHeader,
                            header: true),
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
      child: AutoSizeText(
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
                            // _shiftCard(list),
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
                          AutoSizeText(
                            AppLocalizations.of(context)!.attendanceText,
                            style: _label14,
                          ),
                          TextButton(
                            onPressed: () => _loadAttendance(_tabType),
                            child: AutoSizeText(
                                AppLocalizations.of(context)!.refresh,
                                style: TextStyle(
                                    color: Colors.black87, fontWeight: _wBold)),
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
