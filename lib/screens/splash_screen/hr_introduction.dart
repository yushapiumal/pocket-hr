import 'package:localstorage/localstorage.dart';
import 'package:cn_pocket_hr/screens/home/devices/mobile_home.dart';
import 'package:cn_pocket_hr/screens/home/devices/tablet_home.dart';
import 'package:cn_pocket_hr/screens/login/login_screen.dart';
import 'package:cn_pocket_hr/screens/login/devices/mobile_login.dart';
import 'package:cn_pocket_hr/screens/login/devices/tablet_login.dart';
import 'package:cn_pocket_hr/screens/splash_screen/devices/mobile_intro.dart';
import 'package:cn_pocket_hr/screens/splash_screen/devices/tablet_intro.dart';
import 'package:flutter/material.dart';
import 'package:cn_pocket_hr/api/api_service.dart';

import 'package:cn_pocket_hr/ui/responsive_layout.dart';

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
