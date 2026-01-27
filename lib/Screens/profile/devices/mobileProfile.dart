import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localstorage/localstorage.dart';
import 'package:octo_image/octo_image.dart';
import 'package:cn_pocket_hr/Constant/Slideanimation.dart';
import 'package:cn_pocket_hr/Constant/SmartKitProConstant.dart';
import 'package:cn_pocket_hr/Screens/login/LoginScreen.dart';
import 'package:cn_pocket_hr/Screens/notifications/Notifications.dart';
import 'package:cn_pocket_hr/helper/DesignConfig.dart';
import 'package:cn_pocket_hr/helper/GlassBox.dart';
import 'package:cn_pocket_hr/helper/GlassBoxCurve.dart';
import 'package:cn_pocket_hr/helper/GlassBoxFull.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';
import 'package:cn_pocket_hr/helper/HRStrings.dart';
import 'package:cn_pocket_hr/helper/customBlurHash.dart';

class MobileProfile extends StatefulWidget {
  // MobileProfile({Key? key}) : super(key: key);

  @override
  _MobileProfileState createState() => _MobileProfileState();
}

class _MobileProfileState extends State<MobileProfile>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  ScrollController? scrollController;
  String profileAvatar = "";
  TextEditingController? name;
  TextEditingController? initials;
  TextEditingController? fname;
  TextEditingController? lname;
  TextEditingController? dob;
  TextEditingController? nic;
  TextEditingController? contact;
  TextEditingController? address;
  TextEditingController? designation;
  TextEditingController? biostarID;
  TextEditingController? department;
  TextEditingController? location;
  TextEditingController? empNo;

  File? image;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final LocalStorage storage = LocalStorage('pocketHR');

  setValue() async {
    // await storage.ready.then((_) => {
    // print(storage.getItem('token'));
    // print(storage.getItem('id'));
    profileAvatar =
        storage.getItem('avatar') == null ? "" : storage.getItem('avatar');
    initials = TextEditingController(
        text: storage.getItem('initials') == null
            ? ''
            : storage.getItem('initials'));
    fname = TextEditingController(
        text: storage.getItem('fname') == null ? '' : storage.getItem('fname'));
    lname = TextEditingController(
        text: storage.getItem('lname') == null ? '' : storage.getItem('lname'));
    dob = TextEditingController(
        text: storage.getItem('dob') == null ? '' : storage.getItem('dob'));
    nic = TextEditingController(
        text: storage.getItem('nic') == null ? '' : storage.getItem('nic'));
    contact = TextEditingController(
        text: storage.getItem('contact') == null
            ? ''
            : storage.getItem('contact'));
    address = TextEditingController(
        text: storage.getItem('address') == null
            ? ''
            : storage.getItem('address'));
    designation = TextEditingController(
        text: storage.getItem('designation') == null
            ? ''
            : storage.getItem('designation'));
    biostarID = TextEditingController(
        text: storage.getItem('biostarId') == null
            ? ''
            : storage.getItem('biostarId'));
    department = TextEditingController(text: "-");
    location = TextEditingController(text: "-");
    empNo = TextEditingController(text: "-");
    // });
  }

  @override
  void initState() {
    super.initState();
    setValue();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
  }

  @override
  void dispose() {
    // scrollController!.dispose();
    _animationController!.dispose();

    super.dispose();
  }

  Future pickupImg() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final imageTemporary = File(image.path);
    setState(() => this.image = imageTemporary);
  }

  logOut() async {
    await storage.clear();
    Navigator.pushNamed(context, HRLogin.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      drawerScrimColor: Colors.transparent,
      drawer: DesignConfig.drawer(_scaffoldKey, context),
      body: Container(
        child: GlassBoxFull(
          background:
              'https://images.pexels.com/photos/2880718/pexels-photo-2880718.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
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
                            redius: 40.0,
                            width: 47,
                            height: 50,
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SvgPicture.asset(
                                      "assets/svg/drawer_icon.svg")),
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
                      onTap: () {
                        Navigator.pushNamed(context, HRNotifications.routeName);
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: EdgeInsets.all(5.0),
                          margin: EdgeInsets.only(left: 10.0, top: 25.0),
                          child: GlassBox(
                            redius: 40.0,
                            width: 50,
                            height: 50,
                            child: Align(
                              alignment: Alignment.center,
                              child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: SvgPicture.asset(
                                      "assets/svg/notifications_icon.svg")),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 0),
                child: Stack(
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * .10),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: HRColors.white.withOpacity(0.5),
                        child: Container(
                          padding: EdgeInsets.all(5),
                          child: image != null
                              ? ClipOval(
                                  child: Image.file(
                                    image!,
                                    fit: BoxFit.cover,
                                    width: 135,
                                    height: 135,
                                  ),
                                )
                              : ClipOval(
                                  child: OctoImage(
                                    image: CachedNetworkImageProvider(profileAvatar ==
                                            "http://cdn.rype3.com/human/images/default-avatar.png"
                                        ? "https://cdn.pixabay.com/photo/2019/08/11/18/59/icon-4399701_1280.png"
                                        : profileAvatar),
                                    placeholderBuilder:
                                        OctoBlurHashFix.placeHolder(
                                      "LRHe%pIA.m_2KjxawKNGIWkWD*M{"
                                    ),
                                    errorBuilder:
                                        OctoError.icon(color: Colors.black),
                                    width: 135,
                                    height: 135,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * .15,
                            left: MediaQuery.of(context).size.width * .50),
                        child: GestureDetector(
                          child: Container(
                              padding: EdgeInsets.all(15.0),
                              margin: EdgeInsets.only(top: 35.0, left: 20.0),
                              decoration: DesignConfig.boxDecorationButtonColor(
                                  HRColors.white.withOpacity(0.8),
                                  HRColors.white.withOpacity(0.6),
                                  50),
                              child: SvgPicture.asset("assets/svg/camera.svg",
                                  color: HRColors.black)),
                          onTap: () => pickupImg(),
                        )),
                    SizedBox(
                      height: 40.0,
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 3.7),
                        child: Text(
                          storage.getItem('full_name'),
                          style: TextStyle(
                              fontSize: 25,
                              color: Color(0xff1f1f1f),
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 3.2),
                        child: Text(
                          "EPF : #${storage.getItem('biostarId')}",
                          style: TextStyle(
                              fontSize: 16,
                              color: HRColors.darkFontColor,
                              fontWeight: FontWeight.normal),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Container(
                      height: 50,
                      margin: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 2.9),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SlideAnimation(
                            position: 1,
                            itemCount: 8,
                            slideDirection: SlideDirection.fromLeft,
                            animationController: _animationController,
                            child: GestureDetector(
                              onTap: () {
                                logOut();
                              },
                              child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        colors: [
                                          Colors.white70,
                                          Colors.white12,
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight),
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        offset: const Offset(
                                          5.0,
                                          5.0,
                                        ),
                                        blurRadius: 10.0,
                                        spreadRadius: 2.0,
                                      ), //BoxShadow
                                      BoxShadow(
                                        color: Colors.white38,
                                        offset: const Offset(0.0, 0.0),
                                        blurRadius: 0.0,
                                        spreadRadius: 0.0,
                                      ), //BoxShadow
                                    ],
                                  ),
                                  margin: EdgeInsets.only(right: 10, left: 10),
                                  padding: EdgeInsets.all(15),
                                  alignment: Alignment.center,
                                  child: SvgPicture.asset(
                                      "assets/svg/logout.svg")),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 50.0,
              ),
              _buildFab()
            ],
          ),
        ),
      ),
    );
  }

  Widget line() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 25),
      child: TextFormField(
        controller: name,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.white,
        ),
        decoration: InputDecoration(
            labelStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.normal,
              color: Colors.white,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.darkFontColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            )),
      ),
    );
  }

  Widget showInitials() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        readOnly: true,
        controller: initials,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: HRColors.black,
        ),
        decoration: InputDecoration(
            labelText: "Initials",
            prefixIcon: Icon(Icons.person_rounded, color: HRColors.black),
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: HRColors.black,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            )),
      ),
    );
  }

  Widget showFname() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        readOnly: true,
        controller: fname,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: HRColors.black,
        ),
        decoration: InputDecoration(
            labelText: "First Name",
            prefixIcon: Icon(Icons.person_rounded, color: HRColors.black),
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: HRColors.black,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            )),
      ),
    );
  }

  Widget showLname() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        readOnly: true,
        controller: lname,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: HRColors.black,
        ),
        decoration: InputDecoration(
            labelText: "Last Name",
            prefixIcon: Icon(Icons.person_rounded, color: HRColors.black),
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: HRColors.black,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            )),
      ),
    );
  }

  Widget showDob() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        readOnly: true,
        controller: dob,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: HRColors.black,
        ),
        decoration: InputDecoration(
            labelText: "Date of Birth",
            prefixIcon: Icon(Icons.cake, color: HRColors.black),
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: HRColors.black,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            )),
      ),
    );
  }

  Widget showNic() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        readOnly: true,
        controller: nic,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: HRColors.black,
        ),
        decoration: InputDecoration(
            labelText: "NIC",
            prefixIcon: Icon(Icons.badge, color: HRColors.black),
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: HRColors.black,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            )),
      ),
    );
  }

  Widget showContact() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        readOnly: true,
        controller: contact,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: HRColors.black,
        ),
        decoration: InputDecoration(
            labelText: "Contact",
            prefixIcon: Icon(Icons.local_phone, color: HRColors.black),
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: HRColors.black,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            )),
      ),
    );
  }

  Widget showAddress() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        readOnly: true,
        controller: address,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: HRColors.black,
        ),
        decoration: InputDecoration(
            labelText: "Address",
            prefixIcon: Icon(Icons.location_on_sharp, color: HRColors.black),
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: HRColors.black,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            )),
      ),
    );
  }

  Widget showDesignation() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        readOnly: true,
        controller: designation,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: HRColors.black,
        ),
        decoration: InputDecoration(
            labelText: "Designation",
            prefixIcon: Icon(Icons.business_center, color: HRColors.black),
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: HRColors.black,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            )),
      ),
    );
  }

  Widget showbiostar() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        readOnly: true,
        controller: biostarID,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: HRColors.black,
        ),
        decoration: InputDecoration(
            labelText: "Biostar ID",
            prefixIcon: Icon(Icons.person_rounded, color: HRColors.black),
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: HRColors.black,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            )),
      ),
    );
  }

  Widget showDepartment() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        readOnly: true,
        controller: department,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: HRColors.black,
        ),
        decoration: InputDecoration(
            labelText: "Department",
            prefixIcon: Icon(Icons.business, color: HRColors.black),
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: HRColors.black,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            )),
      ),
    );
  }

  Widget showLocation() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        readOnly: true,
        controller: location,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: HRColors.black,
        ),
        decoration: InputDecoration(
            labelText: "Location",
            prefixIcon: Icon(Icons.location_on_sharp, color: HRColors.black),
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: HRColors.black,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            )),
      ),
    );
  }

  Widget showEmpNo() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        readOnly: true,
        controller: empNo,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.normal,
          color: HRColors.black,
        ),
        decoration: InputDecoration(
            labelText: "Emp No",
            prefixIcon: Icon(Icons.person_rounded, color: HRColors.black),
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: HRColors.black,
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: HRColors.black),
            )),
      ),
    );
  }

  Widget _buildFab() {
    final double defaultTopMargin = MediaQuery.of(context).size.height * .43;
    final double scaleStart = 96.0;
    final double scaleEnd = scaleStart / 2;

    double top = defaultTopMargin;
    double scale = 1.0;

    return new Positioned(
      top: top,
      left: 0,
      child: new Transform(
        transform: new Matrix4.identity()..scale(scale),
        alignment: Alignment.center,
        child: SlideAnimation(
          position: 4,
          itemCount: 8,
          slideDirection: SlideDirection.fromBottom,
          animationController: _animationController,
          child: new Container(
            height: MediaQuery.of(context).size.height,
            alignment: Alignment.center,
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50)),
                boxShadow: [
                  //boxShadow,
                ],
              ),
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 1.01,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              showInitials(),
                              showFname(),
                              showLname(),
                              showDob(),
                              showNic(),
                              showContact(),
                              showAddress(),
                              showDesignation(),
                              showDepartment(),
                              showbiostar(),
                              showLocation(),
                              showEmpNo(),
                              SizedBox(
                                height: 430,
                              )
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
        ),
      ),
    );
  }

  Future<void> navigationPage() async {
    Navigator.pop(context);
  }
}
