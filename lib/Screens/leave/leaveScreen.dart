import 'package:flutter/material.dart';
import 'package:cn_pocket_hr/Screens/leave/devices/mobileLeave.dart';
import 'package:cn_pocket_hr/Screens/leave/devices/tabletLeave.dart';
import 'package:cn_pocket_hr/ui/responsiveLayout.dart';

class HRLeave extends StatefulWidget {
  static String routeName = "/leave";

  const HRLeave({Key? key}) : super(key: key);

  @override
  _HRLeaveState createState() => _HRLeaveState();
}

class _HRLeaveState extends State<HRLeave> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileLeave(),
      tabletBody: TabletLeave(),
    );
  }
}
