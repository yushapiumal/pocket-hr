import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cn_pocket_hr/screens/notifications/notifications.dart';
import 'package:cn_pocket_hr/helpers/glass_box.dart';

class TabletTopBar extends StatefulWidget {
  const TabletTopBar({Key? key}) : super(key: key);

  @override
  State<TabletTopBar> createState() => _TabletTopBarState();
}

class _TabletTopBarState extends State<TabletTopBar> {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Column(
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
                            child:
                                SvgPicture.asset("assets/svg/drawer_icon.svg")),
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
      ],
    );
  }
}
