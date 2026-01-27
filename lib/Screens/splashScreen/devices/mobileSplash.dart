import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:cn_pocket_hr/Screens/main/MainScreen.dart';
import 'package:cn_pocket_hr/Screens/splashScreen/HRIntroduction.dart';
import 'package:cn_pocket_hr/api/apiService.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';
import 'package:cn_pocket_hr/helper/HRConstant.dart';
import 'package:cn_pocket_hr/provider/locale_provider.dart';
import 'package:provider/provider.dart';

class MobileSplash extends StatefulWidget {
  const MobileSplash({Key? key}) : super(key: key);

  @override
  _MobileSplashState createState() => _MobileSplashState();
}

class _MobileSplashState extends State<MobileSplash>
    with TickerProviderStateMixin {
  AnimationController? _animationController;
  LocalStorage storage = LocalStorage('pocketHR');
  APIService apiService = APIService();

  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..forward();
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.fastOutSlowIn,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    startTime();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  startTime() async {
    var _duration = Duration(milliseconds: 1000);
    return Timer(_duration, navigationPage);
  }

  var email = null;
  var token = null;
  var password = null;
  var pin = null;
  var saveLang = null;

  navigationPage() async {
    await storage.ready.then((_) => {
          email = storage.getItem('email'),
          token = storage.getItem('token'),
          password = storage.getItem('password'),
          saveLang = storage.getItem('lang'),
          autoLogin(email, password),
          setLanguage(saveLang)
        });
  }

  setLanguage(saveLang) async {
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    if (saveLang != null) {
      if (saveLang == 'en') {
        provider.setLocale(Locale('en'));
      }
      if (saveLang == 'si') {
        provider.setLocale(Locale('si'));
      }
      if (saveLang == 'ta') {
        provider.setLocale(Locale('ta'));
      }
    }
  }

  void autoLogin(email, password) async {
    if (email != null && password != null) {
      var login1 = await apiService.login(email, password);
      if (login1 != null) {
        if (login1['status']) {
          Navigator.pushNamed(context, HRMain.routeName);
        } else {
          navigationPage();
        }
      } else {
        storage.clear();
        Navigator.pushNamed(context, HRIntroduction.routeName);
      }
    } else {
      storage.clear();
      Navigator.pushNamed(context, HRIntroduction.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return true as Future<bool>;
      },
      child: Scaffold(
        backgroundColor: HRColors.splashbackgroundColor,
        body: Container(
          color: HRColors.white,
          alignment: Alignment.center,
          child: Padding(
            padding:
                EdgeInsets.only(left: MediaQuery.of(context).size.width * .35),
            child: SizeTransition(
              sizeFactor: _animation,
              child: Image.asset(
                HrConstant.getImagePath('logo.png'),
                width: MediaQuery.of(context).size.width / 3.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
