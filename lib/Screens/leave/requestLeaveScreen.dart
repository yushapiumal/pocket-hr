import 'package:flutter/material.dart';
import 'package:cn_pocket_hr/Screens/leave/devices/mobileLeaveRequest.dart';
import 'package:cn_pocket_hr/Screens/leave/devices/tabletLeaveRequest.dart';
import 'package:cn_pocket_hr/ui/responsiveLayout.dart';

class HRLeaveRequest extends StatefulWidget {
  static String routeName = "/leave-request";

  const HRLeaveRequest({Key? key}) : super(key: key);

  @override
  _HRLeaveRequestState createState() => _HRLeaveRequestState();
}

class _HRLeaveRequestState extends State<HRLeaveRequest> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileLeaveRequest(),
      tabletBody: TabletLeaveRequest(),
    );
  }
}
