import 'dart:async';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:expandable/expandable.dart';
import 'package:intl/intl.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:localstorage/localstorage.dart';
import 'package:cn_pocket_hr/Constant/Slideanimation.dart';
import 'package:cn_pocket_hr/Screens/notifications/Notifications.dart';
import 'package:cn_pocket_hr/api/apiService.dart';
import 'package:cn_pocket_hr/helper/DesignConfig.dart';
import 'package:cn_pocket_hr/helper/GlassBox.dart';
import 'package:cn_pocket_hr/helper/GlassBoxFull.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';
import 'package:cn_pocket_hr/helper/HRStrings.dart';
import 'package:cn_pocket_hr/model/hr/AttendanceModel.dart';


class MobileAttendance extends StatefulWidget {
  MobileAttendance({Key? key}) : super(key: key);

  @override
  MobileAttendanceState createState() => MobileAttendanceState();
}

class MobileAttendanceState extends State<MobileAttendance>
    with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController? _animationController;
  final LocalStorage storage = LocalStorage('pocketHR');
  DateTime now = DateTime.now();
  String currentM = "";
  String lastM = "";
  APIService apiService = APIService();
  Future<List<AttendanceModel>>? myAttendance;
  List list = [];
  int _attendanceCount = 0;
  Timer? _timer;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    currentM = DateFormat('MMMM').format(now);
    var prevMonth = new DateTime(now.year, now.month - 1, now.day);
    lastM = DateFormat('MMMM').format(prevMonth);
    getAttendance('cur');
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  callApi(type) async {
    if (type == 0) {
      getAttendance('cur');
    } else {
      getAttendance('prv');
    }
  }

  getAttendance(type) async {
    setState(() {
      isLoading = true;
      final Future<List<AttendanceModel>> attendance =
          apiService.getMyAttendance(type);
      attendance.then((value) {
        _attendanceCount = value.length;
      });

      myAttendance = attendance;

      if ((_attendanceCount > 0)) {
        setState(() {
          myAttendance = attendance;
          isLoading = false;
        });
      } else {
        isLoading = false;
      }
    });
  }

  Widget currentMonth() {
    return FutureBuilder<List<AttendanceModel>>(
      future: myAttendance,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SlideAnimation(
            position: 4,
            itemCount: 8,
            slideDirection: SlideDirection.fromLeft,
            animationController: _animationController,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _attendanceCount,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    Container(
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * .1,
                          right: MediaQuery.of(context).size.width * .1,
                        ),
                        child: Divider(
                          color: Color(0xff26707070),
                          thickness: 2,
                        )),
                    Container(
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * .1,
                          right: MediaQuery.of(context).size.width * .1),
                      decoration: BoxDecoration(
                        color: HRColors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          new BoxShadow(
                            color: Color(0x14212121),
                            blurRadius: 20.0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          // useDetail(snapshot.data![index]),
                          useDetail(snapshot
                              .data![snapshot.data!.length - index - 1]),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }
        return Container(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 90),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ),
        );
      },
    );
  }

  daySplit(date, onlyDate) {
    var day = date.split(' ');
    if (onlyDate) {
      String x = day[1];
      List<String> c = x.split("");
      c.removeLast();
      return c.join();
    }
    return day[0];
  }

  Widget useDetail(data) {
    return ExpandableNotifier(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  daySplit(data.boilerPlate['day'], true),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 25,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                    daySplit(data.boilerPlate['day'], false)
                                        .toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17,
                                        color: Colors.black))
                              ],
                            ),
                          ],
                        ),
                      ),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: data.isOffday
                                ? HRColors.dutyOff.withOpacity(0.30)
                                : HRColors.shift.withOpacity(0.30),
                            blurRadius: 8,
                            spreadRadius: 6,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 3,
                                child: Text(
                                  data.boilerPlate['dow'] +
                                      ' ' +
                                      data.boilerPlate['day'],
                                  style: TextStyle(
                                      fontSize: 15, color: Color(0xff676767)),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 8,
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      data.isOffday
                                          ? TextSpan(
                                              text: "DayOff",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: HRColors.dutyOff,
                                                  fontWeight: FontWeight.w600),
                                            )
                                          : TextSpan(
                                              text: "Shift",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: HRColors.shift,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 45,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width / 15,
                                  child: Text(
                                    "IN : ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: HRColors.grayColor,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 5.5,
                                  child: Text(
                                    data.boilerPlate['in_time_only'] == null
                                        ? ' - '
                                        : data.boilerPlate['in_time_only'],
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: HRColors.black,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 10,
                                  child: Text(
                                    "OUT : ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: HRColors.grayColor,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 5.5,
                                  child: Text(
                                    data.boilerPlate['out_time_only'] == null
                                        ? ' - '
                                        : data.boilerPlate['out_time_only'],
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: HRColors.black,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * .05,
                  right: MediaQuery.of(context).size.width * .05,
                  top: 5),
              child: Divider(
                color: Color(0xff26707070),
                thickness: 2,
              ),
            ),
            ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                theme: ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToCollapse: true,
                ),
                header: Padding(
                  padding: EdgeInsets.only(left: 10, top: 0),
                  child: Text(
                    "View Details",
                  ),
                ),
                collapsed: SizedBox(),
                expanded: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 10, left: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        child: Table(
                          border: TableBorder.symmetric(
                              inside:
                                  BorderSide(width: 1, color: Colors.black)),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            TableRow(
                                decoration: BoxDecoration(
                                  color: Colors.grey[350],
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6)),
                                ),
                                children: [
                                  Text(
                                    "WORKED",
                                    textScaleFactor: 1,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    "LATE",
                                    textScaleFactor: 1,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    "OVER",
                                    textScaleFactor: 1,
                                    textAlign: TextAlign.center,
                                  ),
                                ]),
                            TableRow(children: [
                              Text(
                                data.boilerPlate['wrkd_hours_fmtd'] == null
                                    ? " - "
                                    : data.boilerPlate['wrkd_hours_fmtd']
                                        .toString(),
                                textScaleFactor: 1,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                data.boilerPlate['late'] == null
                                    ? " - "
                                    : data.boilerPlate['late'].toString(),
                                textScaleFactor: 1,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                data.boilerPlate['over'] == null
                                    ? " - "
                                    : data.boilerPlate['over'].toString(),
                                textScaleFactor: 1,
                                textAlign: TextAlign.center,
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget useDetail2(data) {
    return ExpandableNotifier(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  daySplit(data.boilerPlate['day'], true),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 25,
                                      color: Colors.red),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                    daySplit(data.boilerPlate['day'], false)
                                        .toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 17,
                                        color: Colors.black))
                              ],
                            ),
                          ],
                        ),
                      ),
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: data.isOffday
                                ? HRColors.dutyOff.withOpacity(0.30)
                                : HRColors.shift.withOpacity(0.30),
                            blurRadius: 8,
                            spreadRadius: 6,
                            offset: const Offset(0, 0),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 3,
                                child: Text(
                                  data.boilerPlate['dow'] +
                                      ' ' +
                                      data.boilerPlate['day'],
                                  style: TextStyle(
                                      fontSize: 15, color: Color(0xff676767)),
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 8,
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      data.isOffday
                                          ? TextSpan(
                                              text: "DayOff",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: HRColors.dutyOff,
                                                  fontWeight: FontWeight.w600),
                                            )
                                          : TextSpan(
                                              text: "Shift",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: HRColors.shift,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height / 45,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width / 15,
                                  child: Text(
                                    "IN : ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: HRColors.grayColor,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 5.5,
                                  child: Text(
                                    data.boilerPlate['in_time_only'] == null
                                        ? ' - '
                                        : data.boilerPlate['in_time_only'],
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: HRColors.black,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width / 10,
                                  child: Text(
                                    "OUT : ",
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: HRColors.grayColor,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width / 5.5,
                                  child: Text(
                                    data.boilerPlate['out_time_only'] == null
                                        ? ' - '
                                        : data.boilerPlate['out_time_only'],
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: HRColors.black,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ]),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * .05,
                  right: MediaQuery.of(context).size.width * .05,
                  top: 5),
              child: Divider(
                color: Color(0xff26707070),
                thickness: 2,
              ),
            ),
            ScrollOnExpand(
              scrollOnExpand: true,
              scrollOnCollapse: false,
              child: ExpandablePanel(
                theme: ExpandableThemeData(
                  headerAlignment: ExpandablePanelHeaderAlignment.center,
                  tapBodyToCollapse: true,
                ),
                header: Padding(
                  padding: EdgeInsets.only(left: 10, top: 0),
                  child: Text(
                    "View Details",
                  ),
                ),
                collapsed: SizedBox(),
                expanded: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 10, left: 10),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.7,
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        child: Table(
                          border: TableBorder.symmetric(
                              inside:
                                  BorderSide(width: 1, color: Colors.black)),
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          children: [
                            TableRow(
                                decoration: BoxDecoration(
                                  color: Colors.grey[350],
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      topRight: Radius.circular(6)),
                                ),
                                children: [
                                  Text(
                                    "WORKED",
                                    textScaleFactor: 1,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    "LATE",
                                    textScaleFactor: 1,
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    "OVER",
                                    textScaleFactor: 1,
                                    textAlign: TextAlign.center,
                                  ),
                                ]),
                            TableRow(children: [
                              Text(
                                data.boilerPlate['wrkd_hours_fmtd'] == null
                                    ? " - "
                                    : data.boilerPlate['wrkd_hours_fmtd']
                                        .toString(),
                                textScaleFactor: 1,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                data.boilerPlate['late'] == null
                                    ? " - "
                                    : data.boilerPlate['late'].toString(),
                                textScaleFactor: 1,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                data.boilerPlate['over'] == null
                                    ? " - "
                                    : data.boilerPlate['over'].toString(),
                                textScaleFactor: 1,
                                textAlign: TextAlign.center,
                              ),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                builder: (_, collapsed, expanded) {
                  return Padding(
                    padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                    child: Expandable(
                      collapsed: collapsed,
                      expanded: expanded,
                      theme: const ExpandableThemeData(crossFadePoint: 0),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget lastMonth() {
    return FutureBuilder<List<AttendanceModel>>(
      future: myAttendance,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SlideAnimation(
            position: 4,
            itemCount: 8,
            slideDirection: SlideDirection.fromLeft,
            animationController: _animationController,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _attendanceCount,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    Container(
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * .1,
                          right: MediaQuery.of(context).size.width * .1,
                        ),
                        child: Divider(
                          color: Color(0xff26707070),
                          thickness: 2,
                        )),
                    Container(
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * .1,
                          right: MediaQuery.of(context).size.width * .1),
                      decoration: BoxDecoration(
                        color: HRColors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          new BoxShadow(
                            color: Color(0x14212121),
                            blurRadius: 20.0,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 20,
                          ),
                          // useDetail2(snapshot.data![index]),
                          useDetail2(snapshot
                              .data![snapshot.data!.length - index - 1]),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }
        return Container(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 90),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ),
        );
      },
    );
  }

  monthName(month) {
    if (month == 'January') {
      return AppLocalizations.of(context)!.january.toUpperCase();
    }
    if (month == 'February') {
      return AppLocalizations.of(context)!.february.toUpperCase();
    }
    if (month == 'March') {
      return AppLocalizations.of(context)!.march.toUpperCase();
    }
    if (month == 'April') {
      return AppLocalizations.of(context)!.april.toUpperCase();
    }
    if (month == 'May') {
      return AppLocalizations.of(context)!.may.toUpperCase();
    }
    if (month == 'June') {
      return AppLocalizations.of(context)!.june.toUpperCase();
    }
    if (month == 'July') {
      return AppLocalizations.of(context)!.july.toUpperCase();
    }
    if (month == 'August') {
      return AppLocalizations.of(context)!.august.toUpperCase();
    }
    if (month == 'September') {
      return AppLocalizations.of(context)!.september.toUpperCase();
    }
    if (month == 'October') {
      return AppLocalizations.of(context)!.october.toUpperCase();
    }
    if (month == 'November') {
      return AppLocalizations.of(context)!.november.toUpperCase();
    }
    if (month == 'December') {
      return AppLocalizations.of(context)!.december.toUpperCase();
    }
  }

  tabBar() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: 30),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              decoration: DesignConfig.boxDecorationButtonColor(
                  HRColors.white.withOpacity(0.7),
                  HRColors.white.withOpacity(0.6),
                  40),
              child: TabBar(
                onTap: (value) => callApi(value),
                indicatorWeight: 0,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.all(10),
                padding: EdgeInsets.all(8),
                labelColor: HRColors.black,
                unselectedLabelColor: Color(0xff8c989a),
                labelStyle:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: HRColors.intro1Sed1Color),
                tabs: [
                  // Tab(text: monthName(currentM)),
                  // Tab(text: monthName(lastM)),
                  Tab(text: storage.getItem('payroll_active_tag')),
                  Tab(text: storage.getItem('payroll_past_tag')),
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Expanded(
              child: TabBarView(children: [
                SingleChildScrollView(child: currentMonth()),
                SingleChildScrollView(child: lastMonth()),
              ]),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .12,
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      drawerScrimColor: Colors.transparent,
      drawer: DesignConfig.drawer(_scaffoldKey, context),
      body: Container(
        child: GlassBoxFull(
          background:
              'https://images.pexels.com/photos/113845/pexels-photo-113845.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 34.5,
                    bottom: MediaQuery.of(context).size.height / 15.2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _scaffoldKey.currentState!.openDrawer();
                      },
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          padding: EdgeInsets.all(5.0),
                          margin: EdgeInsets.only(left: 1.0, top: 26.0),
                          child: GlassBox(
                            redius: 40.0,
                            width: 47,
                            height: 50,
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SvgPicture.asset(
                                      "assets/svg/drawer_icon.svg")),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 34.5,
                    bottom: MediaQuery.of(context).size.height / 15.2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, HRNotifications.routeName);
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: EdgeInsets.all(5.0),
                          margin: EdgeInsets.only(left: 10.0, top: 25.0),
                          child: GlassBox(
                            redius: 40.0,
                            width: 50,
                            height: 50,
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SvgPicture.asset(
                                      "assets/svg/notifications_icon.svg")),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 10.4,
                      left: MediaQuery.of(context).size.width / 15.5),
                  child: Container(
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            AppLocalizations.of(context)!.attendanceText,
                            style: TextStyle(
                                fontSize: 30,
                                color: HRColors.black,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.left,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 7.5),
                child: tabBar(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> navigationPage() async {
    Navigator.pop(context);
  }
}
