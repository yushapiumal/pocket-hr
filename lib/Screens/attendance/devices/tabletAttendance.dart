import 'dart:async';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cn_pocket_hr/Screens/notifications/Notifications.dart';
import 'package:cn_pocket_hr/helper/DesignConfig.dart';
import 'package:cn_pocket_hr/helper/GlassBox.dart';
import 'package:cn_pocket_hr/helper/GlassBoxFull.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';
import 'package:cn_pocket_hr/helper/HRStrings.dart';

class TabletAttendance extends StatefulWidget {
  TabletAttendance({Key? key}) : super(key: key);

  @override
  TabletAttendanceState createState() => TabletAttendanceState();
}

class TabletAttendanceState extends State<TabletAttendance> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  Widget picUpDropCan1() {
    return Container(
      height: MediaQuery.of(context).size.height * .135,
      margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * .05),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 5,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 25,
                        color: Colors.black38,
                      ),
                      Icon(
                        Icons.circle,
                        size: 15,
                        color: Colors.black,
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .05,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "pickUp",
                    style: TextStyle(color: Color(0xff959595), fontSize: 18),
                  ),
                  Row(
                    children: [
                      Text(
                        "80, Vile Parle West",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .005,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * .1),
                        child: Text(
                          "9:30 PM",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                width: 20,
              ),
            ],
          ),
          Stack(
            children: [
              Container(
                  alignment: Alignment.topLeft,
                  height: 25,
                  padding: EdgeInsets.only(left: 17),
                  child: DottedLine(
                    dashLength: 3,
                    direction: Axis.vertical,
                    lineThickness: 1.0,
                    dashColor: Colors.black38,
                  )),
              Container(
                  margin: EdgeInsets.only(left: 40, top: 5, right: 20),
                  child: Divider(
                    color: Color(0xff26707070),
                    thickness: 2,
                  )),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 5,
              ),
              Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 25,
                        color: HRColors.yellow.withOpacity(0.5),
                      ),
                      Icon(Icons.circle, size: 15, color: HRColors.yellow),
                    ],
                  )
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * .05,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "dropOff",
                    style: TextStyle(color: Color(0xff959595), fontSize: 18),
                  ),
                  Row(
                    children: [
                      Text(
                        "80, Vile Parle Eest",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w600),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * .1),
                        child: Text(
                          "10:10 PM",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget currentMonth() {
    return ListView(
      children: [
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * .1, top: 20),
          child: Text(
            "Yesterday - 11:30 AM",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
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
              useDetail2(),
              Container(
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * .05,
                      right: MediaQuery.of(context).size.width * .05,
                      top: 5),
                  child: Divider(
                    color: Color(0xff26707070),
                    thickness: 2,
                  )),
              Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * .1),
                  child: Text(
                    "TripRoute",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  )),
              Container(
                  margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * .05,
                    right: MediaQuery.of(context).size.width * .05,
                  ),
                  child: Divider(
                    color: Color(0xff26707070),
                    thickness: 2,
                  )),
              picUpDropCan1(),
            ],
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * .1, top: 20),
          child: Text(
            "Yesterday - 10:30 AM",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
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
              useDetail2(),
              Container(
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * .05,
                      right: MediaQuery.of(context).size.width * .05,
                      top: 5),
                  child: Divider(
                    color: Color(0xff26707070),
                    thickness: 2,
                  )),
              Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * .1),
                  child: Text(
                    "TripRoute",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  )),
              Container(
                  margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * .05,
                    right: MediaQuery.of(context).size.width * .05,
                  ),
                  child: Divider(
                    color: Color(0xff26707070),
                    thickness: 2,
                  )),
              picUpDropCan1(),
            ],
          ),
        ),
      ],
    );
  }

  Widget useDetail2() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              height: 50,
              width: 55,
              margin: EdgeInsets.only(left: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: Image.asset(
                  DesignConfig.getPngImagePath("toptrip_b.jpg"),
                  fit: BoxFit.fill,
                ),
              ),
            )
          ],
        ),
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(left: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "JOHN DOE",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                "Mercedes A - 6250",
                style: TextStyle(fontSize: 18, color: Color(0xff676767)),
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                        text: "OTP :",
                        style:
                            TextStyle(fontSize: 18, color: Color(0xff676767))),
                    TextSpan(
                      text: "3653",
                      style: TextStyle(fontSize: 18, color: HRColors.black),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(left: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "FinalCost",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              Text(
                "\$80.00",
                style: TextStyle(
                    fontSize: 18,
                    color: Color(0xff676767),
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(left: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "time",
                style: TextStyle(fontSize: 18),
              ),
              Text(
                "60.00",
                style: TextStyle(
                    fontSize: 18,
                    color: Color(0xff676767),
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget lastMonth() {
    return ListView(
      children: [
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * .1, top: 20),
          child: Text(
            "Last - 11:30 AM",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
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
              useDetail2(),
              Container(
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * .05,
                      right: MediaQuery.of(context).size.width * .05,
                      top: 5),
                  child: Divider(
                    color: Color(0xff26707070),
                    thickness: 2,
                  )),
              Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * .1),
                  child: Text(
                    "TripRoute",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  )),
              Container(
                  margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * .05,
                    right: MediaQuery.of(context).size.width * .05,
                  ),
                  child: Divider(
                    color: Color(0xff26707070),
                    thickness: 2,
                  )),
              picUpDropCan1(),
            ],
          ),
        ),
        Container(
          alignment: Alignment.topLeft,
          padding: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * .1, top: 20),
          child: Text(
            "Yesterday - 10:30 AM",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
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
              useDetail2(),
              Container(
                  margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * .05,
                      right: MediaQuery.of(context).size.width * .05,
                      top: 5),
                  child: Divider(
                    color: Color(0xff26707070),
                    thickness: 2,
                  )),
              Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * .1),
                  child: Text(
                    "TripRoute",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  )),
              Container(
                  margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * .05,
                    right: MediaQuery.of(context).size.width * .05,
                  ),
                  child: Divider(
                    color: Color(0xff26707070),
                    thickness: 2,
                  )),
              picUpDropCan1(),
            ],
          ),
        ),
      ],
    );
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
                indicatorWeight: 0,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.all(10),
                padding: EdgeInsets.all(15),
                labelColor: HRColors.black,
                unselectedLabelColor: Color(0xff8c989a),
                labelStyle:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: HRColors.intro1Sed1Color),
                tabs: [
                  Tab(text: "Current Month"),
                  Tab(text: "Last Month"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(children: [currentMonth(), lastMonth()]),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * .30,
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
              GestureDetector(
                  onTap: () {
                    _scaffoldKey.currentState!.openDrawer();
                  },
                  child: Align(
                      alignment: Alignment.topLeft,
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
                                      "assets/svg/drawer_icon.svg")),
                            ),
                          )))),
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
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height / 10.4,
                      left: MediaQuery.of(context).size.width / 15.5),
                  child: Container(
                    child: Column(
                      children: [
                        Text(
                          HRStrings.attendanceText,
                          style: TextStyle(
                              fontSize: 35,
                              color: HRColors.black,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.left,
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  top: MediaQuery.of(context).size.height / 35),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Column(
                                    children: [
                                      Center(
                                        child: Text(
                                          "(Jan 21 - Feb 20)",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: HRColors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          "February",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: HRColors.black,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 4.2),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // dataTable()
                      tabBar()
                    ],
                  ),
                ),
              ),
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
