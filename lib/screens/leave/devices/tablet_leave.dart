import 'package:auto_size_text/auto_size_text.dart';
import 'package:cn_pocket_hr/config/flavor_config.dart';
import 'package:cn_pocket_hr/services/leave_service.dart';
import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:cn_pocket_hr/constants/slideanimation.dart';
import 'package:cn_pocket_hr/screens/leave/devices/card1.dart';
import 'package:cn_pocket_hr/screens/leave/devices/slidable.dart';
import 'package:cn_pocket_hr/screens/leave/devices/slide_action.dart';
import 'package:cn_pocket_hr/screens/notifications/notifications.dart';
import 'package:cn_pocket_hr/api/api_service.dart';
import 'package:cn_pocket_hr/helpers/design_config.dart';
import 'package:cn_pocket_hr/helpers/hr_colors.dart';
import 'package:cn_pocket_hr/models/hr/leave_model.dart';
import 'package:cn_pocket_hr/models/hr/me_model.dart';

import 'package:cn_pocket_hr/screens/leave/devices/mobile_leave_request_page.dart';
// (Details screen removed)

class TabletLeave extends StatefulWidget {
  const TabletLeave({Key? key}) : super(key: key);

  @override
  TabletLeaveState createState() => TabletLeaveState();
}

class TabletLeaveState extends State<TabletLeave>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController? _animationController;
  late final TabController _tab;
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

  Map<String, dynamic>? _leaveBalances;

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

  Widget _leaveBalanceChip(
      {required String label,
      required String value,
      required Color bg,
      required Color fg}) {
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
          AutoSizeText(label,
              style: TextStyle(fontSize: 12, fontWeight: _wBold, color: fg)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: HRColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: AutoSizeText(value,
                style: TextStyle(fontSize: 12, fontWeight: _wBlack, color: fg)),
          ),
        ],
      ),
    );
  }

  Widget _leaveBalanceSummary() {
    if (_leaveBalances == null) return const SizedBox();

    String buildVal(String type) {
      final quotaMap = (_leaveBalances!['quota'] ?? _leaveBalances!['leave_quota']) as Map?;
      final usedMap = (_leaveBalances!['used'] ?? _leaveBalances!['taken'] ?? _leaveBalances!['leave_used'] ?? _leaveBalances!['leave_taken']) as Map?;
      final balanceMap = (_leaveBalances!['balance'] ?? _leaveBalances!['leave_balance'] ?? _leaveBalances!['remaining']) as Map?;

      num toNum(dynamic v) {
        if (v == null) return 0;
        if (v is num) return v;
        return num.tryParse(v.toString()) ?? 0;
      }

      dynamic find(Map? m, String k) {
        if (m == null) return null;
        if (m.containsKey(k)) return m[k];
        final lowerK = k.toLowerCase();
        for (var entry in m.entries) {
          final sk = entry.key.toString().toLowerCase();
          if (sk == lowerK || sk == '${lowerK}_leave' || sk == 'leave_$lowerK') return entry.value;
        }
        return null;
      }

      var quota = find(quotaMap, type);
      var used = find(usedMap, type);

      // Fallback: If not in maps, maybe they are top-level keys like "annual_quota"
      quota ??= find(_leaveBalances, '${type}_quota') ?? find(_leaveBalances, 'quota_$type');
      used ??= find(_leaveBalances, '${type}_used') ?? find(_leaveBalances, 'used_$type') ?? find(_leaveBalances, '${type}_taken');

      if (used == null && balanceMap != null) {
        final bal = find(balanceMap, type);
        if (bal != null && quota != null) {
          used = toNum(quota) - toNum(bal);
        }
      }

      // Final fallbacks from LocalStorage
      quota ??= storage.getItem('${type}Quota') ?? storage.getItem('${type}_quota');
      if (used == null) {
        final storageBal = storage.getItem('leave${type[0].toUpperCase()}${type.substring(1)}') ?? storage.getItem('leave_$type');
        if (storageBal != null && quota != null) {
          used = toNum(quota) - toNum(storageBal);
        }
      }

      return '${toNum(used)}/${toNum(quota)}';
    }

    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HRColors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
              color: HRColors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AutoSizeText(AppLocalizations.of(context)!.leaveBalanceTitle,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: _wBlack,
                  color: HRColors.darkFontColor)),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _leaveBalanceChip(
                    label: AppLocalizations.of(context)!.annualLabel,
                    value: buildVal('annual'),
                    bg: const Color(0xFFFFF7E6),
                    fg: HRColors.darkOrangeColor),
                const SizedBox(width: 10),
                _leaveBalanceChip(
                    label: AppLocalizations.of(context)!.casualLabel,
                    value: buildVal('casual'),
                    bg: const Color(0xFFEFF6FF),
                    fg: HRColors.blueColor),
                const SizedBox(width: 10),
                _leaveBalanceChip(
                    label: AppLocalizations.of(context)!.medicalLabel,
                    value: buildVal('medical'),
                    bg: const Color(0xFFEAF7EE),
                    fg: HRColors.green),
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
    _tab = TabController(length: 4, vsync: this);
    _tab.addListener(() {
      if (!_tab.indexIsChanging) {
        setState(() {
          switch (_tab.index) {
            case 0:
              _historyFilter = 'all';
              break;
            case 1:
              _historyFilter = 'approved';
              break;
            case 2:
              _historyFilter = 'pending';
              break;
            case 3:
              _historyFilter = 'rejected';
              break;
          }
        });
      }
    });

    // Ensure profile (quotas / balances) is loaded, then load leaves
    _initProfileAndLeaves();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
  }

  @override
  void dispose() {
    _tab.dispose();
    _animationController!.dispose();
    super.dispose();
  }

  Future<void> _initProfileAndLeaves() async {
    try {
      await apiService.fetchMeProfileWithBearer();
      _loadBalance();
    } catch (_) {}
    // Load leaves after profile fetch (ensures storage values exist)
    getMyLeaves();
  }

  Future<void> _loadBalance() async {
    final data = await apiService.getLeaveBalance();
    if (mounted && data != null) {
      setState(() {
        _leaveBalances = data;
      });
    }
  }

  getMyLeaves() async {
    setState(() {
      isLoading = true;
      myLeaves = LeaveService.getMyLeaves();
    });

    // Refresh balance too
    _loadBalance();

    try {
      final value = await myLeaves;
      if (!mounted) return;
      setState(() {
        _leaveListCount = (value ?? <MyLeavesModel>[]).length;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _leaveListCount = 0;
        isLoading = false;
      });
    }
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
              itemCount: _meListCount > 6 ? 6 : _meListCount,
              slideDirection: SlideDirection.fromLeft,
              animationController: _animationController,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20, bottom: 3, left: 16),
                    alignment: Alignment.bottomLeft,
                    // margin: const EdgeInsets.only(bottom: 8, ),
                    child: AutoSizeText(
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
                        child: AutoSizeText(
                          AppLocalizations.of(context)!.leaveText,
                          style: const TextStyle(color: Colors.black),
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
                          color: HRColors.flavorIconBackgroundColor ??
                              Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          border:
                              Border.all(color: Colors.black.withOpacity(0.06)),
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
                      AppLocalizations.of(context)!.leaveText,
                      style: const TextStyle(fontSize: 24, fontWeight: _wBlack),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(
                          context, HRNotifications.routeName),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: HRColors.flavorIconBackgroundColor ??
                              Colors.white,
                          borderRadius: BorderRadius.circular(40),
                          border:
                              Border.all(color: Colors.black.withOpacity(0.06)),
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
                const SizedBox(height: 6),

                _leaveBalanceSummary(),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    AutoSizeText(AppLocalizations.of(context)!.leaveHistory,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    TextButton(
                      onPressed: () {
                        _loadBalance();
                        getMyLeaves();
                      },
                      child: AutoSizeText(AppLocalizations.of(context)!.refresh,
                          style: const TextStyle(
                              color: Colors.black87, fontWeight: _wBold)),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // tabs
                Container(
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withOpacity(0.05)),
                  ),
                  child: TabBar(
                    controller: _tab,
                    isScrollable: true,
                    dividerColor: Colors.transparent,
                    indicatorColor: Colors.transparent,
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabAlignment: TabAlignment.start,
                    indicatorPadding: const EdgeInsets.all(6),
                    labelPadding: const EdgeInsets.only(left: 23, right: 23),
                    indicator: BoxDecoration(
                      color: HRColors.tabColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    labelColor: HRColors.tabLabelColor,
                    unselectedLabelColor: Colors.black54,
                    tabs: [
                      Tab(text: AppLocalizations.of(context)!.allLabel),
                      Tab(text: AppLocalizations.of(context)!.approvedLable),
                      Tab(text: AppLocalizations.of(context)!.pendindingLable),
                      Tab(text: AppLocalizations.of(context)!.rejectedLable),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Debug: show loaded leave count (remove later)
                if (myLeaves != null)
                  FutureBuilder<List<MyLeavesModel>>(
                    future: myLeaves,
                    builder: (context, s) {
                      final n = (s.data ?? const <MyLeavesModel>[]).length;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 6),
                        child: AutoSizeText(
                          "${AppLocalizations.of(context)!.loadedLeaveLable}:$n",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black.withOpacity(0.45),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),

                // Leave history header
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     AutoSizeText('Leave History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                //     TextButton(onPressed: () => getMyLeaves(), child: AutoSizeText('Refresh')),
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
              padding: const EdgeInsets.only(bottom: 150.0),
              child: _GradientPillButton(
                label: '',
                // icon: Icons.menu,
                onTap: () async {
                  setState(() => leaveManageForm = true);

                  await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MobileLeaveRequestPage(
                          isEdit: false, initial: null),
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
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.connectionState == ConnectionState.active) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 90),
            child: Center(
                child: CupertinoActivityIndicator(
              color: HRColors.orangeColor,
              radius: 16.0,
            )),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: AutoSizeText(
                'Failed to load leaves',
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          final all = snapshot.data ?? <MyLeavesModel>[];
          List<MyLeavesModel> filtered = all;
          if (_historyFilter != 'all') {
            filtered = all.where((e) {
              final status = e.status.toString().toLowerCase();
              if (_historyFilter == 'approved') return status == 'approved';
              if (_historyFilter == 'pending')
                return status == 'pending' || status == 'requested';
              if (_historyFilter == 'rejected') return status == 'rejected';
              return true;
            }).toList();
          }
          _leaveListCount = filtered.length;

          if (_leaveListCount == 0) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                  child: AutoSizeText(AppLocalizations.of(context)!.noRecords)),
            );
          }

          return SlideAnimation(
            position: 4,
            itemCount: _leaveListCount > 6 ? 6 : _leaveListCount,
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

        // Future completed but returned null (should not happen) => empty state
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Center(
              child: AutoSizeText(AppLocalizations.of(context)!.noRecords)),
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
        padding: iconOnly
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(iconOnly ? 56 : 30),
          color: HRColors.buttonColor,
          border: Border.all(color: Colors.black.withOpacity(0.06)),
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
              ? Icon(
                  Icons.add_rounded,
                  color: HRColors.tabLabelColor,
                  size: 28,
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AutoSizeText(
                        label,
                        style: TextStyle(
                          color: HRColors.tabLabelColor,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.chevron_right,
                        color: HRColors.tabLabelColor,
                      ),
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

    // Localize end status label
    final endLabel = s == 'rejected'
        ? AppLocalizations.of(context)!.rejectedLable
        : AppLocalizations.of(context)!.approvedLable;

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
          AutoSizeText(
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

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        item(AppLocalizations.of(context)!.create, true, createColor),
        const SizedBox(width: 14),
        item(AppLocalizations.of(context)!.review, step >= 1, reviewColor),
        const SizedBox(width: 14),
        item(endLabel, step >= 2, endColor),
      ],
    );
  }

  String _localizedLeaveTypeLabel(String raw) {
    final s = raw.toLowerCase().trim();

    if (s.contains('annual')) return AppLocalizations.of(context)!.annualLabel;
    if (s.contains('casual')) return AppLocalizations.of(context)!.casualLabel;
    if (s.contains('medical') || s.contains('sick')) {
      return AppLocalizations.of(context)!.medicalLabel;
    }
    if (s.contains('short')) return AppLocalizations.of(context)!.shortLeave;
    if (s.contains('nopay') || s.contains('unpaid')) {
      // If localization key doesn't exist in this app, keep an English fallback.
      return 'No Pay';
    }

    return raw;
  }

  Widget _leaveHistoryCard(MyLeavesModel model, Axis direction) {
    final typeLabel = _localizedLeaveTypeLabel(model.leaveType.toString());
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

    return Container(
      margin:
          const EdgeInsets.only(left: 4.0, right: 4.0, top: 10.0, bottom: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(15.0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Slidable(
          key: Key('${model.leaveTitle}-${model.fromDate}-${model.toDate}'),
          direction: direction,
          delegate: SlidableBehindDelegate(),
          actionExtentRatio: 0.25,
          actions: isFinal
              ? const <Widget>[]
              : [
                  IconSlideAction(
                    caption: AppLocalizations.of(context)!.approvedLable,
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
                    caption: AppLocalizations.of(context)!.rejectedLable,
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
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 14.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        AppLocalizations.of(context)!.leaveSummary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: HRColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.date_range,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: AutoSizeText(
                              (from.isNotEmpty && to.isNotEmpty)
                                  ? '$from  -  $to'
                                  : (from.isNotEmpty ? from : ''),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      AutoSizeText(
                        typeLabel,
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFFF59E0B),
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      _historyStepsRow(model.status),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: trailingBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(trailingIcon, color: trailingFg),
                    ),
                    if (!isFinal)
                      const Icon(
                        Icons.swipe_left_rounded,
                        color: Colors.grey,
                        size: 20,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
