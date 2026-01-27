import 'package:cached_network_image/cached_network_image.dart';
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

class TabletLogin extends StatefulWidget {
  const TabletLogin({Key? key}) : super(key: key);

  @override
  _TabletLoginState createState() => _TabletLoginState();
}

class _TabletLoginState extends State<TabletLogin> {
  bool descTextShowFlag = false;
  bool _keyboardVisible = false;
  final email = TextEditingController();
  final epfNo = TextEditingController();
  final company = TextEditingController();
  final pinCode = TextEditingController();
  bool _validateEmail = false;
  bool _validateEpf = false;
  bool _validateCompany = false;
  bool _validatePin = false;
  bool isLoading = false;
  bool buttonDisable = false;
  bool changeForm = false;
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

  Widget inputPIN() {
    return Container(
      margin: EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0),
      decoration: DesignConfig.boxDecorationButtonColor(
          Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.8), 50),
      padding: const EdgeInsets.only(left: 20.0),
      child: TextFormField(
        controller: pinCode,
        onChanged: (e) {
          setState(() {
            _validatePin = false;
          });
        },
        style: TextStyle(color: HRColors.black),
        cursorColor: HRColors.black,
        decoration: InputDecoration(
          hintText: HRStrings.pinCode,
          hintStyle: Theme.of(context).textTheme.titleSmall!.merge(TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 18,
              color: HRColors.grayColor)),
          border: InputBorder.none,
        ),
        keyboardType: TextInputType.number,
      ),
    );
  }

  Widget inputEPF() {
    return Container(
      margin: EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0),
      decoration: DesignConfig.boxDecorationButtonColor(
          Colors.white.withOpacity(0.8), Colors.white.withOpacity(0.8), 50),
      padding: const EdgeInsets.only(left: 20.0),
      child: TextFormField(
        controller: epfNo,
        onChanged: (e) {
          setState(() {
            _validateEpf = false;
          });
        },
        style: TextStyle(color: HRColors.black),
        cursorColor: HRColors.black,
        decoration: InputDecoration(
          hintText: HRStrings.epfnumber,
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
          hintText: HRStrings.userEmail,
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
          hintText: HRStrings.companyName,
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

  pinCodeError() {
    if (_validatePin) {
      return Text(
        HRStrings.pinCodeValidation,
        style: TextStyle(color: HRColors.red),
      );
    }
    return SizedBox(
      height: 1,
    );
  }

  companyError() {
    if (_validateCompany) {
      return Text(
        HRStrings.tenantValidation,
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
        HRStrings.emailValidation,
        style: TextStyle(color: HRColors.red),
      );
    }
    return SizedBox(
      height: 1,
    );
  }

  epfError() {
    if (_validateEpf) {
      return Text(
        HRStrings.epfValidation,
        style: TextStyle(color: HRColors.red),
      );
    }
    return SizedBox(
      height: 1,
    );
  }

  checkEmailValidate() {
    bool emailValid = RegExp(r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$')
        .hasMatch(email.text);
    setState(() {
      _validateEmail = !emailValid;
    });
  }

  void submit2() async {
    setState(() {
      pinCode.text.isEmpty ? _validatePin = true : _validatePin = false;
    });

    if (!_validatePin) {
      setState(() {
        isLoading = true;
        buttonDisable = true;
      });

      var login3 =
          await apiService.login(storage.getItem('email'), pinCode.text);
      if (login3['status']) {
        Navigator.pushNamed(context, HRMain.routeName);
      } else {
        _showMyDialog(login3['message'].toString(), false);
      }
    }
  }

  void submit() async {
    setState(() {
      company.text.isEmpty ? _validateCompany = true : _validateCompany = false;
      email.text.isEmpty ? _validateEmail = true : _validateEmail = false;
      epfNo.text.isEmpty ? _validateEpf = true : _validateEpf = false;
    });
    checkEmailValidate();

    if (!_validateCompany && !_validateEmail && !_validateEpf) {
      setState(() {
        isLoading = true;
        buttonDisable = true;
      });
      storage.setItem('company', company.text);
      storage.setItem('email', email.text);
      storage.setItem('epfNo', epfNo.text);
      var login1 = await apiService.login(epfNo.text, epfNo.text);

      if (login1['result']['pin'] != null) {
        storage.setItem('pin', login1['result']['pin'].toString());

        var login2 = await apiService.login(
            storage.getItem('email'), storage.getItem('pin'));
        if (login2['status']) {
          setState(() {
            isLoading = false;
            buttonDisable = false;
          });
          Navigator.pushNamed(context, HRMain.routeName);
        } else {
          setState(() {
            isLoading = false;
            buttonDisable = false;
          });
          _showMyDialog(login2['message'].toString(), false);
        }
      } else {
        setState(() {
          changeForm = true;
          isLoading = false;
          buttonDisable = false;
        });
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
                )),
              ],
            ),
            SingleChildScrollView(
              child: !changeForm
                  ? Container(
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
                                HRStrings.welcomeText,
                                style: TextStyle(
                                    fontSize: 35,
                                    color: HRColors.black,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            inputTenant(),
                            companyError(),
                            inputEmail(),
                            emailError(),
                            inputEPF(),
                            epfError(),
                            SizedBox(height: 16.0),
                            isLoading
                                ? Center(
                                    child: CircularProgressIndicator(
                                      valueColor:
                                          new AlwaysStoppedAnimation<Color>(
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
                                  width:
                                      MediaQuery.of(context).size.width / 2.5,
                                  decoration:
                                      DesignConfig.boxDecorationButtonColor(
                                          HRColors.blueColor,
                                          HRColors.blueColor,
                                          25),
                                  alignment: AlignmentDirectional.center,
                                  margin: EdgeInsets.only(
                                      left: 30.0,
                                      top: MediaQuery.of(context).size.height /
                                          99,
                                      right: 30.0),
                                  padding:
                                      EdgeInsets.only(top: 15.0, bottom: 15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        HRStrings.loginText,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: HRColors.white,
                                          fontSize: 25,
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
                    )
                  : Container(
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
                                HRStrings.welcomeText,
                                style: TextStyle(
                                    fontSize: 35,
                                    color: HRColors.black,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            inputPIN(),
                            pinCodeError(),
                            SizedBox(height: 16.0),
                            isLoading
                                ? Center(
                                    child: CircularProgressIndicator(
                                      valueColor:
                                          new AlwaysStoppedAnimation<Color>(
                                              Colors.blue),
                                    ),
                                  )
                                : Text(""),
                            GestureDetector(
                              onTap: () {
                                buttonDisable ? null : submit2();
                              },
                              child: Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width / 2.5,
                                  decoration:
                                      DesignConfig.boxDecorationButtonColor(
                                          HRColors.blueColor,
                                          HRColors.blueColor,
                                          25),
                                  alignment: AlignmentDirectional.center,
                                  margin: EdgeInsets.only(
                                      left: 30.0,
                                      top: MediaQuery.of(context).size.height /
                                          99,
                                      right: 30.0),
                                  padding:
                                      EdgeInsets.only(top: 15.0, bottom: 15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        HRStrings.loginText,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: HRColors.white,
                                          fontSize: 25,
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
