import 'package:cn_pocket_hr/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:cn_pocket_hr/Constant/Slideanimation.dart';
import 'package:cn_pocket_hr/Screens/leave/devices/Slidable.dart';
import 'package:cn_pocket_hr/Screens/leave/devices/Slide_action.dart';
import 'package:cn_pocket_hr/Screens/notifications/Notifications.dart';
import 'package:cn_pocket_hr/Screens/salarySlips/devices/SalarySlipDetailPage.dart';

class MobileSalarySlip extends StatefulWidget {
  const MobileSalarySlip({Key? key}) : super(key: key);

  @override
  State<MobileSalarySlip> createState() => _MobileSalarySlipState();
}

class _MobileSalarySlipState extends State<MobileSalarySlip> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController? _animationController;

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
                            'Salary Slip History',
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
    return OrientationBuilder(
      builder: (context, orientation) => _buildList(context, Axis.horizontal),
    );
  }

  Widget _buildList(BuildContext context, Axis direction) {
    final Future<List<_HomeItem>> homeListFuture = Future<List<_HomeItem>>.value(homeList);

    return FutureBuilder<List<_HomeItem>>(
      future: homeListFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final items = snapshot.data!;
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(child: Text('No records')),
          );
        }

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
                child: Container(
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
                  child: Slidable(
                    key: Key(it.title),
                    direction: direction,
                    delegate: SlidableBehindDelegate(),
                    actionExtentRatio: 0.25,
                    actions: [
                      IconSlideAction(
                        caption: 'Approve',
                        color: const Color.fromARGB(255, 15, 205, 25),
                        icon: Icons.check,
                        onTap: () {},
                      ),
                    ],
                    secondaryActions: [
                      IconSlideAction(
                        caption: 'Reject',
                        color: Colors.red,
                        icon: Icons.cancel,
                        onTap: () {},
                      ),
                    ],
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SalarySlipDetailPage(item: it),
                          ),
                        );
                      },
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
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('From: ${it.from}', style: const TextStyle(fontSize: 12, fontWeight: _wMedium, color: Colors.black54)),
                                const SizedBox(height: 8),
                                Text('To: ${it.to}', style: const TextStyle(fontSize: 12, fontWeight: _wMedium, color: Colors.black54)),
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
          ),
        );
      },
    );
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
  const _HomeItem(this.index, this.title, this.subtitle, this.color, {required this.from, required this.to, required this.pdfUrl});

  final int index;
  final String title;
  final String subtitle;
  final Color color;
  final String from;
  final String to;
  final String pdfUrl;
}

List<_HomeItem> homeList = [
  _HomeItem(1, "Jan 2026", "Salary Slip", Colors.amberAccent, from: "2026-01-01", to: "2026-01-31", pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"),
  _HomeItem(2, "Dec 2025", "Salary Slip", Colors.cyan, from: "2025-12-01", to: "2025-12-31", pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"),
  _HomeItem(3, "Nov 2025", "Salary Slip", Colors.redAccent, from: "2025-11-01", to: "2025-11-30", pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"),
  _HomeItem(4, "Oct 2025", "Salary Slip", Colors.deepPurpleAccent, from: "2025-10-01", to: "2025-10-31", pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"),
  _HomeItem(5, "Sep 2025", "Salary Slip", Colors.orangeAccent, from: "2025-09-01", to: "2025-09-30", pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"),
  _HomeItem(6, "Aug 2025", "Salary Slip", Colors.teal, from: "2025-08-01", to: "2025-08-31", pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"),
  _HomeItem(7, "Jul 2025", "Salary Slip", Colors.pink, from: "2025-07-01", to: "2025-07-31", pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"),
  _HomeItem(8, "Jun 2025", "Salary Slip", Colors.lightBlueAccent, from: "2025-06-01", to: "2025-06-30", pdfUrl: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf"),
];
