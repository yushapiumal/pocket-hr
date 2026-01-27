import 'dart:async';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:octo_image/octo_image.dart';
import 'package:cn_pocket_hr/Constant/Slideanimation.dart';
import 'package:cn_pocket_hr/Screens/leave/devices/Card1.dart';
import 'package:cn_pocket_hr/Screens/leave/devices/Slidable.dart';
import 'package:cn_pocket_hr/Screens/leave/devices/Slide_action.dart';
import 'package:cn_pocket_hr/Screens/leave/requestLeaveScreen.dart';
import 'package:cn_pocket_hr/Screens/notifications/Notifications.dart';
import 'package:cn_pocket_hr/api/apiService.dart';
import 'package:cn_pocket_hr/helper/DesignConfig.dart';
import 'package:cn_pocket_hr/helper/GlassBox.dart';
import 'package:cn_pocket_hr/helper/GlassBoxCurve.dart';
import 'package:cn_pocket_hr/helper/GlassBoxFull.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';
import 'package:cn_pocket_hr/helper/HRStrings.dart';
import 'package:cn_pocket_hr/model/FavouriteModel.dart';
import 'package:cn_pocket_hr/model/hr/LeaveModel.dart';
import 'package:cn_pocket_hr/model/hr/MeModel.dart';

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
  Timer? _timer;
  bool isLoading = false;
  APIService apiService = APIService();
  int _leaveListCount = 0;
  int _meListCount = 0;
  bool isOthers = false;
  bool leaveManageForm = false;
  bool leaveApprove = true;
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // getOthersLeaves();
    getMyLeaves();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
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
      drawer: DesignConfig.drawer(_scaffoldKey, context),
      body: Container(
        child: GlassBoxFull(
          background:
              'https://images.pexels.com/photos/1005417/pexels-photo-1005417.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
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
                                    "assets/svg/drawer_icon.svg"),
                              ),
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
                    // left: MediaQuery.of(context).size.width / 15.5,
                  ),
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.leaveText,
                          style: TextStyle(
                              fontSize: 30,
                              color: HRColors.black,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.left,
                        ),
                        // if (isOthers) othersLeaves(),
                        othersLeaves(),
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
                                                  .toString() +
                                              '/' +
                                              storage
                                                  .getItem('annualQuota')
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
                                                  .toString() +
                                              '/' +
                                              storage
                                                  .getItem('casualQuota')
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
                                                  .toString() +
                                              '/' +
                                              storage
                                                  .getItem('medicalQuota')
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
                        ),
                        Container(
                          height: isOthers
                              ? MediaQuery.of(context).size.width * .73
                              : MediaQuery.of(context).size.height * .7,

                          // child: Expanded(
                          child: SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                showLeave(),
                                SizedBox(
                                  height: isOthers ? 25 : 50,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (leaveManageForm) leaveCard(),
            ],
          ),
        ),
      ),
      floatingActionButton: !leaveManageForm
          ? Padding(
              padding: const EdgeInsets.only(bottom: 90.0),
              child: FloatingActionButton(
                backgroundColor: HRColors.black,
                elevation: 0.2,
                child: Icon(Icons.add),
                onPressed: () {
                  Navigator.pushNamed(context, HRLeaveRequest.routeName);
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
      margin: EdgeInsets.only(
          // left: MediaQuery.of(context).size.width / 90,
          // right: MediaQuery.of(context).size.width / 50,
          ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).size.height / 35,
      ),
      child: Center(
        child: OrientationBuilder(
          builder: (context, orientation) =>
              _buildList(context, Axis.horizontal),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, Axis direction) {
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
                final Axis slidableDirection = Axis.horizontal;
                const double DefaultPadding = 20.0;
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        apiService.showToast(snapshot.data![index].status);
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height / 10,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Color.fromRGBO(66, 66, 66, 1)
                                  .withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset:
                                  Offset(1, 1), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Slidable(
                          key: Key(snapshot.data![index].leaveTitle),
                          direction: direction,
                          // slideToDismissDelegate: SlideToDismissDrawerDelegate(
                          //   onWillDismiss: (_) {
                          //     if (_ == SlideActionType.primary) {
                          //       setState(() {
                          //         leaveManageForm = true;
                          //         leaveApprove = true;
                          //       });
                          //     } else {
                          //       setState(() {
                          //         leaveManageForm = true;
                          //         leaveApprove = false;
                          //       });
                          //     }
                          //     setLeaveValue(snapshot.data![index]);
                          //     return true;
                          //   },
                          // ),
                          delegate: SlidableBehindDelegate(),
                          actionExtentRatio: 0.25,
                          child: Container(
                            height: MediaQuery.of(context).size.height / 10,
                            padding: EdgeInsets.only(left: 10, right: 10),
                            color: Colors.white,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration:
                                      DesignConfig.boxDecorationButtonColor(
                                          Color.fromARGB(255, 255, 254, 254)
                                              .withOpacity(0.6),
                                          Color.fromARGB(255, 184, 184, 184)
                                              .withOpacity(0.7),
                                          50),
                                  child: getIcon(snapshot.data![index].status),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(9.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(width: 10),
                                        Text(snapshot.data![index].leaveTitle),
                                        SizedBox(height: 10),
                                        Text(snapshot.data![index].leaveType),
                                      ],
                                    ),
                                  ),
                                ),
                                Flexible(
                                  fit: FlexFit.tight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 10),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'From : ${snapshot.data![index].fromDate}',
                                          maxLines: 1,
                                          softWrap: false,
                                          // overflow: TextOverflow.fade,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'To : ${snapshot.data![index].toDate}',
                                          maxLines: 1,
                                          softWrap: false,
                                          // overflow: TextOverflow.fade,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            IconSlideAction(
                              caption: 'Approve',
                              color: Color.fromARGB(255, 15, 205, 25),
                              icon: Icons.check,
                              onTap: () {
                                setState(() {
                                  leaveManageForm = true;
                                  leaveApprove = true;
                                });
                                setLeaveValue(snapshot.data![index]);
                              },
                            ),
                          ],
                          secondaryActions: [
                            IconSlideAction(
                              caption: 'Reject',
                              color: Colors.red,
                              icon: Icons.cancel,
                              onTap: () {
                                setState(() {
                                  leaveManageForm = true;
                                  leaveApprove = false;
                                });
                                setLeaveValue(snapshot.data![index]);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 4,
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

  List<String> leaveTypeList = ["annual", "casual", "medical", "duty", "nopay"];
  String? typeValue = "annual";
  String fromText = "From";
  DateTime fDate = DateTime.now();
  String toText = "To";
  DateTime tDate = DateTime.now();
  bool halfDayToggle = false;
  // String description = "";
  TextEditingController description = TextEditingController();
  String dummy = "Full Day Selected";
  String? leave_typeValue = "full_day";

  List<String> reasonList = [
    "Duty Leave",
    "Annual Vacation",
    "Examination",
    "Family Function",
    "Urgent",
    "Additional day"
  ];
  String? reasonListValue = "Duty Leave";
  List<String> firstsecondList = ["First", "Second"];
  String? firstsecondValue = "First";

  setLeaveValue(value) {
    setState(
      () {
        typeValue = value.type;
        description.text = value.description;
        fDate = DateTime.now();
        fromText = DateFormat("yyyy-MM-dd").parse('2012-02-27').toString();
        tDate = DateTime.now();
        toText = DateFormat("yyyy-MM-dd").parse('2012-02-27').toString();
        reasonListValue = value.leaveTitle;
      },
    );
  }

  Future<void> selectFDate(BuildContext context) async {
    var date = new DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: fDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(date.year, date.month + 2, date.day),
    );
    if (pickedDate != null && pickedDate != fDate)
      setState(
        () {
          fDate = pickedDate;
          fromText = DateFormat("yyyy-MM-dd").format(pickedDate).toString();
        },
      );
  }

  Future<void> selectTDate(BuildContext context) async {
    var date = new DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: tDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(date.year, date.month + 2, date.day));
    if (pickedDate != null && pickedDate != tDate)
      setState(
        () {
          tDate = pickedDate;
          toText = DateFormat("yyyy-MM-dd").format(pickedDate).toString();
        },
      );
  }

  Widget showFirstSecond() {
    return Container(
      margin: EdgeInsets.only(top: 15.0, left: 30.0, right: 30.0),
      decoration: DesignConfig.boxDecorationButtonColor(
        Colors.white.withOpacity(0.9),
        Color.fromARGB(255, 213, 213, 213).withOpacity(0.8),
        50,
      ),
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: DropdownButton<String>(
        underline: Container(color: Colors.transparent, height: 2.0),
        dropdownColor: HRColors.white,
        hint: Text(
          HRStrings.countryText,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 18,
            fontWeight: FontWeight.normal,
          ),
        ),
        value: firstsecondValue,
        iconSize: 24,
        elevation: 16,
        iconDisabledColor: HRColors.grayColor,
        iconEnabledColor: HRColors.grayColor,
        isExpanded: true,
        style: TextStyle(
          color: Colors.black54,
          fontSize: 18,
          fontWeight: FontWeight.normal,
        ),
        onChanged: (String? newValue) {
          showhidehalfday(newValue);
        }, //leaveList
        items: firstsecondList.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              textAlign: TextAlign.right,
            ),
          );
        }).toList(),
      ),
    );
  }

  void showhidehalfday(newValue) {
    setState(() {
      leave_typeValue = newValue;
    });
    if (leave_typeValue == "Half Day") {
      setState(() {
        halfDayToggle = !halfDayToggle;
      });
    } else {
      setState(() {
        halfDayToggle = false;
      });
    }
  }

  Widget showDetail() {
    return Container(
      margin: EdgeInsets.only(top: 15.0, left: 30.0, right: 30.0),
      decoration: DesignConfig.boxDecorationButtonColor(
        Colors.white.withOpacity(0.9),
        Color.fromARGB(255, 213, 213, 213).withOpacity(0.8),
        50,
      ),
      padding: const EdgeInsets.only(left: 20.0),
      child: TextField(
        controller: description,
        maxLines: null,
        minLines: 2,
        style: TextStyle(color: HRColors.black),
        cursorColor: HRColors.black,
        decoration: InputDecoration(
          hintText: "Description (optional)",
          hintStyle: Theme.of(context).textTheme.titleSmall!.merge(
                TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                  color: Colors.black54,
                ),
              ),
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.multiline,
      ),
    );
  }

  Widget showSelectLeaveType() {
    return Container(
      margin: EdgeInsets.only(top: 15.0, left: 30.0, right: 30.0),
      decoration: DesignConfig.boxDecorationButtonColor(
        Colors.white.withOpacity(0.9),
        Color.fromARGB(255, 213, 213, 213).withOpacity(0.8),
        50,
      ),
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: DropdownButton<String>(
        underline: Container(color: Colors.transparent, height: 2.0),
        dropdownColor: HRColors.white,
        hint: Text(HRStrings.countryText,
            style: TextStyle(
              color: HRColors.grayColor,
              fontSize: 18,
              fontWeight: FontWeight.normal,
            )),
        value: reasonListValue,
        iconSize: 24,
        elevation: 16,
        iconDisabledColor: HRColors.grayColor,
        iconEnabledColor: HRColors.grayColor,
        isExpanded: true,
        style: TextStyle(
          color: Colors.black54,
          fontSize: 18,
          fontWeight: FontWeight.normal,
        ),
        onChanged: (String? newValue) {
          setState(() {
            reasonListValue = newValue;
          });
        },
        items: reasonList.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              textAlign: TextAlign.right,
            ),
          );
        }).toList(),
      ),
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  Widget showType() {
    return Container(
      margin: EdgeInsets.only(top: 15.0, left: 30.0, right: 30.0),
      decoration: DesignConfig.boxDecorationButtonColor(
        Colors.white.withOpacity(0.9),
        Color.fromARGB(255, 213, 213, 213).withOpacity(0.8),
        50,
      ),
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: DropdownButton<String>(
        underline: Container(color: Colors.transparent, height: 2.0),
        dropdownColor: HRColors.white,
        hint: Text(HRStrings.countryText,
            style: TextStyle(
              color: HRColors.grayColor,
              fontSize: 18,
              fontWeight: FontWeight.normal,
            )),
        value: typeValue,
        iconSize: 24,
        elevation: 16,
        iconDisabledColor: HRColors.grayColor,
        iconEnabledColor: HRColors.grayColor,
        isExpanded: true,
        style: TextStyle(
          color: Colors.black54,
          fontSize: 18,
          fontWeight: FontWeight.normal,
        ),
        onChanged: (String? newValue) {
          setState(() {
            typeValue = newValue;
          });
        },
        items: leaveTypeList.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              capitalize(value),
              textAlign: TextAlign.right,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget showFDate() {
    return GestureDetector(
      onTap: () {
        selectFDate(context);
      },
      child: Container(
        margin: EdgeInsets.only(top: 15.0, left: 30.0, right: 30.0),
        decoration: DesignConfig.boxDecorationButtonColor(
          Colors.white.withOpacity(0.9),
          Color.fromARGB(255, 213, 213, 213).withOpacity(0.8),
          50,
        ),
        padding: const EdgeInsets.only(
            left: 20.0, right: 20.0, top: 12.0, bottom: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(fromText,
                style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.normal,
                    fontSize: 18)),
            Icon(Icons.arrow_drop_down, color: HRColors.grayColor),
          ],
        ),
      ),
    );
  }

  Widget showTDate() {
    return GestureDetector(
      onTap: () {
        selectTDate(context);
      },
      child: Container(
        margin: EdgeInsets.only(top: 15.0, left: 30.0, right: 30.0),
        decoration: DesignConfig.boxDecorationButtonColor(
          Colors.white.withOpacity(0.9),
          Color.fromARGB(255, 213, 213, 213).withOpacity(0.8),
          50,
        ),
        padding: const EdgeInsets.only(
            left: 20.0, right: 20.0, top: 12.0, bottom: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(toText,
                style: TextStyle(
                    color: Colors.black54,
                    fontWeight: FontWeight.normal,
                    fontSize: 18)),
            Icon(Icons.arrow_drop_down, color: HRColors.grayColor),
          ],
        ),
      ),
    );
  }

  Widget leaveCard() {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 6),
      height: MediaQuery.of(context).size.height,
      child: GlassBoxCurve(
        height: MediaQuery.of(context).size.height * .5,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    leaveManageForm = false;
                    leaveApprove = true;
                  });
                },
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    margin: EdgeInsets.only(left: 1.0, top: 26.0),
                    child: const GlassBox(
                      redius: 40.0,
                      width: 47,
                      height: 50,
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Icon(Icons.close),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                leaveApprove
                    ? AppLocalizations.of(context)!.leaveApprove.toUpperCase()
                    : AppLocalizations.of(context)!.leaveReject.toUpperCase(),
                style: TextStyle(
                    fontSize: 25,
                    color: HRColors.black,
                    fontWeight: FontWeight.normal),
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                dummy,
                style: TextStyle(fontSize: 18),
              ),
              if (halfDayToggle) showFirstSecond(),
              if (leaveApprove) showType(),
              if (leaveApprove) showFDate(),
              if (leaveApprove) showTDate(),
              if (leaveApprove) showSelectLeaveType(),
              showDetail(),
              SizedBox(width: 10.0),
              GestureDetector(
                onTap: () {},
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                      width: MediaQuery.of(context).size.width / 2.5,
                      decoration: DesignConfig.boxDecorationButtonColor(
                          HRColors.blueColor, HRColors.blueColor, 25),
                      alignment: AlignmentDirectional.center,
                      margin: EdgeInsets.only(
                          left: 30.0,
                          top: MediaQuery.of(context).size.height / 40,
                          right: 30.0,
                          bottom: MediaQuery.of(context).size.height / 35),
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            HRStrings.submit,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: HRColors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          SizedBox(width: 5),
                        ],
                      )),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom))
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
