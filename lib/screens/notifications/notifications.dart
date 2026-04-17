import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cn_pocket_hr/helpers/design_config.dart';
import 'package:cn_pocket_hr/helpers/glass_box.dart';
import 'package:cn_pocket_hr/helpers/glass_box_full.dart';
import 'package:cn_pocket_hr/helpers/hr_colors.dart';
import 'package:cn_pocket_hr/helpers/hr_strings.dart';

class HRNotifications extends StatefulWidget {
  static String routeName = "/HRNotifications";

  const HRNotifications({Key? key}) : super(key: key);

  @override
  _HRNotificationsState createState() => _HRNotificationsState();
}

class _HRNotificationsState extends State<HRNotifications> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Container(
        child: GlassBoxFull(
          background:
              'https://images.pexels.com/photos/5706029/pexels-photo-5706029.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      "assets/svg/no_notification.svg",
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        HRStrings.noNotificationFoundText,
                        style: TextStyle(
                            color: HRColors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 25),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        HRStrings.notificationSubTitleText,
                        style: TextStyle(
                            color: HRColors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: 18),
                      ),
                    ),
                    // GestureDetector(
                    //   onTap: () {},
                    //   child: Align(
                    //     alignment: Alignment.center,
                    //     child: Container(
                    //         width: MediaQuery.of(context).size.width,
                    //         alignment: Alignment.center,
                    //         decoration: DesignConfig.boxDecorationButtonColor(
                    //             HRColors.blueColor, HRColors.blueColor, 20),
                    //         margin: EdgeInsets.only(
                    //             left: 30.0, top: 30.0, right: 30.0),
                    //         padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                    //         child: Text(
                    //           HRStrings.letsStartExploringText,
                    //           textAlign: TextAlign.center,
                    //           style: TextStyle(
                    //             color: HRColors.white,
                    //             fontSize: 18,
                    //             fontWeight: FontWeight.normal,
                    //           ),
                    //         )),
                    //   ),
                    // )
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                      padding: EdgeInsets.all(5.0),
                      margin: EdgeInsets.only(top: 50.0, left: 7.0),
                      child: GlassBox(
                          redius: 40.0,
                          width: 50,
                          height: 50,
                          child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Icon(Icons.arrow_back_ios_sharp,
                                    color: HRColors.black),
                              )))),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
