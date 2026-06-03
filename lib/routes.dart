import 'package:cn_pocket_hr/contact_us.dart/contact_us.dart';
import 'package:cn_pocket_hr/screens/allowances_deductions/allowance.dart';
import 'package:cn_pocket_hr/screens/team/team.dart';
import 'package:flutter/widgets.dart';
import 'package:cn_pocket_hr/screens/attendance/attendance_screen.dart';
import 'package:cn_pocket_hr/screens/home/home_screen.dart';
import 'package:cn_pocket_hr/screens/leave/leave_screen.dart';
import 'package:cn_pocket_hr/screens/leave/request_leave_screen.dart';
import 'package:cn_pocket_hr/screens/login/login_screen.dart';
import 'package:cn_pocket_hr/screens/location/location_permission_gate.dart';
import 'package:cn_pocket_hr/screens/main/main_screen.dart';
import 'package:cn_pocket_hr/screens/notifications/notifications.dart';
import 'package:cn_pocket_hr/screens/profile/profile_screen.dart';
import 'package:cn_pocket_hr/screens/salary_slips/salary_slips.dart'; 
import 'package:cn_pocket_hr/screens/splash_screen/hr_introduction.dart';
import 'package:cn_pocket_hr/screens/splash_screen/splashscreen.dart';
import 'package:cn_pocket_hr/screens/debts_and_loans/debts_and_loans_screen.dart';

final Map<String, WidgetBuilder> routes = {
  SplashScreen.routeName: (context) => SplashScreen(),
  HRIntroduction.routeName: (context) => HRIntroduction(),
  HRLogin.routeName: (context) => HRLogin(),
  LocationPermissionGate.routeName: (context) => const LocationPermissionGate(),
  HRMain.routeName: (context) => HRMain(),
  HRHome.routeName: (context) => HRHome(),
  HRProfile.routeName: (context) => HRProfile(),
  HRLeave.routeName: (context) => HRLeave(),
  HRAttendance.routeName: (context) => HRAttendance(),
  HRLeaveRequest.routeName: (context) => HRLeaveRequest(),
  HRNotifications.routeName: (context) => HRNotifications(),
  HRSalarySlips.routeName: (context) => HRSalarySlips(),
  HRAllowancesDeductions.routeName: (context) => HRAllowancesDeductions(),
  HRDebtsAndLoans.routeName: (context) => HRDebtsAndLoans(),
  HRTeam.routeName: (context) => HRTeam(),
  HRContactUs.routeName: (context) => HRContactUs(),



};
