import 'package:cn_pocket_hr/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cn_pocket_hr/Constant/Slideanimation.dart';
import 'package:cn_pocket_hr/Screens/leave/devices/Slidable.dart';
import 'package:cn_pocket_hr/Screens/leave/devices/Slide_action.dart';
import 'package:cn_pocket_hr/Screens/main/MainScreen.dart';
import 'package:cn_pocket_hr/Screens/notifications/Notifications.dart';
import 'package:cn_pocket_hr/helper/DesignConfig.dart';
import 'package:cn_pocket_hr/helper/GlassBox.dart';
import 'package:cn_pocket_hr/helper/GlassBoxCurve.dart';
import 'package:cn_pocket_hr/helper/GlassBoxFull.dart';


import 'package:cn_pocket_hr/helper/HRColors.dart';

class MobileSalarySlip extends StatefulWidget {
  const MobileSalarySlip({Key? key}) : super(key: key);

  @override
  State<MobileSalarySlip> createState() => _MobileSalarySlipState();
}

class _MobileSalarySlipState extends State<MobileSalarySlip>
    with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  AnimationController? _animationController;

  // Render HTML only when there is actual content to show.
  bool get _hasHtml => htmlData.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
  }

  @override
  void dispose() {
    _animationController!.dispose();
    super.dispose();
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
              'https://images.pexels.com/photos/2880718/pexels-photo-2880718.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Align(

                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    margin: EdgeInsets.only(top: 50.0, left: 7.0),
                    child: GlassBox(
                      redius: 40.0,
                      width: 50,
                      height: 50,
                      child:Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Icon(Icons.arrow_back_ios_sharp,
                              color: HRColors.black),
                        ),
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
                        Center(
                          child: Text(
                            AppLocalizations.of(context)!.salarySlips,
                            style: TextStyle(
                                fontSize: 30,
                                color: HRColors.black,
                                fontWeight: FontWeight.normal),
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * .7,
                          child: SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            child: Column(
                              children: [
                                // Show slips content on mobile.
                                showSlips(),
                                SizedBox(
                                  height: 50,
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
              if (_hasHtml) showHtml(),
            ],
          ),
        ),
      ),
    );
  }

  Widget showSlips() {
    return Container(
      margin: EdgeInsets.only(
        left: MediaQuery.of(context).size.width / 90,
        right: MediaQuery.of(context).size.width / 20,
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
    // Use the defined sample list so the widget actually renders.
    final Future<List<_HomeItem>> homeListFuture =
        Future<List<_HomeItem>>.value(homeList);

    return FutureBuilder<List<_HomeItem>>(
      future: homeListFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SlideAnimation(
            position: 4,
            itemCount: snapshot.data!.length,
            slideDirection: SlideDirection.fromLeft,
            animationController: _animationController,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: snapshot.data!.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {},
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
                              offset: Offset(1, 1),
                            ),
                          ],
                        ),
                        child: Slidable(
                          key: Key(snapshot.data![index].title),
                          direction: direction,
                          delegate: SlidableBehindDelegate(),
                          actionExtentRatio: 0.25,
                          actions: [
                            IconSlideAction(
                              caption: 'Approve',
                              color: Color.fromARGB(255, 15, 205, 25),
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
                          child: Container(
                            height: MediaQuery.of(context).size.height / 10,
                            padding: EdgeInsets.only(left: 10, right: 10),
                            color: Colors.white,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
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
                                        Text(snapshot.data![index].title),
                                        SizedBox(height: 10),
                                        Text(snapshot.data![index].subtitle),
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
                                          'From ',
                                          maxLines: 1,
                                          softWrap: false,
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          'To : ',
                                          maxLines: 1,
                                          softWrap: false,
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
                    ),
                    SizedBox(
                      height: 10,
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

  final htmlData = r"""   """;

  Widget showHtml() {
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
              Html(
                data: htmlData,
              ),
              Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom))
            ],
          ),
        ),
      ),
    );

    // return SingleChildScrollView(
    //   child: Html(
    //     data: htmlData,
    //     tagsList: Html.tags..addAll(["bird", "flutter"]),
    //     style: {
    //       'h5': Style(maxLines: 2, textOverflow: TextOverflow.ellipsis),
    //     },
    //   ),
    // );
  }

  Future<void> navigationPage() async {
    Navigator.pop(context);
  }
}

class _HomeItem {
  const _HomeItem(
    this.index,
    this.title,
    this.subtitle,
    this.color,
  );

  final int index;
  final String title;
  final String subtitle;
  final Color color;
}

List<_HomeItem> homeList = [
  _HomeItem(
    1,
    "Aayansh",
    "Aayansh@gmail.com",
    Colors.amberAccent,
  ),
  _HomeItem(
    2,
    "Avyukt",
    "Avyukt@gmail.com",
    Colors.cyan,
  ),
  _HomeItem(
    3,
    "Kiyansh",
    "Kiyansh@gmail.com",
    Colors.redAccent,
  ),
  _HomeItem(
    4,
    "Atharv",
    "Atharv@gmail.com",
    Colors.deepPurpleAccent,
  ),
  _HomeItem(
    5,
    "Rihaan",
    "Rihaan@gmail.com",
    Colors.orangeAccent,
  ),
  _HomeItem(
    6,
    "Ivaan",
    "Ivaan@gmail.com",
    Colors.teal,
  ),
  _HomeItem(
    7,
    "Nirved",
    "Nirved@gmail.com",
    Colors.pink,
  ),
  _HomeItem(
    8,
    "Sriansh",
    "Sriansh@gmail.com",
    Colors.lightBlueAccent,
  ),
];
