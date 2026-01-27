import 'package:cached_network_image/cached_network_image.dart';
import 'package:cn_pocket_hr/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:octo_image/octo_image.dart';
import 'package:cn_pocket_hr/Screens/main/MainScreen.dart';
import 'package:cn_pocket_hr/api/apiService.dart';
import 'package:cn_pocket_hr/helper/DesignConfig.dart';
import 'package:cn_pocket_hr/helper/GlassBoxCurve.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';
import 'package:cn_pocket_hr/helper/HRStrings.dart';
import 'package:cn_pocket_hr/helper/customBlurHash.dart';
import 'package:cn_pocket_hr/provider/locale_provider.dart';
import 'package:provider/provider.dart';
import 'package:cn_pocket_hr/model/hr/MeModel.dart';

class MobileLogin extends StatefulWidget {
  const MobileLogin({Key? key}) : super(key: key);

  @override
  _MobileLoginState createState() => _MobileLoginState();
}

class _MobileLoginState extends State<MobileLogin> {
  bool descTextShowFlag = false;
  bool _keyboardVisible = false;
  final email = TextEditingController();
  final password = TextEditingController();
  final company = TextEditingController();
  bool _validateEmail = false;
  bool _validatePassword = false;
  bool _validateCompany = false;
  bool isLoading = false;
  bool buttonDisable = false;
  final LocalStorage storage = LocalStorage('pocketHR');
  APIService apiService = APIService();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget inputEPF() {
    return Container(
      margin: EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0),
      decoration: DesignConfig.boxDecorationButtonColor(
          Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.8), 50),
      padding: const EdgeInsets.only(left: 20.0),
      child: TextFormField(
        controller: password,
        onChanged: (e) {
          setState(() {
            _validatePassword = false;
          });
        },
        style: TextStyle(color: HRColors.black),
        cursorColor: HRColors.black,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.passwordText,
          hintStyle: Theme.of(context).textTheme.titleSmall!.merge(TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18,
              color: HRColors.grayColor)),
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.name,
      ),
    );
  }

  Widget inputEmail() {
    return Container(
      margin: EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0),
      decoration: DesignConfig.boxDecorationButtonColor(
          Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.8), 50),
      padding: const EdgeInsets.only(left: 20.0),
      child: TextField(
        controller: email,
        onChanged: (e) {
          setState(() {
            _validateEmail = false;
          });
        },
        style: TextStyle(color: HRColors.black),
        cursorColor: HRColors.black,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.emailAddressText,
          hintStyle: Theme.of(context).textTheme.titleSmall!.merge(TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18,
              color: HRColors.grayColor)),
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  Widget inputTenant() {
    return Container(
      margin: EdgeInsets.only(
        top: 20.0,
        left: 30.0,
        right: 30.0,
      ),
      decoration: DesignConfig.boxDecorationButtonColor(
          Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.8), 50),
      padding: const EdgeInsets.only(left: 20.0),
      child: TextField(
        controller: company,
        onChanged: (e) {
          setState(() {
            _validateCompany = false;
          });
        },
        style: TextStyle(color: HRColors.black),
        cursorColor: HRColors.black,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.companyName,
          hintStyle: Theme.of(context).textTheme.titleSmall!.merge(TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18,
              color: HRColors.grayColor)),
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.text,
      ),
    );
  }

  Widget langPicker() {
    final provider = Provider.of<LocaleProvider>(context);
    final locale = provider.locale ?? Locale('en');
    return Container(
      margin: EdgeInsets.only(
        top: 20.0,
        left: 30.0,
        right: 30.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            child: ElevatedButton(
              child: Text(
                'EN',
                style: TextStyle(color: Colors.black),
              ),
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
            ),
          ),
          GestureDetector(
            child: ElevatedButton(
              child: Text(
                'සිං',
                style: TextStyle(color: Colors.black),
              ),
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
            ),
          ),
          GestureDetector(
            child: ElevatedButton(
              child: Text(
                'தமிழ்',
                style: TextStyle(color: Colors.black),
              ),
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
            ),
          ),
        ],
      ),
    );
  }

  companyError() {
    if (_validateCompany) {
      return Text(
        AppLocalizations.of(context)!.tenantValidation,
        style: TextStyle(color: HRColors.red),
      );
    }
    return SizedBox(
      height: 1,
    );
  }

  emailError() {
    if (_validateEmail) {
      return Text(
        AppLocalizations.of(context)!.emailValidation,
        style: TextStyle(color: HRColors.red),
      );
    }
    return SizedBox(
      height: 1,
    );
  }

  passwordError() {
    if (_validatePassword) {
      return Text(
        AppLocalizations.of(context)!.epfValidation,
        style: TextStyle(color: HRColors.red),
      );
    }
    return SizedBox(
      height: 1,
    );
  }

  void submit() async {
    setState(() {
      company.text.isEmpty ? _validateCompany = true : _validateCompany = false;
      email.text.isEmpty ? _validateEmail = true : _validateEmail = false;
      password.text.isEmpty
          ? _validatePassword = true
          : _validatePassword = false;
    });

    if (!_validateCompany && !_validateEmail && !_validatePassword) {
      setState(() {
        isLoading = true;
        buttonDisable = true;
      });
      storage.setItem('company', company.text);
      storage.setItem('email', email.text);
      storage.setItem('password', password.text);
      var login1 = await apiService.login(email.text, password.text);

      if (login1 == null) {
        apiService.showToast('Login failed, please Try again');
        setState(() {
          isLoading = false;
          buttonDisable = false;
        });
      } else {
        setState(() {
          isLoading = false;
          buttonDisable = false;
        });
        Navigator.pushNamed(context, HRMain.routeName);

        // if (login1['result']['pin'] != null) {
        //   storage.setItem('pin', login1['result']['pin'].toString());

        //   var login2 = await apiService.login(
        //       storage.getItem('email'), storage.getItem('pin'));

        //   if (login2 == null) {
        //     apiService.showToast('Login failed, please Try again');
        //     setState(() {
        //       isLoading = false;
        //       buttonDisable = false;
        //     });
        //   } else {
        //     if (login2['status']) {
        //       setState(() {
        //         isLoading = false;
        //         buttonDisable = false;
        //       });
        //       Navigator.pushNamed(context, HRMain.routeName);
        //     } else {
        //       setState(() {
        //         isLoading = false;
        //         buttonDisable = false;
        //       });
        //       _showMyDialog(login2['message'].toString(), false);
        //     }
        //   }
        // } else {
        //   setState(() {
        //     isLoading = false;
        //     buttonDisable = false;
        //   });
        // }
      }
    }
  }

  Future<void> _showMyDialog(text, access) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Login Pin Code'),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Text(text),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                // email.clear();
                // password.clear();
                access
                    ? Navigator.pushNamed(context, HRMain.routeName)
                    : Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _keyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    double point = 2.5;
    if (_keyboardVisible) {
      point = 6;
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: OctoImage(
                    image: CachedNetworkImageProvider(
                        'https://c8.alamy.com/comp/TAWF2Y/vertical-panorama-banner-hr-human-resources-recruitment-organisation-structure-and-social-network-concept-TAWF2Y.jpg'),
                    placeholderBuilder: OctoBlurHashFix.placeHolder(
                      'LA7{HstRnNyEK-.SkDkWMJXT%zWB',
                    ),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    errorBuilder: OctoError.icon(color: HRColors.bottomColor),
                    fit: BoxFit.fill,
                  ),
                ),
              ],
            ),
            SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height / point),
                height: MediaQuery.of(context).size.height,
                child: GlassBoxCurve(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Text(
                          AppLocalizations.of(context)!.welcomeText,
                          style: TextStyle(
                              fontSize: 35,
                              color: HRColors.black,
                              fontWeight: FontWeight.normal),
                        ),
                      ),
                      inputTenant(),
                      SizedBox(height: 5),
                      companyError(),
                      inputEmail(),
                      SizedBox(height: 5),
                      emailError(),
                      SizedBox(height: 5),
                      inputEPF(),
                      SizedBox(height: 5),
                      passwordError(),
                      langPicker(),
                      SizedBox(height: 10.0),
                      isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                valueColor: new AlwaysStoppedAnimation<Color>(
                                    Colors.blue),
                              ),
                            )
                          : Text(""),
                      GestureDetector(
                        onTap: () {
                          buttonDisable ? null : submit();
                        },
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Container(
                            width: MediaQuery.of(context).size.width / 2.5,
                            decoration: DesignConfig.boxDecorationButtonColor(
                                HRColors.blueColor, HRColors.blueColor, 25),
                            alignment: AlignmentDirectional.center,
                            margin: EdgeInsets.only(
                                left: 30.0,
                                top: MediaQuery.of(context).size.height / 99,
                                right: 30.0),
                            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.loginText,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: HRColors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.width / 22,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                SizedBox(width: 5),
                                Icon(Icons.arrow_forward,
                                    color: HRColors.white),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
