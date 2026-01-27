import 'package:localstorage/localstorage.dart';
import 'package:cn_pocket_hr/Screens/home/devices/mobileHome.dart';
import 'package:cn_pocket_hr/Screens/home/devices/tabletHome.dart';
import 'package:cn_pocket_hr/Screens/login/LoginScreen.dart';
import 'package:cn_pocket_hr/Screens/login/devices/mobileLogin.dart';
import 'package:cn_pocket_hr/Screens/login/devices/tabletLogin.dart';
import 'package:cn_pocket_hr/Screens/splashScreen/devices/mobileIntro.dart';
import 'package:cn_pocket_hr/Screens/splashScreen/devices/tabletIntro.dart';
import 'package:flutter/material.dart';
import 'package:cn_pocket_hr/api/apiService.dart';

import 'package:cn_pocket_hr/ui/responsiveLayout.dart';

class HRIntroduction extends StatefulWidget {
  static String routeName = "/intro";

  @override
  HRIntroductionState createState() => HRIntroductionState();
}

class HRIntroductionState extends State<HRIntroduction> {
  final LocalStorage storage = LocalStorage('pocketHR');
  APIService apiService = APIService();
  late bool isLogin = false;

  @override
  void initState() {
    super.initState();
    if (storage.getItem('login') == true ||
        storage.getItem('login') == "true") {
      setState(() {
        isLogin = true;
      });
    }
    var log = storage.getItem('login');
  }

  @override
  Widget build(BuildContext context) {
    return isLogin
        ? ResponsiveLayout(mobileBody: MobileHome(), tabletBody: TabletHome())
        : ResponsiveLayout(
            mobileBody: MobileIntro(),
            tabletBody: TabletIntro(),
          );
  }
}
