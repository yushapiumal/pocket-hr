import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:localstorage/localstorage.dart';
import 'package:octo_image/octo_image.dart';

import 'package:cn_pocket_hr/Constant/Slideanimation.dart';
import 'package:cn_pocket_hr/Screens/login/LoginScreen.dart';
import 'package:cn_pocket_hr/Screens/notifications/Notifications.dart';
import 'package:cn_pocket_hr/helper/DesignConfig.dart';
import 'package:cn_pocket_hr/helper/GlassBox.dart';
import 'package:cn_pocket_hr/helper/GlassBoxFull.dart';
import 'package:cn_pocket_hr/helper/HRColors.dart';
import 'package:cn_pocket_hr/helper/customBlurHash.dart';

class TabletProfile extends StatefulWidget {
  const TabletProfile({super.key});

  @override
  State<TabletProfile> createState() => _TabletProfileState();
}

class _TabletProfileState extends State<TabletProfile> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final LocalStorage storage = LocalStorage('pocketHR');

  @override
  void initState() {
    super.initState();

    initials = TextEditingController(text: storage.getItem('initials')?.toString() ?? '');
    fname = TextEditingController(text: storage.getItem('fname')?.toString() ?? '');
    lname = TextEditingController(text: storage.getItem('lname')?.toString() ?? '');
    dob = TextEditingController(text: storage.getItem('dob')?.toString() ?? '');
    nic = TextEditingController(text: storage.getItem('nic')?.toString() ?? '');
    contact = TextEditingController(text: storage.getItem('contact')?.toString() ?? '');
    address = TextEditingController(text: storage.getItem('address')?.toString() ?? '');
    designation = TextEditingController(text: storage.getItem('designation')?.toString() ?? '');
    biostarID = TextEditingController(text: storage.getItem('biostarId')?.toString() ?? '');
    department = TextEditingController(text: storage.getItem('department')?.toString() ?? '-');
    location = TextEditingController(text: storage.getItem('location')?.toString() ?? '-');
    empNo = TextEditingController(text: storage.getItem('empNo')?.toString() ?? '-');

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000));
  }

  @override
  void dispose() {
    _animationController?.dispose();
    initials?.dispose();
    fname?.dispose();
    lname?.dispose();
    dob?.dispose();
    nic?.dispose();
    contact?.dispose();
    address?.dispose();
    designation?.dispose();
    biostarID?.dispose();
    department?.dispose();
    location?.dispose();
    empNo?.dispose();
    super.dispose();
  }

  Future<void> pickupImg() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    setState(() => image = File(picked.path));
  }

  Future<void> logOut() async {
    await storage.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, HRLogin.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final avatar = storage.getItem('avatar')?.toString() ?? '';
    final avatarUrl = (avatar == 'http://cdn.rype3.com/human/images/default-avatar.png' || avatar.isEmpty)
        ? 'https://cdn.pixabay.com/photo/2019/08/11/18/59/icon-4399701_1280.png'
        : avatar;

    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      drawerScrimColor: Colors.transparent,
      drawer: Drawer(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: DesignConfig.drawerContent(_scaffoldKey, context),
      ),
      body: GlassBoxFull(
        background:
            'https://images.pexels.com/photos/2880718/pexels-photo-2880718.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1',
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            // Drawer button
            GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding: const EdgeInsets.all(5.0),
                  margin: const EdgeInsets.only(left: 10.0, top: 25.0),
                  child: GlassBox(
                    redius: 40.0,
                    width: 50,
                    height: 50,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset('assets/svg/drawer_icon.svg'),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Notifications
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, HRNotifications.routeName),
              child: Align(
                alignment: Alignment.topRight,
                child: Container(
                  padding: const EdgeInsets.all(5.0),
                  margin: const EdgeInsets.only(right: 10.0, top: 25.0),
                  child: GlassBox(
                    redius: 40.0,
                    width: 50,
                    height: 50,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset('assets/svg/notifications_icon.svg'),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Avatar
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * .10),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: HRColors.white.withOpacity(0.5),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: ClipOval(
                      child: image != null
                          ? Image.file(image!, fit: BoxFit.cover, width: 135, height: 135)
                          : OctoImage(
                              image: CachedNetworkImageProvider(avatarUrl),
                              placeholderBuilder: OctoBlurHashFix.placeHolder('LRHe%pIA.m_2KjxawKNGIWkWD*M{'),
                              errorBuilder: OctoError.icon(color: Colors.black),
                              width: 135,
                              height: 135,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
            ),

            // Camera button
            Positioned(
              top: MediaQuery.of(context).size.height * .15,
              left: MediaQuery.of(context).size.width * .50,
              child: GestureDetector(
                onTap: pickupImg,
                child: Container(
                  padding: const EdgeInsets.all(15.0),
                  margin: const EdgeInsets.only(top: 35.0, left: 20.0),
                  decoration: DesignConfig.boxDecorationButtonColor(
                    HRColors.white.withOpacity(0.8),
                    HRColors.white.withOpacity(0.6),
                    50,
                  ),
                  child: SvgPicture.asset('assets/svg/camera.svg', colorFilter: const ColorFilter.mode(HRColors.black, BlendMode.srcIn)),
                ),
              ),
            ),

            // Name & EPF
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3.7),
                child: Text(
                  storage.getItem('full_name')?.toString() ?? '',
                  style: const TextStyle(fontSize: 25, color: Color(0xff1f1f1f), fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 3.2),
                child: Text(
                  'EPF : #${storage.getItem('biostarId')?.toString() ?? ''}',
                  style: const TextStyle(fontSize: 16, color: HRColors.darkFontColor, fontWeight: FontWeight.normal),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Logout button
            Container(
              height: 50,
              margin: EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.9),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SlideAnimation(
                    position: 1,
                    itemCount: 8,
                    slideDirection: SlideDirection.fromLeft,
                    animationController: _animationController,
                    child: GestureDetector(
                      onTap: logOut,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.white70, Colors.white12],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              offset: const Offset(5.0, 5.0),
                              blurRadius: 10.0,
                              spreadRadius: 2.0,
                            ),
                            const BoxShadow(
                              color: Colors.white38,
                              offset: Offset(0.0, 0.0),
                              blurRadius: 0.0,
                              spreadRadius: 0.0,
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.only(right: 10, left: 10),
                        padding: const EdgeInsets.all(15),
                        alignment: Alignment.center,
                        child: SvgPicture.asset('assets/svg/logout.svg'),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            _buildFab(),
          ],
        ),
      ),
    );
  }

  InputDecoration _roFieldDecoration({required String label, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: HRColors.black),
      labelStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: HRColors.black),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: HRColors.black)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: HRColors.black)),
    );
  }

  Widget _roField({required TextEditingController? controller, required String label, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: TextFormField(
        readOnly: true,
        controller: controller,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal, color: HRColors.black),
        decoration: _roFieldDecoration(label: label, icon: icon),
      ),
    );
  }

  Widget _buildFab() {
    final double defaultTopMargin = MediaQuery.of(context).size.height * .43;

    return Positioned(
      top: defaultTopMargin,
      left: 0,
      child: SlideAnimation(
        position: 4,
        itemCount: 8,
        slideDirection: SlideDirection.fromBottom,
        animationController: _animationController,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            color: Colors.white30,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
          ),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 1.01,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _roField(controller: initials, label: 'Initials', icon: Icons.person_rounded),
                          _roField(controller: fname, label: 'First Name', icon: Icons.person_rounded),
                          _roField(controller: lname, label: 'Last Name', icon: Icons.person_rounded),
                          _roField(controller: dob, label: 'Date of Birth', icon: Icons.cake),
                          _roField(controller: nic, label: 'NIC', icon: Icons.badge),
                          _roField(controller: contact, label: 'Contact', icon: Icons.local_phone),
                          _roField(controller: address, label: 'Address', icon: Icons.location_on_sharp),
                          _roField(controller: designation, label: 'Designation', icon: Icons.business_center),
                          _roField(controller: department, label: 'Department', icon: Icons.business),
                          _roField(controller: biostarID, label: 'Biostar ID', icon: Icons.person_rounded),
                          _roField(controller: location, label: 'Location', icon: Icons.location_on_sharp),
                          _roField(controller: empNo, label: 'Emp No', icon: Icons.person_rounded),
                          const SizedBox(height: 430),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}