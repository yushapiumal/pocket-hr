import 'package:auto_size_text/auto_size_text.dart';
import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:cn_pocket_hr/screens/attendance/attendance_screen.dart';
import 'package:cn_pocket_hr/screens/home/home_screen.dart';
import 'package:cn_pocket_hr/screens/leave/leave_screen.dart';
import 'package:cn_pocket_hr/screens/profile/profile_screen.dart';
import 'package:cn_pocket_hr/helpers/hr_colors.dart';
import 'package:cn_pocket_hr/helpers/design_config.dart';
import 'package:cn_pocket_hr/helpers/liquid_side_menu.dart';

class HRMain extends StatefulWidget {
  static String routeName = "/main";

  final int? id;
  const HRMain({Key? key, this.id}) : super(key: key);

  @override
  State<HRMain> createState() => _HRMainState();
}

class _HRMainState extends State<HRMain> {
  int selectedIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        child: LiquidSideMenu(
          menu: DesignConfig.drawerContent(_scaffoldKey, context),
          child: Scaffold(
            key: _scaffoldKey,
            extendBody: true,
            backgroundColor: Colors.transparent,
            body: fragments[selectedIndex],

            // Bubble-style bottom navigation (white pill)
            bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  height: 76,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: const [
                      BoxShadow(color: Color(0x24000000), blurRadius: 24, offset: Offset(0, 10)),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          _navItem(Icons.home_outlined, AppLocalizations.of(context)!.homeText, 0),
                          _navItem(Icons.event_busy, AppLocalizations.of(context)!.leaveText, 1),
                          _navItem(Icons.event_rounded, AppLocalizations.of(context)!.attendanceText, 2),
                          _navItem(Icons.person_outline, AppLocalizations.of(context)!.profileText, 3),
                        ],
                      ),
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

  Widget _navItem(IconData icon, String label, int index) {
    bool isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => updateTabSelection(index),
        child: SizedBox(
          height: 76,
          child: Padding(
            // give extra vertical space only for the selected tab
            padding: EdgeInsets.only(top: isSelected ? 10 : 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.12 : 1.0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    transform: Matrix4.translationValues(0, isSelected ? -4.0 : 0.0, 0),
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? HRColors.lightOrangeColor : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 22,
                      color: isSelected ? HRColors.darkOrangeColor : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  height: 14,
                  child: AutoSizeText(
                    label,
                    maxLines: 1,
                    minFontSize: 9,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? HRColors.darkOrangeColor : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
