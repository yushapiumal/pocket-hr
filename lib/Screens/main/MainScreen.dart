import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cn_pocket_hr/Screens/attendance/attendanceScreen.dart';
import 'package:cn_pocket_hr/Screens/home/HomeScreen.dart';
import 'package:cn_pocket_hr/Screens/leave/leaveScreen.dart';
import 'package:cn_pocket_hr/Screens/profile/ProfileScreen.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';
import 'package:cn_pocket_hr/helper/HRStrings.dart';

class HRMain extends StatefulWidget {
  static String routeName = "/main";

  final int? id;
  const HRMain({Key? key, this.id}) : super(key: key);

  @override
  State<HRMain> createState() => _HRMainState();
}

class _HRMainState extends State<HRMain> {
  int selectedIndex = 0;

  late List<Widget> fragments;

  @override
  void initState() {
    super.initState();

    fragments = [
      HRHome(),
      const HRLeave(),
      const HRAttendance(),
      const HRProfile(),
    ];

    selectedIndex = widget.id ?? 0;

    SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp],
    );
  }

  void updateTabSelection(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarIconBrightness:
              Platform.isIOS ? Brightness.light : Brightness.dark,
        ),
        child: Scaffold(
          extendBody: true,
          backgroundColor: Colors.transparent,
          body: fragments[selectedIndex],

          // 🔥 GLASS + BLUE NAVBAR
          bottomNavigationBar: SafeArea(
            top: false,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 15,
                  sigmaY: 15,
                ),
                child: Container(
                  height: 86,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.65),
                        Colors.blueAccent.withOpacity(0.55),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      _navItem(Icons.home_outlined, 0),
                      _navItem(Icons.event_busy, 1),
                      _navItem(Icons.event_rounded, 2),
                      _navItem(Icons.person_outline, 3),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, int index) {
    bool isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => updateTabSelection(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.25)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 26,
                color: isSelected
                    ? Colors.white
                    : Colors.white70,
              ),
            ),

            const SizedBox(height: 4),

            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 4,
              width: isSelected ? 18 : 6,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
