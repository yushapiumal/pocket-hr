import 'package:flutter/material.dart';
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

  final APIService apiService = APIService();

  final List<String> leaveTypeList = const ["annual", "casual", "medical", "duty", "nopay"];

  String? typeValue = "annual";
  String? leaveTypeValue = "full_day";
  final TextEditingController description = TextEditingController();

  DateTime fDate = DateTime.now();
  DateTime tDate = DateTime.now();

  String fromText = 'From';
  String toText = 'To';

  final FixedExtentScrollController _monthWheel = FixedExtentScrollController();
  final FixedExtentScrollController _dayWheel = FixedExtentScrollController();
  final FixedExtentScrollController _yearWheel = FixedExtentScrollController();

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
          // handle both yyyy-MM-dd and dd/MM/yyyy
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

    // Final safety: DropdownButton requires its value to exist exactly once in items.
    if (typeValue == null || !leaveTypeList.contains(typeValue)) {
      typeValue = 'annual';
    }
  }

  @override
  void dispose() {
    description.dispose();
    _monthWheel.dispose();
    _dayWheel.dispose();
    _yearWheel.dispose();
    super.dispose();
  }

  bool _isDefaultFromTo() => fromText == 'From' || toText == 'To';

  Future<DateTime?> _pickWheelDate({required DateTime initial}) async {
    final months = List<int>.generate(12, (i) => i + 1);
    final years = List<int>.generate(30, (i) => DateTime.now().year - 10 + i);
    int selMonth = initial.month;
    int selYear = initial.year;
    int selDay = initial.day;

    _monthWheel.jumpToItem(selMonth - 1);
    _yearWheel.jumpToItem(years.indexOf(selYear).clamp(0, years.length - 1));

    int daysInMonth = DateUtils.getDaysInMonth(selYear, selMonth);
    selDay = selDay.clamp(1, daysInMonth);
    _dayWheel.jumpToItem(selDay - 1);

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
                          controller: _monthWheel,
                          items: months,
                          label: (m) => DateFormat.MMMM().format(DateTime(2000, m, 1)),
                          onSelected: (i) {
                            setLocal(() {
                              selMonth = months[i];
                              final dim = DateUtils.getDaysInMonth(selYear, selMonth);
                              if (selDay > dim) {
                                selDay = dim;
                                _dayWheel.jumpToItem(selDay - 1);
                              }
                            });
                          },
                        ),
                        wheel<int>(
                          controller: _dayWheel,
                          items: days,
                          label: (d) => d.toString(),
                          onSelected: (i) => setLocal(() => selDay = days[i]),
                        ),
                        wheel<int>(
                          controller: _yearWheel,
                          items: years,
                          label: (y) => y.toString(),
                          onSelected: (i) {
                            setLocal(() {
                              selYear = years[i];
                              final dim = DateUtils.getDaysInMonth(selYear, selMonth);
                              if (selDay > dim) {
                                selDay = dim;
                                _dayWheel.jumpToItem(selDay - 1);
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
                        onPressed: () => Navigator.pop(ctx, DateTime(selYear, selMonth, selDay)),
                        child: const Text('Confirm', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.white)),
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
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w800, color: Colors.black87)),
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
              title,
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
        color: HRColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HRColors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(color: HRColors.black.withOpacity(0.05), blurRadius: 14, offset: const Offset(0, 8)),
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
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 52,
          padding: const EdgeInsets.only(right: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
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
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 20),
              Text(
                label,
                style: const TextStyle(color: HRColors.white, fontWeight: FontWeight.w900, letterSpacing: 1.0),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: HRColors.white),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (typeValue == null || typeValue!.isEmpty) {
      apiService.showToast('Please select leave type');
      return;
    }
    if (_isDefaultFromTo()) {
      apiService.showToast('Please select From and To dates');
      return;
    }
    if (tDate.isBefore(fDate)) {
      apiService.showToast('To date must be after From date');
      return;
    }

    final ok = await apiService.leave({
      'leave_title': 'Leave Request',
      'from_date': DateFormat('yyyy-MM-dd').format(fDate),
      'to_date': DateFormat('yyyy-MM-dd').format(tDate),
      'leave_type': typeValue,
      'type': leaveTypeValue ?? 'full_day',
      'session': leaveTypeValue ?? 'full_day',
      'description': description.text,
    });

    if (ok == true && mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final readOnly = widget.isEdit;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 244, 246),
      appBar: AppBar(
        backgroundColor: HRColors.white,
        surfaceTintColor: HRColors.white,
        elevation: 0,
        title: Text(readOnly ? 'Leave Details' : 'Leave Request', style: const TextStyle(fontWeight: FontWeight.w900, color: HRColors.black)),
        iconTheme: const IconThemeData(color: HRColors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionCard(
              title: 'Leave Type',
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
                      .map((v) => DropdownMenuItem<String>(
                            value: v,
                            child: Text(
                              v[0].toUpperCase() + v.substring(1),
                              style: const TextStyle(fontWeight: FontWeight.w600, color: HRColors.black),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),

            _sectionCard(
              title: 'Leave Mode',
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
              title: 'From / To',
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: readOnly
                          ? null
                          : () async {
                              final picked = await _pickWheelDate(initial: fDate);
                              if (picked == null) return;
                              setState(() {
                                fDate = picked;
                                fromText = DateFormat('dd/MM/yyyy').format(picked);
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
                              setState(() {
                                tDate = picked;
                                toText = DateFormat('dd/MM/yyyy').format(picked);
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
              title: 'Description',
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
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Description (optional)',
                    hintStyle: TextStyle(color: HRColors.black, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            if (!readOnly)
              Align(
                alignment: Alignment.centerRight,
                child: _gradientActionButton(
                  label: 'APPLY',
                  //icon: Icons.menu,
                  onTap: _submit,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
