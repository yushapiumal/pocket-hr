import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cn_pocket_hr/screens/notifications/notifications.dart';
import 'package:cn_pocket_hr/helpers/glass_box.dart';
import 'package:cn_pocket_hr/helpers/hr_colors.dart';
import 'package:cn_pocket_hr/services/fcm_service.dart';

class TabletTopBar extends StatefulWidget {
  const TabletTopBar({Key? key}) : super(key: key);

  @override
  State<TabletTopBar> createState() => _TabletTopBarState();
}

class _TabletTopBarState extends State<TabletTopBar>
    with WidgetsBindingObserver {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      FCMService.loadUnreadCount();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 34.5,
              bottom: MediaQuery.of(context).size.height / 15.2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  _scaffoldKey.currentState!.openDrawer();
                },
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    margin: EdgeInsets.only(left: 1.0, top: 26.0),
                    child: GlassBox(
                      backgroundColor: HRColors.flavorIconBackgroundColor,
                      redius: 40.0,
                      width: 47,
                      height: 50,
                      child: Align(
                        alignment: Alignment.center,
                        child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: SvgPicture.asset(
                              "assets/svg/drawer_icon.svg",
                              colorFilter: ColorFilter.mode(
                                  HRColors.flavorIconColor, BlendMode.srcIn),
                            )),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 34.5,
              bottom: MediaQuery.of(context).size.height / 15.2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () async {
                  await Navigator.pushNamed(context, HRNotifications.routeName);
                  // Reload count in case background notifications arrived
                  await FCMService.loadUnreadCount();
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: EdgeInsets.all(5.0),
                    margin: EdgeInsets.only(left: 10.0, top: 25.0),
                    child: ValueListenableBuilder<int>(
                      valueListenable: FCMService.unreadCount,
                      builder: (context, count, _) => Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GlassBox(
                            backgroundColor: HRColors.flavorIconBackgroundColor,
                            redius: 40.0,
                            width: 50,
                            height: 50,
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: SvgPicture.asset(
                                  'assets/svg/notifications_icon.svg',
                                  colorFilter: ColorFilter.mode(
                                      HRColors.flavorIconColor,
                                      BlendMode.srcIn),
                                ),
                              ),
                            ),
                          ),
                          if (count > 0)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  count > 99 ? '99+' : '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
