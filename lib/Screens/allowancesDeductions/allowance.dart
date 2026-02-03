import 'package:cn_pocket_hr/Screens/allowancesDeductions/devices/mobileAllowancesDeductionsScreen.dart';
import 'package:cn_pocket_hr/Screens/allowancesDeductions/devices/tabletAllowancesDeductionsScreen.dart';
import 'package:flutter/material.dart';
import 'package:cn_pocket_hr/ui/responsiveLayout.dart';

class HRAllowancesDeductions extends StatefulWidget {
  static String routeName = "/allowances-deductions";
  HRAllowancesDeductions({Key? key}) : super(key: key);

  @override
  _HRAllowancesDeductionsState createState() => _HRAllowancesDeductionsState();
}

class _HRAllowancesDeductionsState extends State<HRAllowancesDeductions> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileAllowancesDeductionsScreen(),
      tabletBody: TabletAllowancesDeductionsScreen(),
    );
  }
}
