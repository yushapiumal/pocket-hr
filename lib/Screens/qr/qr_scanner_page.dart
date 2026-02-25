import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({Key? key}) : super(key: key);

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  bool _scanned = false;
  final MobileScannerController _controller = MobileScannerController();
  String? _lastScanned;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                try {
                  if (_scanned) return;
                  final barcodes = capture.barcodes;
                  if (barcodes.isEmpty) return;
                  final b = barcodes.first;
                  final String? code = b.rawValue;
                  if (code != null && code.isNotEmpty) {
                    // store and print
                    _lastScanned = code;
                    print('[QR SCANNED] $code');
                    _scanned = true;

                    // show dialog with scanned data and actions
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Scanned Data'),
                        content: SingleChildScrollView(child: Text(code)),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              // copy to clipboard
                              try {
                                await Clipboard.setData(ClipboardData(text: code));
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                              } catch (_) {}
                            },
                            child: const Text('Copy'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              // return scanned code to caller
                              Navigator.of(context).pop(code);
                            },
                            child: const Text('Use'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              // allow scanning again
                              setState(() { _scanned = false; });
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  }
                } catch (_) {}

                print(capture.barcodes);
              },
            ),
            // bottom bar showing last scanned data
            if (_lastScanned != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      Expanded(child: Text(_lastScanned!, style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis)),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.white),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: _lastScanned!));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white24, width: 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
