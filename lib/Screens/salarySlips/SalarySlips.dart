import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cn_pocket_hr/Screens/salarySlips/devices/MobileSalarySlip.dart';
import 'package:cn_pocket_hr/Screens/salarySlips/devices/TabletSalarySlip.dart';
import 'package:cn_pocket_hr/ui/responsiveLayout.dart';

class HRSalarySlips extends StatefulWidget {
  static String routeName = "/salary-slips";

  const HRSalarySlips({Key? key}) : super(key: key);

  @override
  State<HRSalarySlips> createState() => _HRSalarySlipsState();
}

class _HRSalarySlipsState extends State<HRSalarySlips> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileSalarySlip(),
      tabletBody: TabletSalarySlip(),
    );
  }
}
