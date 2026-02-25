import 'package:flutter/material.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

import 'package:cn_pocket_hr/api/apiService.dart';
import 'package:cn_pocket_hr/model/hr/LeaveModel.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';

class MobileLeaveRequestPage extends StatefulWidget {
  final bool isEdit;
  final MyLeavesModel? initial;

  const MobileLeaveRequestPage({super.key, required this.isEdit, required this.initial});

  @override
  State<MobileLeaveRequestPage> createState() => _MobileLeaveRequestPageState();
}

class _MobileLeaveRequestPageState extends State<MobileLeaveRequestPage> {
  static const Color _accent = HRColors.orangeColor;
  static const Color _accentLight = HRColors.lightOrangeColor;

  static const Color _pageBg = Colors.white;
  static const Color _surface = Color.fromARGB(255, 248, 250, 252);

  final APIService apiService = APIService();

  final List<String> leaveTypeList = const ["annual", "casual", "medical", "duty", "nopay"];

  String? typeValue = "annual";
  String? leaveTypeValue = "full_day";
  final TextEditingController description = TextEditingController();

  DateTime fDate = DateTime.now();
  DateTime tDate = DateTime.now();

  String fromText = 'From';
  String toText = 'To';

  @override
  void initState() {
    super.initState();

    final m = widget.initial;
    if (m != null) {
      final rawType = m.leaveType.toString().trim().toLowerCase();
      final fallbackType = m.type.toString().trim().toLowerCase();
      final candidate = rawType.isNotEmpty ? rawType : (fallbackType.isNotEmpty ? fallbackType : 'annual');
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

    // If no initial leave provided, default From = start of this week (Monday), To = today
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
    // Treat Monday as start of week
    final int weekday = d.weekday; // 1 = Monday
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: weekday - 1));
  }

  @override
  void dispose() {
    description.dispose();
    super.dispose();
  }

  // Show a transient message banner at the top of the page.
  Future<void> _showTopMessage(String message, {bool error = false, Duration duration = const Duration(seconds: 3)}) async {
    if (!mounted) return;
    final overlay = Overlay.of(context);
    final topPadding = MediaQuery.of(context).padding.top + 8.0;
    final bg = error ? Colors.red.shade700 : HRColors.darkOrangeColor;

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
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            child: SafeArea(
              top: false,
              bottom: false,
              child: Row(
                children: [
                  Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                  const SizedBox(width: 8),
                  GestureDetector(onTap: () { try { entry.remove(); } catch (_) {} }, child: const Icon(Icons.close, color: Colors.white, size: 18)),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    await Future.delayed(duration);
    try { entry.remove(); } catch (_) {}
  }

  bool _isDefaultFromTo() => fromText == 'From' || toText == 'To';

  Future<DateTime?> _pickWheelDate({required DateTime initial}) async {
    final months = List<int>.generate(12, (i) => i + 1);
    final years = List<int>.generate(30, (i) => DateTime.now().year - 10 + i);
    int selMonth = initial.month;
    int selYear = initial.year;
    int selDay = initial.day;

    // Create controllers with initialItem so picker shows the initial date
    final monthController = FixedExtentScrollController(initialItem: selMonth - 1);
    final yearController = FixedExtentScrollController(initialItem: years.indexOf(selYear).clamp(0, years.length - 1));
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
                          top: BorderSide(color: Colors.black.withOpacity(0.08)),
                          bottom: BorderSide(color: Colors.black.withOpacity(0.08)),
                        ),
                      ),
                    ),
                    onSelectedItemChanged: onSelected,
                    children: items
                        .map((e) => Center(
                              child: Text(
                                label(e),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10), blurRadius: 24, offset: const Offset(0, 10))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(color: _accent, shape: BoxShape.circle),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(Icons.close, size: 16, color: Colors.white),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        wheel<int>(
                          controller: monthController,
                          items: months,
                          label: (m) => DateFormat.MMMM().format(DateTime(2000, m, 1)),
                          onSelected: (i) {
                            setLocal(() {
                              selMonth = months[i];
                              final dim = DateUtils.getDaysInMonth(selYear, selMonth);
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
                              final dim = DateUtils.getDaysInMonth(selYear, selMonth);
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
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        onPressed: () {
                          // dispose controllers before popping
                          try { monthController.dispose(); } catch (_) {}
                          try { dayController.dispose(); } catch (_) {}
                          try { yearController.dispose(); } catch (_) {}
                          Navigator.pop(ctx, DateTime(selYear, selMonth, selDay));
                        },
                        child: Text(AppLocalizations.of(context)!.confirmLabel, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          side: BorderSide(color: HRColors.black.withOpacity(0.10)),
                        ),
                        onPressed: () {
                          try { monthController.dispose(); } catch (_) {}
                          try { dayController.dispose(); } catch (_) {}
                          try { yearController.dispose(); } catch (_) {}
                          Navigator.pop(ctx);
                        },
                        child: Text(AppLocalizations.of(context)!.cancelLabel, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.black87)),
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

  Widget _modeButton(String title, String value) {
    final isSelected = leaveTypeValue == value;
    return Expanded(
      child: InkWell(
        onTap: widget.isEdit ? null : () => setState(() => leaveTypeValue = value),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _accentLight : HRColors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              // Mode titles passed from caller; localize common ones
              title == 'Half Day'
                  ? AppLocalizations.of(context)!.halfDay
                  : (title == 'Full Day'
                      ? AppLocalizations.of(context)!.fullDay
                      : (title == 'Alternative'
                          ? AppLocalizations.of(context)!.alternative
                          : title)),
              style: TextStyle(
                color: isSelected ? _accent : HRColors.black,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HRColors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: HRColors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: HRColors.darkFontColor)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _gradientActionButton({
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(56),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [HRColors.orangeColor, HRColors.orangeColor],
            ),
            boxShadow: [
              BoxShadow(
                color: HRColors.black.withOpacity(0.18),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Icon(Icons.check_rounded, color: HRColors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (typeValue == null || typeValue!.isEmpty) {
      await _showTopMessage('Please select ${AppLocalizations.of(context)!.leaveTypeLabel}', error: true);
      return;
    }
    if (_isDefaultFromTo()) {
      await _showTopMessage('Please select ${AppLocalizations.of(context)!.fromToLabel}', error: true);
      return;
    }
    if (tDate.isBefore(fDate)) {
      await _showTopMessage(AppLocalizations.of(context)!.toDateMustBeAfterFrom, error: true);
      return;
    }

    final res = await apiService.leave({
      'leave_title': 'Leave Request',
      'from_date': DateFormat('yyyy-MM-dd').format(fDate),
      'to_date': DateFormat('yyyy-MM-dd').format(tDate),
      'leave_type': typeValue,
      'type': leaveTypeValue ?? 'full_day',
      'session': leaveTypeValue ?? 'full_day',
      'description': description.text,
    });

    try {
      if (res is Map && (res['status'] == true || res['status'] == 'true')) {
        final msg = (res['message'] ?? 'Submitted').toString();
        await _showTopMessage(msg, error: false);
        if (mounted) Navigator.pop(context, true);
        return;
      }

      if (res is Map) {
        String msg = '';
        try {
          if (res['errors'] is Map && res['errors']['message'] != null && res['errors']['message'].toString().trim().isNotEmpty) {
            msg = res['errors']['message'].toString();
          } else if (res['message'] != null && res['message'].toString().trim().isNotEmpty) {
            msg = res['message'].toString();
          }
        } catch (_) {}
        if (msg.isEmpty) msg = 'Failed to submit leave.';
        await _showTopMessage(msg, error: true);
        return;
      }
    } catch (_) {}

    await _showTopMessage('Failed to submit leave.', error: true);
  }



  Future<bool?> _showLeaveConfirmationDialog() async {
    final days = tDate.difference(fDate).inDays + 1;
    return showGeneralDialog<bool>(
      context: context,
      barrierLabel: 'Confirm Leave',
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (ctx, a1, a2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: curved,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 20)],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppLocalizations.of(context)!.confirmLeave, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 12),
                      Row(children: [Expanded(child: Text(AppLocalizations.of(context)!.fromLabel, style: TextStyle(fontWeight: FontWeight.w700))), Text(DateFormat('dd/MM/yyyy').format(fDate))]),
                      const SizedBox(height: 6),
                      Row(children: [Expanded(child: Text(AppLocalizations.of(context)!.toLabel, style: TextStyle(fontWeight: FontWeight.w700))), Text(DateFormat('dd/MM/yyyy').format(tDate))]),
                      const SizedBox(height: 6),
                      Row(children: [Expanded(child: Text(AppLocalizations.of(context)!.daysLabel, style: TextStyle(fontWeight: FontWeight.w700))), Text('$days')]),
                      const SizedBox(height: 6),
                      Row(children: [Expanded(child: Text(AppLocalizations.of(context)!.leaveTypeLabel, style: TextStyle(fontWeight: FontWeight.w700))), Text((typeValue ?? '').toString())]),
                      const SizedBox(height: 8),
                      if (description.text.trim().isNotEmpty)
                        Column(children: [Align(alignment: Alignment.centerLeft, child: Text(AppLocalizations.of(context)!.noteLabel, style: TextStyle(fontWeight: FontWeight.w700))), const SizedBox(height: 4), Text(description.text.trim())]),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(AppLocalizations.of(context)!.cancelLabel),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              style: ElevatedButton.styleFrom(backgroundColor: _accent),
                              child: Text(AppLocalizations.of(context)!.confirmLabel, style: const TextStyle(color: Colors.white)),
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
      await _showTopMessage('Please select ${AppLocalizations.of(context)!.leaveTypeLabel}', error: true);
      return;
    }
    if (_isDefaultFromTo()) {
      await _showTopMessage('Please select ${AppLocalizations.of(context)!.fromToLabel}', error: true);
      return;
    }
    if (tDate.isBefore(fDate)) {
      await _showTopMessage(AppLocalizations.of(context)!.toDateMustBeAfterFrom, error: true);
      return;
    }

    final confirmed = await _showLeaveConfirmationDialog();
    if (confirmed == true) {
      await _submit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final readOnly = widget.isEdit;

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: _pageBg,
        surfaceTintColor: _pageBg,
        elevation: 0,
        title: Text(readOnly ? AppLocalizations.of(context)!.leaveDetailsLabel : AppLocalizations.of(context)!.leaveRequestLabel, style: const TextStyle(fontWeight: FontWeight.w900, color: HRColors.black)),
        iconTheme: const IconThemeData(color: HRColors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(
              title: AppLocalizations.of(context)!.leaveTypeLabel,
               child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: HRColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: HRColors.black.withOpacity(0.10)),
                ),
                child: DropdownButton<String>(
                  underline: const SizedBox.shrink(),
                  dropdownColor: HRColors.white,
                  value: typeValue,
                  iconEnabledColor: HRColors.darkFontColor,
                  isExpanded: true,
                  onChanged: readOnly ? null : (v) => setState(() => typeValue = v),
                  items: leaveTypeList
                      .map((v) {
                        String label;
                        switch (v) {
                          case 'annual':
                            label = AppLocalizations.of(context)!.annualLabel;
                            break;
                          case 'casual':
                            label = AppLocalizations.of(context)!.casualLabel;
                            break;
                          case 'medical':
                            label = AppLocalizations.of(context)!.medicalLabel;
                            break;
                          case 'duty':
                            label = 'Duty';
                            break;
                          case 'nopay':
                            label = 'No-Pay';
                            break;
                          default:
                            label = v[0].toUpperCase() + v.substring(1);
                        }
                        return DropdownMenuItem<String>(
                          value: v,
                          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: HRColors.black)),
                        );
                      }).toList(),
                ),
              ),
            ),

            _sectionCard(
              title: AppLocalizations.of(context)!.leaveMode,
               child: Row(
                children: [
                  _modeButton('Half Day', 'half_day'),
                  const SizedBox(width: 8),
                  _modeButton('Full Day', 'full_day'),
                  const SizedBox(width: 8),
                  _modeButton('Alternative', 'alternative'),
                ],
              ),
            ),

            _sectionCard(
              title: AppLocalizations.of(context)!.fromToLabel,
               child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: readOnly
                          ? null
                          : () async {
                              final picked = await _pickWheelDate(initial: fDate);
                              if (picked == null) return;

                              // normalize to date only
                              final pickedDate = DateTime(picked.year, picked.month, picked.day);
                              final today = DateTime.now();
                              final todayDate = DateTime(today.year, today.month, today.day);

                              if (pickedDate.isBefore(todayDate)) {
                                apiService.showToast(AppLocalizations.of(context)!.cannotSelectPastDate);
                                return;
                              }

                              // If selected From is after current To, show error
                              final currentTo = DateTime(tDate.year, tDate.month, tDate.day);
                              if (pickedDate.isAfter(currentTo)) {
                                apiService.showToast(AppLocalizations.of(context)!.fromDateCannotBeAfterTo);
                                return;
                              }

                              setState(() {
                                fDate = pickedDate;
                                fromText = DateFormat('dd/MM/yyyy').format(pickedDate);
                              });
                            },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: HRColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: HRColors.black.withOpacity(0.10)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              fromText,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: fromText == 'From' ? HRColors.lightFontColor : HRColors.black,
                              ),
                            ),
                            const Icon(Icons.calendar_month, size: 18, color: _accent),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: readOnly
                          ? null
                          : () async {
                              final picked = await _pickWheelDate(initial: tDate);
                              if (picked == null) return;

                              final pickedDate = DateTime(picked.year, picked.month, picked.day);
                              final today = DateTime.now();
                              final todayDate = DateTime(today.year, today.month, today.day);

                              if (pickedDate.isBefore(todayDate)) {
                                apiService.showToast(AppLocalizations.of(context)!.cannotSelectPastDate);
                                return;
                              }

                              // If selected To is before current From, show error
                              final currentFrom = DateTime(fDate.year, fDate.month, fDate.day);
                              if (pickedDate.isBefore(currentFrom)) {
                                apiService.showToast(AppLocalizations.of(context)!.toDateMustBeAfterFrom);
                                return;
                              }

                              setState(() {
                                tDate = pickedDate;
                                toText = DateFormat('dd/MM/yyyy').format(pickedDate);
                              });
                            },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: HRColors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: HRColors.black.withOpacity(0.10)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              toText,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: toText == 'To' ? HRColors.lightFontColor : HRColors.black,
                              ),
                            ),
                            const Icon(Icons.calendar_month, size: 18, color: _accent),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _sectionCard(
              title: AppLocalizations.of(context)!.noteLabel,
               child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: HRColors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: HRColors.black.withOpacity(0.10)),
                ),
                child: TextField(
                  controller: description,
                  enabled: !readOnly,
                  minLines: 2,
                  maxLines: 4,
                  style: const TextStyle(color: HRColors.darkFontColor, fontWeight: FontWeight.w700),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '${AppLocalizations.of(context)!.noteLabel} (${AppLocalizations.of(context)!.optional})',
                    hintStyle: const TextStyle(color: HRColors.black, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            if (!readOnly)
              Align(
                alignment: Alignment.centerRight,
                child: _gradientActionButton(
                  onTap: _confirmAndSubmit,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
