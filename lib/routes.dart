import 'package:flutter/widgets.dart';
import 'package:cn_pocket_hr/Screens/attendance/attendanceScreen.dart';
import 'package:cn_pocket_hr/Screens/home/HomeScreen.dart';
import 'package:cn_pocket_hr/Screens/leave/leaveScreen.dart';
import 'package:cn_pocket_hr/Screens/leave/requestLeaveScreen.dart';
import 'package:cn_pocket_hr/Screens/login/LoginScreen.dart';
import 'package:cn_pocket_hr/Screens/main/MainScreen.dart';
import 'package:cn_pocket_hr/Screens/notifications/Notifications.dart';
import 'package:cn_pocket_hr/Screens/profile/ProfileScreen.dart';
import 'package:cn_pocket_hr/Screens/salarySlips/SalarySlips.dart'; 
import 'package:cn_pocket_hr/Screens/splashScreen/HRIntroduction.dart';
import 'package:cn_pocket_hr/Screens/splashScreen/Splashscreen.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  HRIntroduction.routeName: (context) => HRIntroduction(),
  HRLogin.routeName: (context) => HRLogin(),
  HRMain.routeName: (context) => HRMain(),
  HRHome.routeName: (context) => HRHome(),
  HRProfile.routeName: (context) => HRProfile(),
  HRLeave.routeName: (context) => HRLeave(),
  HRAttendance.routeName: (context) => HRAttendance(),
  HRLeaveRequest.routeName: (context) => HRLeaveRequest(),
  HRNotifications.routeName: (context) => HRNotifications(),
  HRSalarySlips.routeName: (context) => HRSalarySlips(),
};
