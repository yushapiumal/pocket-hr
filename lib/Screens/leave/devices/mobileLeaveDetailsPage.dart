import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:cn_pocket_hr/model/hr/LeaveModel.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';

class MobileLeaveDetailsPage extends StatelessWidget {
  final MyLeavesModel model;

  const MobileLeaveDetailsPage({super.key, required this.model});

  // Use app theme accent
  static const Color _accent = HRColors.blueColor;

  String _fmtDate(String s) {
    final raw = s.toString();
    if (raw.isEmpty) return '';
    // if already dd/MM/yyyy keep
    if (raw.contains('/')) return raw;
    // try parse yyyy-MM-dd
    final d = DateTime.tryParse(raw);
    if (d == null) return raw;
    return DateFormat('dd/MM/yyyy').format(d);
  }

  Widget _tile(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: HRColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HRColors.black.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: HRColors.black.withOpacity(0.55))),
          const SizedBox(height: 6),
          Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: HRColors.black)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = model.leaveTitle.toString();
    final type = model.leaveType.toString();
    final status = model.status.toString();
    final from = _fmtDate(model.fromDate.toString());
    final to = _fmtDate(model.toDate.toString());
    final desc = model.description.toString();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 244, 246),
      appBar: AppBar(
        backgroundColor: HRColors.white,
        surfaceTintColor: HRColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: HRColors.black),
        title: const Text('Leave Details', style: TextStyle(fontWeight: FontWeight.w900, color: HRColors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: HRColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: HRColors.black.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: _accent.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.event_note, color: _accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title.isEmpty ? 'Leave Request' : title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: HRColors.black)),
                        const SizedBox(height: 4),
                        Text('$from  -  $to', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: HRColors.black.withOpacity(0.55))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            _tile('Leave Type', type),
            _tile('Status', status),
            _tile('From', from),
            _tile('To', to),
            _tile('Description', desc),
          ],
        ),
      ),
    );
  }
}
