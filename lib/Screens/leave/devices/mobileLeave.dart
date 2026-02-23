import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:cn_pocket_hr/Constant/Slideanimation.dart';
import 'package:cn_pocket_hr/Screens/leave/devices/Card1.dart';
import 'package:cn_pocket_hr/Screens/leave/devices/Slidable.dart';
import 'package:cn_pocket_hr/Screens/leave/devices/Slide_action.dart';
import 'package:cn_pocket_hr/Screens/notifications/Notifications.dart';
import 'package:cn_pocket_hr/api/apiService.dart';
import 'package:cn_pocket_hr/helper/DesignConfig.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';
import 'package:cn_pocket_hr/model/hr/LeaveModel.dart';
import 'package:cn_pocket_hr/model/hr/MeModel.dart';

import 'package:cn_pocket_hr/Screens/leave/devices/mobileLeaveRequestPage.dart';
// (Details screen removed)

class MobileLeave extends StatefulWidget {
  MobileLeave({Key? key}) : super(key: key);

  @override
  MobileLeaveState createState() => MobileLeaveState();
}

class MobileLeaveState extends State<MobileLeave>
    with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController? _animationController;
  Future<List<MyLeavesModel>>? myLeaves;
  Future<List<MeSubsModel>>? otherLeaves;
  final LocalStorage storage = LocalStorage('pocketHR');
  List list = [];
  // Timer? _timer; // unused
  bool isLoading = false;
  APIService apiService = APIService();
  int _leaveListCount = 0;
  int _meListCount = 0;
  bool isOthers = false;
  bool leaveManageForm = false;
  bool leaveApprove = true;

  // History filter tabs
  String _historyFilter = 'all'; // all|annual|casual|sick|unpaid

  // Bottom-sheet wizard
  // int _applyStep = 0; // 0=type, 1=mode+dates, 2=desc+confirm

  static const Color _pageBg = Colors.white;

  static const Color _surface = Color.fromARGB(255, 248, 250, 252);

  // Fonts (match Attendance screen; keep existing sizes)
  static const FontWeight _wSemi = FontWeight.w600;
  static const FontWeight _wBold = FontWeight.w700;
  static const FontWeight _wBlack = FontWeight.w900;

  Widget _leaveBalanceChip({required String label, required String value, required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HRColors.black.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: _wBold, color: fg)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: HRColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(value, style: TextStyle(fontSize: 12, fontWeight: _wBlack, color: fg)),
          ),
        ],
      ),
    );
  }

  Widget _leaveBalanceSummary() {
    // sample values (replace with API values later)
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HRColors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(color: HRColors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('My Leave Balance', style: TextStyle(fontSize: 14, fontWeight: _wBlack, color: HRColors.darkFontColor)),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _leaveBalanceChip(label: 'Annual', value: '2/12', bg: const Color(0xFFFFF7E6), fg: HRColors.darkOrangeColor),
                const SizedBox(width: 10),
                _leaveBalanceChip(label: 'Casual', value: '1/7', bg: const Color(0xFFEFF6FF), fg: HRColors.blueColor),
                const SizedBox(width: 10),
                _leaveBalanceChip(label: 'Medical', value: '0/10', bg: const Color(0xFFEAF7EE), fg: HRColors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // Ensure profile (quotas / balances) is loaded, then load leaves
    _initProfileAndLeaves();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  Future<void> _initProfileAndLeaves() async {
    try {
      await apiService.fetchMeProfileWithBearer();
    } catch (_) {}
    // Load leaves after profile fetch (ensures storage values exist)
    getMyLeaves();
  }

  getMyLeaves() async {
    setState(() {
      isLoading = true;
      final Future<List<MyLeavesModel>> leaves = apiService.getMyLeaves(false);
      leaves.then((value) {
        _leaveListCount = value.length;
      });
      myLeaves = leaves;
      if ((_leaveListCount > 0)) {
        setState(() {
          myLeaves = leaves;
          isLoading = false;
        });
      } else {
        isLoading = false;
      }
    });
  }

  handleTimeout() {
    if (_meListCount > 0) {
      setState(() {
        isOthers = true;
      });
    }
  }

  getOthersLeaves() async {
    setState(() {
      final Future<List<MeSubsModel>> others = apiService.getMeSubs();
      others.then((value) {
        _meListCount = value.length;
      });
      otherLeaves = others;

      Timer(Duration(milliseconds: 1000), handleTimeout);
      if (_meListCount > 0) {
        isOthers = true;
      } else {
        isOthers = false;
      }
    });
  }

  Widget othersLeaves() {
    return FutureBuilder<List<MeSubsModel>>(
        future: otherLeaves,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SlideAnimation(
              position: 4,
              itemCount: 8,
              slideDirection: SlideDirection.fromLeft,
              animationController: _animationController,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 3, left: 16),
                    alignment: Alignment.bottomLeft,
                    // margin: const EdgeInsets.only(bottom: 8, ),
                    child: Text(
                      "Others",
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.red[400],
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 3, bottom: 3, left: 16),
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: 70,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        // color: Color(0xff5AD2F1).withOpacity(0.50),
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(bottom: 0, top: 15, right: 8, left: 4),
                    height: MediaQuery.of(context).size.height / 2 - 290,
                    child: ListView.builder(
                      physics: ScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _meListCount,
                      itemBuilder: (BuildContext context, int index) {
                        return WrCard1(
                          localimg: snapshot.data![index].avatar,
                          image: snapshot.data![index].avatar,
                          blurUrl: "LlF70ZnNsmbv_Noze.RjkXxaogV@",
                          title: snapshot.data![index].nickName,
                          country: snapshot.data![index].epfNo,
                          price: 240,
                          press: () {},
                        );
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 3, left: 16),
                    alignment: Alignment.topLeft,
                    child: Container(
                      child: ElevatedButton(
                        child: Text(
                          'My Leaves',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          apiService.showToast('Already loaded');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10), // <-- Radius
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 3, left: 16),
                    alignment: Alignment.bottomLeft,
                    child: Container(
                      width: 70,
                      height: 3,
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        // color: Color(0xff5AD2F1).withOpacity(0.50),
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            isOthers = false;
            return SizedBox();
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      drawerScrimColor: Colors.transparent,
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: DesignConfig.drawerContent(_scaffoldKey, context),
      ),
      backgroundColor: _pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                      AppLocalizations.of(context)!.leaveText,
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
                const SizedBox(height: 6),

                _leaveBalanceSummary(),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Leave History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    TextButton(
                      onPressed: () => getMyLeaves(),
                      child: const Text('Refresh', style: TextStyle(color: Colors.black87, fontWeight: _wBold)),
                    ),
                  ],
                ),

                // Leave history header
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     const Text('Leave History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                //     TextButton(onPressed: () => getMyLeaves(), child: const Text('Refresh')),
                //   ],
                // ),

                // History list
                showLeave(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: !leaveManageForm
          ? Padding(
              padding: const EdgeInsets.only(bottom: 90.0),
              child: _GradientPillButton(
                label: '',
                // icon: Icons.menu,
                onTap: () async {
                  setState(() => leaveManageForm = true);

                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MobileLeaveRequestPage(isEdit: false, initial: null),
                    ),
                  );

                  if (mounted) {
                    setState(() => leaveManageForm = false);
                    getMyLeaves();
                  }
                },
              ),
            )
          : SizedBox(),
    );
  }

  getIcon(status) {
    if (status == "pending") {
      return Icon(
        Icons.pending_actions,
        color: HRColors.darkOrangeColor,
      );
    } else if (status == "approved") {
      return Icon(
        Icons.check_circle_outline,
        color: Colors.green,
      );
    } else if (status == "rejected") {
      return Icon(
        Icons.dangerous_outlined,
        color: Colors.red,
      );
    }
  }

  Widget showLeave() {
    return Container(
      margin: const EdgeInsets.only(),
      padding: EdgeInsets.only(
        top: 8,
      ),
      child: Column(
        children: [
          _buildList(context, Axis.horizontal),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, Axis direction) {
    return FutureBuilder<List<MyLeavesModel>>(
      future: myLeaves,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final all = snapshot.data ?? <MyLeavesModel>[];
          List<MyLeavesModel> filtered = all;
          if (_historyFilter != 'all') {
            filtered = all.where((e) {
              final t = e.leaveType.toString().toLowerCase();
              if (_historyFilter == 'sick') return t.contains('medical') || t.contains('sick');
              if (_historyFilter == 'unpaid') return t.contains('nopay') || t.contains('unpaid');
              return t.contains(_historyFilter);
            }).toList();
          }
          _leaveListCount = filtered.length;

          if (_leaveListCount == 0) {
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
              itemCount: _leaveListCount,
              itemBuilder: (_, i) => _leaveHistoryCard(filtered[i], direction),
            ),
          );
        }

        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 90),
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  void setLeaveValue(MyLeavesModel value) {
    // kept for approve/reject flow (if used elsewhere)
  }

  Widget _GradientPillButton({
    required String label,
    // required IconData icon,
    required VoidCallback onTap,
  }) {
    // Matches the provided UI: circular icon bubble + pill gradient
    final iconOnly = label.trim().isEmpty;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: iconOnly ? 56 : 52,
        width: iconOnly ? 56 : null,
        padding: iconOnly ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(iconOnly ? 56 : 30),
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [HRColors.orangeColor, HRColors.orangeColor],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: iconOnly
              ? const Icon(Icons.add_rounded, color: HRColors.white, size: 28)
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: HRColors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right, color: HRColors.white),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _historyStepsRow(String? status) {
    final s = (status ?? '').toLowerCase();
    int step = 0;
    if (s == 'pending') step = 1;
    if (s == 'approved' || s == 'rejected') step = 2;

    final createColor = HRColors.black;
    final reviewColor = HRColors.black;
    final approvedColor = HRColors.green;
    final rejectedColor = HRColors.red;
    final endColor = s == 'rejected' ? rejectedColor : approvedColor;

    Widget dot(bool active, Color color) {
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: active ? color : color.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
      );
    }

    Widget item(String label, bool active, Color color) {
      return Row(
        children: [
          dot(active, color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: _wBold,
              color: active ? color : HRColors.grayColor,
            ),
          ),
        ],
      );
    }

    final endLabel = s == 'rejected' ? 'Rejected' : 'Approved';
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        item('Create', true, createColor),
        const SizedBox(width: 14),
        item('Review', step >= 1, reviewColor),
        const SizedBox(width: 14),
        item(endLabel, step >= 2, endColor),
      ],
    );
  }

  Widget _leaveHistoryCard(MyLeavesModel model, Axis direction) {
    final typeLabel = model.leaveType.toString();
    final title = model.leaveTitle.toString();
    final from = model.fromDate.toString();
    final to = model.toDate.toString();

    final status = model.status.toString().toLowerCase();
    final bool isFinal = status == 'approved' || status == 'rejected';

    IconData trailingIcon;
    Color trailingBg;
    Color trailingFg;
    if (status == 'approved') {
      trailingIcon = Icons.check_rounded;
      trailingBg = HRColors.green.withOpacity(0.12);
      trailingFg = HRColors.green;
    } else if (status == 'rejected') {
      trailingIcon = Icons.close_rounded;
      trailingBg = HRColors.red.withOpacity(0.12);
      trailingFg = HRColors.red;
    } else {
      trailingIcon = Icons.hourglass_bottom_rounded;
      trailingBg = HRColors.lightOrangeColor;
      trailingFg = HRColors.darkOrangeColor;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: HRColors.black.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(color: HRColors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 6)),
          ],
        ),
        child: Slidable(
          key: Key('${model.leaveTitle}-${model.fromDate}-${model.toDate}'),
          direction: direction,
          delegate: SlidableBehindDelegate(),
          actionExtentRatio: 0.25,
          actions: isFinal
              ? const <Widget>[]
              : [
                  IconSlideAction(
                    caption: 'Approve',
                    color: const Color.fromARGB(255, 15, 205, 25),
                    icon: Icons.check,
                    onTap: () {
                      setState(() {
                        leaveManageForm = true;
                        leaveApprove = true;
                      });
                      setLeaveValue(model);
                    },
                  ),
                ],
          secondaryActions: isFinal
              ? const <Widget>[]
              : [
                  IconSlideAction(
                    caption: 'Reject',
                    color: HRColors.red,
                    icon: Icons.cancel,
                    onTap: () {
                      setState(() {
                        leaveManageForm = true;
                        leaveApprove = false;
                      });
                      setLeaveValue(model);
                    },
                  ),
                ],
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.isNotEmpty ? title : 'Leave Request',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: _wBold, fontSize: 14, color: Colors.black87),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (from.isNotEmpty && to.isNotEmpty) ? '$from  -  $to' : (from.isNotEmpty ? from : ''),
                            style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: _wSemi),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            typeLabel,
                            style: const TextStyle(fontSize: 12, color: Color(0xFFF59E0B), fontWeight: _wBold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: trailingBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(trailingIcon, color: trailingFg),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _historyStepsRow(model.status),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
