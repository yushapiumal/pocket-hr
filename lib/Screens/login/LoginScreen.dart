import 'package:flutter/material.dart';
import 'package:cn_pocket_hr/Screens/login/devices/mobileLogin.dart';
import 'package:cn_pocket_hr/Screens/login/devices/tabletLogin.dart';
import 'package:cn_pocket_hr/ui/responsiveLayout.dart';

class HRLogin extends StatefulWidget {
  static String routeName = "/login";

  @override
  HRLoginState createState() => HRLoginState();
}

class HRLoginState extends State<HRLogin> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileLogin(),
      tabletBody: TabletLogin(),
    );
  }
}
