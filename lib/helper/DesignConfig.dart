import 'dart:io';
import 'dart:ui';
import 'package:cn_pocket_hr/Screens/allowancesDeductions/allowance.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart'; 
import 'package:cn_pocket_hr/helper/HRColors.dart';
import 'package:cn_pocket_hr/helper/HRStrings.dart';
import 'package:cn_pocket_hr/Screens/salarySlips/SalarySlips.dart'; 
import 'package:cn_pocket_hr/helper/flutter_rating_bar.dart';
import 'package:cn_pocket_hr/provider/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:cn_pocket_hr/Screens/debtsAndLoans/DebtsAndLoansScreen.dart';
import 'package:cn_pocket_hr/Screens/common/ComingSoonScreen.dart';



class DesignConfig {
  static String getPngImagePath(String imageName) {
    return "assets/images/img/$imageName";
  }

  static String getSvgImagePath(String imageName) {
    return "assets/svg/$imageName";
  }

  static BoxDecoration boxDecorationIntroductionColor(
      Color color1, Color color2, double sizes) {
    return BoxDecoration(
      gradient: LinearGradient(colors: [
        color1,
        color2,
      ], begin: Alignment.centerLeft, end: Alignment.centerRight),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(sizes),
        topRight: Radius.circular(sizes),
      ),
    );
  }

  static RoundedRectangleBorder setRoundedBorder(
      Color bordercolor, double bradius, bool issetside) {
    return RoundedRectangleBorder(
        side: new BorderSide(color: bordercolor, width: 0),
        borderRadius: BorderRadius.circular(bradius));
  }

  static BoxDecoration boxDecorationButton(Color color1, Color color2) {
    return BoxDecoration(
      gradient: LinearGradient(colors: [
        color1,
        color2,
      ], begin: Alignment.centerLeft, end: Alignment.centerRight),
      borderRadius: BorderRadius.circular(10),
    );
  }

  static BoxDecoration boxDecorationContainer(Color color, double radius) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration boxDecorationBorderButtonColor(
      Color color, double sizes) {
    return BoxDecoration(
        borderRadius: BorderRadius.circular(sizes),
        border: Border.all(color: color, width: 1));
  }

  static BoxDecoration boxDecorationButtonColor(
      Color color1, Color color2, double sizes) {
    return BoxDecoration(
      gradient: LinearGradient(colors: [
        color1,
        color2,
      ], begin: Alignment.centerLeft, end: Alignment.centerRight),
      borderRadius: BorderRadius.circular(sizes),
    );
  }

  static BoxDecoration boxDecorationLeafButtonColor(
      Color color1, Color color2, double sizes) {
    return BoxDecoration(
      gradient: LinearGradient(colors: [
        color1,
        color2,
      ], begin: Alignment.centerLeft, end: Alignment.centerRight),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(sizes),
        bottomRight: Radius.circular(sizes),
      ),
    );
  }

  static Widget drawerContent(GlobalKey<ScaffoldState> _scaffoldKey, BuildContext context) {
    Widget langPicker() {
      final provider = Provider.of<LocaleProvider>(context);
      final LocalStorage storage = LocalStorage('pocketHR');

      return Container(
        margin: EdgeInsets.only(
          top: 80.0,
          left: 8.0,
          right: 30.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              child: ElevatedButton(
                onPressed: () {
                  provider.setLocale(Locale('en'));
                  storage.setItem('lang', 'en');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // <-- Radius
                  ),
                ),
                child: Text(
                  'EN',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            GestureDetector(
              child: ElevatedButton(
                onPressed: () {
                  provider.setLocale(Locale('si'));
                  storage.setItem('lang', 'si');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // <-- Radius
                  ),
                ),
                child: Text(
                  'සිං',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            GestureDetector(
              child: ElevatedButton(
                onPressed: () {
                  provider.setLocale(Locale('ta'));
                  storage.setItem('lang', 'ta');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // <-- Radius
                  ),
                ),
                child: Text(
                  'தமிழ்',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: 300,
      height: double.infinity,
      decoration: BoxDecoration(
        color: HRColors.white.withOpacity(0.9),
        boxShadow: [
          BoxShadow(
            color: HRColors.white.withOpacity(0.4),
            blurRadius: 8.0,
          )
        ],
      ),
      child: Stack(
        children: [
          SizedBox(
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 4.0,
                  sigmaY: 4.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                    Colors.grey.withOpacity(0.4),
                    Colors.white.withOpacity(0.9),
                  ])),
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 70,
                margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 20.5,
                  bottom: MediaQuery.of(context).size.height / 80,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_scaffoldKey.currentState!.isDrawerOpen) {
                          Navigator.of(context).pop();
                        } else {
                          _scaffoldKey.currentState!.openDrawer();
                        }
                      },
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Platform.isIOS ? BackButton() : Text(""),
                            Container(
                              padding: EdgeInsets.all(10.0),
                              margin: EdgeInsets.only(left: 5.0),
                              decoration: DesignConfig.boxDecorationButtonColor(
                                  HRColors.white.withOpacity(0.9),
                                  HRColors.white.withOpacity(0.9),
                                  50),
                              child: Icon(Icons.close, color: HRColors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 20.0,
                    ),
                    Align(
                        alignment: Alignment.center,
                        child: Text(
                          HRStrings.menuText,
                          style: TextStyle(
                              fontSize: 20,
                              color: HRColors.black,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ))
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity(horizontal: 1, vertical: -2),
                      onTap: () {
                        Navigator.pushNamed(context, HRSalarySlips.routeName);
                      },
                      leading: const Icon(Icons.receipt_long, color: HRColors.black),
                      title: Text(
                        AppLocalizations.of(context)!.salarySlips,
                        style: TextStyle(
                            fontSize: 17,
                            color: HRColors.black,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity(horizontal: 1, vertical: -2),
                      onTap: () {
                        Navigator.pushNamed(
                            context, HRAllowancesDeductions.routeName);
                      },
                      leading: const Icon(Icons.account_balance_wallet_outlined, color: HRColors.black),
                      title: Text(
                        AppLocalizations.of(context)!.allowanceDeductions,
                        style: TextStyle(
                            fontSize: 17,
                            color: HRColors.black,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity(horizontal: 1, vertical: -2),
                      onTap: () {
                        Navigator.pushNamed(context, HRDebtsAndLoans.routeName);
                      },
                      leading: const Icon(Icons.payments_outlined, color: HRColors.black),
                      title: Text(
                        AppLocalizations.of(context)!.debtLoans,
                        style: TextStyle(
                            fontSize: 17,
                            color: HRColors.black,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity(horizontal: 1, vertical: -2),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ComingSoonScreen(title: 'FAQ'),
                          ),
                        );
                      },
                      leading: const Icon(Icons.help_outline, color: HRColors.black),
                      title: Text(
                        AppLocalizations.of(context)!.faqText,
                        style: TextStyle(
                            fontSize: 17,
                            color: HRColors.black,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity(horizontal: 1, vertical: -2),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ComingSoonScreen(title: 'Privacy Policy'),
                          ),
                        );
                      },
                      leading: const Icon(Icons.privacy_tip_outlined, color: HRColors.black),
                      title: Text(
                        AppLocalizations.of(context)!.privacyPolicyText,
                        style: TextStyle(
                            fontSize: 17,
                            color: HRColors.black,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity(horizontal: 1, vertical: -2),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ComingSoonScreen(title: 'Terms & Conditions'),
                          ),
                        );
                      },
                      leading: const Icon(Icons.gavel_outlined, color: HRColors.black),
                      title: Text(
                        AppLocalizations.of(context)!.termsConditionsText,
                        style: TextStyle(
                            fontSize: 17,
                            color: HRColors.black,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    ListTile(
                      dense: true,
                      visualDensity: VisualDensity(horizontal: 1, vertical: -4),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ComingSoonScreen(title: 'Contact Us'),
                          ),
                        );
                      },
                      leading: const Icon(Icons.contact_support_outlined, color: HRColors.black),
                      title: Text(
                        AppLocalizations.of(context)!.contactUsText,
                        style: TextStyle(
                            fontSize: 17,
                            color: HRColors.black,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    langPicker()
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  static Widget displayCourseImage(String image, double height, double width) {
    return Image.asset(
      image,
      width: width,
      height: height,
      fit: BoxFit.fill,
    );
  }

  static Widget displayRating(String rating, bool isfullratingbar) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 5, end: 5),
      child: Row(
        children: <Widget>[
          isfullratingbar
              ? RatingBarIndicator(
                  rating: double.parse(rating),
                  itemBuilder: (context, index) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 14,
                  direction: Axis.horizontal,
                )
              : Icon(
                  Icons.star,
                  size: 14,
                  color: Colors.amber,
                ),
          Text(
            "\t\t${rating}",
            style:
                TextStyle(color: HRColors.white, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  static Widget displayRatingFull(String? rating, bool isfullratingbar) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 5, end: 5),
      child: Row(
        children: <Widget>[
          isfullratingbar
              ? RatingBarIndicator(
                  rating: double.parse(rating!),
                  itemBuilder: (context, index) => Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 14,
                  direction: Axis.horizontal,
                )
              : Icon(
                  Icons.star,
                  size: 14,
                  color: Colors.amber,
                ),
          //Text("\t\t${item.rate}",style: TextStyle(color: HRColors.white,fontWeight: FontWeight.w400),),
        ],
      ),
    );
  }

  static Future<bool> checkInternet() async {
    bool check = false;
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      //print("===check==true");
      // return true;
      check = true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      //print("===check=***=true");
      //return true;
      check = true;
    }
    //print("===check==false");
    //return false;
    return check;
  }
}
