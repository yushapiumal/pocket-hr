import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:localstorage/localstorage.dart';
import 'package:octo_image/octo_image.dart';
import 'package:cn_pocket_hr/Constant/Slideanimation.dart';
import 'package:cn_pocket_hr/Screens/leave/requestLeaveScreen.dart';
import 'package:cn_pocket_hr/Screens/notifications/Notifications.dart';
import 'package:cn_pocket_hr/api/apiService.dart';
import 'package:cn_pocket_hr/helper/DesignConfig.dart';
import 'package:cn_pocket_hr/helper/GlassBox.dart';
import 'package:cn_pocket_hr/helper/GlassBoxFull.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';
import 'package:cn_pocket_hr/helper/HRStrings.dart';
import 'package:cn_pocket_hr/model/FavouriteModel.dart';
import 'package:cn_pocket_hr/model/hr/LeaveModel.dart';

class TabletLeave extends StatefulWidget {
  TabletLeave({Key? key}) : super(key: key);

  @override
  TabletLeaveState createState() => TabletLeaveState();
}

class TabletLeaveState extends State<TabletLeave>
    with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController? _animationController;
  Future<List<MyLeavesModel>>? myLeaves;
  final LocalStorage storage = LocalStorage('pocketHR');
  List list = [];
  Timer? _timer;
  bool isLoading = false;
  APIService apiService = APIService();
  int _leaveListCount = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    getLeaves();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
  }

  getLeaves() async {
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
      body: Container(
        child: GlassBoxFull(
          background:
              'https://firebasestorage.googleapis.com/v0/b/smartkit-8e62c.appspot.com/o/travelapp%2Fimage_b.jpg?alt=media&token=2279a2b7-205e-4543-8260-b379377c5ba4',
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
                    left: MediaQuery.of(context).size.width / 15.5,
                  ),
                  child: Container(
                    child: Column(
                      children: [
                        Text(
                          HRStrings.leaveText,
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
                                          storage
                                              .getItem('leaveAnnual')
                                              .toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: HRColors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          "Anual",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: HRColors.black,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Center(
                                        child: Text(
                                          storage
                                              .getItem('leaveCasual')
                                              .toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: HRColors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          "Casual",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: HRColors.black,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Center(
                                        child: Text(
                                          storage
                                              .getItem('leaveMedical')
                                              .toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: HRColors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          "Medicle",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: HRColors.black,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Center(
                                        child: Text(
                                          storage
                                              .getItem('leaveNopay')
                                              .toString(),
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: HRColors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Text(
                                          "Nopay",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: HRColors.black,
                                            fontWeight: FontWeight.normal,
                                            fontSize: 15,
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
                    children: [showLeave()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: FloatingActionButton(
          backgroundColor: HRColors.black,
          elevation: 0.2,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.pushNamed(context, HRLeaveRequest.routeName);
          },
        ),
      ),
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
    return FutureBuilder<List<MyLeavesModel>>(
      future: myLeaves,
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
              itemCount: _leaveListCount,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  decoration: DesignConfig.boxDecorationButtonColor(
                      HRColors.white.withOpacity(0.7),
                      HRColors.white.withOpacity(0.6),
                      40),
                  padding: EdgeInsets.all(15.0),
                  margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 0.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  children: [
                                                    Text(
                                                        snapshot.data![index]
                                                            .leaveTitle,
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color:
                                                                HRColors.black,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Column(
                                                  children: [
                                                    Text(
                                                      '( ' +
                                                          snapshot.data![index]
                                                              .leaveType +
                                                          ' )',
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: HRColors
                                                              .darkFontColor
                                                              .withOpacity(0.7),
                                                          fontWeight: FontWeight
                                                              .normal),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2.0),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .52,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text(
                                                        'From : ' +
                                                            snapshot
                                                                .data![index]
                                                                .fromDate,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: HRColors
                                                                .darkFontColor
                                                                .withOpacity(
                                                                    0.7),
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 2.0),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .52,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    children: [
                                                      Text(
                                                        'To : ' +
                                                            snapshot
                                                                .data![index]
                                                                .toDate,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: HRColors
                                                                .darkFontColor
                                                                .withOpacity(
                                                                    0.7),
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Align(
                                        //   alignment: Alignment.topLeft,
                                        //   child: Padding(
                                        //     padding:
                                        //         const EdgeInsets.only(top: 2.0),
                                        //     child: Container(
                                        //       width: MediaQuery.of(context)
                                        //               .size
                                        //               .width *
                                        //           .52,
                                        //       child: Text(
                                        //         snapshot.data![index].description,
                                        //         style: TextStyle(
                                        //             fontSize: 16,
                                        //             color: HRColors.iconColor
                                        //                 .withOpacity(0.7),
                                        //             fontWeight:
                                        //                 FontWeight.normal),
                                        //         overflow: TextOverflow.ellipsis,
                                        //       ),
                                        //     ),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: GestureDetector(
                              onTap: () {
                                apiService
                                    .showToast(snapshot.data![index].status);
                              },
                              child: Card(
                                color: HRColors.white.withOpacity(0.7),
                                elevation: 5,
                                shadowColor:
                                    HRColors.iconColor.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Container(
                                    height: 50,
                                    width: 50,
                                    padding: EdgeInsets.all(10.0),
                                    decoration:
                                        DesignConfig.boxDecorationButtonColor(
                                            HRColors.white.withOpacity(0.7),
                                            HRColors.white.withOpacity(0.6),
                                            50),
                                    child:
                                        getIcon(snapshot.data![index].status)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
              ))),
        );
      },
    );
  }

  Future<void> navigationPage() async {
    Navigator.pop(context);
  }
}
