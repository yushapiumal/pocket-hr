import 'package:auto_size_text/auto_size_text.dart';
import 'package:cn_pocket_hr/services/leave_service.dart';
import 'package:flutter/material.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

import 'package:cn_pocket_hr/api/api_service.dart';
import 'package:cn_pocket_hr/models/hr/leave_model.dart';
import 'package:cn_pocket_hr/helpers/hr_colors.dart';
import 'package:cn_pocket_hr/config/flavor_config.dart';

class MobileLeaveRequestPage extends StatefulWidget {
  final bool isEdit;
  final MyLeavesModel? initial;

  const MobileLeaveRequestPage({
    super.key,
    required this.isEdit,
    required this.initial,
  });

  @override
  State<MobileLeaveRequestPage> createState() => _MobileLeaveRequestPageState();
}

class _MobileLeaveRequestPageState extends State<MobileLeaveRequestPage> {
  static Color get _accent => HRColors.orangeColor;
  static const Color _pageBg = Colors.white;
  static const Color _surface = Color.fromARGB(255, 248, 250, 252);
  static const Color _textDark = Color(0xFF1F2937);
  static const Color _textMuted = Color(0xFF6B7280);

  final APIService apiService = APIService();

  final List<String> leaveTypeList = const [
    "annual",
    "casual",
    "medical",
  ];

  String? typeValue = "annual";
  String? leaveTypeValue = "full_day";
  String? shortLeaveSession = "morning";
  String? halfDaySession = "morning";
  final TextEditingController description = TextEditingController();

  DateTime fDate = DateTime.now();
  DateTime tDate = DateTime.now();

  String fromText = 'From';
  String toText = 'To';

  late Future<List<MyLeavesModel>> _myLeavesFuture;
  late Future<Map<String, dynamic>?> _leaveBalanceFuture;
  late Future<List<dynamic>> _combinedFuture;

  @override
  void initState() {
    super.initState();
    _myLeavesFuture = LeaveService.getMyLeaves();
    _leaveBalanceFuture = apiService.getLeaveBalance();
    _combinedFuture = Future.wait([_myLeavesFuture, _leaveBalanceFuture]);

    final m = widget.initial;
    if (m != null) {
      final rawType = m.leaveType.toString().trim().toLowerCase();
      final fallbackType = m.type.toString().trim().toLowerCase();
      final candidate = rawType.isNotEmpty
          ? rawType
          : (fallbackType.isNotEmpty ? fallbackType : 'annual');

      typeValue = leaveTypeList.contains(candidate) ? candidate : 'annual';
      description.text = m.description.toString();

      final fromStr = m.fromDate.toString();
      final toStr = m.toDate.toString();

      DateTime? tryParse(String s) {
        try {
          if (s.contains('/')) return DateFormat('dd/MM/yyyy').parse(s);
          if (s.contains('-')) return DateTime.tryParse(s);
        } catch (_) {}
        return null;
      }

      final fd = tryParse(fromStr);
      final td = tryParse(toStr);

      if (fd != null) {
        fDate = fd;
        fromText = DateFormat('dd/MM/yyyy').format(fd);
      }
      if (td != null) {
        tDate = td;
        toText = DateFormat('dd/MM/yyyy').format(td);
      }
    }

    if (typeValue == null || !leaveTypeList.contains(typeValue)) {
      typeValue = 'annual';
    }

    if (m == null) {
      final today = DateTime.now();
      final startWeek = _startOfWeek(today);
      fDate = startWeek;
      tDate = today;
      fromText = DateFormat('dd/MM/yyyy').format(fDate);
      toText = DateFormat('dd/MM/yyyy').format(tDate);
    }
  }

  DateTime _startOfWeek(DateTime d) {
    final int weekday = d.weekday;
    return DateTime(d.year, d.month, d.day)
        .subtract(Duration(days: weekday - 1));
  }

  @override
  void dispose() {
    description.dispose();
    super.dispose();
  }

