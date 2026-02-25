import 'package:cn_pocket_hr/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:cn_pocket_hr/Constant/Slideanimation.dart';
import 'package:cn_pocket_hr/Screens/notifications/Notifications.dart';
import 'package:cn_pocket_hr/Screens/salarySlips/devices/SalarySlipDetailPage.dart';
import 'package:cn_pocket_hr/api/apiService.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';

class MobileSalarySlip extends StatefulWidget {
  const MobileSalarySlip({Key? key}) : super(key: key);

  @override
  State<MobileSalarySlip> createState() => _MobileSalarySlipState();
}

class _MobileSalarySlipState extends State<MobileSalarySlip> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController? _animationController;
  final APIService _api = APIService();
  bool _shownSalaryMessage = false; // guard to show API message only once per page load

  // Theme aligned with Attendance / Leave screens
  static const Color _pageBg = Colors.white;
  static const Color _surface = Color.fromARGB(255, 248, 250, 252);
  static const double _g8 = 8;
  static const double _g12 = 12;
  static const double _g16 = 16;

  // Fonts (keep sizes; normalize weights)
  static const FontWeight _wMedium = FontWeight.w500;
  static const FontWeight _wSemi = FontWeight.w600;
  static const FontWeight _wBold = FontWeight.w700;
  static const FontWeight _wBlack = FontWeight.w900;

  // Render HTML only when there is actual content to show.
  bool get _hasHtml => htmlData.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
    // kick off load
    _loadSlips();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Widget _topActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_g16, _g8, _g16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: Center(
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 18),
              ),
            ),
          ),
          Text(
            AppLocalizations.of(context)!.salarySlips,
            style: const TextStyle(fontSize: 24, fontWeight: _wBlack),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: _pageBg,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _topActions(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: _g16),
                    child: Column(
                      children: [
                        const SizedBox(height: _g12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            AppLocalizations.of(context)!.salarySlipHistory,
                            style: const TextStyle(fontSize: 16, fontWeight: _wBold),
                          ),
                        ),
                        const SizedBox(height: _g12),
                        showSlips(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_hasHtml) showHtml(),
          ],
        ),
      ),
    );
  }

  Widget showSlips() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _api.getSalarySlips().then((slips) => {'slips': slips}),
      builder: (context, snap) {
        if (!snap.hasData) return const Padding(padding: EdgeInsets.symmetric(vertical: 40), child: Center(child: CircularProgressIndicator()));
        final data = snap.data!;
        final items = (data['slips'] as List).cast<Map<String, dynamic>>();

        // show message once after load
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_shownSalaryMessage) {
            final msg = data['message']?.toString() ?? '';
            if (msg.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(msg, style: const TextStyle(color: Colors.white)),
                  backgroundColor: HRColors.darkOrangeColor,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
            _shownSalaryMessage = true;
          }
        });

        if (items.isEmpty) return Padding(padding: const EdgeInsets.symmetric(vertical: 40), child: Center(child: Text(AppLocalizations.of(context)!.noRecords)));

        // convert to _HomeItem list
        final list = items.map((m) => _HomeItem(items.indexOf(m), m['title'] ?? '', m['subtitle'] ?? '', HRColors.darkOrangeColor, from: m['from'] ?? '', to: m['to'] ?? '', pdfUrl: m['pdfUrl'] ?? '', id: m['id'] ?? '')).toList();
        return _buildListFromData(context, list);
      },
    );
  }

  Widget _buildListFromData(BuildContext context, List<_HomeItem> items) {
    return SlideAnimation(
      position: 4,
      itemCount: items.length,
      slideDirection: SlideDirection.fromLeft,
      animationController: _animationController,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: items.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (BuildContext context, int index) {
          final it = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Stack(
              children: [
                Container(
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
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    // onTap: () async {
                    //   Navigator.of(context).push(MaterialPageRoute(builder: (_) => SalarySlipDetailPage(item: it.id)));
                    // },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(it.title, style: const TextStyle(fontSize: 14, fontWeight: _wBold, color: Colors.black87)),
                                const SizedBox(height: 6),
                                Text(it.subtitle, style: const TextStyle(fontSize: 12, fontWeight: _wSemi, color: Colors.black54)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: GestureDetector(
                    onTap: () async {
                      final resp = await _api.emailSalarySlip(it.id);
                      final msg = resp['message'] ?? '';
                      // show on-screen SnackBar so it's visible within the app
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(msg, style: const TextStyle(color: Colors.white)),
                          backgroundColor: HRColors.darkOrangeColor,
                          behavior: SnackBarBehavior.floating,
                          margin: const EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0),
                          duration: const Duration(seconds: 4),
                        ),
                      );
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.black12)),
                      child: const Icon(Icons.email, size: 18, color: HRColors.darkOrangeColor),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _loadSlips() async {
    setState(() {});
  }

  final htmlData = r"""   """;

  Widget showHtml() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() {}),
        child: Container(
          color: Colors.black.withOpacity(0.25),
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.65),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'HTML preview is not wired yet.',
                style: TextStyle(fontWeight: _wSemi, color: Colors.black87),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeItem {
  const _HomeItem(this.index, this.title, this.subtitle, this.color, {required this.from, required this.to, required this.pdfUrl, required this.id});

  final int index;
  final String id;
  final String title;
  final String subtitle;
  final Color color;
  final String from;
  final String to;
  final String pdfUrl;
}

List<_HomeItem> homeList = [
  _HomeItem(1, "Jan 2026", "Salary Slip", Colors.amberAccent, from: "2026-01-01", to: "2026-01-31", pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf", id: 'slip-2026-01'),
  _HomeItem(2, "Dec 2025", "Salary Slip", Colors.cyan, from: "2025-12-01", to: "2025-12-31", pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf", id: 'slip-2025-12'),
  _HomeItem(3, "Nov 2025", "Salary Slip", Colors.redAccent, from: "2025-11-01", to: "2025-11-30", pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf", id: 'slip-2025-11'),
  _HomeItem(4, "Oct 2025", "Salary Slip", Colors.deepPurpleAccent, from: "2025-10-01", to: "2025-10-31", pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf", id: 'slip-2025-10'),
  _HomeItem(5, "Sep 2025", "Salary Slip", Colors.orangeAccent, from: "2025-09-01", to: "2025-09-30", pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf", id: 'slip-2025-09'),
  _HomeItem(6, "Aug 2025", "Salary Slip", Colors.teal, from: "2025-08-01", to: "2025-08-31", pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf", id: 'slip-2025-08'),
  _HomeItem(7, "Jul 2025", "Salary Slip", Colors.pink, from: "2025-07-01", to: "2025-07-31", pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf", id: 'slip-2025-07'),
  _HomeItem(8, "Jun 2025", "Salary Slip", Colors.lightBlueAccent, from: "2025-06-01", to: "2025-06-30", pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf", id: 'slip-2025-06'),
];
