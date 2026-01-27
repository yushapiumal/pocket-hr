import 'package:flutter/material.dart';
import 'package:cn_pocket_hr/Screens/profile/devices/mobileProfile.dart';
import 'package:cn_pocket_hr/Screens/profile/devices/tabletProfile.dart';
import 'package:cn_pocket_hr/ui/responsiveLayout.dart';

class HRProfile extends StatefulWidget {
  static String routeName = "/profile";
  const HRProfile({Key? key}) : super(key: key);

  @override
  _HRProfileState createState() => _HRProfileState();
}

class _HRProfileState extends State<HRProfile> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileBody: MobileProfile(),
      tabletBody: TabletProfile(),
    );
  }
}
