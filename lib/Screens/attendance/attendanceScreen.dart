import 'dart:async';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cn_pocket_hr/Screens/attendance/devices/mobileAttendance.dart';
import 'package:cn_pocket_hr/Screens/attendance/devices/tabletAttendance.dart';
import 'package:cn_pocket_hr/Screens/notifications/Notifications.dart';
import 'package:cn_pocket_hr/helper/DesignConfig.dart';
import 'package:cn_pocket_hr/helper/GlassBox.dart';
import 'package:cn_pocket_hr/helper/GlassBoxFull.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';
import 'package:cn_pocket_hr/helper/HRStrings.dart';
import 'package:cn_pocket_hr/ui/responsiveLayout.dart';

class HRAttendance extends StatefulWidget {
  static String routeName = "/attendance";
  const HRAttendance({Key? key}) : super(key: key);

  @override
  _HRAttendanceState createState() => _HRAttendanceState();
}

class _HRAttendanceState extends State<HRAttendance> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileAttendance(),
      tabletBody: TabletAttendance(),
    );
  }
}