  Future<void> _showTopMessage(
    String message, {
    bool error = false,
    Duration duration = const Duration(seconds: 3),
  }) async {
    if (!mounted) return;

    final overlay = Overlay.of(context);
    final topPadding = MediaQuery.of(context).padding.top + 10.0;
    final bg = error ? Colors.red.shade600 : Colors.green.shade600;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => Positioned(
        top: topPadding,
        left: 12,
        right: 12,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Row(
                children: [
                  Icon(
                    error
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AutoSizeText(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      try {
                        entry.remove();
                      } catch (_) {}
                    },
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    await Future.delayed(duration);
    try {
      entry.remove();
    } catch (_) {}
  }

  bool _isDefaultFromTo() => fromText == 'From' || toText == 'To';

  Future<DateTime?> _pickWheelDate({required DateTime initial}) async {
    final months = List<String>.generate(12, (i) {
      final dt = DateTime(DateTime.now().year, i + 1, 1);
      // Use Flutter's MaterialLocalizations to get a localized "Month Year" string,
      // then strip the year to keep only the localized month name.
      var label = MaterialLocalizations.of(context).formatMonthYear(dt);
      label = label
          .replaceAll(RegExp(r'\b\d{4}\b'), '')
          .replaceAll(RegExp(r',[\s]*'), '')
          .trim();
      return label;
    });
    final years = List<int>.generate(30, (i) => DateTime.now().year - 10 + i);
    int selMonth = initial.month;
    int selYear = initial.year;
    int selDay = initial.day;

    final monthController =
        FixedExtentScrollController(initialItem: selMonth - 1);
    final yearController = FixedExtentScrollController(
      initialItem: years.indexOf(selYear).clamp(0, years.length - 1),
    );
    int daysInMonth = DateUtils.getDaysInMonth(selYear, selMonth);
    selDay = selDay.clamp(1, daysInMonth);
    final dayController = FixedExtentScrollController(initialItem: selDay - 1);

    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            daysInMonth = DateUtils.getDaysInMonth(selYear, selMonth);
            final days = List<int>.generate(daysInMonth, (i) => i + 1);
            if (selDay > daysInMonth) selDay = daysInMonth;

            Widget wheel<T>({
              required FixedExtentScrollController controller,
              required List<T> items,
              required String Function(T) label,
              required void Function(int) onSelected,
            }) {
              return Expanded(
                child: SizedBox(
                  height: 170,
                  child: CupertinoPicker(
                    scrollController: controller,
                    itemExtent: 36,
                    useMagnifier: true,
                    magnification: 1.08,
                    selectionOverlay: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top:
                              BorderSide(color: Colors.black.withOpacity(0.08)),
                          bottom:
                              BorderSide(color: Colors.black.withOpacity(0.08)),
                        ),
                      ),
                    ),
                    onSelectedItemChanged: onSelected,
                    children: items
                        .map((e) => Center(
                              child: AutoSizeText(
                                label(e),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              );
            }

            return SafeArea(
              child: Container(
                margin: const EdgeInsets.all(14),
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                decoration: BoxDecoration(
                  color: HRColors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: _accent,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.close,
                              size: 16, color: Colors.white),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        wheel<String>(
                          controller: monthController,
                          items: months,
                          label: (m) => m,
                          onSelected: (i) {
                            setLocal(() {
                              selMonth = i + 1;
                              final dim =
                                  DateUtils.getDaysInMonth(selYear, selMonth);
                              if (selDay > dim) {
                                selDay = dim;
                                dayController.jumpToItem(selDay - 1);
                              }
                            });
                          },
                        ),
                        wheel<int>(
                          controller: dayController,
                          items: days,
                          label: (d) => d.toString(),
                          onSelected: (i) => setLocal(() => selDay = days[i]),
                        ),
                        wheel<int>(
                          controller: yearController,
                          items: years,
                          label: (y) => y.toString(),
                          onSelected: (i) {
                            setLocal(() {
                              selYear = years[i];
                              final dim =
                                  DateUtils.getDaysInMonth(selYear, selMonth);
                              if (selDay > dim) {
                                selDay = dim;
                                dayController.jumpToItem(selDay - 1);
                              }
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          try {
                            monthController.dispose();
                          } catch (_) {}
                          try {
                            dayController.dispose();
                          } catch (_) {}
                          try {
                            yearController.dispose();
                          } catch (_) {}
                          Navigator.pop(
                              ctx, DateTime(selYear, selMonth, selDay));
                        },
                        child: AutoSizeText(
                          AppLocalizations.of(context)!.confirmLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          side: BorderSide(
                              color: HRColors.black.withOpacity(0.10)),
                        ),
                        onPressed: () {
                          try {
                            monthController.dispose();
                          } catch (_) {}
                          try {
                            dayController.dispose();
                          } catch (_) {}
                          try {
                            yearController.dispose();
                          } catch (_) {}
                          Navigator.pop(ctx);
                        },
                        child: AutoSizeText(
                          AppLocalizations.of(context)!.cancelLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _modeButton(String title, String value, IconData icon) {
    final isSelected = leaveTypeValue == value;

    final String label = title == 'Half Day'
        ? AppLocalizations.of(context)!.halfDay
        : (title == 'Full Day'
            ? AppLocalizations.of(context)!.fullDay
            : (title == 'Short Leave'
                ? AppLocalizations.of(context)!.shortLeave
                : title));

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: InkWell(
          onTap: widget.isEdit
              ? null
              : () => setState(() => leaveTypeValue = value),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isSelected
                  ? const Color(0xFF791b27)
                  : const Color(0xFFF9FAFB),
              border: Border.all(
                color: isSelected ? Colors.transparent : Colors.grey.shade300,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF791b27).withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSelected ? const Color(0xFFeed06e) : _accent,
                ),
                const SizedBox(height: 5),
                AutoSizeText(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFeed06e) : _textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String text,
    required VoidCallback? onTap,
  }) {
    final isPlaceholder = text == 'From' || text == 'To';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _accent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  Icon(Icons.calendar_month_rounded, color: _accent, size: 16),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AutoSizeText(
                text,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isPlaceholder ? _textMuted : _textDark,
                  fontSize: 12,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 11, color: _textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool readOnly) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB15E), Color(0xFFFF8A1F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AutoSizeText(
                  readOnly
                      ? "View your leave information"
                      : "Fill in the details and submit your leave request",
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.white.withOpacity(0.92),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 48,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_accent, _accent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: _accent.withOpacity(0.20),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _confirmAndSubmit,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              AutoSizeText(
                AppLocalizations.of(context)!.submitRequest,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (typeValue == null || typeValue!.isEmpty) {
      await _showTopMessage(
        'Please select ${AppLocalizations.of(context)!.leaveTypeLabel}',
        error: true,
      );
      return;
    }
    if (_isDefaultFromTo()) {
      await _showTopMessage(
        'Please select ${AppLocalizations.of(context)!.fromToLabel}',
        error: true,
      );
      return;
    }

    // Prevent selecting past dates on submission
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (DateTime(fDate.year, fDate.month, fDate.day).isBefore(today) ||
        DateTime(tDate.year, tDate.month, tDate.day).isBefore(today)) {
      await _showTopMessage(
        AppLocalizations.of(context)!.cannotSelectPastDate,
        error: true,
      );
      return;
    }

    final fDateOnly = DateTime(fDate.year, fDate.month, fDate.day);
    final tDateOnly = DateTime(tDate.year, tDate.month, tDate.day);
    if (tDateOnly.isBefore(fDateOnly)) {
      await _showTopMessage(
        AppLocalizations.of(context)!.toDateMustBeAfterFrom,
        error: true,
      );
      return;
    }

    final res = await apiService.leave({
      'leave_title': 'Leave Request',
      'from_date': DateFormat('yyyy-MM-dd').format(fDate),
      'to_date': DateFormat('yyyy-MM-dd').format(tDate),
      'leave_type': typeValue,
      'type': leaveTypeValue ?? 'full_day',
      // Pass the session conditionally
      'session': leaveTypeValue == 'short_leave'
          ? shortLeaveSession
          : (leaveTypeValue == 'half'
              ? halfDaySession
              : (leaveTypeValue ?? 'full_day')),
      'description': description.text,
    });

    try {
      final statusCode = (res is Map && res.containsKey('statusCode'))
          ? res['statusCode']
          : 500;

      if (statusCode == 200 || statusCode == 201) {
        // If it's a "success": true response, maybe the inner 'data' payload has success: false (Backend validation)
        if (res['data'] is Map &&
            (res['data']['success'] == false ||
                res['data']['success'] == 'false')) {
          String errMsg =
              'Your leave quota is over. Contact your merchant.'; // generic message mapped
          if (res['data']['errors'] != null &&
              res['data']['errors'].toString().isNotEmpty) {
            errMsg = res['data']['errors'].toString();
          }
          await _showTopMessage(errMsg, error: true);
          return;
        }

        await _showTopMessage(
            AppLocalizations.of(context)!.leaveAppliedSuccessfully,
            error: false);
        if (mounted) Navigator.pop(context, true);
        return;
      }

      if (statusCode == 401 || statusCode == 403) {
        await _showTopMessage(AppLocalizations.of(context)!.sessionExpired,
            error: true);
        return;
      }

      if (statusCode == 400 || statusCode == 422) {
        await _showTopMessage(
            AppLocalizations.of(context)!.invalidDetailsPleaseCheckYourForm,
            error: true);
        return;
      }

      await _showTopMessage(AppLocalizations.of(context)!.failedToSubmitLeave,
          error: true);
      return;
    } catch (_) {}

    await _showTopMessage(AppLocalizations.of(context)!.failedToSubmitLeave,
        error: true);
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Expanded(
              child: AutoSizeText(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _textMuted,
                  fontSize: 12,
                ),
              ),
            ),
            AutoSizeText(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: _textDark,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showLeaveConfirmationDialog() async {
    final days = tDate.difference(fDate).inDays + 1;

    return showGeneralDialog<bool>(
      context: context,
      barrierLabel: 'Confirm Leave',
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.45),
      transitionDuration: const Duration(milliseconds: 280),
      pageBuilder: (ctx, a1, a2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: curved,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.14),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: _accent.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.assignment_turned_in_rounded,
                          color: _accent,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AutoSizeText(
                        AppLocalizations.of(context)!.confirmLeave,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: _textDark,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _infoRow(
                        AppLocalizations.of(context)!.fromLabel,
                        DateFormat('dd/MM/yyyy').format(fDate),
                      ),
                      _infoRow(
                        AppLocalizations.of(context)!.toLabel,
                        DateFormat('dd/MM/yyyy').format(tDate),
                      ),
                      _infoRow(
                        AppLocalizations.of(context)!.daysLabel,
                        '$days',
                      ),
                      _infoRow(
                        AppLocalizations.of(context)!.leaveTypeLabel,
                        (typeValue ?? '').toString(),
                      ),
                      if (description.text.trim().isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: AutoSizeText(
                            AppLocalizations.of(context)!.noteLabel,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: _textDark,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: AutoSizeText(
                            description.text.trim(),
                            style: const TextStyle(
                              color: _textDark,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(42),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                              child: AutoSizeText(
                                AppLocalizations.of(context)!.cancelLabel,
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accent,
                                elevation: 0,
                                minimumSize: const Size.fromHeight(42),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: AutoSizeText(
                                AppLocalizations.of(context)!.confirmLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmAndSubmit() async {
    if (typeValue == null || typeValue!.isEmpty) {
      await _showTopMessage(
        'Please select ${AppLocalizations.of(context)!.leaveTypeLabel}',
        error: true,
      );
      return;
    }
    if (_isDefaultFromTo()) {
      await _showTopMessage(
        'Please select ${AppLocalizations.of(context)!.fromToLabel}',
        error: true,
      );
      return;
    }

    // Prevent selecting past dates on submission confirmation
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (DateTime(fDate.year, fDate.month, fDate.day).isBefore(today) ||
        DateTime(tDate.year, tDate.month, tDate.day).isBefore(today)) {
      await _showTopMessage(
        AppLocalizations.of(context)!.cannotSelectPastDate,
        error: true,
      );
      return;
    }

    final fDateOnlyConfirm = DateTime(fDate.year, fDate.month, fDate.day);
    final tDateOnlyConfirm = DateTime(tDate.year, tDate.month, tDate.day);
    if (tDateOnlyConfirm.isBefore(fDateOnlyConfirm)) {
      await _showTopMessage(
        AppLocalizations.of(context)!.toDateMustBeAfterFrom,
        error: true,
      );
      return;
    }

    try {
      final balanceData = await _leaveBalanceFuture;
      if (balanceData != null && balanceData['balance'] != null) {
        final currentType = typeValue!.toLowerCase();

        // Skip balance check for unpaid/no-pay leave types
        if (currentType != 'nopay' && currentType != 'unpaid') {
          final bal = balanceData['balance'][currentType];
          final num availableBalance =
              (bal is num) ? bal : num.tryParse(bal?.toString() ?? '') ?? 0;

          if (availableBalance <= 0) {
            await _showTopMessage(
              'Your leave quota is over. Contact your merchant.',
              error: true,
            );
            return;
          }
        }
      }
    } catch (_) {}

    final confirmed = await _showLeaveConfirmationDialog();
    if (confirmed == true) {
      await _submit();
    }
  }

  String _getLeaveTypeLabel(String v) {
    switch (v) {
      case 'annual':
        return AppLocalizations.of(context)!.annualLabel;
      case 'casual':
        return AppLocalizations.of(context)!.casualLabel;
      case 'medical':
        return AppLocalizations.of(context)!.medicalLabel;
      default:
        return v[0].toUpperCase() + v.substring(1);
    }
  }

  Widget _sectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.10),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: _accent, size: 15),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: AutoSizeText(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: _textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestedLeavesCard() {
    // We combine the two futures (leaves history and balance)
    return FutureBuilder(
      future: _combinedFuture,
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: CupertinoActivityIndicator(
                color: _accent,
                radius: 16.0,
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return const SizedBox.shrink(); // Hide if error
        }

        final leavesData = snapshot.data?[0] as List<MyLeavesModel>? ?? [];
        final balanceData = snapshot.data?[1] as Map<String, dynamic>?;

        final pendingLeavesCount = leavesData
            .where((l) =>
                l.status.trim().toLowerCase() == 'pending' ||
                l.status.trim().toLowerCase() == 'requested')
            .length;

        final totalLeavesCount = leavesData.length;

        // Parse balance
        Map<String, dynamic> balanceNested = {};
        if (balanceData != null && balanceData['balance'] != null) {
          balanceNested = Map<String, dynamic>.from(balanceData['balance']);
        }

        // We filter out 0 values just keeping it clean, or show all
        List<Widget> balanceChips = [];
        balanceNested.forEach((key, value) {
          balanceChips.add(
            Container(
              margin: const EdgeInsets.only(right: 8, top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AutoSizeText(
                    '${_getLeaveTypeLabel(key.toLowerCase())}: ',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                  AutoSizeText(
                    value.toString(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
          );
        });

        return Container(
          margin: const EdgeInsets.only(bottom: 20, top: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                FlavorConfig.instance.secondaryColor,
                FlavorConfig.instance.secondaryColor.withOpacity(0.75),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: FlavorConfig.instance.secondaryColor.withOpacity(0.28),
                blurRadius: 14,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.history_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AutoSizeText(
                          AppLocalizations.of(context)!.leaveSummary,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4),
                        AutoSizeText(
                          "${AppLocalizations.of(context)!.totalRequests}: $totalLeavesCount • ${AppLocalizations.of(context)!.pendindingLable}: $pendingLeavesCount",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (balanceChips.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 8),
                AutoSizeText(
                  AppLocalizations.of(context)!.availableBalance,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Wrap(
                  children: balanceChips,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final readOnly = widget.isEdit;

    return Scaffold(
      backgroundColor: _pageBg,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: _pageBg,
        surfaceTintColor: _pageBg,
        elevation: 0,
        centerTitle: true,
        title: AutoSizeText(
          readOnly
              ? AppLocalizations.of(context)!.leaveDetailsLabel
              : AppLocalizations.of(context)!.leaveRequestLabel,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            color: _textDark,
            fontSize: 17,
          ),
        ),
        iconTheme: const IconThemeData(color: _textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!readOnly) _buildRequestedLeavesCard(),
            // _buildHeader(readOnly),
            // const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(color: Colors.black.withOpacity(0.04)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: DropdownButton<String>(
                      underline: const SizedBox.shrink(),
                      dropdownColor: HRColors.white,
                      borderRadius: BorderRadius.circular(14),
                      value: typeValue,
                      iconEnabledColor: _textDark,
                      isExpanded: true,
                      onChanged: readOnly
                          ? null
                          : (v) => setState(() => typeValue = v),
                      items: leaveTypeList.map((v) {
                        return DropdownMenuItem<String>(
                          value: v,
                          child: AutoSizeText(
                            _getLeaveTypeLabel(v),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: _textDark,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _modeButton('Half Day', 'half', Icons.timelapse_rounded),
                      const SizedBox(width: 8),
                      _modeButton(
                          'Full Day', 'full_day', Icons.wb_sunny_outlined),
                      const SizedBox(width: 8),
                      _modeButton('Short Leave', 'short_leave',
                          Icons.access_time_rounded),
                    ],
                  ),

                  // Show dropdown only if Short Leave is selected

                  const SizedBox(height: 20),
                  _sectionHeader(
                    AppLocalizations.of(context)!.fromToLabel,
                    Icons.date_range_rounded,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
                          text: fromText,
                          onTap: readOnly
                              ? null
                              : () async {
                                  final picked =
                                      await _pickWheelDate(initial: fDate);
                                  if (picked == null) return;

                                  setState(() {
                                    fDate = picked;
                                    fromText =
                                        DateFormat('dd/MM/yyyy').format(picked);
                                  });
                                },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _buildDateField(
                          text: toText,
                          onTap: readOnly
                              ? null
                              : () async {
                                  final picked =
                                      await _pickWheelDate(initial: tDate);
                                  if (picked == null) return;

                                  setState(() {
                                    tDate = picked;
                                    toText =
                                        DateFormat('dd/MM/yyyy').format(picked);
                                  });
                                },
                        ),
                      ),
                    ],
                  ),

                  if (leaveTypeValue == 'short_leave') ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: readOnly
                                  ? null
                                  : () => setState(
                                      () => shortLeaveSession = 'morning'),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: shortLeaveSession == 'morning'
                                      ? const Color(0xFF791b27)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: AutoSizeText(
                                    AppLocalizations.of(context)!.morning,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: shortLeaveSession == 'morning'
                                          ? const Color(0xFFeed06e)
                                          : _textDark,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: InkWell(
                              onTap: readOnly
                                  ? null
                                  : () => setState(
                                      () => shortLeaveSession = 'evening'),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: shortLeaveSession == 'evening'
                                      ? const Color(0xFF791b27)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: AutoSizeText(
                                    AppLocalizations.of(context)!.evening,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: shortLeaveSession == 'evening'
                                          ? const Color(0xFFeed06e)
                                          : _textDark,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const SizedBox(height: 20),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: description,
                      enabled: !readOnly,
                      minLines: 2,
                      maxLines: 4,
                      style: const TextStyle(
                        color: _textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText:
                            '${AppLocalizations.of(context)!.noteLabel} (${AppLocalizations.of(context)!.optional})',
                        hintStyle: const TextStyle(
                          color: _textMuted,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  if (!readOnly) ...[
                    const SizedBox(height: 28),
                    _buildSubmitButton(),
                    const SizedBox(height: 28),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
