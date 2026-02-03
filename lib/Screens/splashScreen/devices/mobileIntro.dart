import 'package:cached_network_image/cached_network_image.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart' show AppLocalizations;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:octo_image/octo_image.dart';
import 'package:cn_pocket_hr/Screens/login/LoginScreen.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';
import 'package:cn_pocket_hr/helper/HRStrings.dart';
import 'package:cn_pocket_hr/helper/customBlurHash.dart';
import 'package:cn_pocket_hr/model/IntroductionModel.dart';

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

              // Soft overlay to match in-app pages
              Container(color: const Color.fromARGB(60, 0, 0, 0)),

              // Bottom card (Attendance/Leave style)
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
                    decoration: BoxDecoration(
                      color: HRColors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: HRColors.black.withOpacity(0.06)),
                      boxShadow: [
                        BoxShadow(color: HRColors.black.withOpacity(0.12), blurRadius: 24, offset: const Offset(0, 10)),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text(
                            setIntroText(currentIndex),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: HRColors.darkFontColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: List.generate(
                                introductionList.length,
                                (index) => buildDot(index),
                              ),
                            ),
                            SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: HRColors.orangeColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                                onPressed: () {
                                  if (currentIndex < introductionList.length - 1) {
                                    _controller.nextPage(
                                      duration: const Duration(milliseconds: 250),
                                      curve: Curves.easeOut,
                                    );
                                  } else {
                                    Navigator.pushNamed(context, HRLogin.routeName);
                                  }
                                },
                                child: Text(
                                  currentIndex == introductionList.length - 1 ? HRStrings.continueText : HRStrings.nextText,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: HRColors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
      height: 8,
      width: currentIndex == index ? 20 : 8,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: currentIndex == index ? HRColors.orangeColor : HRColors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
