import 'dart:io';

import 'package:cn_pocket_hr/api/apiService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class SalarySlipDetailPage extends StatefulWidget {
  const SalarySlipDetailPage({Key? key, required this.item}) : super(key: key);

  final dynamic item; // expects _HomeItem from MobileSalarySlip

  @override
  State<SalarySlipDetailPage> createState() => _SalarySlipDetailPageState();
}

class _SalarySlipDetailPageState extends State<SalarySlipDetailPage> {
  final APIService _api = APIService();

  bool _downloading = false;

  Future<File> _buildDummyPdf({required String filePath}) async {
    final title = widget.item.title?.toString() ?? 'Salary Slip';
    final from = widget.item.from?.toString() ?? '';
    final to = widget.item.to?.toString() ?? '';

    // Dummy numbers
    const basic = 120000.00;
    const allowance = 25000.00;
    const bonus = 10000.00;
    const epf = 9600.00;
    const tax = 5000.00;
    const other = 1200.00;

    final gross = basic + allowance + bonus;
    final deductions = epf + tax + other;
    final net = gross - deductions;

    final doc = pw.Document();

    pw.Widget row2(String a, String b) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(a, style: const pw.TextStyle(fontSize: 11)),
            pw.Text(b, style:  pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
          ],
        ),
      );
    }

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (context) => [
          pw.Text('Pocket HR', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.orange)),
          pw.SizedBox(height: 6),
          pw.Text(title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 14),

          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                row2('Period From', from),
                row2('Period To', to),
                row2('Employee', 'John Doe'),
                row2('EPF No', 'EPF-00123'),
                row2('Department', 'Engineering'),
              ],
            ),
          ),

          pw.SizedBox(height: 16),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Earnings', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                      pw.Divider(color: PdfColors.grey400),
                      row2('Basic Salary', basic.toStringAsFixed(2)),
                      row2('Allowance', allowance.toStringAsFixed(2)),
                      row2('Bonus', bonus.toStringAsFixed(2)),
                      pw.Divider(color: PdfColors.grey400),
                      row2('Gross', gross.toStringAsFixed(2)),
                    ],
                  ),
                ),
              ),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Deductions', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
                      pw.Divider(color: PdfColors.grey400),
                      row2('EPF', epf.toStringAsFixed(2)),
                      row2('Tax', tax.toStringAsFixed(2)),
                      row2('Other', other.toStringAsFixed(2)),
                      pw.Divider(color: PdfColors.grey400),
                      row2('Total', deductions.toStringAsFixed(2)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 16),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(14),
            decoration: pw.BoxDecoration(
              color: PdfColors.orange100,
              borderRadius: pw.BorderRadius.circular(8),
              border: pw.Border.all(color: PdfColors.orange300),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Net Pay', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.Text(net.toStringAsFixed(2), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),

          pw.SizedBox(height: 18),
          pw.Text('This is a system generated salary slip (dummy data).', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
        ],
      ),
    );

    final file = File(filePath);
    await file.writeAsBytes(await doc.save(), flush: true);
    return file;
  }

  Future<void> _download() async {
    final idx = (widget.item.index ?? '').toString();

    setState(() => _downloading = true);

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = await _buildDummyPdf(filePath: '${dir.path}/salary-slip-$idx.pdf');

      final result = await OpenFilex.open(file.path, type: 'application/pdf');
      if (result.type != ResultType.done) {
        _api.showToast('Saved: ${file.path}');
      }
    } on MissingPluginException {
      _api.showToast('Plugin not ready. Stop the app and run again (flutter clean + run).');
    } catch (e) {
      _api.showToast('Open failed. Saved: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.item.title?.toString() ?? 'Salary Slip';
    final from = widget.item.from?.toString() ?? '';
    final to = widget.item.to?.toString() ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w900)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 248, 250, 252),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('From: $from', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)),
                  const SizedBox(height: 8),
                  Text('To: $to', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.black87)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Text(
                  'Tap Download to generate a dummy Salary Slip PDF and open it in your PDF viewer.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black.withOpacity(0.60), fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _downloading ? null : _download,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _downloading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Download', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFF59E0B)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Back', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFF59E0B))),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
