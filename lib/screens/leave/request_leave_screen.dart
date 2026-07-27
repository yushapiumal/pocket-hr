import 'package:flutter/material.dart';
import 'package:cn_pocket_hr/screens/leave/devices/mobile_leave_request_page.dart';

class HRLeaveRequest extends StatefulWidget {
  static String routeName = "/leave-request";

  const HRLeaveRequest({Key? key}) : super(key: key);

  @override
  _HRLeaveRequestState createState() => _HRLeaveRequestState();
}

class _HRLeaveRequestState extends State<HRLeaveRequest> {
  @override
  Widget build(BuildContext context) {
    return const MobileLeaveRequestPage(
      isEdit: false,
      initial: null,
    );
  }
}
