import 'dart:async';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cn_pocket_hr/screens/attendance/devices/mobile_attendance.dart';
import 'package:cn_pocket_hr/screens/attendance/devices/tablet_attendance.dart';
import 'package:cn_pocket_hr/screens/notifications/notifications.dart';
import 'package:cn_pocket_hr/helpers/design_config.dart';
import 'package:cn_pocket_hr/helpers/glass_box.dart';
import 'package:cn_pocket_hr/helpers/glass_box_full.dart';
import 'package:cn_pocket_hr/helpers/hr_colors.dart';
import 'package:cn_pocket_hr/helpers/hr_strings.dart';
import 'package:cn_pocket_hr/ui/responsive_layout.dart';

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
