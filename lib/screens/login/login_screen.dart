import 'package:flutter/material.dart';
import 'package:cn_pocket_hr/screens/login/devices/mobile_login.dart';
import 'package:cn_pocket_hr/screens/login/devices/tablet_login.dart';
import 'package:cn_pocket_hr/ui/responsive_layout.dart';

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
