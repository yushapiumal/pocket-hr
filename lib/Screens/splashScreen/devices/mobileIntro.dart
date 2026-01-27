import 'package:cached_network_image/cached_network_image.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:octo_image/octo_image.dart';
import 'package:cn_pocket_hr/Screens/login/LoginScreen.dart';
import 'package:cn_pocket_hr/helper/DesignConfig.dart';
import 'package:cn_pocket_hr/helper/GlassBoxCurve.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';
import 'package:cn_pocket_hr/helper/HRStrings.dart';
import 'package:cn_pocket_hr/helper/customBlurHash.dart';
import 'package:cn_pocket_hr/l10n/l10n.dart';
import 'package:cn_pocket_hr/model/IntroductionModel.dart';
import 'package:cn_pocket_hr/provider/locale_provider.dart';
import 'package:provider/provider.dart';

class MobileIntro extends StatefulWidget {
  const MobileIntro({Key? key}) : super(key: key);

  @override
  _MobileIntroState createState() => _MobileIntroState();
}

class _MobileIntroState extends State<MobileIntro> {
  int currentIndex = 0;
  late PageController _controller;

  final LocalStorage storage = LocalStorage('pocketHR');

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String setIntroText(int index) {
    if (index == 0) {
      return AppLocalizations.of(context)!.introductionOneText;
    }
    if (index == 1) {
      return AppLocalizations.of(context)!.introductionTwoText;
    }
    return AppLocalizations.of(context)!.introductionThreeText;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: introductionList.length,
                      onPageChanged: (int index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (_, i) {
                        return OctoImage(
                          image: CachedNetworkImageProvider(
                              introductionList[i].imageUrl!),
                          placeholderBuilder:
                              OctoBlurHashFix.placeHolder(
                            introductionList[i].blurUrl!,
                          ),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          errorBuilder:
                              OctoError.icon(color: HRColors.black),
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Bottom Glass Box
              Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / 1.8),
                child: GlassBoxCurve(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    children: [
                      Expanded(
                        flex: 5,
                        child: SingleChildScrollView(
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(
                                left: 20, top: 30, right: 20),
                            child: Text(
                              setIntroText(currentIndex),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: HRColors.black,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      Expanded(
                        flex: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Dots
                            Container(
                              margin: const EdgeInsets.only(left: 20),
                              child: Row(
                                children: List.generate(
                                  introductionList.length,
                                  (index) => buildDot(index),
                                ),
                              ),
                            ),

                            // Button
                            TextButton(
                              onPressed: () {
                                if (currentIndex <
                                    introductionList.length - 1) {
                                  _controller.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeIn,
                                  );
                                } else {
                                  Navigator.pushNamed(
                                      context, HRLogin.routeName);
                                }
                              },
                              child: Text(
                                currentIndex ==
                                        introductionList.length - 1
                                    ? HRStrings.continueText
                                    : HRStrings.nextText,
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: HRColors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container buildDot(int index) {
    return Container(
      height: 10,
      width: 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: currentIndex == index
          ? DesignConfig.boxDecorationContainer(HRColors.black, 10)
          : DesignConfig.boxDecorationBorderButtonColor(
              HRColors.black, 10),
    );
  }
}
